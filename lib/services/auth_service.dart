// auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = "https://cfdptest-auth.tejasbalkhande221.workers.dev";

  static String generateUserId() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  static Future<bool> createAccount(String email, String password, String username) async {
    final userId = generateUserId();
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/signup"),
        body: jsonEncode({
          'userId': userId,
          'email': email,
          'password': password,
          'username': username,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Account creation failed';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Failed to create account: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/login"),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Login failed';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Failed to login: ${e.toString()}');
    }
  }
}