import 'package:cryptography_flutter/data/models/m_user.dart';
import 'package:cryptography_flutter/s_auth/w_login.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Set<String> users = {
    "You",
    "Correspondent 1",
    "Correspondent 2",
    "Correspondent 3",
    "Correspondent 4",
    "Correspondent 5",
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose whose keys to operate with")),
      body: ListView(
        children: List.generate(
          users.length,
          (index) => LoginWidget(
            user: User(username: users.elementAt(index), index: index),
            index: index,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () =>
                launchUrl(Uri.parse("https://github.com/jfletcher20/cryptography_flutter")),
            child: const Text("Developed by Joshua Lee Fletcher, click to open on GitHub"),
          ),
        ),
      ),
    );
  }
}
