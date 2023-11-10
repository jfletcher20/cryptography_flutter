import 'package:cryptography_flutter/data/models/m_user.dart';
import 'package:cryptography_flutter/s_auth/w_login.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Set<String> users = {
    "Joshua",
    "Quinn",
    "Taissa",
    "Dario",
    "Noa",
    "Stjepan",
    "Marko",
    "Mislav",
    "Lovro",
  };
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: users.map((username) => LoginWidget(user: User(username: username))).toList(),
    );
  }
}
