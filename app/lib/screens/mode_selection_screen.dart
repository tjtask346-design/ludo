import 'package:flutter/material.dart';
import 'online_room_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E130C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('SELECT MODE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeButton(context, 'VS COMPUTER', 'Play against AI', Icons.computer, Colors.blueAccent, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI mode coming soon!')));
            }),
            const SizedBox(height: 20),
            _buildModeButton(context, 'PASS & PLAY', 'Play with friends offline', Icons.people, Colors.greenAccent, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local multiplayer coming soon!')));
            }),
            const SizedBox(height: 20),
            _buildModeButton(context, 'ONLINE MULTIPLAYER', 'Play with friends via code', Icons.wifi, Colors.orangeAccent, () {
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
          color: const Color(0xFF2E1C12),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), offset: const Offset(0, 5), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
