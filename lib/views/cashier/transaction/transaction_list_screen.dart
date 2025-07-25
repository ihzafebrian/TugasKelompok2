import 'package:flutter/material.dart';
import '../../../models/transaction_model.dart';
import '../../../services/transaction_service.dart';
import 'transaction_form_screen.dart';
import 'payment_screen.dart';
import 'receipt_screen.dart'; // ✅ Import halaman struk
import '../../../models/transaction_detail_model.dart';

class TransactionListScreen extends StatefulWidget {
  final String token;

  const TransactionListScreen({super.key, required this.token});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late TransactionService service;
  List<TransactionModel> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    service = TransactionService(widget.token);
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final data = await service.fetchTransactions();
      setState(() {
        transactions = data;
        isLoading = false;
      });
    } catch (e) {
      print('Gagal memuat transaksi: $e');
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> mapTransactionDetails(List<TransactionDetailModel> details) {
    return details.map((d) => {
      'product_name': d.productName,
      'quantity': d.quantity,
      'subtotal': d.subtotal,
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Transaksi'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final trx = transactions[index];
                final itemList = mapTransactionDetails(trx.details);

                return Card(
                  child: ListTile(
                    title: Text(trx.transactionCode),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rp ${trx.totalPrice} • ${trx.paymentMethod}'),
                        Text('Status: ${trx.paymentStatus}'),
                      ],
                    ),
                    trailing: trx.paymentStatus.toLowerCase() == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentScreen(
                                        transaction: trx,
                                        items: itemList,
                                        token: widget.token,
                                      ),
                                    ),
                                  ).then((value) {
                                    fetchTransactions(); // Refresh setelah bayar
                                  });
                                },
                                icon: Icon(Icons.payment),
                                label: Text('Bayar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReceiptScreen(
                                        storeName: 'Vaporate Store',
                                        transactionCode: trx.transactionCode,
                                        transactionDate: trx.transactionDate,
                                        items: itemList,
                                        totalPrice: trx.totalPrice,
                                        paymentMethod: trx.paymentMethod,
                                        paymentChannel: trx.paymentChannel ?? '-',
                                        isPaid: trx.paymentStatus.toLowerCase() == 'paid',
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.receipt_long),
                                label: Text('Struk'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                            ],
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReceiptScreen(
                                    storeName: 'Vaporate Store',
                                    transactionCode: trx.transactionCode,
                                    transactionDate: trx.transactionDate,
                                    items: itemList,
                                    totalPrice: trx.totalPrice,
                                    paymentMethod: trx.paymentMethod,
                                    paymentChannel: trx.paymentChannel ?? '-',
                                    isPaid: trx.paymentStatus.toLowerCase() == 'paid',
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.receipt),
                            label: Text('Struk'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                            ),
                          ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final success = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionFormScreen(token: widget.token),
            ),
          );
          if (success == true) {
            fetchTransactions();
          }
        },
      ),
    );
  }
}
