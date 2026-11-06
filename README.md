# Ludo

Multiplayer Ludo with server-authoritative dice + admin control panel.

## Structure
- app/    - Flutter player app
- server/ - WebSocket + HTTP server (Node.js + TypeScript)
- .github/workflows/build-apk.yml - split-APK release pipeline

## Server quickstart
cd server && npm install && npm run build && npm start

Listens on port 2567.

## HTTP endpoints
GET /                    - server status
GET /api/lookup/:code    - resolve 6-digit code to roomId

## WebSocket JSON protocol
create          { type: "create", name }
                -> { type: "room", roomId, matchCode, playerId }
join            { type: "join", roomId: "<6-digit>", name }
                -> { type: "joined", roomId, matchCode, playerId }
roll_dice       { type: "roll_dice" }
                -> broadcast { type: "dice_rolled", playerId, value }
admin_join      { type: "admin_join", matchCode }
                -> { type: "admin_joined", matchCode, roomId, players }
admin_set_dice  { type: "admin_set_dice", playerId, value }
                -> { type: "dice_override_set", playerId, value }
