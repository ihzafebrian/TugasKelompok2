import 'package:flutter/material.dart';

class LaporanMenuScreen extends StatelessWidget {
  const LaporanMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Laporan')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/laporan-harian');
              },
              child: const Text('Laporan Harian'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/laporan-bulanan');
              },
              child: const Text('Laporan Bulanan'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/laporan-tahunan');
              },
              child: const Text('Laporan Tahunan'),
            ),
          ],
        ),
      ),
    );
  }
}
