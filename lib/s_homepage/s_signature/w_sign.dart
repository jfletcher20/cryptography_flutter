// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/file_management/u_keys.dart';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

class SignFileWidget extends StatefulWidget {
  const SignFileWidget({super.key});

  @override
  State<SignFileWidget> createState() => _SignFileWidgetState();
}

class _SignFileWidgetState extends State<SignFileWidget> {
  File? selectedFile;
  bool isDigestButtonEnabled = false;
  String digestText = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...wrap("Selected file: ", Text(selectedFile?.path ?? "None")),
        ...wrap("File contents: ", FileContentsWidget(file: selectedFile)),
        ElevatedButton(onPressed: _pickFile, child: const Text("Select File")),
        const SizedBox(height: 16),
        if (digestText.isNotEmpty) ..._digestTextWidget,
        ElevatedButton(
          onPressed: isDigestButtonEnabled ? _calculateDigestOfFile : null,
          child: const Text("Calculate Digest"),
        ),
      ],
    );
  }

  List<Widget> get _digestTextWidget {
    TextStyle style = Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.green[200]);
    return wrap(
      "Digest text: ",
      Text(digestText, style: style),
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
        isDigestButtonEnabled = true;
      });
    }
  }

  Future<void> _calculateDigestOfFile() async {
    if (selectedFile == null) return;
    final fileName = selectedFile!.path.split("\\").last.replaceAll(".txt", "");
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String asym = await calculateDigestOfFile();
    try {
      await FileManager.saveToFile(
        "${fileName}_digest_$timestamp.txt",
        asym,
        createDir: true,
        additionalPath: "signature/digest",
      );
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<String> calculateDigestOfFile() async {
    String fileContents = FileManager.readFromFile(selectedFile!);

    AsymmetricKeyParameter<RSAPrivateKey> privateKey =
        PrivateKeyParameter(await KeysManager.privateKey());

    RSASigner signer = RSASigner(SHA256Digest(), "0609608648016503040201");
    signer.init(true, privateKey);

    RSASignature digest = signer.generateSignature(Uint8List.fromList(fileContents.codeUnits));

    setState(() {
      digestText = String.fromCharCodes(digest.bytes);
    });

    return String.fromCharCodes(digest.bytes);
  }
}
