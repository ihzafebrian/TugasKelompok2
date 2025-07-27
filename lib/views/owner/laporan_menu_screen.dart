import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class LaporanMenuScreen extends StatelessWidget {
  const LaporanMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppTheme.themedAppBar('Menu Laporan'),
      body: Container(
        decoration: AppTheme.mainBackground(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MenuCard(
                title: 'Laporan Harian',
                icon: Icons.calendar_today,
                onTap: () => Navigator.pushNamed(context, '/laporan-harian'),
              ),
              const SizedBox(height: 24),
              _MenuCard(
                title: 'Laporan Bulanan',
                icon: Icons.calendar_view_month,
                onTap: () => Navigator.pushNamed(context, '/laporan-bulanan'),
              ),
              const SizedBox(height: 24),
              _MenuCard(
                title: 'Laporan Tahunan',
                icon: Icons.calendar_today_outlined,
                onTap: () => Navigator.pushNamed(context, '/laporan-tahunan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _MenuCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(18),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 22),
          ],
        ),
      ),
    );
  }
}
