import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthViewModel with ChangeNotifier {
  UserModel? user;
  String? token; // ⬅️ Tambahkan token
  bool isLoading = false;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final response = await ApiService.post('/login', {
      'email': email,
      'password': password,
    });

    isLoading = false;

    if (response != null && response['user'] != null && response['token'] != null) {
      user = UserModel.fromJson(response['user']);
      token = response['token']; // ⬅️ Simpan token
      notifyListeners();
      return true;
    }
    return false;
  }
}
