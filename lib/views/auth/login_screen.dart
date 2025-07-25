import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../owner/dashboard_screen.dart';
import '../cashier/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                bool success = await auth.login(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );

                if (success) {
                  String role = auth.user!.role;

                  // Simpan token dan role ke SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('token', auth.token!);
                  await prefs.setString('role', role);

                  // Navigasi ke dashboard sesuai role
                  if (role == 'pemilik') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  } else if (role == 'kasir') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KasirDashboardPage(token: auth.token!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Role tidak dikenal')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login gagal')),
                  );
                }
              },
              child: auth.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}
