import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../services/colyseus_client.dart';

class OnlineRoomScreen extends StatefulWidget {
  const OnlineRoomScreen({super.key});
  @override
  State<OnlineRoomScreen> createState() => _OnlineRoomScreenState();
}

class _OnlineRoomScreenState extends State<OnlineRoomScreen> {
  final _codeCtrl = TextEditingController();
  final String _serverUrl = 'wss://ludo-od5h.onrender.com'; // Hidden from player!
  bool _isLoading = false;

  void _createRoom() async {
    setState(() => _isLoading = true);
    final client = ColyseusClient(onMessage: (m) {
      if (m['type'] == 'room') {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => GameScreen(client: client, matchCode: m['matchCode']),
        ));
      }
    });
    await client.connect(_serverUrl);
    client.createRoom('Player 1');
  }

  void _joinRoom() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter 6-digit code')));
      return;
    }
    setState(() => _isLoading = true);
    final client = ColyseusClient(onMessage: (m) {
      if (m['type'] == 'joined') {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => GameScreen(client: client, matchCode: code),
        ));
      }
    });
    await client.connect(_serverUrl);
    client.joinRoom(code, 'Player 2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.orange)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('PLAY ONLINE', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _createRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('CREATE PRIVATE ROOM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 40),
                const Text('OR JOIN WITH CODE', style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8, color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      hintText: '000000',
                      hintStyle: const TextStyle(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _joinRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('JOIN MATCH', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
      ),
    );
  }
}
