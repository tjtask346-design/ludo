import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import 'setup_screen.dart';
import 'online_lobby_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'daily_rewards_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});
  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;
  int coins = 1000;
  int diamonds = 50;
  int level = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String playerId = prefs.getString('playerId') ?? 'P${Random().nextInt(99999999)}';
    await prefs.setString('playerId', playerId);
    final data = await ApiService.login(playerId, 'Player');
    if (mounted) {
      setState(() {
        if (data != null) {
          coins = data['coins'] ?? 1000;
          diamonds = data['diamonds'] ?? 50;
          level = data['level'] ?? 1;
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator(color: AppColors.blue)));
    }

    final List<Widget> _screens = [
      _buildHomeTab(),
      const ShopScreen(),
      const LeaderboardScreen(),
      ProfileScreen(coins: coins, diamonds: diamonds, level: level),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.blue,
        unselectedItemColor: AppColors.textLight,
        backgroundColor: AppColors.card,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Ranking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BULLA LUDO'),
        actions: [IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())))],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChip(Icons.monetization_on, AppColors.yellow, '$coins'),
                  const SizedBox(width: 12),
                  _buildChip(Icons.diamond, AppColors.blueLight, '$diamonds'),
                  const SizedBox(width: 12),
                  _buildChip(Icons.star, AppColors.green, 'Lv. $level'),
                ],
              ),
              const Spacer(),
              const Icon(Icons.grid_on, size: 100, color: AppColors.red),
              const SizedBox(height: 20),
              const Text('PLAY LUDO', textAlign: TextAlign.center, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4)),
              const Spacer(),
              _buildMenuButton('ONLINE MULTIPLAYER', AppColors.blue, Icons.public, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineLobbyScreen()))),
              const SizedBox(height: 16),
              _buildMenuButton('PLAY VS COMPUTER', AppColors.red, Icons.computer, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen(isVsComputer: true)))),
              const SizedBox(height: 16),
              _buildMenuButton('PASS N PLAY', AppColors.green, Icons.people, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen(isVsComputer: false)))),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyRewardsScreen())),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                  child: const Row(
                    children: [
                      Icon(Icons.card_giftcard, color: AppColors.red, size: 40),
                      SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Daily Reward Available!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        Text('Claim your free coins now.', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                      ])),
                      Icon(Icons.chevron_right, color: AppColors.textLight),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, Color color, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
