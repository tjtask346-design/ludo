import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'setup_screen.dart';
import 'snakes_ladders_screen.dart';

class GameModesScreen extends StatelessWidget {
  const GameModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('SELECT GAME MODE')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            _buildModeCard('Classic Ludo', Icons.grid_on, AppColors.blue, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen(isVsComputer: false)));
            }),
            _buildModeCard('Snakes & Ladders', Icons.stairs, AppColors.green, () {
              _showPlayerCountDialog(context);
            }),
            _buildModeCard('Team Up (2v2)', Icons.group_work, AppColors.yellow, () {
              _showComingSoon(context);
            }),
            _buildModeCard('Tournament', Icons.emoji_events, AppColors.red, () {
              _showComingSoon(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: color),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _showPlayerCountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Select Players', style: TextStyle(color: Colors.white)),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [2, 3, 4].map((n) => GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => SnakesLaddersScreen(playerCount: n)));
            },
            child: CircleAvatar(
              backgroundColor: AppColors.blue,
              child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This mode is under development!'), backgroundColor: AppColors.red),
    );
  }
}
