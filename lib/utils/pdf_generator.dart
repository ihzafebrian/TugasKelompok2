import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<pw.Document> generateReceiptPDF({
  required String storeName,
  required String transactionCode,
  required DateTime transactionDate,
  required List<Map<String, dynamic>> items,
  required double totalPrice,
  required String paymentMethod,
  required String paymentChannel,
  required bool isPaid,
}) async {
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(storeName,
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Divider(),
              pw.Text('Kode Transaksi: $transactionCode'),
              pw.Text('Tanggal: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(transactionDate)}'),
              pw.SizedBox(height: 10),
              pw.Text('Daftar Belanja:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              ...items.map((item) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text('${item['product_name']} x ${item['quantity']}'),
                    ),
                    pw.Text(currency.format(item['subtotal'])),
                  ],
                );
              }).toList(),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(currency.format(totalPrice),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text('Metode Pembayaran: ${paymentMethod.toUpperCase()}'),
              pw.Text('Channel: $paymentChannel'),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  isPaid ? 'LUNAS' : 'BELUM LUNAS',
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: isPaid ? PdfColors.green : PdfColors.red,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        );
      },
    ),
  );

  return pdf;
}
