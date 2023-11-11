import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/file_management/u_keys.dart';
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
    final fileName = selectedFile!.path.split("\\").last.replaceAll(".txt", "");
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // await FileManager.saveToFile('${originalFileName}_symmetric_$timestamp', encrypt());
    String asym = await encrypt();
    await FileManager.saveToFile('${fileName}_asymmetric_encryption_$timestamp.txt', asym);
  }

  Future<String> encrypt() async {
    String fileContents = FileManager.readFromFile(selectedFile!);

    AsymmetricKeyParameter<RSAPublicKey> publicKey =
        PublicKeyParameter(await KeysManager.publicKey());
    AsymmetricKeyParameter<RSAPrivateKey> privateKey =
        PrivateKeyParameter(await KeysManager.privateKey());

    crypto.RSAEngine cipher = crypto.RSAEngine();
    cipher.init(true, publicKey);

    Uint8List cipherText = cipher.process(Uint8List.fromList(fileContents.codeUnits));
    print("Encrypted: ${String.fromCharCodes(cipherText)}");

    cipher.init(false, privateKey);
    var decrypted = cipher.process(cipherText);
    print("Decrypted: ${String.fromCharCodes(decrypted)}");

    return String.fromCharCodes(cipherText);
  }
}
