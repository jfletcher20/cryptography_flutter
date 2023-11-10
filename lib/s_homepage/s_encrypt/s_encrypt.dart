import 'dart:io';
import 'package:cryptography_flutter/file_management/u_file_creation.dart';
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
    await FileManager.saveToFile('${originalFileName}_symmetric_$timestamp', encrypt());
    await FileManager.saveToFile('${originalFileName}_asymmetric_$timestamp', encrypt());
  }

  String encrypt() {
    return selectedFile!.readAsStringSync();
  }
}
