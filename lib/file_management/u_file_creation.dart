import 'dart:io';

import 'package:cryptography_flutter/s_auth/u_auth.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static Future<File?> saveToFile(String fileName, String data, {bool createDir = false}) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File("${directory.path}/${Auth.userPath}/$fileName");
      await file.writeAsString(data);
      final String fileContents = await file.readAsString();
      print('Contents of $fileName: $fileContents');
      return file;
    } catch (e) {
      print('Error saving file: $e');
    }
    return null;
  }

  static String readFromFile(File file) {
    try {
      final String fileContents = file.readAsStringSync();
      return fileContents;
    } catch (e) {
      print('Error reading key: $e');
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
      print('Error reading key: $e');
    }
    return ("Error: A file does not exist", "Error: A file does not exist");
  }
}
