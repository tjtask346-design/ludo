import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import 'mode_selection_screen.dart';
import 'daily_rewards_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String playerName = 'Player';
  int coins = 0;
  int diamonds = 0;
  int level = 1;
  String playerId = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    playerId = prefs.getString('playerId') ?? '';

    if (playerId.isEmpty) {
      // Generate a random player ID if new user
      playerId = 'P${Random().nextInt(99999999)}';
      await prefs.setString('playerId', playerId);
    }

    // Fetch from MongoDB via API
    final userData = await ApiService.login(playerId, 'Player');
    if (userData != null) {
      setState(() {
        playerName = userData['name'] ?? 'Player';
        coins = userData['coins'] ?? 1000;
        diamonds = userData['diamonds'] ?? 50;
        level = userData['level'] ?? 1;
        isLoading = false;
      });
    } else {
      // Fallback if server is sleeping
      setState(() {
        coins = 1000;
        diamonds = 50;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu, color: AppColors.textDark), onPressed: () => Scaffold.of(context).openDrawer())),
        actions: [
          IconButton(icon: const Icon(Icons.settings, color: AppColors.textDark), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ],
      ),
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.blue))
          : Column(
              children: [
                _buildTopHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildGameModeCard('PLAY ONLINE', 'Play with players around the world', AppColors.blue, Icons.public, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ModeSelectionScreen()));
                      }),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildGameModeCard('WITH FRIENDS', 'Create private room', AppColors.green, Icons.group, () {})),
                          const SizedBox(width: 12),
                          Expanded(child: _buildGameModeCard('COMPUTER', 'Play vs AI', AppColors.red, Icons.computer, () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ModeSelectionScreen()));
                          })),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildGameModeCard('PASS N PLAY', 'Play offline with friends', AppColors.yellow, Icons.phone_android, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ModeSelectionScreen()));
                      }),
                      const SizedBox(height: 24),
                      const Text('EVENTS & REWARDS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      _buildRewardBanner(context),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.blueLight,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(playerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(4)),
                      child: Text('Lv. $level', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: AppColors.border,
                        color: AppColors.green,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildResourceChip(Icons.monetization_on, AppColors.yellow, '$coins'),
          const SizedBox(width: 8),
          _buildResourceChip(Icons.diamond, AppColors.blueLight, '$diamonds'),
        ],
      ),
    );
  }

  Widget _buildResourceChip(IconData icon, Color color, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildGameModeCard(String title, String subtitle, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyRewardsScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard, color: AppColors.red, size: 40),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Reward Available!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Claim your free coins now.', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyRewardsScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, padding: const EdgeInsets.symmetric(horizontal: 16)),
              child: const Text('CLAIM'),
            ),
          ],
        ),
      ),
    );
  }
}
