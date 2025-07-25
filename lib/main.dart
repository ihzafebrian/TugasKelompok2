import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import screen
import 'views/auth/login_screen.dart';
import 'views/owner/dashboard_screen.dart';
import 'views/owner/laporan_harian_screen.dart';
import 'views/owner/laporan_bulanan_screen.dart';
import 'views/owner/laporan_tahunan_screen.dart';

// Import viewmodel
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'POS Flutter',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const RootScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/laporan-harian': (context) => LaporanHarianScreen(),
          '/laporan-bulanan': (context) => LaporanBulananScreen(),
          '/laporan-tahunan': (context) => LaporanTahunanScreen(),
        },
      ),
    );
  }
}

/// Widget untuk menentukan apakah user sudah login atau belum
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();

    // Mengeksekusi pengecekan login setelah frame pertama dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!mounted) return;

    // Jika token ada, user sudah login -> dashboard
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
