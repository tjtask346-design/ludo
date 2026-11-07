import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../services/colyseus_client.dart';
import '../services/settings_service.dart';
import '../widgets/ludo_board.dart';
import '../widgets/dice_widget.dart';
import 'game_result_screen.dart';

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
  int diceValue = 0;
  bool rolling = false;
  bool diceRolled = false;
  String? myPlayerId;
  bool gameOver = false;
  String winnerName = "";

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
        if (SettingsService.vibrationOn) HapticFeedback.mediumImpact();
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
        setState(() {
          gameOver = true;
          winnerName = m['winner'];
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (_) => GameResultScreen(winnerName: winnerName, isWin: winnerName == (playerNames[myPlayerId] ?? '')),
            ));
          }
        });
        break;
      case 'error':
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m['message'] ?? 'Error')));
        break;
    }
  }

  bool get isMyTurn => currentTurn == myPlayerId;

  Color _colorFromName(String n) {
    switch (n) {
      case 'red': return const Color(0xFFE53935);
      case 'green': return const Color(0xFF20A65A);
      case 'yellow': return const Color(0xFFFFC928);
      case 'blue': return const Color(0xFF2878DB);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Match ${widget.matchCode}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.red),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
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
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isMyTurn ? 'YOUR TURN' : 'WAITING...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isMyTurn ? AppColors.green : AppColors.textLight)),
                      Text(diceRolled ? 'Select a token' : 'Tap dice to roll', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                    ],
                  ),
                  DiceWidget(
                    value: diceValue,
                    rolling: rolling,
                    onTap: isMyTurn && !diceRolled ? _rollDice : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
