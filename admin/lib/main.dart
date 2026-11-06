import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(const AdminApp());

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const AdminLoginScreen(),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _serverCtrl = TextEditingController(text: 'wss://ludo-od5h.onrender.com');
  final _codeCtrl = TextEditingController();
  WebSocketChannel? _channel;
  Map<String, dynamic>? _roomData;
  List<dynamic> _players = [];
  String? _selectedPlayerId;
  int _diceValue = 6;

  void _connect() {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter 6-digit match code')));
      return;
    }

    _channel = WebSocketChannel.connect(Uri.parse(_serverCtrl.text.trim()));
    
    _channel!.stream.listen((raw) {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      
      if (msg['type'] == 'admin_joined') {
        setState(() {
          _roomData = msg;
          _players = msg['players'] ?? [];
        });
      } else if (msg['type'] == 'player_added') {
        setState(() {
          _players.add(msg['player']);
        });
      } else if (msg['type'] == 'dice_override_set') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dice set to ${msg['value']} for ${msg['playerId']}'), backgroundColor: Colors.green),
        );
      } else if (msg['type'] == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${msg['message']}'), backgroundColor: Colors.red),
        );
      }
    });

    // Send admin_join
    _channel!.sink.add(jsonEncode({'type': 'admin_join', 'matchCode': code}));
  }

  void _setDice() {
    if (_selectedPlayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a player first')));
      return;
    }
    _channel?.sink.add(jsonEncode({
      'type': 'admin_set_dice',
      'playerId': _selectedPlayerId,
      'value': _diceValue
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👑 God Mode Admin'), backgroundColor: Colors.redAccent),
      body: _roomData == null ? _buildLoginUI() : _buildControlUI(),
    );
  }

  Widget _buildLoginUI() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.admin_panel_settings, size: 100, color: Colors.redAccent),
          const SizedBox(height: 32),
          TextField(
            controller: _serverCtrl,
            decoration: const InputDecoration(labelText: 'Server URL', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(labelText: '6-Digit Match Code', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _connect,
            icon: const Icon(Icons.login),
            label: const Text('Connect to Match'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildControlUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.redAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Connected to Match: ${_roomData!['matchCode']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select Player:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _players.map<DropdownMenuItem<String>>((p) {
              return DropdownMenuItem<String>(
                value: p['id'],
                child: Text('${p['name']} (${p['color']})'),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedPlayerId = val),
          ),
          const SizedBox(height: 24),
          const Text('Set Dice Value (1-6):', style: TextStyle(fontSize: 18)),
          Slider(
            value: _diceValue.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            label: _diceValue.toString(),
            onChanged: (val) => setState(() => _diceValue = val.toInt()),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _setDice,
            icon: const Icon(Icons.casino),
            label: Text('Force Dice to $_diceValue'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }
}
