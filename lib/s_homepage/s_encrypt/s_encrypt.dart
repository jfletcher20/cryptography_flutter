import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/file_management/u_keys.dart';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
import 'package:pointycastle/random/fortuna_random.dart';

class EncryptScreen extends StatefulWidget {
  const EncryptScreen({super.key});

  @override
  State<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends State<EncryptScreen> {
  File? selectedFile;
  bool isEncryptButtonEnabled = false;
  String encryptedTextRSA = "", encryptedTextAES = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...wrap("Selected file: ", Text(selectedFile?.path ?? "None")),
        ...wrap("File contents: ", FileContentsWidget(file: selectedFile)),
        ElevatedButton(onPressed: _pickFile, child: const Text("Select File")),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _asymmetricEncryptionWidget,
            const SizedBox(width: 64),
            _symmetricEncryptionWidget,
          ],
        )
      ],
    );
  }

  Widget get _asymmetricEncryptionWidget {
    return Column(children: [
      if (encryptedTextRSA.isNotEmpty) ..._encryptedTextRSAWidget,
      ElevatedButton(
        onPressed: isEncryptButtonEnabled ? _encryptFileRSA : null,
        child: const Text("Asymmetric Encryption"),
      ),
    ]);
  }

  Widget get _symmetricEncryptionWidget {
    return Column(children: [
      if (encryptedTextAES.isNotEmpty) ..._encryptedTextAESWidget,
      ElevatedButton(
        onPressed: isEncryptButtonEnabled ? _encryptFileAES : null,
        child: const Text("Symmetric Encryption"),
      ),
    ]);
  }

  List<Widget> get _encryptedTextRSAWidget {
    TextStyle style = Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.green[200]);
    return wrap(
      "Encrypted text: ",
      Text(encryptedTextRSA, style: style),
    );
  }

  List<Widget> get _encryptedTextAESWidget {
    TextStyle style = Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.green[200]);
    return wrap(
      "Encrypted text: ",
      Text(encryptedTextAES, style: style),
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
        isEncryptButtonEnabled = true;
      });
    }
  }

  String getFileName(String type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String originalFileName = selectedFile!.path.split("\\").last.replaceAll(".txt", "");
    String fileName = "${originalFileName}_${type}_encryption_$timestamp.txt";
    return fileName;
  }

  Future<void> _encryptFileAES() async {
    if (selectedFile == null) return;
    try {
      await FileManager.saveToFile(
        getFileName("symmetric"),
        await symmetricEncryption(),
        additionalPath: "symmetric_encryption",
        createDir: true,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _encryptFileRSA() async {
    if (selectedFile == null) return;
    try {
      await FileManager.saveToFile(
        getFileName("asymmetric"),
        await asymmetricEncryption(),
        additionalPath: "asymmetric_encryption",
        createDir: true,
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<String> asymmetricEncryption() async {
    String fileContents = FileManager.readFromFile(selectedFile!);

    AsymmetricKeyParameter<RSAPublicKey> publicKey =
        PublicKeyParameter(await KeysManager.publicKey());

    RSAEngine cipher = RSAEngine();
    cipher.init(true, publicKey);

    Uint8List cipherText = cipher.process(Uint8List.fromList(fileContents.codeUnits));
    setState(() {
      encryptedTextRSA = String.fromCharCodes(cipherText);
    });

    return String.fromCharCodes(cipherText);
  }

  Future<String> symmetricEncryption() async {
    String fileContents = FileManager.readFromFile(selectedFile!);

    Uint8List secretKey = await KeysManager.secretKey();

    SecureRandom secureRandom = FortunaRandom();
    Random seedRandom = Random.secure();

    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedRandom.nextInt(256));
    }

    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    Uint8List iv = secureRandom.nextBytes(16);

    CBCBlockCipher cipher = CBCBlockCipher(AESEngine());
    ParametersWithIV<KeyParameter> keyParameters = ParametersWithIV(KeyParameter(secretKey), iv);

    PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null> params =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(keyParameters, null);

    cipher.init(true, keyParameters);

    PaddedBlockCipherImpl cipherImpl = PaddedBlockCipherImpl(PKCS7Padding(), cipher);
    cipherImpl.init(true, params);

    Uint8List cipherText =
        cipherImpl.process(Uint8List.fromList(Uint8List.fromList(fileContents.codeUnits)));

    // Prepend the IV to the ciphertext (for later decryption)
    Uint8List result = Uint8List.fromList([...iv, ...cipherText]);

    setState(() {
      encryptedTextAES = String.fromCharCodes(result);
    });

    return String.fromCharCodes(result);
  }

  Uint8List pad(Uint8List bytes, int blockSize) {
    int padLength = blockSize - (bytes.length % blockSize);
    Uint8List padded = Uint8List(bytes.length + padLength)..setAll(0, bytes);
    PKCS7Padding().addPadding(padded, bytes.length);
    return padded;
  }
}
