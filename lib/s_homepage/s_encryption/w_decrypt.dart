// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/file_management/u_keys.dart';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/export.dart' as crypto;
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

class DecryptWidget extends StatefulWidget {
  const DecryptWidget({super.key});

  @override
  State<DecryptWidget> createState() => _DecryptWidgetState();
}

class _DecryptWidgetState extends State<DecryptWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  File? selectedFile;
  bool isDecryptButtonEnabled = false;
  String decryptedTextRSA = "", decryptedTextAES = "";

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        fileInput,
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _asymmetricDecryptionWidget,
          Opacity(
            opacity: 0,
            child: ElevatedButton(onPressed: _pickFile, child: const Text("Select File")),
          ),
          _symmetricDecryptionWidget,
        ])
      ],
    );
  }

  Widget get fileInput {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: wrap(
          "Selected file: ",
          FileContentsWidget(
            contentOverride: selectedFile?.path ?? "None",
            useErrorStyle: selectedFile == null,
            maxExtents: (horizontal: true, vertical: selectedFile != null),
          ),
        ),
      ),
      ElevatedButton(onPressed: _pickFile, child: const Text("Select File")),
      Column(
        children: wrap(
          "File contents: ",
          FileContentsWidget(
            file: selectedFile,
            useErrorStyle: selectedFile == null,
            maxExtents: (horizontal: true, vertical: selectedFile != null),
          ),
        ),
      ),
    ]);
  }

  File? _decryptedRSAFile, _decryptedAESFile;

  Widget get _asymmetricDecryptionWidget {
    return Column(children: [
      ..._decryptedTextWidgetRSA,
      Row(children: [
        ElevatedButton(
          onPressed: isDecryptButtonEnabled ? _decryptFileRSA : null,
          child: const Text("Asymmetric Decryption"),
        ),
        ElevatedButton(
          onPressed: _decryptedRSAFile == null
              ? null
              : () {
                  Clipboard.setData(
                      ClipboardData(text: _decryptedRSAFile!.path.replaceAll("/", "\\")));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Copied ${_decryptedRSAFile!.path.replaceAll("/", "\\")} to clipboard",
                      ),
                    ),
                  );
                },
          child: const Text("Copy path"),
        ),
      ]),
    ]);
  }

  Widget get _symmetricDecryptionWidget {
    return Column(children: [
      ..._decryptedTextWidgetAES,
      Row(children: [
        ElevatedButton(
          onPressed: isDecryptButtonEnabled ? _decryptFileAES : null,
          child: const Text("Symmetric Decryption"),
        ),
        ElevatedButton(
          onPressed: _decryptedAESFile == null
              ? null
              : () {
                  Clipboard.setData(
                      ClipboardData(text: _decryptedAESFile!.path.replaceAll("/", "\\")));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Copied ${_decryptedAESFile!.path.replaceAll("/", "\\")} to clipboard",
                      ),
                    ),
                  );
                },
          child: const Text("Copy path"),
        ),
      ]),
    ]);
  }

  List<Widget> get _decryptedTextWidgetRSA {
    TextStyle style = Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.green[200]);
    return wrap(
      "Decrypted text: ",
      FileContentsWidget(
        contentOverride: decryptedTextRSA.isNotEmpty ? decryptedTextRSA : "Not decrypted yet",
        styleOverride: decryptedTextRSA.isNotEmpty ? style : null,
        useErrorStyle: decryptedTextRSA.isEmpty,
        maxExtents: (horizontal: true, vertical: decryptedTextRSA.isNotEmpty),
      ),
    );
  }

  List<Widget> get _decryptedTextWidgetAES {
    TextStyle style = Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.green[200]);
    return wrap(
      "Decrypted text: ",
      FileContentsWidget(
        contentOverride: decryptedTextAES.isNotEmpty ? decryptedTextAES : "Not decrypted yet",
        styleOverride: decryptedTextAES.isNotEmpty ? style : null,
        useErrorStyle: decryptedTextAES.isEmpty,
        maxExtents: (horizontal: true, vertical: decryptedTextAES.isNotEmpty),
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
      File? result = await FileManager.saveToFile(
        getFileName("asymmetric"),
        await asymmetricDecryption(),
        createDir: true,
        additionalPath: "asymmetric_decryption",
      );
      if (mounted) setState(() => _decryptedRSAFile = result);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _decryptFileAES() async {
    if (selectedFile == null) return;
    try {
      File? result = await FileManager.saveToFile(
        getFileName("symmetric"),
        await symmetricDecryption(),
        createDir: true,
        additionalPath: "symmetric_decryption",
      );
      if (mounted) setState(() => _decryptedAESFile = result);
    } catch (e) {
      if (mounted)
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

    // extract IV from the first 16 bytes
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
