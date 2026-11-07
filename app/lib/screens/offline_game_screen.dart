import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../game/ludo_engine.dart';
import '../widgets/ludo_board.dart';
import '../widgets/dice_widget.dart';

class OfflineGameScreen extends StatefulWidget {
  final bool isVsComputer;
  const OfflineGameScreen({super.key, this.isVsComputer = false});

  @override
  State<OfflineGameScreen> createState() => _OfflineGameScreenState();
}

class _OfflineGameScreenState extends State<OfflineGameScreen> {
  late LudoEngine engine;
  bool isRolling = false;

  @override
  void initState() {
    super.initState();
    engine = LudoEngine(players: [
      LudoPlayer(name: 'You', color: 'red'),
      LudoPlayer(name: 'Player 2', color: 'green', isBot: widget.isVsComputer),
      LudoPlayer(name: 'Player 3', color: 'yellow', isBot: true),
      LudoPlayer(name: 'Player 4', color: 'blue', isBot: true),
    ]);
    _checkBotTurn();
  }

  void _checkBotTurn() {
    if (engine.currentPlayer.isBot) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            engine.rollDice();
          });
        }
      });
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

  void _onTokenTap(int tokenIndex) {
    if (engine.currentPlayer.isBot) return;
    setState(() {
      engine.moveToken(tokenIndex);
    });
    _checkBotTurn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(engine.gameOver ? 'Game Over' : '${engine.currentPlayer.name}\'s Turn'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: LudoBoard(engine: engine, onTokenTap: _onTokenTap),
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
                  // Player Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(engine.currentPlayer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(engine.hasRolled ? 'Select a token' : 'Tap dice to roll', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                    ],
                  ),
                  // Dice
                  DiceWidget(
                    value: engine.diceValue,
                    rolling: isRolling,
                    onTap: _rollDice,
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
