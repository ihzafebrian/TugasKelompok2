import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../models/product_model.dart';
import 'api_base.dart';

class ProductService {
  final String token;
  ProductService(this.token);

  Future<List<ProductModel>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }

  Future<void> createProduct(ProductModel product, {File? imageFile}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products'));
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['product_name'] = product.productName;
    request.fields['category_id'] = product.categoryId.toString();
    request.fields['supplier_id'] = product.supplierId.toString();
    request.fields['price'] = product.price.toString();
    request.fields['stock'] = product.stock.toString();

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception('Gagal menambah produk: ${response.body}');
    }
  }

  Future<void> updateProduct(ProductModel product, {File? imageFile}) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/products/${product.id}?_method=PUT'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['product_name'] = product.productName;
    request.fields['category_id'] = product.categoryId.toString();
    request.fields['supplier_id'] = product.supplierId.toString();
    request.fields['price'] = product.price.toString();
    request.fields['stock'] = product.stock.toString();

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengupdate produk: ${response.body}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus produk');
    }
  }

  Future<List<ProductModel>> fetchProductsByCategory(int categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products?category_id=$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat produk berdasarkan kategori');
    }
  }
}
