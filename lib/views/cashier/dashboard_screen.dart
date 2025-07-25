import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/services/KasirDashboardService.dart';
import '/models/kasirdashboardmodel.dart';
import 'package:frontend_vaporate/views/cashier/products/product_list_screen.dart';
import 'package:frontend_vaporate/views/cashier/category/category_list_screen.dart';
import 'package:frontend_vaporate/views/cashier/supplier/supplier_list_screen.dart';
import 'package:frontend_vaporate/views/cashier/transaction/transaction_list_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kasir'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboard == null
              ? const Center(child: Text('Gagal memuat data'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Row(
                        children: [
                          _infoCard('Total Produk',
                              dashboard!.totalProduk.toString()),
                          const SizedBox(width: 16),
                          _infoCard('Total Supplier',
                              dashboard!.totalSupplier.toString()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Grafik Transaksi (Bulanan)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1.8,
                        child: dashboard!.grafikTransaksi.isEmpty
                            ? const Center(child: Text('Tidak ada data grafik'))
                            : LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: 11,
                                  minY: 0,
                                  maxY: getMaxY(),
                                  gridData: FlGridData(show: true),
                                  borderData: FlBorderData(show: true),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: (getMaxY() / 5).toDouble(),
                                          getTitlesWidget: (value, _) {
                                            return Text(
                                                value.toInt().toString());
                                          }),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (value, _) {
                                          int index = value.toInt();
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(index >= 0 &&
                                                    index < months.length
                                                ? months[index].substring(0, 3)
                                                : ''),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: generateChartData(
                                          dashboard!.grafikTransaksi),
                                      isCurved: true,
                                      barWidth: 3,
                                      color: Colors.blue,
                                      dotData: FlDotData(show: true),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      _buildButtonGrid(),
                      const SizedBox(height: 24),
                      const Text('Transaksi Terbaru',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...dashboard!.transaksiTerbaru.map((transaksi) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(transaksi.kode),
                            subtitle: Text(transaksi.tanggal),
                            trailing: Text('Rp ${transaksi.total}'),
                          ),
                        );
                      }).toList(),
                    ],
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
            }),
            const SizedBox(width: 16),
            _navButton(Icons.category, 'Kelola Kategori', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CategoryListScreen(token: widget.token)));
            }),
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
            }),
            const SizedBox(width: 16),
            _navButton(Icons.point_of_sale, 'Transaksi', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          TransactionListScreen(token: widget.token)));
            }),
          ],
        ),
      ],
    );
  }

  Widget _navButton(IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
