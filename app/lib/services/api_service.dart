import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Render URL (HTTPS, not WSS for REST API)
  static const String baseUrl = 'https://ludo-od5h.onrender.com';

  // Login or create user
  static Future<Map<String, dynamic>?> login(String playerId, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'playerId': playerId, 'name': name}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }

  // Update user stats after a match
  static Future<Map<String, dynamic>?> updateStats(String playerId, bool isWin, int coinsEarned) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'playerId': playerId, 'isWin': isWin, 'coinsEarned': coinsEarned}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }
}
