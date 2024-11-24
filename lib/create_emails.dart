import 'dart:io';
import 'd_emails.dart';

void main() async {
  Directory directory = Directory("C:/Users/Public/Documents/cryptography_flutter/emails");
  if (!directory.existsSync()) {
    print("Creating directory...");
    directory.createSync(recursive: true);
    print("Directory created at: ${directory.path}");
  }
  print("Creating emails...");

  // Function to sanitize file names
  String sanitizeFileName(String name) {
    // Replace invalid characters with an underscore
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  emails.forEach((key, value) {
    String sanitizedKey = sanitizeFileName(key); // Sanitize the file name
    File file = File("${directory.path}/$sanitizedKey.txt");
    file.writeAsStringSync(value);
  });
  print("Emails created.");
}
