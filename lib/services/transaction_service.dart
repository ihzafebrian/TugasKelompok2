import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import '../models/transaction_detail_model.dart';

class TransactionService {
  final String token;
  final String baseUrl = 'http://192.168.43.252:8000/api';

  TransactionService(this.token);

  Future<List<TransactionModel>> fetchTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      List jsonData = jsonResponse['data'];
      return jsonData
          .map<TransactionModel>((e) => TransactionModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Gagal memuat transaksi');
    }
  }

  Future<TransactionModel> getTransaction(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return TransactionModel.fromJson(jsonData['data']);
    } else {
      throw Exception('Gagal mengambil detail transaksi');
    }
  }

  Future<int> createTransaction(Map<String, String> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: data,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return jsonData['data']['id'];
    } else {
      print('Response: ${response.body}');
      throw Exception('Gagal membuat transaksi');
    }
  }

  Future<void> addTransactionDetail(Map<String, String> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transaction-details'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: data,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Response: ${response.body}');
      throw Exception('Gagal menambahkan detail transaksi');
    }
  }

  Future<void> createTransactionWithDetails(
    List<TransactionDetailModel> items, {
    required int supplierId,
    required String image,
  }) async {
    final transactionId = await createTransaction({
      'total_price':
          items.fold(0.0, (sum, item) => sum + item.subtotal).toString(),
      'supplier_id': supplierId.toString(),
      'image': image,
    });

    for (var item in items) {
      await addTransactionDetail({
        'transaction_id': transactionId.toString(),
        'product_id': item.productId.toString(),
        'quantity': item.quantity.toString(),
        'price': item.price.toString(),
        'subtotal': item.subtotal.toString(),
      });
    }
  }

  Future<void> payTransaction(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/$id/pay'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: data,
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memproses pembayaran');
    }
  }

  /// ✅ Versi lengkap update status + metode + channel
  Future<bool> updatePaymentStatus(
  int id,
  String status, {
  required String method,
  required String channelName,
  required String channelCode,
}) async {
  final url = Uri.parse('$baseUrl/transactions/$id');
  final response = await http.put(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'payment_status': status,
      'payment_method': method,
      'payment_channel': channelName,
      'channel_code': channelCode,
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print('Gagal update status: ${response.body}');
    return false;
  }
}

}
