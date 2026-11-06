import express from "express";
import { createServer } from "http";
import { WebSocketServer, WebSocket } from "ws";

type Player = {
  id: string; name: string; color: string;
  diceValue: number; diceRolled: boolean;
  tokens: number[];
  sixCount: number;
};
type Room = {
  roomId: string; matchCode: string;
  players: Map<string, Player>;
  sockets: Map<string, WebSocket>;
  adminId: string | null;
  currentTurn: string;
  diceOverrides: Map<string, number>;
};

const rooms = new Map<string, Room>();
const codeToRoom = new Map<string, string>();
const COLORS = ["red", "green", "yellow", "blue"] as const;
const SAFE_INDICES = new Set([0, 8, 13, 21, 26, 34, 39, 47]);

function genCode(): string {
  for (let i = 0; i < 100; i++) {
    const c = String(Math.floor(100000 + Math.random() * 900000));
    if (!codeToRoom.has(c)) return c;
  }
  return String(Date.now()).slice(-6);
}
function genRoomId(): string { return "r_" + Math.random().toString(36).slice(2, 10); }
function send(ws: WebSocket, obj: any) { try { ws.send(JSON.stringify(obj)); } catch {} }
function broadcast(room: Room, obj: any) { for (const s of room.sockets.values()) send(s, obj); }

function isValidMove(p: Player, idx: number, dice: number, room: Room): boolean {
  const pos = p.tokens[idx];
  if (pos === -1) return dice === 6;
  if (pos >= 0 && pos <= 56) return pos + dice <= 56;
  return false;
}

function nextTurn(room: Room) {
  const ids = Array.from(room.players.keys());
  if (ids.length === 0) { room.currentTurn = ""; return; }
  const idx = ids.indexOf(room.currentTurn);
  room.currentTurn = ids[(idx + 1) % ids.length];
  const cur = room.players.get(room.currentTurn);
  if (cur) { cur.diceRolled = false; cur.sixCount = 0; }
}

const app = express();
app.get("/", (_req, res) => res.json({ name: "ludo-server", status: "ok", rooms: rooms.size, codes: codeToRoom.size }));
app.get("/api/lookup/:code", (req, res) => {
  const rid = codeToRoom.get(req.params.code);
  if (!rid) return res.status(404).json({ error: "match_not_found" });
  res.json({ matchCode: req.params.code, roomId: rid });
});

const httpServer = createServer(app);
const wss = new WebSocketServer({ server: httpServer });
type Conn = { roomId: string | null; playerId: string; isAdmin: boolean; matchCode: string | null };
const conns = new WeakMap<WebSocket, Conn>();

