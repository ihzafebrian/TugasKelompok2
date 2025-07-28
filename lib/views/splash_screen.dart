import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconScale;
  late Animation<double> _iconFade;

  late AnimationController _textController;
  late Animation<Offset> _textOffset;
  late Animation<double> _textFade;

  late AnimationController _smokeController;

  late AnimationController _outController;
  late Animation<double> _outFade;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _iconScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeIn),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOffset = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _smokeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _outController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _outFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _outController, curve: Curves.easeInOut),
    );

    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 900), () {
      _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 2400), () async {
      await _outController.forward();
      if (!mounted) return;
      widget.onFinish();
    });

  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _smokeController.dispose();
    _outController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _outFade,
      builder: (context, child) {
        return Opacity(
          opacity: _outFade.value,
          child: child,
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8D6E63), // coklat muda
              Color(0xFF4E342E), // coklat tua
              Color(0xFFD7CCC8), // cream
            ],
          ),
        ),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: maxHeight * 0.10),
                  // Efek asap
                  AnimatedBuilder(
                    animation: _smokeController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: SmokePainter(_smokeController.value),
                        size: const Size(120, 60),
                      );
                    },
                  ),
                  // Ikon rokok
                  ScaleTransition(
                    scale: _iconScale,
                    child: FadeTransition(
                      opacity: _iconFade,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.13),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(36),
                        child: Image.asset(
                        'lib/assets/images/vape.jpg',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: maxHeight * 0.04),
                  // Tulisan VAPORATESTORE dan slogan
                  SlideTransition(
                    position: _textOffset,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'VAPORATESTORE',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 3,
                              fontFamily: 'Montserrat',
                              decoration: TextDecoration.none,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.22),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                                Shadow(
                                  color: Colors.brown.withOpacity(0.18),
                                  blurRadius: 18,
                                  offset: Offset(0, 7),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Solusi Kasir Modern untuk Bisnis Vape Anda',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white.withOpacity(0.93),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.1,
                              fontFamily: 'Montserrat',
                              decoration: TextDecoration.none,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.13),
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: maxHeight * 0.04),
                  // Loader animasi
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.25),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF795548)),
                        backgroundColor: Colors.white24,
                        strokeWidth: 4.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(height: maxHeight * 0.10),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Efek asap sederhana
class SmokePainter extends CustomPainter {
  final double progress;
  SmokePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.18 + 0.12 * sin(progress * pi))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.cubicTo(
      size.width * 0.3,
      size.height * (0.7 - 0.1 * sin(progress * pi)),
      size.width * 0.7,
      size.height * (0.5 + 0.1 * cos(progress * pi)),
      size.width * 0.8,
      size.height * 0.2,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SmokePainter oldDelegate) => oldDelegate.progress != progress;
} 