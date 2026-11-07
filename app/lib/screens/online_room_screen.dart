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
  final String _serverUrl = 'wss://ludo-od5h.onrender.com';
  bool _isLoading = false;

  void _createRoom() async {
    setState(() => _isLoading = true);
    late final ColyseusClient client;
    client = ColyseusClient(onMessage: (m) {
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
    late final ColyseusClient client;
    client = ColyseusClient(onMessage: (m) {
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
      backgroundColor: const Color(0xFF1E130C),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.orange)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ONLINE MULTIPLAYER', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _createRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 8,
                    shadowColor: Colors.greenAccent,
                  ),
                  child: const Text('CREATE PRIVATE ROOM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 40),
                const Text('OR JOIN WITH CODE', style: TextStyle(color: Colors.white54, letterSpacing: 1)),
                const SizedBox(height: 16),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, letterSpacing: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      hintText: '------',
                      hintStyle: const TextStyle(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _joinRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 8,
                    shadowColor: Colors.blue,
                  ),
                  child: const Text('JOIN ROOM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
      ),
    );
  }
}
