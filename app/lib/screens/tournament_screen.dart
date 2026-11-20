import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../game/ludo_engine.dart';
import 'game_screen.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});
  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  int currentRound = 1; // 1: Quarter, 2: Semi, 3: Final

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('TOURNAMENT')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 100, color: AppColors.yellow),
            const SizedBox(height: 20),
            Text(
              currentRound == 1 ? 'Quarter Final' : currentRound == 2 ? 'Semi Final' : 'Grand Final',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('Win to advance to the next round!', style: TextStyle(color: AppColors.textLight)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                // Play 1v1 against hard AI
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => GameScreen(isVsComputer: true, isTeamMode: false, playerCount: 2, difficulty: AIDifficulty.hard),
                ));
                // Assuming user won for the demo
                if (mounted) {
                  setState(() {
                    if (currentRound < 3) {
                      currentRound++;
                    } else {
                      _showWinnerDialog();
                    }
                  });
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
              child: Text('PLAY ROUND $currentRound', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('🏆 CHAMPION!', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold)),
        content: const Text('You have won the tournament!', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => currentRound = 1);
            },
            child: const Text('PLAY AGAIN', style: TextStyle(color: AppColors.green)),
          ),
        ],
      ),
    );
  }
}
