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
        isDigestButtonEnabled = true;
      });
    }
  }

  Future<void> _calculateDigestOfFile() async {
    if (selectedFile == null) return;
    final fileName = selectedFile!.path.split("\\").last.replaceAll(".txt", "");
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String asym = await digitalSignature();
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

  Future<String> digitalSignature() async {
    String fileContents = FileManager.readFromFile(selectedFile!);

    AsymmetricKeyParameter<RSAPrivateKey> privateKey =
        PrivateKeyParameter(await KeysManager.privateKey());

    /* updated code in library to extract the function for the digest info */

    /*
    @override
    RSASignature generateSignature(Uint8List message, {bool normalize = false}) {
      if (!_forSigning) {
        throw StateError('Signer was not initialised for signature generation');
      }

      var data = message;//generateDigest(message, normalize: normalize);
      var out = Uint8List(_rsa.outputBlockSize);
      var len = _rsa.processBlock(data, 0, data.length, out, 0);
      return RSASignature(out.sublist(0, len));
    }

    @override
    Uint8List generateDigest(Uint8List message, {bool normalize = false}) {
      if (!_forSigning) {
        throw StateError('Signer was not initialised for signature generation');
      }

      var hash = Uint8List(_digest.digestSize);
      _digest.reset();
      _digest.update(message, 0, message.length);
      _digest.doFinal(hash, 0);

      return _derEncode(hash);
    }
    */

    RSASigner signer = RSASigner(SHA256Digest(), _digestIdentifierHex);
    signer.init(true, privateKey);

    Uint8List digest = signer.generateDigest(Uint8List.fromList(fileContents.codeUnits));
    File digestFile = await FileManager.saveToFile(
      "digest.txt",
      String.fromCharCodes(digest),
      createDir: true,
      additionalPath: "signature",
    ) as File;

    fileContents = FileManager.readFromFile(digestFile);

    RSASignature signature = signer.generateSignature(Uint8List.fromList(fileContents.codeUnits));

    setState(() => digestText = String.fromCharCodes(signature.bytes));

    return String.fromCharCodes(signature.bytes);
  }
}
