// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:cryptography_flutter/s_homepage/s_encryption/s_encryption.dart';
import 'package:cryptography_flutter/s_homepage/s_signature/s_signature.dart';
import 'package:cryptography_flutter/s_homepage/s_cipher/s_cipher.dart';
import 'package:cryptography_flutter/s_homepage/s_keys/s_keys.dart';
import 'package:cryptography_flutter/s_auth/s_login.dart';
import 'package:cryptography_flutter/s_auth/u_auth.dart';

import 'package:flutter/material.dart';

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
      EncryptionScreen(key: GlobalKey()),
      CipherScreen(key: GlobalKey()),
      SignatureScreen(key: GlobalKey()),
    ];
  }

  String get user => Auth.currentUser.username;
  String get wrapUserText => Auth.currentUser.index == 0 ? "Your keys" : "$user's keys";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Operating with $wrapUserText"),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showLoginScreen(),
            icon: const Icon(Icons.person),
            label: const Text("Change profile"),
          )
        ],
      ),
      body: Center(child: _screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: 'Keys'),
          BottomNavigationBarItem(icon: Icon(Icons.enhanced_encryption), label: 'Encryption'),
          BottomNavigationBarItem(icon: Icon(Icons.private_connectivity), label: 'Cipher'),
          BottomNavigationBarItem(icon: Icon(Icons.approval_rounded), label: 'Sign'),
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
