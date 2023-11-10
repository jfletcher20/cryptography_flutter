import 'dart:io';

class DirectoryManager {
  static String get appDocsDirectory => "cryptography_flutter";
  static void createDirectoryIfNotExists(String path) {
    var directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print('Directory created: $path');
    } else {
      print('Directory already exists: $path');
    }
  }
}
