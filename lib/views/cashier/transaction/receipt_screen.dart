import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../utils/pdf_generator.dart';

class ReceiptScreen extends StatelessWidget {
  final String storeName;
  final String transactionCode;
  final DateTime transactionDate;
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final String paymentMethod;
  final String paymentChannel;
  final bool isPaid;

  const ReceiptScreen({
    super.key,
    required this.storeName,
    required this.transactionCode,
    required this.transactionDate,
    required this.items,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentChannel,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final themeGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF8D6E63), // coklat muda
        Color(0xFF4E342E), // coklat tua
        Color(0xFFD7CCC8), // cream
      ],
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Struk Belanja',
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
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        storeName,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Montserrat'),
                      ),
                    ),
                    const Divider(thickness: 1, color: Colors.white24),
                    const SizedBox(height: 4),
                    Text('Kode Transaksi: $transactionCode', style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat')),
                    Text('Tanggal: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(transactionDate)}', style: const TextStyle(color: Colors.white70, fontFamily: 'Montserrat')),
                    const Divider(thickness: 1, color: Colors.white24),
                    const Text('Daftar Belanja:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Montserrat')),
                    const SizedBox(height: 4),
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(
                                      '${item['product_name']} x ${item['quantity']}', style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'))),
                              Text(currency.format(item['subtotal']), style: const TextStyle(color: Color(0xFFFFD54F), fontFamily: 'Montserrat')),
                            ],
                          ),
                        )),
                    const Divider(thickness: 1, color: Colors.white24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Montserrat')),
                        Text(currency.format(totalPrice),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD54F), fontFamily: 'Montserrat')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Metode Pembayaran: ${paymentMethod.toUpperCase()}', style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat')),
                    Text('Channel: $paymentChannel', style: const TextStyle(color: Colors.white70, fontFamily: 'Montserrat')),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        isPaid ? 'LUNAS' : 'BELUM LUNAS',
                        style: TextStyle(
                          fontSize: 20,
                          color: isPaid ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Cetak PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF795548),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            textStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            final pdf = await generateReceiptPDF(
                              storeName: storeName,
                              transactionCode: transactionCode,
                              transactionDate: transactionDate,
                              items: items,
                              totalPrice: totalPrice,
                              paymentMethod: paymentMethod,
                              paymentChannel: paymentChannel,
                              isPaid: isPaid,
                            );

                            await Printing.layoutPdf(
                              onLayout: (format) async => pdf.save(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
