import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/file_management/u_keys.dart';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/export.dart' as crypto;

class EncryptScreen extends StatefulWidget {
  const EncryptScreen({super.key});

  @override
  State<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends State<EncryptScreen> {
  File? selectedFile;
  bool isEncryptButtonEnabled = false;
  String encryptedText = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...wrap("Selected file: ", Text(selectedFile?.path ?? "None")),
        ...wrap("File contents: ", FileContentsWidget(file: selectedFile)),
        ElevatedButton(onPressed: _pickFile, child: const Text("Select File")),
        const SizedBox(height: 16),
        if (encryptedText.isNotEmpty) ...wrap("Encrypted text: ", Text(encryptedText)),
        ElevatedButton(
          onPressed: isEncryptButtonEnabled ? _encryptFile : null,
          child: const Text("Encrypt File"),
        ),
      ],
    );
  }

  List<Widget> wrap(String label, Widget child) {
    return [
      Text(label),
      Container(
        padding: const EdgeInsets.all(20),
        height: 100,
        child: SingleChildScrollView(child: child),
      ),
    ];
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

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String originalFileName = selectedFile!.path.split("\\").last.replaceAll(".txt", "");

    String asymmetricFileName = "${originalFileName}_asymmetric_encryption_$timestamp.txt";
    try {
      await FileManager.saveToFile(asymmetricFileName, await asymetricEncryption());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    // String symmetricFileName = "${fileName}_symmetric_encryption_$timestamp.txt";
    // await FileManager.saveToFile("${fileName}_symmetric_encryption_$timestamp", encrypt());
  }

  Future<String> asymetricEncryption() async {
    String fileContents = FileManager.readFromFile(selectedFile!);

    AsymmetricKeyParameter<RSAPublicKey> publicKey =
        PublicKeyParameter(await KeysManager.publicKey());

    crypto.RSAEngine cipher = crypto.RSAEngine();
    cipher.init(true, publicKey);

    Uint8List cipherText = cipher.process(Uint8List.fromList(fileContents.codeUnits));
    setState(() {
      encryptedText = String.fromCharCodes(cipherText);
    });

    return String.fromCharCodes(cipherText);
  }
}
