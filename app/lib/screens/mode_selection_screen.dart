import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'offline_setup_screen.dart';
import 'online_room_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('SELECT MODE')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeButton(context, 'VS COMPUTER', 'Play against AI', Icons.computer, AppColors.red, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineSetupScreen(isVsComputer: true)));
            }),
            const SizedBox(height: 20),
            _buildModeButton(context, 'PASS & PLAY', 'Play with friends offline', Icons.people, AppColors.green, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineSetupScreen(isVsComputer: false)));
            }),
            const SizedBox(height: 20),
            _buildModeButton(context, 'ONLINE MULTIPLAYER', 'Play with friends via code', Icons.wifi, AppColors.blue, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineRoomScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, 4), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
