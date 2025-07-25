import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class ApiService {
  // POST method (sudah ada)
  static Future<Map<String, dynamic>?> post(String endpoint, Map data) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('POST ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }

  // ✅ Tambahkan GET method di bawah ini:
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('GET ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET API Error: $e');
      return null;
    }
  }
}
