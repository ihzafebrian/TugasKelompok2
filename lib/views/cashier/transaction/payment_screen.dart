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
        const SnackBar(
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
            title: const Text('Pembayaran Berhasil'),
            content: Text(
              'Transaksi telah dibayar melalui $selectedChannelName.\n\n'
              'VA: ${generateVaNumber()}\n'
              'Total: ${currency.format(widget.transaction.totalPrice)}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyelesaikan pembayaran'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error saat update status pembayaran: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trx = widget.transaction;
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
          'Pembayaran Transaksi',
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final minHeight = constraints.maxHeight;
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Transaksi #${trx.transactionCode}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tanggal: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(trx.transactionDate)}',
                                style: const TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
                              ),
                              Text(
                                'Metode: ${trx.paymentMethod}',
                                style: const TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(color: Colors.white24),
                          const Text('Detail Barang', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Montserrat')),
                          ...widget.items.map((item) => ListTile(
                                dense: true,
                                title: Text('${item['product_name']} x ${item['quantity']}', style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat')),
                                trailing: Text(currency.format(item['subtotal']), style: const TextStyle(color: Color(0xFFFFD54F), fontFamily: 'Montserrat')),
                              )),
                          const Divider(color: Colors.white24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Montserrat')),
                              Text(currency.format(trx.totalPrice), style: const TextStyle(fontSize: 16, color: Color(0xFFFFD54F), fontFamily: 'Montserrat')),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            trx.paymentMethod == 'ewallet' ? 'Pilih E-Wallet' : 'Pilih Bank Virtual Account',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Montserrat'),
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedChannelName,
                            dropdownColor: const Color(0xFF4E342E),
                            style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                            items: (trx.paymentMethod == 'ewallet' ? walletMap : bankMap)
                                .entries
                                .map(
                                  (entry) => DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(entry.key, style: const TextStyle(color: Colors.white)),
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
                              hintStyle: const TextStyle(color: Colors.white54),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.07),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (selectedChannelCode != null)
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: QrImageView(
                                    data: '''
VA: ${generateVaNumber()}
Total: ${currency.format(trx.totalPrice)}
Metode: ${trx.paymentMethod.toUpperCase()}
''',
                                    size: 180,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text('Scan QR untuk info pembayaran', style: TextStyle(color: Colors.white70, fontFamily: 'Montserrat')),
                              ],
                            ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              onPressed: handlePayment,
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Selesaikan Pembayaran'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
