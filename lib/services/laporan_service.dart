import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LaporanService {
  final String baseUrl = 'http://192.168.43.252:8000/api'; // Ganti IP sesuai server backend kamu

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> getLaporanHarian() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/pemilik/laporan-harian');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    print('🔍 [LaporanHarian] Memanggil: $url');
    print('🔐 Token: $token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📥 [LaporanHarian] Status Code: ${response.statusCode}');
      print('📄 [LaporanHarian] Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          return jsonData['data'];
        } else {
          throw Exception('Format data tidak valid: ${jsonData.toString()}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ [LaporanHarian] Terjadi error: $e');
      throw Exception('Gagal memuat laporan harian: $e');
    }
  }

  Future<List<dynamic>> getLaporanBulanan() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/pemilik/laporan-bulanan');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    print('🔍 [LaporanBulanan] Memanggil: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📥 [LaporanBulanan] Status Code: ${response.statusCode}');
      print('📄 [LaporanBulanan] Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          return jsonData['data'];
        } else {
          throw Exception('Format data tidak valid: ${jsonData.toString()}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ [LaporanBulanan] Terjadi error: $e');
      throw Exception('Gagal memuat laporan bulanan: $e');
    }
  }

  Future<List<dynamic>> getLaporanTahunan() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/pemilik/laporan-tahunan');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    print('🔍 [LaporanTahunan] Memanggil: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📥 [LaporanTahunan] Status Code: ${response.statusCode}');
      print('📄 [LaporanTahunan] Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          return jsonData['data'];
        } else {
          throw Exception('Format data tidak valid: ${jsonData.toString()}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ [LaporanTahunan] Terjadi error: $e');
      throw Exception('Gagal memuat laporan tahunan: $e');
    }
  }
}
