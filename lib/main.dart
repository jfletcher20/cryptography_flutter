import 'package:cryptography_flutter/s_homepage/s_homepage.dart';
import 'package:cryptography_flutter/s_auth/u_auth.dart';
import 'package:cryptography_flutter/data/d_theme.dart';

import 'package:flutter/material.dart';

void main() async {
  await Auth.safeLogin(username: "You", index: 0);
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
