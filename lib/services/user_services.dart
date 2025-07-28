import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserService {
  final String baseUrl = 'http://192.168.1.89:8000/api';

  // GET all users
  Future<List<UserModel>> getUsers(String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/users'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    try {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      print('Parsing error: $e');
      throw Exception('Failed to parse user list');
    }
  } else {
    print('Fetch failed: ${response.statusCode}');
    print('Body: ${response.body}');
    throw Exception('Failed to load users');
  }
}


  // CREATE user
  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('Token not found');

    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      },
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Create user failed: ${response.body}');
      return false;
    }
  }

  // UPDATE user
  Future<bool> updateUser({
    required int id,
    required String name,
    required String email,
    required String role,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('Token not found');

    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'name': name,
        'email': email,
        'role': role,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Update user failed: ${response.body}');
      return false;
    }
  }

  // DELETE user
  Future<bool> deleteUser(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('Token not found');

    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Delete user failed: ${response.body}');
      return false;
    }
  }
}
