import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/transaction_model.dart';
import '../../../services/transaction_service.dart';
import 'transaction_form_screen.dart';
import 'payment_screen.dart';
import 'receipt_screen.dart';
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
  Map<String, List<TransactionModel>> groupedTransactions = {};
  bool isLoading = true;
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  void initState() {
    super.initState();
    service = TransactionService(widget.token);
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final data = await service.fetchTransactions();
      data.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      setState(() {
        transactions = data;
        groupedTransactions = groupByDate(data);
        isLoading = false;
      });
    } catch (e) {
      print('Gagal memuat transaksi: $e');
      setState(() => isLoading = false);
    }
  }

  Map<String, List<TransactionModel>> groupByDate(List<TransactionModel> list) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (var trx in list) {
      final dateKey = DateFormat('yyyy-MM-dd').format(trx.transactionDate);
      grouped.putIfAbsent(dateKey, () => []).add(trx);
    }
    return grouped;
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
    final themeGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF8D6E63),
        Color(0xFF4E342E),
        Color(0xFFD7CCC8),
      ],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Daftar Transaksi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeGradient),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF795548)))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  children: groupedTransactions.entries.map((entry) {
                    final date = entry.key;
                    final dateFormatted = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.parse(date));
                    final trxList = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            dateFormatted,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        ...trxList.map((trx) {
                          final itemList = mapTransactionDetails(trx.details);
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              title: Text(
                                trx.transactionCode,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${currency.format(trx.totalPrice)} • ${trx.paymentMethod}',
                                      style: const TextStyle(color: Colors.white70, fontFamily: 'Montserrat')),
                                  Text('Status: ${trx.paymentStatus}', style: const TextStyle(color: Colors.white54, fontFamily: 'Montserrat')),
                                ],
                              ),
                              trailing: _buildTrailingButton(trx, itemList),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF795548),
        child: const Icon(Icons.add, color: Colors.white),
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

  Widget _buildTrailingButton(TransactionModel trx, List<Map<String, dynamic>> itemList) {
    if (trx.paymentStatus.toLowerCase() == 'pending') {
      return Row(
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
              ).then((_) => fetchTransactions());
            },
            icon: const Icon(Icons.payment, color: Colors.white),
            label: const Text('Bayar', style: TextStyle(fontFamily: 'Montserrat')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
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
                    isPaid: false,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            label: const Text('Struk', style: TextStyle(fontFamily: 'Montserrat')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      );
    } else {
      return ElevatedButton.icon(
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
                isPaid: true,
              ),
            ),
          );
        },
        icon: const Icon(Icons.receipt, color: Colors.white),
        label: const Text('Struk', style: TextStyle(fontFamily: 'Montserrat')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }
  }
}
