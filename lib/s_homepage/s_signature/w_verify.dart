// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/file_management/u_keys.dart';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

class VerifySignatureWidget extends StatefulWidget {
  const VerifySignatureWidget({super.key});

  @override
  State<VerifySignatureWidget> createState() => _VerifySignatureWidgetState();
}

class _VerifySignatureWidgetState extends State<VerifySignatureWidget> {
  File? originalFile, signedFile;
  bool isVerificationButtonEnabled = false;
  bool verificationResult = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _originalFilePicker,
            const SizedBox(width: 32),
            _signedFilePicker,
          ],
        )),
        const SizedBox(height: 64),
        ..._verificationResultWidget,
        ElevatedButton(
          onPressed: isVerificationButtonEnabled ? _verifyFile : null,
          child: const Text("Verify Signature"),
        ),
      ],
    );
  }

  Widget get _originalFilePicker {
    return Column(
      children: [
        ...wrap(
          "Original file: ",
          FileContentsWidget(
            contentOverride: originalFile?.path ?? "None",
            useErrorStyle: originalFile == null,
          ),
        ),
        ...wrap("File contents: ", FileContentsWidget(file: originalFile)),
        ElevatedButton(onPressed: _pickOriginalFile, child: const Text("Select Original File")),
      ],
    );
  }

  Widget get _signedFilePicker {
    return Column(
      children: [
        ...wrap(
          "Signed file: ",
          FileContentsWidget(
            contentOverride: signedFile?.path ?? "None",
            useErrorStyle: signedFile == null,
          ),
        ),
        ...wrap("File contents: ", FileContentsWidget(file: signedFile)),
        ElevatedButton(onPressed: _pickSignedFile, child: const Text("Select Signed File")),
      ],
    );
  }

  List<Widget> get _verificationResultWidget {
    TextStyle style = Theme.of(context)
        .textTheme
        .displaySmall!
        .copyWith(color: verificationResult ? Colors.green[200] : Colors.red[200]);
    return wrap(
      "Verification result: ",
      Text(verificationResult ? "All is in order" : "Did not pass verification", style: style),
    );
  }

  List<Widget> wrap(String label, Widget child) {
    return [Text(label), child];
  }

  Future<void> _pickOriginalFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        originalFile = File(result.files.single.path!);
        isVerificationButtonEnabled = originalFile != null && signedFile != null;
      });
    }
  }

  Future<void> _pickSignedFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        signedFile = File(result.files.single.path!);
        isVerificationButtonEnabled = originalFile != null && signedFile != null;
      });
    }
  }

  Future<void> _verifyFile() async {
    if (signedFile == null || originalFile == null) return;
    await calculateDigestOfFile();
  }

  Future<bool> calculateDigestOfFile() async {
    String signedFileContents = FileManager.readFromFile(signedFile!);
    String originalFileContents = FileManager.readFromFile(originalFile!);

    AsymmetricKeyParameter<RSAPublicKey> publicKey =
        PublicKeyParameter(await KeysManager.publicKey());

    RSASigner signer = RSASigner(SHA256Digest(), "0609608648016503040201");
    signer.init(false, publicKey);

    bool verification = signer.verifySignature(
      Uint8List.fromList(originalFileContents.codeUnits),
      RSASignature(Uint8List.fromList(signedFileContents.codeUnits)),
    );

    setState(() {
      verificationResult = verification;
    });

    return verification;
  }
}
