import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../game/ludo_engine.dart';
import '../widgets/ludo_board.dart';
import '../widgets/dice_widget.dart';

class OfflineGameScreen extends StatefulWidget {
  final bool isVsComputer;
  final int playerCount;
  final AIDifficulty difficulty;
  const OfflineGameScreen({super.key, required this.isVsComputer, required this.playerCount, this.difficulty = AIDifficulty.medium});

  @override
  State<OfflineGameScreen> createState() => _OfflineGameScreenState();
}

class _OfflineGameScreenState extends State<OfflineGameScreen> {
  late LudoEngine engine;
  bool isRolling = false;
  bool showHandover = false;
  int previousTurnIndex = -1;

  @override
  void initState() {
    super.initState();
    List<LudoPlayer> players = [
      LudoPlayer(name: 'Player 1', color: 'red'),
      LudoPlayer(name: 'Player 2', color: 'green', isBot: widget.isVsComputer),
      if (widget.playerCount >= 3) LudoPlayer(name: 'Player 3', color: 'yellow', isBot: widget.isVsComputer),
      if (widget.playerCount >= 4) LudoPlayer(name: 'Player 4', color: 'blue', isBot: widget.isVsComputer),
    ];
    engine = LudoEngine(players: players, difficulty: widget.difficulty);
    _checkBotTurn();
  }

  void _checkBotTurn() {
    if (engine.currentPlayer.isBot) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() { engine.rollDice(); });
      });
    } else {
      if (!widget.isVsComputer && previousTurnIndex != -1 && previousTurnIndex != engine.currentTurnIndex) {
        setState(() => showHandover = true);
      }
      previousTurnIndex = engine.currentTurnIndex;
    }
  }

  void _rollDice() {
    if (engine.hasRolled || engine.currentPlayer.isBot) return;
    setState(() => isRolling = true);
    engine.rollDice();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => isRolling = false);
    });
  }

  void _onTokenTap(String playerId, int tokenIndex) {
    if (engine.currentPlayer.isBot) return;
    setState(() {
      engine.moveToken(tokenIndex);
    });
    _checkBotTurn();
  }

  Color _getTurnColor() {
    switch (engine.currentPlayer.color) {
      case 'red': return const Color(0xFFE53935);
      case 'green': return const Color(0xFF20A65A);
      case 'yellow': return const Color(0xFFFFC928);
      case 'blue': return const Color(0xFF2878DB);
      default: return AppColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Map engine state to UI maps
    Map<String, List<int>> tokensMap = {};
    Map<String, String> colorsMap = {};
    for (var p in engine.players) {
      tokensMap[p.name] = p.tokens.map((t) => t.position).toList();
      colorsMap[p.name] = p.color;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(engine.gameOver ? 'Game Over' : '${engine.currentPlayer.name}\'s Turn')),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: LudoBoard(
                          tokensByPlayer: tokensMap,
                          playerColors: colorsMap,
                          highlightedPlayer: engine.currentPlayer.name,
                          onTokenTap: _onTokenTap,
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
                      Row(
                        children: [
                          Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(color: _getTurnColor(), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(engine.currentPlayer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  color: Colors.black.withValues(alpha: 0.85),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Pass phone to\n${engine.currentPlayer.name}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () => setState(() => showHandover = false),
                          style: ElevatedButton.styleFrom(backgroundColor: _getTurnColor(), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                          child: const Text('I AM READY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
