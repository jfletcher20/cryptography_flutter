// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cryptography_flutter/s_auth/s_login.dart';
import 'package:cryptography_flutter/s_auth/u_auth.dart';
import 'package:cryptography_flutter/s_homepage/s_encrypt/s_encrypt.dart';
import 'package:flutter/material.dart';
import 's_keys/s_keys.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      KeysScreen(key: GlobalKey()),
      EncryptScreen(key: GlobalKey()),
      Placeholder(key: GlobalKey()),
      Placeholder(key: GlobalKey()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${Auth.currentUser.username}"),
        actions: [IconButton(onPressed: () => _showLoginScreen(), icon: const Icon(Icons.person))],
      ),
      body: Center(child: _screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: 'Keys'),
          BottomNavigationBarItem(icon: Icon(Icons.enhanced_encryption), label: 'Encrypt'),
          BottomNavigationBarItem(icon: Icon(Icons.no_encryption_rounded), label: 'Decrypt'),
          BottomNavigationBarItem(icon: Icon(Icons.approval_rounded), label: 'Stamp'),
        ],
      ),
    );
  }

  void _showLoginScreen() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
    if (context.mounted) {
      setState(() {
        for (var element in _screens) {
          (element.key as GlobalKey).currentState?.setState(() {});
        }
      });
    }
  }
}
