import express from "express";
import { createServer } from "http";
import { WebSocketServer, WebSocket } from "ws";

type Player = { id: string; name: string; color: string; diceValue: number; position: number };
type Room = {
  roomId: string;
  matchCode: string;
  players: Map<string, Player>;
  sockets: Map<string, WebSocket>;
  adminId: string | null;
  currentTurn: string;
  diceOverrides: Map<string, number>;
};

const rooms = new Map<string, Room>();
const codeToRoom = new Map<string, string>();
const COLORS = ["red", "green", "yellow", "blue"] as const;

function genCode(): string {
  for (let i = 0; i < 100; i++) {
    const c = String(Math.floor(100000 + Math.random() * 900000));
    if (!codeToRoom.has(c)) return c;
  }
  return String(Date.now()).slice(-6);
}

function genRoomId(): string {
  return "r_" + Math.random().toString(36).slice(2, 10);
}

function send(ws: WebSocket, obj: any) {
  try { ws.send(JSON.stringify(obj)); } catch {}
}

function broadcast(room: Room, obj: any) {
  for (const s of room.sockets.values()) send(s, obj);
}

const app = express();

app.get("/", (_req, res) => {
  res.json({ name: "ludo-server", status: "ok", rooms: rooms.size, codes: codeToRoom.size });
});

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
    console.log("msg", msg.type, "from", playerId);

    if (msg.type === "create") {
      const roomId = genRoomId();
      const matchCode = genCode();
      const p: Player = { id: playerId, name: msg.name || "Player", color: COLORS[0], diceValue: 0, position: 0 };
      const room: Room = {
        roomId, matchCode,
        players: new Map([[playerId, p]]),
        sockets: new Map([[playerId, ws]]),
        adminId: null,
        currentTurn: playerId,
        diceOverrides: new Map(),
      };
      rooms.set(roomId, room);
      codeToRoom.set(matchCode, roomId);
      conn.roomId = roomId;
      conn.matchCode = matchCode;
      send(ws, { type: "room", roomId, matchCode, playerId });
      broadcast(room, { type: "player_added", player: p });
    }
    else if (msg.type === "join") {
      const code = String(msg.roomId || "").trim();
      const roomId = codeToRoom.get(code);
      if (!roomId) { send(ws, { type: "error", message: "match_not_found" }); return; }
      const room = rooms.get(roomId)!;
      const used = new Set(Array.from(room.players.values()).map((p) => p.color));
      const color = COLORS.find((c) => !used.has(c)) || "red";
      const p: Player = { id: playerId, name: msg.name || "Player", color, diceValue: 0, position: 0 };
      room.players.set(playerId, p);
      room.sockets.set(playerId, ws);
      conn.roomId = roomId;
      conn.matchCode = code;
      send(ws, { type: "joined", roomId, matchCode: code, playerId });
      broadcast(room, { type: "player_added", player: p });
    } else if (msg.type === "roll_dice") {
      if (!conn.roomId) return;
      const room = rooms.get(conn.roomId)!;
      if (room.currentTurn !== playerId) { send(ws, { type: "error", message: "not_your_turn" }); return; }
      let value: number;
      if (room.diceOverrides.has(playerId)) {
        value = room.diceOverrides.get(playerId)!;
        room.diceOverrides.delete(playerId);
      } else {
        value = Math.floor(Math.random() * 6) + 1;
      }
      room.players.get(playerId)!.diceValue = value;
      broadcast(room, { type: "dice_rolled", playerId, value });
      const ids = Array.from(room.players.keys());
      const idx = ids.indexOf(room.currentTurn);
      room.currentTurn = ids[(idx + 1) % ids.length];
    } else if (msg.type === "admin_join") {
      const code = String(msg.matchCode || msg.roomId || "").trim();
      const roomId = codeToRoom.get(code);
      if (!roomId) { send(ws, { type: "error", message: "match_not_found" }); return; }
      const room = rooms.get(roomId)!;
      room.adminId = playerId;
      conn.roomId = roomId;
      conn.isAdmin = true;
      conn.matchCode = code;
      send(ws, { type: "admin_joined", matchCode: code, roomId, players: Array.from(room.players.values()) });
    } else if (msg.type === "admin_set_dice") {
      if (!conn.isAdmin || !conn.roomId) { send(ws, { type: "error", message: "not_admin" }); return; }
      const room = rooms.get(conn.roomId)!;
      const targetId = msg.playerId;
      const value = msg.value;
      if (!targetId || typeof value !== "number" || value < 1 || value > 6) {
        send(ws, { type: "error", message: "invalid_override" }); return;
      }
      room.diceOverrides.set(targetId, value);
      send(ws, { type: "dice_override_set", playerId: targetId, value });
      console.log("override", targetId, "=", value);
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
