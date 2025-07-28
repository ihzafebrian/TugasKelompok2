import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Import screens
import 'views/auth/login_screen.dart';
import 'views/owner/dashboard_screen.dart';
import 'views/owner/laporan_harian_screen.dart';
import 'views/owner/laporan_bulanan_screen.dart';
import 'views/owner/laporan_tahunan_screen.dart';
import 'views/splash_screen.dart';

// Import viewmodels
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
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
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreenWrapper(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/laporan-harian': (context) => const LaporanHarianScreen(),
          '/laporan-bulanan': (context) => const LaporanBulananScreen(),
          '/laporan-tahunan': (context) => const LaporanTahunanScreen(),
        },
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _showRoot = false;

  void _onSplashFinish() {
    setState(() {
      _showRoot = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showRoot ? const RootScreen() : SplashScreen(onFinish: _onSplashFinish);
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLoginStatus());
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
