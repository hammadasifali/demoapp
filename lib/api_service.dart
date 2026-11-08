import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // TODO: replace with your backend URL
  static const String baseUrl = 'https://your-api.com/api';

  static Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString('token');

  static Future<void> logout() async =>
      (await SharedPreferences.getInstance()).remove('token');

  /// Returns null on success, or an error message.
  static Future<String?> login(String email, String password) =>
      _auth('/login', {'email': email, 'password': password});

  static Future<String?> signup(String name, String email, String password) =>
      _auth('/signup', {'name': name, 'email': email, 'password': password});

  static Future<String?> _auth(String path, Map<String, String> body) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl$path'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token'] ?? '');
        return null;
      }
      return data['message']?.toString() ?? 'Request failed (${res.statusCode})';
    } catch (e) {
      return 'Network error: $e';
    }
  }
}
