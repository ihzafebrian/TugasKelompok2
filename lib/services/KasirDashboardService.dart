import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/kasirdashboardmodel.dart';

class KasirDashboardService {
  final String baseUrl = 'http://192.168.43.252:8000/api';
  final String token; // <- kirim saat inisialisasi

  KasirDashboardService(this.token);

  Future<KasirDashboardModel> fetchDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/kasir-dashboard'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return KasirDashboardModel.fromJson(jsonResponse);
    } else {
      throw Exception('Gagal memuat dashboard');
    }
  }
}
