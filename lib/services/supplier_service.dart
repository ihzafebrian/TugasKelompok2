import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supplier_model.dart';

class SupplierService {
  final String token;
  final String baseUrl = 'http://192.168.1.6:8000/api/suppliers';

  SupplierService(this.token);

  Future<List<SupplierModel>> fetchSuppliers() async {
    final res = await http.get(Uri.parse(baseUrl), headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((json) => SupplierModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data supplier');
    }
  }

  Future<void> createSupplier(Map<String, String> body) async {
    final res = await http.post(Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: body);

    if (res.statusCode != 201) {
      throw Exception('Gagal membuat supplier');
    }
  }

  Future<void> updateSupplier(int id, Map<String, String> body) async {
    final res = await http.put(Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: body);

    if (res.statusCode != 200) {
      throw Exception('Gagal memperbarui supplier');
    }
  }

  Future<void> deleteSupplier(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'), headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 200) {
      throw Exception('Gagal menghapus supplier');
    }
  }
}
