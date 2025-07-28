import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/services/KasirDashboardService.dart';
import '/models/kasirdashboardmodel.dart';
import 'package:frontend_vaporate/views/cashier/products/product_list_screen.dart';
import 'package:frontend_vaporate/views/cashier/category/category_list_screen.dart';
import 'package:frontend_vaporate/views/cashier/supplier/supplier_list_screen.dart';
import 'package:frontend_vaporate/views/cashier/transaction/transaction_list_screen.dart';
import 'package:frontend_vaporate/views/auth/login_screen.dart';


class KasirDashboardPage extends StatefulWidget {
  final String token;

  const KasirDashboardPage({Key? key, required this.token}) : super(key: key);

  @override
  State<KasirDashboardPage> createState() => _KasirDashboardPageState();
}

class _KasirDashboardPageState extends State<KasirDashboardPage> {
  late KasirDashboardService service;
  KasirDashboardModel? dashboard;
  bool isLoading = true;

  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  @override
  void initState() {
    super.initState();
    service = KasirDashboardService(widget.token);
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final result = await service.fetchDashboard();
      setState(() {
        dashboard = result;
        isLoading = false;
      });
    } catch (e) {
      print('API Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<FlSpot> generateChartData(Map<String, int> grafik) {
    return List.generate(months.length, (index) {
      final key = months[index];
      final value = grafik[key] ?? 0;
      return FlSpot(index.toDouble(), value.toDouble());
    });
  }

  double getMaxY() {
    if (dashboard == null || dashboard!.grafikTransaksi.isEmpty) return 10;
    return dashboard!.grafikTransaksi.values
            .reduce((a, b) => a > b ? a : b)
            .toDouble() +
        5;
  }

  @override
  Widget build(BuildContext context) {
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
          'Dashboard Kasir',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 1.2,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => LoginScreen()),
    (route) => false,
  );
},

          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeGradient),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF795548)))
            : dashboard == null
                ? const Center(child: Text('Gagal memuat data', style: TextStyle(color: Colors.white)))
                : SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      children: [
                        Row(
                          children: [
                            _infoCard(
                              icon: Icons.inventory_2,
                              title: 'Total Produk',
                              value: dashboard!.totalProduk.toString(),
                              color: const Color(0xFF8D6E63),
                            ),
                            const SizedBox(width: 16),
                            _infoCard(
                              icon: Icons.local_shipping,
                              title: 'Total Supplier',
                              value: dashboard!.totalSupplier.toString(),
                              color: const Color(0xFF4E342E),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Grafik Transaksi (Bulanan)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AspectRatio(
                                aspectRatio: 1.8,
                                child: dashboard!.grafikTransaksi.isEmpty
                                    ? const Center(child: Text('Tidak ada data grafik', style: TextStyle(color: Colors.white70)))
                                    : LineChart(
                                        LineChartData(
                                          minX: 0,
                                          maxX: 11,
                                          minY: 0,
                                          maxY: getMaxY(),
                                          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1)),
                                          borderData: FlBorderData(show: false),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: true,
                                                  interval: (getMaxY() / 5).toDouble(),
                                                  getTitlesWidget: (value, _) {
                                                    return Text(
                                                      value.toInt().toString(),
                                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                                    );
                                                  }),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: 1,
                                                getTitlesWidget: (value, _) {
                                                  int index = value.toInt();
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    child: Text(
                                                      index >= 0 && index < months.length ? months[index].substring(0, 3) : '',
                                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: generateChartData(dashboard!.grafikTransaksi),
                                              isCurved: true,
                                              barWidth: 3,
                                              color: const Color(0xFF795548),
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter: (spot, percent, barData, index) {
                                                  return FlDotCirclePainter(
                                                    radius: 4,
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                    strokeColor: const Color(0xFF795548),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildButtonGrid(),
                        const SizedBox(height: 28),
                        const Text('Transaksi Terbaru',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Montserrat', fontSize: 16)),
                        const SizedBox(height: 10),
                        ...dashboard!.transaksiTerbaru.map((transaksi) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF795548),
                                child: const Icon(Icons.receipt_long, color: Colors.white),
                              ),
                              title: Text(transaksi.kode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(transaksi.tanggal, style: const TextStyle(color: Colors.white70)),
                              trailing: Text('Rp ${transaksi.total}', style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Column(
      children: [
        Row(
          children: [
            _navButton(Icons.inventory_2, 'Kelola Produk', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProductListScreen(token: widget.token)));
            }, color: const Color(0xFF8D6E63)),
            const SizedBox(width: 16),
            _navButton(Icons.category, 'Kelola Kategori', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CategoryListScreen(token: widget.token)));
            }, color: const Color(0xFFD7CCC8)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _navButton(Icons.local_shipping, 'Kelola Supplier', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SupplierListScreen(token: widget.token)));
            }, color: const Color(0xFF4E342E)),
            const SizedBox(width: 16),
            _navButton(Icons.point_of_sale, 'Transaksi', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TransactionListScreen(token: widget.token)));
            }, color: const Color(0xFFFFD54F)),
          ],
        ),
      ],
    );
  }

  Widget _navButton(IconData icon, String label, VoidCallback onPressed, {required Color color}) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String value, required Color color}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.13),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.85),
              radius: 22,
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Montserrat', fontSize: 14)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Montserrat')),
          ],
        ),
      ),
    );
  }
}
