import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../game/ludo_engine.dart';
import '../widgets/ludo_board.dart';
import '../widgets/dice_widget.dart';
import '../services/settings_service.dart';
import 'game_result_screen.dart';

class GameScreen extends StatefulWidget {
  final bool isVsComputer;
  final bool isTeamMode;
  final int playerCount;
  final AIDifficulty difficulty;
  
  const GameScreen({super.key, required this.isVsComputer, required this.isTeamMode, required this.playerCount, this.difficulty = AIDifficulty.medium});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late LudoEngine engine;
  bool isRolling = false;
  bool showHandover = false;
  int previousTurnIndex = -1;

  @override
  void initState() {
    super.initState();
    List<LudoPlayer> players = [];
    
    if (widget.isTeamMode) {
      // 2v2 Teams: Red+Yellow (Team A) vs Green+Blue (Team B)
      players = [
        LudoPlayer(name: 'P1', color: 'red', team: 'A', isBot: widget.isVsComputer),
        LudoPlayer(name: widget.isVsComputer ? 'Bot 1' : 'P2', color: 'green', team: 'B', isBot: widget.isVsComputer),
        LudoPlayer(name: widget.isVsComputer ? 'Bot 2' : 'P3', color: 'yellow', team: 'A', isBot: widget.isVsComputer),
        LudoPlayer(name: widget.isVsComputer ? 'Bot 3' : 'P4', color: 'blue', team: 'B', isBot: widget.isVsComputer),
      ];
    } else {
      players = [
        LudoPlayer(name: 'Player 1', color: 'red'),
        LudoPlayer(name: widget.isVsComputer ? 'Computer 1' : 'Player 2', color: 'green', isBot: widget.isVsComputer),
        if (widget.playerCount >= 3) LudoPlayer(name: widget.isVsComputer ? 'Computer 2' : 'Player 3', color: 'yellow', isBot: widget.isVsComputer),
        if (widget.playerCount >= 4) LudoPlayer(name: widget.isVsComputer ? 'Computer 3' : 'Player 4', color: 'blue', isBot: widget.isVsComputer),
      ];
    }
    
    engine = LudoEngine(players: players, difficulty: widget.difficulty, isTeamMode: widget.isTeamMode);
    _checkBotTurn();
  }

  void _checkGameOver() {
    if (engine.gameOver) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => GameResultScreen(winnerName: engine.winner, isWin: engine.winner.contains('Player 1') || engine.winner.contains('Team Red')),
          ));
        }
      });
    }
  }

  void _checkBotTurn() {
    if (engine.currentPlayer.isBot) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => engine.rollDice());
          if (SettingsService.vibrationOn) HapticFeedback.mediumImpact();
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted && engine.hasRolled && !engine.gameOver) {
              for (int i = 0; i < 4; i++) {
                if (engine.isValidMove(engine.currentPlayer, i, engine.diceValue)) {
                  setState(() => engine.moveToken(i));
                  if (SettingsService.vibrationOn) HapticFeedback.mediumImpact();
                  break;
                }
              }
              _checkGameOver();
              _checkBotTurn();
            }
          });
        }
      });
    } else {
      if (!widget.isVsComputer && previousTurnIndex != -1 && previousTurnIndex != engine.currentTurnIndex && engine.diceValue == 0) {
        setState(() => showHandover = true);
      }
      previousTurnIndex = engine.currentTurnIndex;
    }
  }

  void _rollDice() {
    if (engine.hasRolled || engine.currentPlayer.isBot) return;
    setState(() => isRolling = true);
    if (SettingsService.vibrationOn) HapticFeedback.mediumImpact();
    engine.rollDice();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => isRolling = false);
    });
  }

  void _onTokenTap(String playerId, int tokenIndex) {
    if (engine.currentPlayer.isBot) return;
    setState(() => engine.moveToken(tokenIndex));
    if (SettingsService.vibrationOn) HapticFeedback.mediumImpact();
    _checkGameOver();
    _checkBotTurn();
  }

  Color _getTurnColor() {
    switch (engine.currentPlayer.color) {
      case 'red': return AppColors.red;
      case 'green': return AppColors.green;
      case 'yellow': return AppColors.yellow;
      case 'blue': return AppColors.blue;
      default: return AppColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<int>> tokensMap = {};
    Map<String, String> colorsMap = {};
    for (var p in engine.players) {
      tokensMap[p.name] = p.tokens.map((t) => t.position).toList();
      colorsMap[p.name] = p.color;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(engine.gameOver ? 'Game Over' : '${engine.currentPlayer.name}\'s Turn'),
        actions: [IconButton(icon: const Icon(Icons.exit_to_app, color: AppColors.red), onPressed: () => Navigator.pop(context))],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (widget.isTeamMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.card,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Text('Team Red & Yellow', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
                        Text('VS', style: TextStyle(color: Colors.white54)),
                        Text('Team Green & Blue', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: LudoBoard(tokensByPlayer: tokensMap, playerColors: colorsMap, highlightedPlayer: engine.currentPlayer.name, onTokenTap: _onTokenTap),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: const BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 16, height: 16, decoration: BoxDecoration(color: _getTurnColor(), shape: BoxShape.circle)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(engine.currentPlayer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text(engine.hasRolled ? 'Select a token' : 'Tap dice to roll', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      DiceWidget(value: engine.diceValue, rolling: isRolling, onTap: _rollDice),
                    ],
                  ),
                ),
              ],
            ),
            if (showHandover)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.9),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Pass phone to\n${engine.currentPlayer.name}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () => setState(() => showHandover = false),
                          style: ElevatedButton.styleFrom(backgroundColor: _getTurnColor(), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                          child: const Text('I AM READY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
