import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../services/colyseus_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _serverCtrl = TextEditingController(text: 'ws://10.0.2.2:2567');
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(text: 'Player');

  void _create() async {
    final client = ColyseusClient(onMessage: (m) {
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
    final client = ColyseusClient(onMessage: (m) {
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
      appBar: AppBar(title: const Text('Ludo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _serverCtrl, decoration: const InputDecoration(labelText: 'Server URL')),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Your name')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _create, child: const Text('Create Match')),
            const Divider(height: 32),
            TextField(controller: _codeCtrl, keyboardType: TextInputType.number, maxLength: 6, decoration: const InputDecoration(labelText: '6-digit match code')),
            ElevatedButton(onPressed: _join, child: const Text('Join Match')),
          ],
        ),
      ),
    );
  }
}
