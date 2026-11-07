import 'package:flutter/material.dart';
import 'mode_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E130C), Color(0xFF9A8478)], // Warm wood-like gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar (Coins, Gems)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildResourceBar(Icons.monetization_on, Colors.amber, '10,250'),
                        const SizedBox(width: 8),
                        _buildResourceBar(Icons.diamond, Colors.cyanAccent, '150'),
                      ],
                    ),
                    const Icon(Icons.settings, color: Colors.white, size: 32),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Logo
              const Text(
                'BULLA',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: Colors.amber,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(color: Colors.black, offset: Offset(0, 4), blurRadius: 10),
                  ],
                ),
              ),
              const Text(
                'L U D O',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 15,
                  shadows: [
                    Shadow(color: Colors.black, offset: Offset(0, 4), blurRadius: 10),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Player Profile
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Player Name', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Level 12', style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, color: Colors.white54),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Play Button
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ModeSelectionScreen()));
                },
                child: Container(
                  width: 200,
                  height: 75,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFE000), Color(0xFFFFA500)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.6), offset: const Offset(0, 8), blurRadius: 10),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'PLAY',
                      style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceBar(IconData icon, Color color, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
