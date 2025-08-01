import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/laporan_service.dart';
import '../../utils/app_theme.dart';

class LaporanTahunanScreen extends StatefulWidget {
  const LaporanTahunanScreen({super.key});

  @override
  State<LaporanTahunanScreen> createState() => _LaporanTahunanScreenState();
}

class _LaporanTahunanScreenState extends State<LaporanTahunanScreen> {
  final laporanService = LaporanService();
  late Future<List<dynamic>> _data;
  List<dynamic> _laporanData = [];

  @override
  void initState() {
    super.initState();
    _data = laporanService.getLaporanTahunan();
    _data.then((value) => _laporanData = value);
  }

  Future<void> _cetakPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Header Toko
            pw.Center(
              child: pw.Text(
                'Vaporate Store',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 12),

            // Judul Laporan
            pw.Center(
              child: pw.Text(
                'Laporan Penjualan Tahunan',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 16),

            // Tabel Data
            pw.Table.fromTextArray(
              headers: ['Tahun', 'Total Penjualan', 'Total Transaksi'],
              data: _laporanData.map((item) {
                return [
                  item['date'].toString(),
                  'Rp ${item['total_sales']}',
                  '${item['total_transactions']} transaksi'
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(3),
              },
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
      appBar: AppTheme.themedAppBar('Laporan Tahunan', actions: [
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
                      title: Text('Tahun: ${item['date']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