wss.on("connection", (ws) => {
  const playerId = "p_" + Math.random().toString(36).slice(2, 8);
  conns.set(ws, { roomId: null, playerId, isAdmin: false, matchCode: null });

  ws.on("message", (raw) => {
    let msg: any;
    try { msg = JSON.parse(raw.toString()); } catch { return; }
    const conn = conns.get(ws)!;

    if (msg.type === "create") {
      const roomId = genRoomId();
      const matchCode = genCode();
      const p: Player = { id: playerId, name: msg.name || "Player", color: COLORS[0], diceValue: 0, diceRolled: false, tokens: [-1, -1, -1, -1], sixCount: 0 };
      const room: Room = {
        roomId, matchCode,
        players: new Map([[playerId, p]]),
        sockets: new Map([[playerId, ws]]),
        adminId: null, currentTurn: playerId,
        diceOverrides: new Map(),
      };
      rooms.set(roomId, room);
      codeToRoom.set(matchCode, roomId);
      conn.roomId = roomId; conn.matchCode = matchCode;
      send(ws, { type: "room", roomId, matchCode, playerId, players: [p] });
    } else if (msg.type === "join") {
      const code = String(msg.roomId || "").trim();
      const roomId = codeToRoom.get(code);
      if (!roomId) { send(ws, { type: "error", message: "match_not_found" }); return; }
      const room = rooms.get(roomId)!;
      if (room.players.size >= 4) { send(ws, { type: "error", message: "room_full" }); return; }
      const used = new Set(Array.from(room.players.values()).map((p) => p.color));
      const color = COLORS.find((c) => !used.has(c)) || "red";
      const p: Player = { id: playerId, name: msg.name || "Player", color, diceValue: 0, diceRolled: false, tokens: [-1, -1, -1, -1], sixCount: 0 };
      room.players.set(playerId, p);
      room.sockets.set(playerId, ws);
      conn.roomId = roomId; conn.matchCode = code;
      send(ws, { type: "joined", roomId, matchCode: code, playerId, players: Array.from(room.players.values()) });
      broadcast(room, { type: "player_added", player: p });
    } else if (msg.type === "roll_dice") {
      if (!conn.roomId) return;
      const room = rooms.get(conn.roomId)!;
      if (room.currentTurn !== playerId) { send(ws, { type: "error", message: "not_your_turn" }); return; }
      const p = room.players.get(playerId)!;
      if (p.diceRolled) { send(ws, { type: "error", message: "already_rolled" }); return; }
      
      let value: number;
      if (room.diceOverrides.has(playerId)) {
        value = room.diceOverrides.get(playerId)!;
        room.diceOverrides.delete(playerId);
      } else {
        value = Math.floor(Math.random() * 6) + 1;
      }

      p.diceValue = value;
      p.diceRolled = true;
      
      if (value === 6) { p.sixCount++; } else { p.sixCount = 0; }

      if (p.sixCount === 3) {
        p.sixCount = 0;
        p.diceRolled = false;
        broadcast(room, { type: "dice_rolled", playerId, value });
        broadcast(room, { type: "turn_voided", playerId });
        nextTurn(room);
        broadcast(room, { type: "turn_changed", currentTurn: room.currentTurn });
        return;
      }

      broadcast(room, { type: "dice_rolled", playerId, value });
    } else if (msg.type === "move_token") {
      if (!conn.roomId) return;
      const room = rooms.get(conn.roomId)!;
      if (room.currentTurn !== playerId) { send(ws, { type: "error", message: "not_your_turn" }); return; }
      const p = room.players.get(playerId)!;
      if (!p.diceRolled) { send(ws, { type: "error", message: "roll_first" }); return; }
      const tokenIdx = msg.tokenIndex;
      if (typeof tokenIdx !== "number" || tokenIdx < 0 || tokenIdx > 3) return;
      if (!isValidMove(p, tokenIdx, p.diceValue, room)) { send(ws, { type: "error", message: "invalid_move" }); return; }
      
      const dice = p.diceValue;
      let captured = false;
      let reachedHome = false;

      if (p.tokens[tokenIdx] === -1) {
        p.tokens[tokenIdx] = 0;
      } else {
        const newPos = p.tokens[tokenIdx] + dice;
        if (newPos === 56) reachedHome = true;
        p.tokens[tokenIdx] = newPos;
      }

      p.diceRolled = false;
      broadcast(room, { type: "token_moved", playerId, tokenIndex: tokenIdx, tokens: p.tokens, captured, reachedHome });

      if (dice === 6 || captured || reachedHome) {
        // same player rolls again (already reset diceRolled to false)
      } else {
        nextTurn(room);
        broadcast(room, { type: "turn_changed", currentTurn: room.currentTurn });
      }
    } else if (msg.type === "skip_turn") {
      if (!conn.roomId) return;
      const room = rooms.get(conn.roomId)!;
      if (room.currentTurn !== playerId) return;
      const p = room.players.get(playerId)!;
      p.diceRolled = false;
      nextTurn(room);
      broadcast(room, { type: "turn_changed", currentTurn: room.currentTurn });
    } else if (msg.type === "admin_join") {
      const code = String(msg.matchCode || "").trim();
      const roomId = codeToRoom.get(code);
      if (!roomId) { send(ws, { type: "error", message: "match_not_found" }); return; }
      const room = rooms.get(roomId)!;
      room.adminId = playerId;
      conn.roomId = roomId; conn.isAdmin = true; conn.matchCode = code;
      send(ws, { type: "admin_joined", matchCode: code, roomId, players: Array.from(room.players.values()) });
    } else if (msg.type === "admin_set_dice") {
      if (!conn.isAdmin || !conn.roomId) { send(ws, { type: "error", message: "not_admin" }); return; }
      const room = rooms.get(conn.roomId)!;
      const value = msg.value;
      if (!msg.playerId || typeof value !== "number" || value < 1 || value > 6) {
        send(ws, { type: "error", message: "invalid_override" }); return;
      }
      room.diceOverrides.set(msg.playerId, value);
      send(ws, { type: "dice_override_set", playerId: msg.playerId, value });
    }
  });

  ws.on("close", () => {
    const conn = conns.get(ws);
    if (!conn || !conn.roomId) return;
    const room = rooms.get(conn.roomId);
    if (!room) return;
    room.sockets.delete(conn.playerId);
    room.players.delete(conn.playerId);
    if (room.adminId === conn.playerId) room.adminId = null;
    room.diceOverrides.delete(conn.playerId);
    broadcast(room, { type: "player_left", playerId: conn.playerId });
    if (room.players.size === 0) { rooms.delete(room.roomId); codeToRoom.delete(room.matchCode); }
  });
});

const port = Number(process.env.PORT) || 2567;
httpServer.listen(port, () => console.log("Ludo server on :" + port));
