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
    const Placeholder(), // Replace with Screen2
    const Placeholder(), // Replace with Screen3
    const Placeholder(), // Replace with Screen4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tabbed App')),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: 'Keys'),
          BottomNavigationBarItem(icon: Icon(Icons.tab), label: 'Screen2'),
          BottomNavigationBarItem(icon: Icon(Icons.tab), label: 'Screen3'),
          BottomNavigationBarItem(icon: Icon(Icons.tab), label: 'Screen4'),
        ],
      ),
    );
  }
}
