import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../game/ludo_engine.dart';
import 'game_screen.dart';

class TeamUpSetupScreen extends StatefulWidget {
  const TeamUpSetupScreen({super.key});
  @override
  State<TeamUpSetupScreen> createState() => _TeamUpSetupScreenState();
}

class _TeamUpSetupScreenState extends State<TeamUpSetupScreen> {
  AIDifficulty difficulty = AIDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('TEAM UP (2 vs 2)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.group, size: 80, color: AppColors.yellow),
            const SizedBox(height: 20),
            const Text('Team Red & Yellow vs Team Green & Blue', style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 40),
            const Text('AI Difficulty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    child: Text(diff.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.white70)),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => GameScreen(isVsComputer: true, isTeamMode: true, playerCount: 4, difficulty: difficulty),
                  ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.yellow),
                child: const Text('START MATCH', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
