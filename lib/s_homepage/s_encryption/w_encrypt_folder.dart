// ignore_for_file: prefer_void_to_null
import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/file_management/u_keys.dart';
import 'package:cryptography_flutter/w_file_contents.dart';

import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/api.dart';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math';
import 'dart:io';

class EncryptFolderWidget extends StatefulWidget {
  const EncryptFolderWidget({super.key});

  @override
  State<EncryptFolderWidget> createState() => _EncryptFolderWidgetState();
}

class _EncryptFolderWidgetState extends State<EncryptFolderWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Directory? selectedFolder;
  bool isEncryptButtonEnabled = false;
  String encryptedTextRSA = "", encryptedTextAES = "";

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        fileInput,
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _asymmetricEncryptionWidget,
            Opacity(
              opacity: 0,
              child: ElevatedButton(onPressed: _pickFolder, child: const Text("Select File")),
            ),
            _symmetricEncryptionWidget,
          ],
        )
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
            contentOverride: selectedFolder?.path ?? "None",
            useErrorStyle: selectedFolder == null,
            maxExtents: (horizontal: true, vertical: selectedFolder != null),
          ),
        ),
      ),
      ElevatedButton(onPressed: _pickFolder, child: const Text("Select File")),
      Column(
        children: wrap(
          "File contents: ",
          FileContentsWidget(
            contentOverride:
                selectedFolder != null ? selectedFolder?.path ?? "Folder selected" : "",
            useErrorStyle: selectedFolder == null,
            maxExtents: (horizontal: true, vertical: selectedFolder != null),
          ),
        ),
      ),
    ]);
  }

  File? _encryptedRSAFile, _encryptedAESFile;

  Widget get _asymmetricEncryptionWidget {
    return Column(children: [
      ..._encryptedTextRSAWidget,
      Row(children: [
        ElevatedButton(
          onPressed: isEncryptButtonEnabled ? _encryptFolderRSA : null,
          child: const Text("Asymmetric Encryption"),
        ),
        ElevatedButton(
          onPressed: _encryptedRSAFile == null
              ? null
              : () {
                  Clipboard.setData(
                      ClipboardData(text: _encryptedRSAFile!.path.replaceAll("/", "\\")));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Copied ${_encryptedRSAFile!.path.replaceAll("/", "\\")} to clipboard",
                      ),
                    ),
                  );
                },
          child: const Text("Copy path"),
        ),
      ]),
    ]);
  }

  Widget get _symmetricEncryptionWidget {
    return Column(children: [
      ..._encryptedTextAESWidget,
      Row(children: [
        ElevatedButton(
          onPressed: isEncryptButtonEnabled ? _encryptFolderAES : null,
          child: const Text("Symmetric Encryption"),
        ),
        ElevatedButton(
          onPressed: _encryptedAESFile == null
              ? null
              : () {
                  Clipboard.setData(
                      ClipboardData(text: _encryptedAESFile!.path.replaceAll("/", "\\")));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Copied ${_encryptedAESFile!.path.replaceAll("/", "\\")} to clipboard",
                      ),
                    ),
                  );
                },
          child: const Text("Copy path"),
        ),
      ]),
    ]);
  }

  List<Widget> get _encryptedTextRSAWidget {
    TextStyle style = Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.green[200]);
    return wrap(
      "Encrypted text: ",
      FileContentsWidget(
        contentOverride: encryptedTextRSA.isNotEmpty ? encryptedTextRSA : "Not encrypted yet.",
        styleOverride: encryptedTextRSA.isNotEmpty ? style : null,
        useErrorStyle: encryptedTextRSA.isEmpty,
        maxExtents: (horizontal: true, vertical: encryptedTextRSA.isNotEmpty),
      ),
    );
  }

  List<Widget> get _encryptedTextAESWidget {
    TextStyle style = Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.green[200]);
    return wrap(
      "Encrypted text: ",
      FileContentsWidget(
        contentOverride: encryptedTextAES.isNotEmpty ? encryptedTextAES : "Not encrypted yet.",
        styleOverride: encryptedTextAES.isNotEmpty ? style : null,
        useErrorStyle: encryptedTextAES.isEmpty,
        maxExtents: (horizontal: true, vertical: encryptedTextAES.isNotEmpty),
      ),
    );
  }

  List<Widget> wrap(String label, Widget child) {
    return [Text(label), child];
  }

  Future<void> _pickFolder() async {
    // Use FilePicker to allow folder selection.
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        selectedFolder = Directory(selectedDirectory);
        isEncryptButtonEnabled = true;
      });
    }
  }

  Future<void> _encryptFolderAES() async {
    Directory dir = selectedFolder!;
    if (await dir.exists()) {
      for (var file in dir.listSync()) {
        if (file is File) {
          String encryptedFileName = "${file.path}_encrypted_aes";
          String encryptedContent = await symmetricEncryption(file.path);
          await File(encryptedFileName).writeAsString(encryptedContent);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All files in folder encrypted with AES.")),
        );
      }
    }
  }

  Future<void> _encryptFolderRSA() async {
    try {
      Directory dir = selectedFolder!;
      if (await dir.exists()) {
        for (var file in dir.listSync()) {
          if (file is File) {
            String encryptedFileName = "${file.path}_encrypted_rsa";
            String encryptedContent = await asymmetricEncryption(file.path);
            await File(encryptedFileName).writeAsString(encryptedContent);
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("All files in folder encrypted with RSA.")),
          );
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error encrypting folder with RSA: $e")),
        );
      }
    }
  }

  String getFileName(String type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String originalFileName = selectedFolder!.path.split("\\").last.replaceAll(".txt", "");
    String fileName = "${originalFileName}_${type}_encryption_$timestamp.txt";
    return fileName;
  }

  Future<String> asymmetricEncryption(String filePath) async {
    String fileContents = FileManager.readFromFile(File(filePath));

    AsymmetricKeyParameter<RSAPublicKey> publicKey =
        PublicKeyParameter(await KeysManager.publicKey());

    RSAEngine cipher = RSAEngine();
    cipher.init(true, publicKey);

    Uint8List cipherText = cipher.process(Uint8List.fromList(fileContents.codeUnits));

    // Return encrypted data as a String or Uint8List, depending on your needs
    return String.fromCharCodes(cipherText);
  }

  Future<String> symmetricEncryption(String filePath) async {
    String fileContents = "" + FileManager.readFromFile(File(filePath)) + "\n";

    Uint8List secretKey = await KeysManager.secretKey();

    SecureRandom secureRandom = FortunaRandom();
    Random seedRandom = Random.secure();

    List<int> seeds = [];
    for (int i = 0; i < 32; i++) seeds.add(seedRandom.nextInt(256));

    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    Uint8List iv = secureRandom.nextBytes(16);

    CBCBlockCipher cipher = CBCBlockCipher(AESEngine());
    ParametersWithIV<KeyParameter> keyParameters = ParametersWithIV(KeyParameter(secretKey), iv);

    PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null> params =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(keyParameters, null);

    cipher.init(true, keyParameters);

    PaddedBlockCipherImpl cipherImpl = PaddedBlockCipherImpl(PKCS7Padding(), cipher);
    cipherImpl.init(true, params);

    Uint8List cipherText = cipherImpl.process(Uint8List.fromList(fileContents.codeUnits));

    // Prepend the IV to the ciphertext (for later decryption)
    Uint8List result = Uint8List.fromList([...iv, ...cipherText]);

    // Return encrypted data as a String or Uint8List, depending on your needs
    return String.fromCharCodes(result);
  }

  Uint8List pad(Uint8List bytes, int blockSize) {
    int padLength = blockSize - (bytes.length % blockSize);
    Uint8List padded = Uint8List(bytes.length + padLength)..setAll(0, bytes);
    PKCS7Padding().addPadding(padded, bytes.length);
    return padded;
  }
}
