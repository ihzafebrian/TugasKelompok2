import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'laporan_menu_screen.dart'; // pastikan file ini ada
import '../auth/login_screen.dart'; // arahkan ke halaman login setelah logout
import '../../utils/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userRole = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  Future<void> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? '';
      isLoading = false;
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data dari SharedPreferences

    // Arahkan ke halaman login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil keluar')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppTheme.themedAppBar('Dashboard'),
      body: Container(
        decoration: AppTheme.mainBackground(),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  if (userRole == 'pemilik') ...[
                    ListTile(
                      leading: const Icon(Icons.bar_chart, color: Colors.white),
                      title: const Text('📊 Laporan Pemilik', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LaporanMenuScreen()),
                        );
                      },
                    ),
                  ],
                  if (userRole == 'kasir') ...[
                    ListTile(
                      leading: const Icon(Icons.point_of_sale, color: Colors.white),
                      title: const Text('💰 Transaksi Kasir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onTap: () {
                        // TODO: arahkan ke halaman kasir
                      },
                    ),
                  ],
                  const Divider(color: Colors.white70),
                  // Tombol Logout
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: logout,
                  ),
                ],
              ),
      ),
    );
  }
}
