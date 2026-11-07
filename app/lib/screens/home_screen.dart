import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../services/colyseus_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _serverCtrl = TextEditingController(text: 'wss://ludo-od5h.onrender.com');
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(text: 'Player');

  void _create() async {
    late final ColyseusClient client;
    client = ColyseusClient(onMessage: (m) {
      if (m['type'] == 'room') {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => GameScreen(client: client, matchCode: m['matchCode']),
        ));
      }
    });
    await client.connect(_serverCtrl.text.trim());
    client.createRoom(_nameCtrl.text.trim());
  }

  void _join() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter 6-digit match code')),
      );
      return;
    }
    late final ColyseusClient client;
    client = ColyseusClient(onMessage: (m) {
      if (m['type'] == 'joined') {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => GameScreen(client: client, matchCode: code),
        ));
      }
    });
    await client.connect(_serverCtrl.text.trim());
    client.joinRoom(code, _nameCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game Logo
                  const Text(
                    'LUDO',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(color: Colors.blueAccent, offset: Offset(0, 4), blurRadius: 10),
                        Shadow(color: Colors.black45, offset: Offset(0, 8), blurRadius: 20),
                      ],
                    ),
                  ),
                  const Text(
                    'PLAY WITH FRIENDS',
                    style: TextStyle(color: Colors.white54, letterSpacing: 4, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48),

                  // Custom TextFields
                  _buildTextField(_serverCtrl, 'Server URL', Icons.link),
                  const SizedBox(height: 16),
                  _buildTextField(_nameCtrl, 'Your Name', Icons.person),
                  const SizedBox(height: 32),

                  // Create Match Button
                  _build3DButton(
                    text: 'CREATE MATCH',
                    color1: Colors.greenAccent.shade700,
                    color2: Colors.green.shade900,
                    onTap: _create,
                  ),

                  const SizedBox(height: 32),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR JOIN', style: TextStyle(color: Colors.white54)),
                      ),
                      Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Join Section
                  _buildTextField(_codeCtrl, '6-Digit Match Code', Icons.gamepad, isNumber: true),
                  const SizedBox(height: 16),

                  // Join Button
                  _build3DButton(
                    text: 'JOIN MATCH',
                    color1: Colors.lightBlue.shade400,
                    color2: Colors.blue.shade900,
                    onTap: _join,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: isNumber ? 6 : null,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        counterStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }

  Widget _build3DButton({required String text, required Color color1, required Color color2, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color2, offset: const Offset(0, 6), blurRadius: 0),
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), offset: const Offset(0, 10), blurRadius: 15),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }
}
