import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Jwt {
  Jwt();

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static Future<Map<String, dynamic>?> decodeToken(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw FormatException('Invalid token');
      }

      final payload = parts[1];
      final String normalized = base64Url.normalize(payload);
      final Map<String, dynamic> decoded =
          jsonDecode(utf8.decode(base64Url.decode(normalized)));

      return decoded;
    } catch (error) {
      print('Error decoding token: $error');
      return null;
    }
  }
}
