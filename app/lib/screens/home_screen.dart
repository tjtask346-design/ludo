import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import 'setup_screen.dart';
import 'online_lobby_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BULLA LUDO'),
        actions: [IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())))],
      ),
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.blue))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildResourceRow(),
                  const Spacer(),
                  const Icon(Icons.grid_on, size: 100, color: AppColors.red),
                  const SizedBox(height: 20),
                  const Text('PLAY LUDO', textAlign: TextAlign.center, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4)),
                  const Spacer(),
                  _buildMenuButton('ONLINE MULTIPLAYER', AppColors.blue, Icons.public, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineLobbyScreen()));
                  }),
                  const SizedBox(height: 16),
                  _buildMenuButton('PLAY VS COMPUTER', AppColors.red, Icons.computer, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen(isVsComputer: true)));
                  }),
                  const SizedBox(height: 16),
                  _buildMenuButton('PASS N PLAY', AppColors.green, Icons.people, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen(isVsComputer: false)));
                  }),
                  const Spacer(),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildResourceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChip(Icons.monetization_on, AppColors.yellow, '$coins'),
        const SizedBox(width: 12),
        _buildChip(Icons.diamond, AppColors.blueLight, '$diamonds'),
        const SizedBox(width: 12),
        _buildChip(Icons.star, AppColors.green, 'Lv. $level'),
      ],
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
