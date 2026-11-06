import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ColyseusClient {
  WebSocketChannel? _channel;
  String? roomId;
  String? matchCode;
  String? playerId;
  List<dynamic> players = [];
  void Function(Map<String, dynamic>)? onMessage;

  ColyseusClient({this.onMessage});

  Future<void> connect(String serverUrl) async {
    _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
    _channel!.stream.listen((raw) {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      if (msg['type'] == 'room' || msg['type'] == 'joined') {
        roomId = msg['roomId'];
        matchCode = msg['matchCode'];
        playerId = msg['playerId'];
        players = (msg['players'] as List?) ?? [];
      }
      onMessage?.call(msg);
    });
  }

  void createRoom(String name) {
    _channel?.sink.add(jsonEncode({'type': 'create', 'name': name}));
  }

  void joinRoom(String code, String name) {
    _channel?.sink.add(jsonEncode({'type': 'join', 'roomId': code, 'name': name}));
  }

  void rollDice() {
    _channel?.sink.add(jsonEncode({'type': 'roll_dice'}));
  }

  void moveToken(int index) {
    _channel?.sink.add(jsonEncode({'type': 'move_token', 'tokenIndex': index}));
  }

  void skipTurn() {
    _channel?.sink.add(jsonEncode({'type': 'skip_turn'}));
  }

  void disconnect() => _channel?.sink.close();
}
