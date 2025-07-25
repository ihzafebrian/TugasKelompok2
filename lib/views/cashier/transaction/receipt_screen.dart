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

    return Scaffold(
      appBar: AppBar(title: const Text('Struk Belanja')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      storeName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(thickness: 1),
                  const SizedBox(height: 4),
                  Text('Kode Transaksi: $transactionCode'),
                  Text('Tanggal: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(transactionDate)}'),
                  const Divider(thickness: 1),
                  const Text('Daftar Belanja:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                                    '${item['product_name']} x ${item['quantity']}')),
                            Text(currency.format(item['subtotal'])),
                          ],
                        ),
                      )),
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(currency.format(totalPrice),
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Metode Pembayaran: ${paymentMethod.toUpperCase()}'),
                  Text('Channel: $paymentChannel'),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      isPaid ? 'LUNAS' : 'BELUM LUNAS',
                      style: TextStyle(
                        fontSize: 20,
                        color: isPaid ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Cetak PDF'),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
