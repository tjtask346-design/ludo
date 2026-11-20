import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'setup_screen.dart';
import 'snakes_ladders_screen.dart';
import 'team_up_setup_screen.dart';
import 'tournament_screen.dart';

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
            _buildModeCard('Classic Ludo', 'Play 2-4 players', Icons.grid_on, AppColors.blue, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen(isVsComputer: false)));
            }),
            _buildModeCard('Snakes & Ladders', 'Classic board game', Icons.stairs, AppColors.green, () {
              _showPlayerCountDialog(context);
            }),
            _buildModeCard('Team Up', '2 vs 2 Mode', Icons.group, AppColors.yellow, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamUpSetupScreen()));
            }),
            _buildModeCard('Tournament', 'Compete for the cup', Icons.emoji_events, AppColors.red, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TournamentScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.white70)),
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
              backgroundColor: AppColors.green,
              child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )).toList(),
        ),
      ),
    );
  }
}
