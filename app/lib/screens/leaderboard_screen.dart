import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('LEADERBOARD'),
          bottom: const TabBar(
            labelColor: AppColors.blue,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.blue,
            tabs: [Tab(text: 'Global'), Tab(text: 'Friends')],
          ),
        ),
        body: Column(
          children: [
            _buildPodium(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 10,
                itemBuilder: (context, index) {
                  int rank = index + 4; // Starting from rank 4
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Text('$rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textLight)),
                        const SizedBox(width: 16),
                        const CircleAvatar(backgroundColor: AppColors.blueLight, child: Icon(Icons.person, color: Colors.white)),
                        const SizedBox(width: 16),
                        const Expanded(child: Text('Player Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        const Icon(Icons.monetization_on, color: AppColors.yellow, size: 16),
                        const SizedBox(width: 4),
                        Text('${10000 - (index * 500)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumAvatar('2nd', 80, AppColors.textLight),
          _buildPodiumAvatar('1st', 110, AppColors.yellow),
          _buildPodiumAvatar('3rd', 70, AppColors.redLight),
        ],
      ),
    );
  }

  Widget _buildPodiumAvatar(String rank, double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: height / 3,
          backgroundColor: color,
          child: Icon(Icons.person, size: height / 2, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(rank, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const Text('Player', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
      ],
    );
  }
}
