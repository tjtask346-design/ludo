import 'package:flutter/material.dart';
import '../services/colyseus_client.dart';
import '../widgets/ludo_board.dart';
import '../widgets/dice_widget.dart';

class GameScreen extends StatefulWidget {
  final ColyseusClient client;
  final String matchCode;
  const GameScreen({super.key, required this.client, required this.matchCode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Map<String, List<int>> tokensByPlayer = {};
  Map<String, String> playerColors = {};
  Map<String, String> playerNames = {};
  String? currentTurn;
  int dice = 0;
  bool rolling = false;
  bool diceRolled = false;
  String? myPlayerId;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    myPlayerId = widget.client.playerId;
    _processPlayers(widget.client.players);
    widget.client.onMessage = _onMessage;
  }

  void _processPlayers(List<dynamic> players) {
    for (final p in players) {
      final m = p as Map<String, dynamic>;
      final id = m['id'] as String;
      playerColors[id] = m['color'] as String;
      playerNames[id] = m['name'] as String;
      tokensByPlayer[id] = List<int>.from((m['tokens'] as List?) ?? [-1, -1, -1, -1]);
    }
    if (currentTurn == null && players.isNotEmpty) {
      currentTurn = (players.first as Map)['id'];
    }
    setState(() {});
  }

  void _onMessage(Map<String, dynamic> m) {
    switch (m['type']) {
      case 'player_added':
        _processPlayers([m['player']]);
        break;
      case 'joined':
      case 'room':
        _processPlayers(m['players'] ?? []);
        break;
      case 'dice_rolled':
        setState(() {
          rolling = true;
          dice = m['value'];
          if (m['playerId'] == myPlayerId) diceRolled = true;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => rolling = false);
        });
        break;
      case 'token_moved':
        setState(() {
          tokensByPlayer[m['playerId']] = List<int>.from(m['tokens']);
          diceRolled = false;
        });
        break;
      case 'turn_voided':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${playerNames[m['playerId']]} rolled 3 sixes! Turn voided.')),
        );
        break;
      case 'turn_changed':
        setState(() {
          currentTurn = m['currentTurn'];
          if (currentTurn == myPlayerId) diceRolled = false;
        });
        break;
      case 'error':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(m['message'] ?? 'Error')),
        );
        break;
    }
  }

  bool get isMyTurn => currentTurn == myPlayerId;

  Color _colorFromName(String n) {
    switch (n) {
      case 'red': return Colors.red.shade600;
      case 'green': return Colors.green.shade600;
      case 'yellow': return Colors.amber.shade600;
      case 'blue': return Colors.blue.shade600;
      default: return Colors.grey;
    }
  }

  void _rollDice() {
    if (!isMyTurn || diceRolled) return;
    widget.client.rollDice();
  }

  void _tapToken(String playerId, int index) {
    if (!isMyTurn || !diceRolled) return;
    widget.client.moveToken(index);
  }

  @override
  Widget build(BuildContext context) {
    final myTokens = tokensByPlayer[myPlayerId] ?? [-1, -1, -1, -1];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('Match ${widget.matchCode}', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                children: playerColors.entries.map((e) {
                  final isTurn = e.key == currentTurn;
                  return Chip(
                    backgroundColor: isTurn ? _colorFromName(e.value) : _colorFromName(e.value).withValues(alpha: 0.4),
                    label: Text(playerNames[e.key] ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: LudoBoard(
                      tokensByPlayer: tokensByPlayer,
                      playerColors: playerColors,
                      highlightedPlayer: isMyTurn ? myPlayerId : null,
                      onTokenTap: _tapToken,
                    ),
                  ),
                ),
              ),
            ),
            if (isMyTurn && diceRolled)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Tap a token to move (dice: $dice)',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DiceWidget(value: dice, rolling: rolling, onTap: _rollDice),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: isMyTurn && !diceRolled ? _rollDice : null,
                        icon: const Icon(Icons.casino),
                        label: Text(isMyTurn ? 'Roll Dice' : 'Wait...'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMyTurn ? _colorFromName(playerColors[myPlayerId] ?? 'red') : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      if (isMyTurn && diceRolled)
                        TextButton(
                          onPressed: () => widget.client.skipTurn(),
                          child: const Text('Skip Turn', style: TextStyle(color: Colors.white70)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (i) {
                  final pos = myTokens[i];
                  final label = pos == -1 ? 'Base' : (pos == 56 ? 'Home' : 'Tile $pos');
                  return GestureDetector(
                    onTap: () => _tapToken(myPlayerId ?? '', i),
                    child: Column(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: _colorFromName(playerColors[myPlayerId] ?? 'red'),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Center(child: Icon(Icons.circle, color: Colors.white, size: 8)),
                        ),
                        const SizedBox(height: 4),
                        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
