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

const _digestIdentifierHex = "0609608648016503040201";

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...wrap(
              "Selected file: ",
              FileContentsWidget(
                contentOverride: selectedFile?.path ?? "None",
                useErrorStyle: selectedFile == null,
                maxExtents: (horizontal: true, vertical: selectedFile != null),
              ),
            ),
            ...wrap(
              "File contents: ",
              FileContentsWidget(
                file: selectedFile,
                maxExtents: (horizontal: true, vertical: selectedFile != null),
              ),
            ),
            ElevatedButton(onPressed: _pickFile, child: const Text("Select File")),
          ],
        ),
        const SizedBox(width: 32),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...wrap(
              "Output file: ",
              FileContentsWidget(
                contentOverride: digestFileOutput?.path.replaceAll("/", "\\") ?? "None",
                useErrorStyle: digestFileOutput == null,
                maxExtents: (horizontal: true, vertical: digestText.isNotEmpty),
              ),
            ),
            ..._digestTextWidget,
            ElevatedButton(
              onPressed: isDigestButtonEnabled ? _calculateDigestOfFile : null,
              child: const Text("Calculate Digest"),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> get _digestTextWidget {
    TextStyle style = Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.green[200]);
    return wrap(
      "Digest text: ",
      FileContentsWidget(
        contentOverride: digestText.isNotEmpty ? digestText : "Not calculated yet",
        styleOverride: style,
        useErrorStyle: digestText.isEmpty,
        maxExtents: (horizontal: true, vertical: digestText.isNotEmpty),
      ),
    );
  }

  List<Widget> wrap(String label, Widget child) {
    return [Text(label), child];
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

  File? digestFileOutput;

  Future<void> _calculateDigestOfFile() async {
    if (selectedFile == null) return;
    final fileName = selectedFile!.path.split("\\").last.replaceAll(".txt", "");
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String asym = await digitalSignature();
    try {
      File? digestFile = await FileManager.saveToFile(
        "${fileName}_digest_$timestamp.txt",
        asym,
        createDir: true,
        additionalPath: "signature/digest",
      );
      setState(() => digestFileOutput = digestFile);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<String> digitalSignature() async {
    String fileContents = FileManager.readFromFile(selectedFile!);

    AsymmetricKeyParameter<RSAPrivateKey> privateKey =
        PrivateKeyParameter(await KeysManager.privateKey());

    RSASigner signer = RSASigner(SHA256Digest(), _digestIdentifierHex);
    signer.init(true, privateKey);

    fileContents = FileManager.readFromFile(selectedFile!);

    RSASignature signature = signer.generateSignature(Uint8List.fromList(fileContents.codeUnits));

    setState(() => digestText = String.fromCharCodes(signature.bytes));

    return String.fromCharCodes(signature.bytes);
  }
}
