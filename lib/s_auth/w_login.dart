import 'package:cryptography_flutter/data/models/m_user.dart';
import 'package:cryptography_flutter/s_auth/u_auth.dart';
import 'package:flutter/material.dart';

class LoginWidget extends StatelessWidget {
  final User user;
  const LoginWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(user.toString()),
        TextButton(onPressed: () => _login(context), child: const Text("Log in")),
      ],
    );
  }

  void _login(BuildContext context) async {
    await Auth.safeLogin(user: user);
    if (context.mounted) Navigator.of(context).pop();
  }
}
