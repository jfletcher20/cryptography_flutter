import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EncryptScreen extends StatefulWidget {
  const EncryptScreen({super.key});

  @override
  State<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends State<EncryptScreen> {
  File? selectedFile;
  bool isEncryptButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _pickFile,
          child: const Text('Select File'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isEncryptButtonEnabled ? _encryptFile : null,
          child: const Text('Encrypt File'),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        isEncryptButtonEnabled = true;
      });
    }
  }

  Future<void> _encryptFile() async {
    if (selectedFile == null) return;
    final originalFileName = selectedFile!.path.split('/').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _saveEncryptedFile(originalFileName, 'symmetric_$timestamp');
    await _saveEncryptedFile(originalFileName, 'asymmetric_$timestamp');
  }

  Future<void> _saveEncryptedFile(String originalFileName, String suffix) async {
    try {
      // final directory = await getApplicationDocumentsDirectory();
      final encryptedFileName = '$originalFileName' '_encrypted_$suffix.txt';
      // final encryptedFile = File('${directory.path}/$encryptedFileName');

      // Perform encryption logic here, for example:
      // final encryptedData = performEncryption(selectedFile!.readAsStringSync());

      // Write encrypted data to the file
      // await encryptedFile.writeAsString(encryptedData);

      print('File encrypted and saved as $encryptedFileName');
    } catch (e) {
      print('Error encrypting file: $e');
    }
  }
}
