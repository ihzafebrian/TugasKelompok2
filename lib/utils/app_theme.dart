import 'package:flutter/material.dart';

class AppTheme {
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8D6E63), // coklat muda
      Color(0xFF4E342E), // coklat tua
      Color(0xFFD7CCC8), // cream
    ],
  );

  static const TextStyle appBarTitle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 22,
    letterSpacing: 1.2,
    fontFamily: 'Montserrat',
    color: Colors.white,
  );

  static AppBar themedAppBar(String title, {List<Widget>? actions}) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(title, style: appBarTitle),
      actions: actions,
    );
  }

  static BoxDecoration mainBackground() => const BoxDecoration(
        gradient: mainGradient,
      );
} 