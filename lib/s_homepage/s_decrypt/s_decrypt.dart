// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/file_management/u_keys.dart';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/export.dart' as crypto;
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

class DecryptScreen extends StatefulWidget {
  const DecryptScreen({super.key});

  @override
  State<DecryptScreen> createState() => _DecryptScreenState();
}

class _DecryptScreenState extends State<DecryptScreen> {
  File? selectedFile;
  bool isDecryptButtonEnabled = false;
  String decryptedTextRSA = "", decryptedTextAES = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...wrap("Selected file: ", Text(selectedFile?.path ?? "None")),
        ...wrap("File contents: ", FileContentsWidget(file: selectedFile)),
        ElevatedButton(onPressed: _pickFile, child: const Text("Select File")),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _asymmetricDecryptionWidget,
          const SizedBox(width: 64),
          _symmetricDecryptionWidget,
        ])
      ],
    );
  }

  Widget get _asymmetricDecryptionWidget {
    return Column(children: [
      if (decryptedTextRSA.isNotEmpty) ..._decryptedTextWidgetRSA,
      ElevatedButton(
        onPressed: isDecryptButtonEnabled ? _decryptFileRSA : null,
        child: const Text("Asymmetric Decryption"),
      ),
    ]);
  }

  Widget get _symmetricDecryptionWidget {
    return Column(children: [
      if (decryptedTextAES.isNotEmpty) ..._decryptedTextWidgetAES,
      ElevatedButton(
        onPressed: isDecryptButtonEnabled ? _decryptFileAES : null,
        child: const Text("Symmetric Decryption"),
      ),
    ]);
  }

  List<Widget> get _decryptedTextWidgetRSA {
    TextStyle style = Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.green[200]);
    return wrap(
      "Decrypted text: ",
      Text(decryptedTextRSA, style: style),
    );
  }

  List<Widget> get _decryptedTextWidgetAES {
    TextStyle style = Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.green[200]);
    return wrap(
      "Decrypted text: ",
      Text(decryptedTextAES, style: style),
    );
  }

  List<Widget> wrap(String label, Widget child) {
    return [
      Text(label),
      Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 100, maxWidth: 500),
        child: SingleChildScrollView(child: child),
      ),
    ];
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

  String getFileName(String type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String originalFileName = selectedFile!.path.split("\\").last.replaceAll(".txt", "");
    String fileName = "${originalFileName}_${type}_decryption_$timestamp.txt";
    return fileName;
  }

  Future<void> _decryptFileRSA() async {
    if (selectedFile == null) return;
    try {
      await FileManager.saveToFile(
        getFileName("asymmetric"),
        await asymmetricDecryption(),
        createDir: true,
        additionalPath: "asymmetric_decryption",
      );
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _decryptFileAES() async {
    if (selectedFile == null) return;
    try {
      await FileManager.saveToFile(
        getFileName("symmetric"),
        await symmetricDecryption(),
        createDir: true,
        additionalPath: "symmetric_decryption",
      );
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<String> asymmetricDecryption() async {
    String fileContents = FileManager.readFromFile(selectedFile!);

    AsymmetricKeyParameter<RSAPrivateKey> privateKey =
        PrivateKeyParameter(await KeysManager.privateKey());

    crypto.RSAEngine cipher = crypto.RSAEngine();
    cipher.init(false, privateKey);

    Uint8List decrypted = cipher.process(Uint8List.fromList(fileContents.codeUnits));
    setState(() {
      decryptedTextRSA = String.fromCharCodes(decrypted);
    });

    return String.fromCharCodes(decrypted);
  }

  Future<String> symmetricDecryption() async {
    String fileContents = FileManager.readFromFile(selectedFile!);

    Uint8List secretKey = await KeysManager.secretKey();

    // Extract IV from the first 16 bytes
    Uint8List iv = Uint8List.sublistView(Uint8List.fromList(fileContents.codeUnits), 0, 16);

    AESEngine aes = AESEngine();
    CBCBlockCipher cipher = CBCBlockCipher(aes);
    ParametersWithIV<KeyParameter> keyParameters = ParametersWithIV(KeyParameter(secretKey), iv);

    PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null> params =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(keyParameters, null);

    PaddedBlockCipherImpl cipherImpl = PaddedBlockCipherImpl(PKCS7Padding(), cipher);
    cipherImpl.init(false, params);

    // Skip the first 16 bytes (IV) during decryption
    Uint8List decrypted =
        cipherImpl.process(Uint8List.sublistView(Uint8List.fromList(fileContents.codeUnits), 16));

    setState(() {
      decryptedTextAES = String.fromCharCodes(decrypted);
    });

    return String.fromCharCodes(decrypted);
  }
}
