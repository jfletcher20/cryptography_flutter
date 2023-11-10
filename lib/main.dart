import 'package:cryptography_flutter/data/d_theme.dart';
import 'package:cryptography_flutter/s_homepage/s_homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeEditor.dark,
      home: const HomePage(),
    );
  }
}
