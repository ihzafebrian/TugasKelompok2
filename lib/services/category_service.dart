import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class CategoryService {
  final String token;
  final String baseUrl = 'http://192.168.43.252:8000/api'; // Ganti jika URL berbeda

  CategoryService(this.token);

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<List<CategoryModel>> fetchCategories() async {
  final response = await http.get(Uri.parse('$baseUrl/categories'), headers: headers);
  if (response.statusCode == 200) {
    final jsonBody = json.decode(response.body);
    final List<dynamic> data = jsonBody['data'];

    return data.map((e) => CategoryModel.fromJson(e)).toList();
  } else {
    throw Exception('Gagal mengambil kategori');
  }
}


  Future<void> createCategory(CategoryModel category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
      body: json.encode({
        'category_name': category.categoryName,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Gagal menambah kategori');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/${category.id}'),
      headers: headers,
      body: json.encode({
        'category_name': category.categoryName,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal mengedit kategori');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus kategori');
    }
  }
}