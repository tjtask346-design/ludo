import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../game/ludo_engine.dart';
import 'offline_game_screen.dart';

class OfflineSetupScreen extends StatefulWidget {
  final bool isVsComputer;
  const OfflineSetupScreen({super.key, required this.isVsComputer});

  @override
  State<OfflineSetupScreen> createState() => _OfflineSetupScreenState();
}

class _OfflineSetupScreenState extends State<OfflineSetupScreen> {
  int playerCount = 4;
  AIDifficulty difficulty = AIDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.isVsComputer ? 'VS COMPUTER' : 'PASS N PLAY')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Number of Players', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [2, 3, 4].map((num) {
                bool isSelected = playerCount == num;
                return GestureDetector(
                  onTap: () => setState(() => playerCount = num),
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.blue : AppColors.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blue, width: 2),
                      boxShadow: isSelected ? [BoxShadow(color: AppColors.blue.withValues(alpha: 0.4), blurRadius: 10)] : [],
                    ),
                    child: Center(
                      child: Text('$num', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textDark)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            if (widget.isVsComputer) ...[
              const Text('AI Difficulty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: AIDifficulty.values.map((diff) {
                  bool isSelected = difficulty == diff;
                  return GestureDetector(
                    onTap: () => setState(() => difficulty = diff),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.red : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.red, width: 2),
                      ),
                      child: Text(
                        diff.name.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textDark),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => OfflineGameScreen(
                      isVsComputer: widget.isVsComputer,
                      playerCount: playerCount,
                      difficulty: difficulty,
                    ),
                  ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                child: const Text('START GAME', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
