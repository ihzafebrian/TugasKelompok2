import 'user_model.dart';
import 'transaction_detail_model.dart';

class TransactionModel {
  final int id;
  final String transactionCode;
  final String paymentMethod;
  final String paymentStatus;
  final int printStatus;
  final DateTime transactionDate;
  final double totalPrice; // ✅ ubah ke double
  final UserModel? user;
  final List<TransactionDetailModel> details;

  final String? paymentChannel; // ✅ Tambahkan untuk struk belanja

  TransactionModel({
    required this.id,
    required this.transactionCode,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.printStatus,
    required this.transactionDate,
    required this.totalPrice,
    required this.details,
    this.user,
    this.paymentChannel, // ✅ Include di constructor
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      transactionCode: json['transaction_code'],
      paymentMethod: json['payment_method'] ?? '-',
      paymentStatus: json['payment_status'] ?? '-',
      printStatus: json['print_status'] ?? 0,
      transactionDate: DateTime.parse(json['transaction_date']),
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      paymentChannel: json['payment_channel'], // ✅ Ambil dari API
      details: (json['details'] as List)
          .map((e) => TransactionDetailModel.fromJson(e))
          .toList(),
    );
  }
}
