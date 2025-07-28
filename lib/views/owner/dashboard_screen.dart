import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'laporan_menu_screen.dart'; // pastikan file ini ada
import '../auth/login_screen.dart'; // arahkan ke halaman login setelah logout
import '../../utils/app_theme.dart';
import '../splash_screen.dart';
import '../../main.dart'; // ⬅️ Tambahkan ini
import '../user/user_list_screen.dart'; // Pastikan path ini benar



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
  await prefs.clear();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Berhasil keluar')),
  );

  await Future.delayed(const Duration(milliseconds: 500));

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const SplashScreenWrapper()),
    (route) => false,
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
                    ListTile(
                      leading: const Icon(Icons.person_add, color: Colors.white),
                      title: const Text(
                        '➕ Tambah User',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserListScreen()),
                        );
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
