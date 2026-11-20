import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://ludo-od5h.onrender.com';

  static Future<Map<String, dynamic>?> login(String playerId, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'playerId': playerId, 'name': name}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      print("API login error: $e");
    }
    return null;
  }
}
