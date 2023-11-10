import 'package:cryptography_flutter/s_homepage/s_encrypt/s_encrypt.dart';
import 'package:flutter/material.dart';
import 's_keys/s_keys.dart'; // Import other screens

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const KeysScreen(),
    const EncryptScreen(), // Replace with Screen2
    const Placeholder(), // Replace with Screen3
    const Placeholder(), // Replace with Screen4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tabbed App')),
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
}
