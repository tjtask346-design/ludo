import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import 'mode_selection_screen.dart';
import 'online_room_screen.dart';
import 'offline_setup_screen.dart';
import 'club_screen.dart';
import 'daily_rewards_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String playerName = 'Player';
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
      backgroundColor: const Color(0xFF0F1423),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white), 
            onPressed: () => Scaffold.of(context).openDrawer()
          )
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.blue))
          : Column(
              children: [
                _buildTopHeader(),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final cards = [
                        {'img': '01_computer.png', 'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineSetupScreen(isVsComputer: true)))},
                        {'img': '02_players2.png', 'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineSetupScreen(isVsComputer: false)))},
                        {'img': '03_players4.png', 'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineSetupScreen(isVsComputer: false)))},
                        {'img': '04_teamup.png', 'action': () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming Soon')))},
                        {'img': '05_quickludo.png', 'action': () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming Soon')))},
                        {'img': '06_tournament.png', 'action': () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming Soon')))},
                        {'img': '07_snakes.png', 'action': () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming Soon')))},
                        {'img': '08_privateroom.png', 'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineRoomScreen()))},
                        {'img': '09_offline.png', 'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ModeSelectionScreen()))},
                        {'img': '10_adda.png', 'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClubScreen()))},
                      ];
                      return GestureDetector(
                        onTap: cards[index]['action'] as VoidCallback,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 6))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset('assets/images/${cards[index]['img']}', fit: BoxFit.cover),
                          ),
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

  Widget _buildTopHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2235),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 24, backgroundColor: AppColors.blueLight, child: Icon(Icons.person, color: Colors.white, size: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(playerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(4)),
                      child: Text('Lv. $level', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(value: 0.6, backgroundColor: Colors.white12, color: AppColors.green, minHeight: 6, borderRadius: BorderRadius.circular(3)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildResourceChip(Icons.monetization_on, AppColors.yellow, '$coins'),
          const SizedBox(width: 8),
          _buildResourceChip(Icons.diamond, AppColors.blueLight, '$diamonds'),
        ],
      ),
    );
  }

  Widget _buildResourceChip(IconData icon, Color color, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF0F1423), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }
}
