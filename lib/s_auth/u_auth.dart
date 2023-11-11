// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:cryptography_flutter/data/models/m_user.dart';
import 'package:path_provider/path_provider.dart';

import '../file_management/u_directory.dart';

class Auth {
  static late User _currentUser;

  static User get currentUser => _currentUser;
  static String get userPath => "${DirectoryManager.appDocsDirectory}/${_currentUser.username}";

  static bool login({String? username, User? user}) {
    if (username == null && user == null)
      return false;
    else if (username != null)
      _currentUser = User(username: username);
    else
      _currentUser = user!;
    return true;
  }

  /// Login safely (create directory if needed)
  static Future<bool> safeLogin({String? username, User? user}) async {
    bool successfulLogin = login(username: username, user: user);
    if (successfulLogin) {
      await _safeLogin();
    }
    return successfulLogin;
  }

  static _safeLogin() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    DirectoryManager.createDirectoryIfNotExists("${directory.path}/${Auth.userPath}");
  }
}
