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
      print('Error saving key: $e');
    }
    return null;
  }
}
