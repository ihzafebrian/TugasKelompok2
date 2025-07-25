import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../services/laporan_service.dart';

class LaporanHarianScreen extends StatefulWidget {
  const LaporanHarianScreen({super.key});

  @override
  State<LaporanHarianScreen> createState() => _LaporanHarianScreenState();
}

class _LaporanHarianScreenState extends State<LaporanHarianScreen> {
  final laporanService = LaporanService();
  late Future<List<dynamic>> _data;

  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _data = laporanService.getLaporanHarian();
  }

  void _cetakPDF(List<dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            // Header seperti gambar: Vaporate Store + garis
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'Vaporate Store',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 16),
                ],
              ),
            ),

            pw.Text(
              'Laporan Harian',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),

            pw.Table.fromTextArray(
              headers: ['Tanggal', 'Total Penjualan', 'Jumlah Transaksi'],
              data: data.map((item) {
                final tanggal = item['date'] ?? '-';
                final total = currencyFormatter.format(
                    double.tryParse(item['total_sales'].toString()) ?? 0);
                final transaksi = item['total_transactions'].toString();
                return [tanggal, total, transaksi];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Harian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final data = await _data;
              if (data.isNotEmpty) {
                _cetakPDF(data);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Data kosong, tidak bisa mencetak')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error saat memuat data: ${snapshot.error}');
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data laporan.'));
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              final tanggal = item['date'] ?? 'Tanggal tidak tersedia';
              final totalSales =
                  double.tryParse(item['total_sales'].toString()) ?? 0;
              final totalTransaksi = item['total_transactions'] ?? 0;

              return ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('Tanggal: $tanggal'),
                subtitle:
                    Text('Total: ${currencyFormatter.format(totalSales)}'),
                trailing: Text('$totalTransaksi transaksi'),
              );
            },
          );
        },
      ),
    );
  }
}
