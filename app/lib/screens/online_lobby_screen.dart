import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/online_client.dart';
import 'online_game_screen.dart';

class OnlineLobbyScreen extends StatefulWidget {
  const OnlineLobbyScreen({super.key});
  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  final _codeCtrl = TextEditingController();
  final String _serverUrl = 'wss://ludo-od5h.onrender.com';
  bool _isLoading = false;

  void _createRoom() async {
    setState(() => _isLoading = true);
    late final OnlineClient client;
    client = OnlineClient(onMessage: (m) {
      if (m['type'] == 'room') {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => OnlineGameScreen(client: client, matchCode: m['matchCode']),
        ));
      }
    });
    await client.connect(_serverUrl);
    client.createRoom('Host');
  }

  void _joinRoom() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter 6-digit code')));
      return;
    }
    setState(() => _isLoading = true);
    late final OnlineClient client;
    client = OnlineClient(onMessage: (m) {
      if (m['type'] == 'joined') {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => OnlineGameScreen(client: client, matchCode: code),
        ));
      }
    });
    await client.connect(_serverUrl);
    client.joinRoom(code, 'Guest');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('ONLINE MULTIPLAYER')),
      body: Center(
        child: _isLoading 
          ? const CircularProgressIndicator(color: AppColors.blue)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _createRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('CREATE PRIVATE ROOM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 40),
                const Text('OR JOIN WITH CODE', style: TextStyle(color: AppColors.textLight, letterSpacing: 1)),
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
                      fillColor: AppColors.card,
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
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('JOIN ROOM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
      ),
    );
  }
}
