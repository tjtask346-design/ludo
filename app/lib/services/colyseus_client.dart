import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ColyseusClient {
  WebSocketChannel? _channel;
  String? roomId;
  String? matchCode;
  void Function(Map<String, dynamic>)? onMessage;

  ColyseusClient({this.onMessage});

  Future<void> connect(String serverUrl) async {
    _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
    _channel!.stream.listen((raw) {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      if (msg['type'] == 'room') {
        roomId = msg['roomId'];
        matchCode = msg['matchCode'];
      }
      onMessage?.call(msg);
    });
  }

  void createRoom(String name) {
    _channel?.sink.add(jsonEncode({'type': 'create', 'name': name}));
  }

  void joinRoom(String roomId, String name) {
    _channel?.sink.add(jsonEncode({'type': 'join', 'roomId': roomId, 'name': name}));
  }

  void rollDice() {
    _channel?.sink.add(jsonEncode({'type': 'roll_dice'}));
  }

  void disconnect() => _channel?.sink.close();
}
