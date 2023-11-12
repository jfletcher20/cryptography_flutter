import 'dart:convert';
import 'dart:math';

import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/export.dart' as crypto;
import 'package:pointycastle/impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
import 'package:pointycastle/random/fortuna_random.dart';

class KeysScreen extends StatefulWidget {
  const KeysScreen({super.key});

  @override
  State<KeysScreen> createState() => _KeysScreenState();
}

class _KeysScreenState extends State<KeysScreen> {
  String public = "javni_kljuc.txt";
  String private = "privatni_kljuc.txt";
  String secret = "tajni_kljuc.txt";

  GlobalKey<FileContentsWidgetState> publicKey = GlobalKey();
  GlobalKey<FileContentsWidgetState> privateKey = GlobalKey();
  GlobalKey<FileContentsWidgetState> secretKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          wrap("Public key: ", FileContentsWidget(key: publicKey, fileName: public)),
          wrap("Private key: ", FileContentsWidget(key: privateKey, fileName: private)),
        ]),
        ElevatedButton(
            onPressed: () => genAsymmetricKeys(), child: const Text("Generate Asymmetric keys")),
        const SizedBox(height: 64),
        wrap("Secret key: ", FileContentsWidget(key: secretKey, fileName: secret)),
        ElevatedButton(
            onPressed: () async => await genSecretKey(), child: const Text("Generate Secret Key")),
      ],
    );
  }

  Widget wrap(String label, Widget child) {
    return Column(children: [
      Text(label),
      Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 100, maxWidth: 500),
        child: SingleChildScrollView(child: child),
      ),
    ]);
  }

  (RSAKeyGeneratorParameters, FortunaRandom) _keyParametersRSA() {
    RSAKeyGeneratorParameters keyParams = RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 5);
    FortunaRandom secureRandom = FortunaRandom();
    Random seedRandom = Random.secure();

    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedRandom.nextInt(256));
    }

    // alternatively, generate according to username as seed:
    /* for (int i = 0; i < Auth.currentUser.username.length - 1; i++) {
          seeds.add(Auth.currentUser.username.codeUnitAt(i));
        }
        for (int i = seeds.length; i < 32; i++) {
          seeds.add(0);
        } */

    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    return (keyParams, secureRandom);
  }

  Future<void> genAsymmetricKeys() async {
    // secure random key generator
    (RSAKeyGeneratorParameters, FortunaRandom) keyParameters = _keyParametersRSA();

    var rngParams = ParametersWithRandom(keyParameters.$1, keyParameters.$2);
    var k = crypto.RSAKeyGenerator();
    k.init(rngParams);

    AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = k.generateKeyPair();

    AsymmetricKeyParameter<RSAPublicKey> publicKey = PublicKeyParameter(keyPair.publicKey);
    AsymmetricKeyParameter<RSAPrivateKey> privateKey = PrivateKeyParameter(keyPair.privateKey);

    await savePublicKey("${publicKey.key.exponent},${publicKey.key.modulus}");
    await savePrivateKey("${privateKey.key.privateExponent},${privateKey.key.modulus},"
        "${privateKey.key.p},${privateKey.key.q}");

    setState(() {});
  }

  Future<void> genSecretKey() async {
    AESEngine aes = AESEngine();
    SecureRandom secureRandom = FortunaRandom();
    Random seedRandom = Random.secure();

    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedRandom.nextInt(256));
    }

    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    KeyParameter params = KeyParameter(secureRandom.nextBytes(32));
    List<List<int>>? key = aes.generateWorkingKey(true, params);

    // Convert the key to a byte list
    Uint8List keyBytes = Uint8List.fromList(key!.expand((e) => e).toList());

    // Encode the key as a Base64-encoded string
    String encodedKey = base64.encode(params.key);

    List<List<int>>? decodedKey =
        aes.generateWorkingKey(true, KeyParameter(base64.decode(encodedKey)));
    print(key!.expand((e) => e).toList());
    print(decodedKey!.expand((e) => e).toList());

    await saveSecretKey(encodedKey);
    setState(() {});
  }

  Future<void> savePublicKey(String publicKey) async {
    await FileManager.saveToFile(public, publicKey);
  }

  Future<void> savePrivateKey(String privateKey) async {
    await FileManager.saveToFile(private, privateKey);
  }

  Future<void> saveSecretKey(String secretKey) async {
    await FileManager.saveToFile(secret, secretKey);
  }
}
