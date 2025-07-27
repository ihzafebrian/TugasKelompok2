import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/laporan_service.dart';
import '../../utils/app_theme.dart';

class LaporanBulananScreen extends StatefulWidget {
  const LaporanBulananScreen({super.key});

  @override
  State<LaporanBulananScreen> createState() => _LaporanBulananScreenState();
}

class _LaporanBulananScreenState extends State<LaporanBulananScreen> {
  final laporanService = LaporanService();
  late Future<List<dynamic>> _data;
  List<dynamic> _laporanData = [];

  @override
  void initState() {
    super.initState();
    _data = laporanService.getLaporanBulanan();
    _data.then((value) => _laporanData = value);
  }

  Future<void> _cetakPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'Vaporate Store',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            // pw.Center(
            //   child: pw.Text(
            //     'Jl. Contoh Alamat No. 123, Padang\nHP: 081234567890',
            //     textAlign: pw.TextAlign.center,
            //     style: pw.TextStyle(fontSize: 12),
            //   ),
            // ),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'Laporan Penjualan Bulanan',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Bulan', 'Total Penjualan', 'Total Transaksi'],
              data: _laporanData
                  .map((item) => [
                        item['date'],
                        'Rp ${item['total_sales']}',
                        '${item['total_transactions']} transaksi'
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellHeight: 25,
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppTheme.themedAppBar('Laporan Bulanan', actions: [
        IconButton(
          icon: const Icon(Icons.print, color: Colors.white),
          onPressed: () {
            if (_laporanData.isNotEmpty) {
              _cetakPDF();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data belum tersedia untuk dicetak')),
              );
            }
          },
        ),
      ]),
      body: Container(
        decoration: AppTheme.mainBackground(),
        child: FutureBuilder<List<dynamic>>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: snapshot.data!.map((item) {
                  return Card(
                    color: Colors.white.withOpacity(0.13),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Text('Bulan: ${item['date']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('Total: Rp ${item['total_sales']}', style: const TextStyle(color: Colors.white70)),
                      trailing: Text('${item['total_transactions']} transaksi', style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }).toList(),
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Gagal memuat data', style: TextStyle(color: Colors.white)));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
