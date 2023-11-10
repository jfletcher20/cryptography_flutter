// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cryptography_flutter/data/models/m_user.dart';

class Auth {
  static User _currentUser = User(username: "Joshua");
  static User get currentUser => _currentUser;
  static void login({String? username, User? user}) {
    if (username == null && user == null)
      return;
    else if (username != null)
      _currentUser = User(username: username);
    else
      _currentUser = user!;
  }
}
