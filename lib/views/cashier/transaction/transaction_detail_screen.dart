import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction_model.dart';
import '../../../services/transaction_service.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String token;
  final int transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.token,
    required this.transactionId,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late TransactionService transactionService;
  TransactionModel? transaction;
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  void initState() {
    super.initState();
    transactionService = TransactionService(widget.token);
    fetchTransaction();
  }

  Future<void> fetchTransaction() async {
    try {
      final data = await transactionService.getTransaction(widget.transactionId);
      setState(() {
        transaction = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Detail Transaksi')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Detail Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode: ${transaction!.transactionCode}', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction!.transactionDate)}'),
            Text('Kasir: ${transaction!.user?.name ?? "-"}'),
            Text('Metode: ${transaction!.paymentMethod}'),
            Text('Status Pembayaran: ${transaction!.paymentStatus}'),
            Text('Status Cetak: ${transaction!.printStatus == 1 ? 'Sudah' : 'Belum'}'),
            Divider(),
            Text('Produk:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: transaction!.details.length,
                itemBuilder: (context, index) {
                  final detail = transaction!.details[index];
                  return ListTile(
                    title: Text(detail.productName),
                    subtitle: Text('Qty: ${detail.quantity} × ${currency.format(detail.price)}'),
                    trailing: Text(currency.format(detail.subtotal)),
                  );
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Total'),
              trailing: Text(currency.format(transaction!.totalPrice),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
