import 'package:flutter/material.dart';
import 'online_room_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Select Mode', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeButton(context, 'Play vs Computer', 'Play against AI', Icons.computer, Colors.blueAccent, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI mode coming soon!')));
            }),
            const SizedBox(height: 20),
            _buildModeButton(context, 'Pass & Play (Offline)', 'Play with friends on this phone', Icons.people, Colors.green, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local multiplayer coming soon!')));
            }),
            const SizedBox(height: 20),
            _buildModeButton(context, 'Play Online', 'Play with friends via code', Icons.wifi, Colors.orange, () {
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2)],
        ),
        child: Row(
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
