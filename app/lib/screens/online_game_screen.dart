import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/online_client.dart';
import '../widgets/ludo_board.dart';
import '../widgets/dice_widget.dart';
import 'game_result_screen.dart';

class OnlineGameScreen extends StatefulWidget {
  final OnlineClient client;
  final String matchCode;
  const OnlineGameScreen({super.key, required this.client, required this.matchCode});

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  Map<String, List<int>> tokensByPlayer = {};
  Map<String, String> playerColors = {};
  Map<String, String> playerNames = {};
  String? currentTurn;
  int diceValue = 0;
  bool rolling = false;
  bool diceRolled = false;
  String? myPlayerId;

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
    if (mounted) setState(() {});
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
          diceValue = m['value'];
          if (m['playerId'] == myPlayerId) diceRolled = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => rolling = false);
        });
        break;
      case 'token_moved':
        setState(() {
          tokensByPlayer[m['playerId']] = List<int>.from(m['tokens']);
          diceRolled = false;
        });
        break;
      case 'turn_changed':
        setState(() {
          currentTurn = m['currentTurn'];
          if (currentTurn == myPlayerId) diceRolled = false;
        });
        break;
      case 'game_over':
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => GameResultScreen(winnerName: m['winner'], isWin: m['winner'] == playerNames[myPlayerId]),
        ));
        break;
    }
  }

  bool get isMyTurn => currentTurn == myPlayerId;

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Match: ${widget.matchCode}')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
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
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isMyTurn ? 'YOUR TURN' : 'WAITING...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isMyTurn ? AppColors.green : Colors.white70)),
                  DiceWidget(value: diceValue, rolling: rolling, onTap: isMyTurn && !diceRolled ? _rollDice : null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
