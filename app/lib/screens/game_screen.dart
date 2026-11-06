import 'package:flutter/material.dart';
import '../services/colyseus_client.dart';

class GameScreen extends StatefulWidget {
  final ColyseusClient client;
  final String matchCode;
  const GameScreen({super.key, required this.client, required this.matchCode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int? lastDice;

  @override
  void initState() {
    super.initState();
    widget.client.onMessage = (m) {
      if (m['type'] == 'dice_rolled' && mounted) {
        setState(() => lastDice = m['value']);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Match ${widget.matchCode}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Match Code: ${widget.matchCode}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            Text(lastDice == null ? 'No roll yet' : 'Dice: $lastDice', style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => widget.client.rollDice(),
              child: const Text('Roll Dice'),
            ),
          ],
        ),
      ),
    );
  }
}
