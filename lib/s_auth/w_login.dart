import 'package:cryptography_flutter/data/models/m_user.dart';
import 'package:cryptography_flutter/s_auth/u_auth.dart';
import 'package:flutter/material.dart';

class LoginWidget extends StatelessWidget {
  final User user;
  final int index;
  const LoginWidget({super.key, required this.user, required this.index});

  bool get isCurrentUser => index == Auth.currentUser.index;

  @override
  Widget build(BuildContext context) {
    Color? col = isCurrentUser ? Theme.of(context).colorScheme.primary : null;
    return ListTile(
      leading: Icon(isCurrentUser ? Icons.person : Icons.person_outline, color: col),
      title: Text(user.toString()),
      onTap: () => _login(context),
      trailing: const Icon(Icons.arrow_forward_ios),
      titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: col),
    );
  }

  void _login(BuildContext context) async {
    await Auth.safeLogin(user: user, index: index);
    if (context.mounted) Navigator.of(context).pop();
  }
}
