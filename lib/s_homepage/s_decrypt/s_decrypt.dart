import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/file_management/u_keys.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/export.dart' as crypto;

class DecryptScreen extends StatefulWidget {
  const DecryptScreen({super.key});

  @override
  State<DecryptScreen> createState() => _DecryptScreenState();
}

class _DecryptScreenState extends State<DecryptScreen> {
  File? selectedFile;
  bool isDecryptButtonEnabled = false;

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
          onPressed: isDecryptButtonEnabled ? _decryptFile : null,
          child: const Text('Decrypt File'),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        isDecryptButtonEnabled = true;
      });
    }
  }

  Future<void> _decryptFile() async {
    if (selectedFile == null) return;
    final fileName = selectedFile!.path.split("\\").last.replaceAll(".txt", "");
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // await FileManager.saveToFile('${fileName}_symmetric_decryption_$timestamp', encrypt());
    String asym = await asymmetricDecryption();
    await FileManager.saveToFile('${fileName}_asymmetric_decryption_$timestamp.txt', asym);
  }

  Future<String> asymmetricDecryption() async {
    String fileContents = FileManager.readFromFile(selectedFile!);

    AsymmetricKeyParameter<RSAPrivateKey> privateKey =
        PrivateKeyParameter(await KeysManager.privateKey());

    crypto.RSAEngine cipher = crypto.RSAEngine();

    cipher.init(false, privateKey);
    Uint8List decrypted = cipher.process(Uint8List.fromList(fileContents.codeUnits));
    print("Decrypted: ${String.fromCharCodes(decrypted)}");

    return String.fromCharCodes(decrypted);
  }
}
