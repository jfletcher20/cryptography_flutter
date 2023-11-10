import 'dart:io';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class KeysScreen extends StatefulWidget {
  const KeysScreen({super.key});

  @override
  State<KeysScreen> createState() => _KeysScreenState();
}

class _KeysScreenState extends State<KeysScreen> {
  String public = "javni_kljuc.txt";
  String private = "privatni_kljuc.txt";
  String secret = "tajni_kljuc.txt";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FileContentsWidget(file: public),
        ElevatedButton(
          onPressed: () => _saveKeyToFile(public),
          child: const Text('Public Key'),
        ),
        FileContentsWidget(file: private),
        ElevatedButton(
          onPressed: () => _saveKeyToFile(private),
          child: const Text('Private Key'),
        ),
        FileContentsWidget(file: secret),
        ElevatedButton(
          onPressed: () => _saveKeyToFile(secret),
          child: const Text('Secret Key'),
        ),
      ],
    );
  }

  Future<void> _saveKeyToFile(String fileName) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$fileName');
      await file.writeAsString('Sample Key Data');
      final String fileContents = await file.readAsString();
      setState(() {});
      print('Contents of $fileName: $fileContents');
    } catch (e) {
      print('Error saving key: $e');
    }
  }
}
