import 'package:flutter/material.dart';

class ThemeEditor {
  static ThemeData dark = ThemeData.dark(useMaterial3: true).copyWith(
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
    textTheme: TextTheme(
      displaySmall: ThemeData.dark().textTheme.bodySmall!.copyWith(
            color: Colors.lightBlue[100],
            decoration: TextDecoration.underline,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
    ),
  );
}
