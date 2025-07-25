import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/transaction_model.dart';
import '../../../services/transaction_service.dart';

class PaymentScreen extends StatefulWidget {
  final TransactionModel transaction;
  final List<Map<String, dynamic>> items;
  final String token;

  const PaymentScreen({
    super.key,
    required this.transaction,
    required this.items,
    required this.token,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  late TransactionService service;

  final Map<String, String> bankMap = {
    'BCA': '014',
    'BNI': '009',
    'BRI': '002',
    'Mandiri': '008',
    'CIMB Niaga': '022',
    'Permata Bank': '013',
  };

  final Map<String, String> walletMap = {
    'GoPay': '89808',
    'OVO': '80908',
    'DANA': '852808',
    'ShopeePay': '89308',
    'LinkAja': '91108',
  };

  String? selectedChannelName;
  String? selectedChannelCode;

  @override
  void initState() {
    super.initState();
    service = TransactionService(widget.token);
  }

  String generateVaNumber() {
    final code = selectedChannelCode ?? '000';
    final trxId = widget.transaction.id.toString().padLeft(10, '0');
    return '$code$trxId';
  }

  Future<void> handlePayment() async {
    if (selectedChannelName == null || selectedChannelCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final success = await service.updatePaymentStatus(
        widget.transaction.id,
        'paid',
        method: widget.transaction.paymentMethod,
        channelName: selectedChannelName!,
        channelCode: selectedChannelCode!,
      );

      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Pembayaran Berhasil'),
            content: Text(
              'Transaksi telah dibayar melalui $selectedChannelName.\n\n'
              'VA: ${generateVaNumber()}\n'
              'Total: ${currency.format(widget.transaction.totalPrice)}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan pembayaran'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error saat update status pembayaran: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trx = widget.transaction;

    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaksi #${trx.transactionCode}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tanggal: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(trx.transactionDate)}'),
                  Text('Metode: ${trx.paymentMethod}'),
                ],
              ),
              SizedBox(height: 8),
              Divider(),

              Text('Detail Barang', style: TextStyle(fontWeight: FontWeight.bold)),
              ...widget.items.map((item) => ListTile(
                    dense: true,
                    title: Text('${item['product_name']} x ${item['quantity']}'),
                    trailing: Text(currency.format(item['subtotal'])),
                  )),
              Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(currency.format(trx.totalPrice), style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 24),

              Text(
                trx.paymentMethod == 'ewallet'
                    ? 'Pilih E-Wallet'
                    : 'Pilih Bank Virtual Account',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: selectedChannelName,
                items: (trx.paymentMethod == 'ewallet' ? walletMap : bankMap)
                    .entries
                    .map(
                      (entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.key),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedChannelName = value;
                    selectedChannelCode = (trx.paymentMethod == 'ewallet'
                        ? walletMap[value]
                        : bankMap[value]);
                  });
                },
                decoration: InputDecoration(
                  hintText: trx.paymentMethod == 'ewallet'
                      ? '-- Pilih E-Wallet --'
                      : '-- Pilih Bank --',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),

              if (selectedChannelCode != null)
                Column(
                  children: [
                    Center(
                      child: QrImageView(
                        data: '''
VA: ${generateVaNumber()}
Total: ${currency.format(trx.totalPrice)}
Metode: ${trx.paymentMethod.toUpperCase()}
''',
                        size: 200,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Scan QR untuk info pembayaran'),
                  ],
                ),

              SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: handlePayment,
                  icon: Icon(Icons.check_circle),
                  label: Text('Selesaikan Pembayaran'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
