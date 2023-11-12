// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:cryptography_flutter/s_auth/u_auth.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static Future<File?> saveToFile(
    String fileName,
    String data, {
    bool createDir = false,
    String additionalPath = "",
  }) async {
    try {
      if (createDir) {
        final Directory directory = await getApplicationDocumentsDirectory();
        final Directory dir = Directory("${directory.path}/${Auth.userPath}/$additionalPath");
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
      }
      final File file = File(await _filePath(additionalPath, fileName));
      file.writeAsStringSync(data);
      return file;
    } catch (e) {
      print("Error saving file: $e");
    }
    return null;
  }

  static Future<String> _filePath(String additionalPath, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}/${Auth.userPath}";
    if (additionalPath.isNotEmpty)
      path += "/$additionalPath/$fileName";
    else
      path += "/$fileName";
    return path;
  }

  static String readFromFile(File file) {
    try {
      final String fileContents = file.readAsStringSync();
      return fileContents;
    } catch (e) {
      print("Error reading key: $e");
    }
    return "File does not exist";
  }

  static Future<(String, String)> readAsymmetricKeyFromFile() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File public = File("${directory.path}/${Auth.userPath}/javni_kljuc.txt");
      final File private = File("${directory.path}/${Auth.userPath}/privatni_kljuc.txt");
      return (public.readAsStringSync(), private.readAsStringSync());
    } catch (e) {
      print("Error reading key: $e");
    }
    return ("Error: A file does not exist", "Error: A file does not exist");
  }
}
