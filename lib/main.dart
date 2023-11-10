import 'package:cryptography_flutter/s_homepage.dart';
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
      theme: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? ThemeData.dark()
          : ThemeData.light(),
      home: const HomePage(),
    );
  }
}
