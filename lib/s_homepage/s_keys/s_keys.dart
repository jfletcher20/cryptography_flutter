import 'dart:math';

import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/s_auth/u_auth.dart';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/export.dart' as crypto;
import 'package:pointycastle/impl.dart';
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
        ...wrap("Public key: ", FileContentsWidget(key: publicKey, file: public)),
        ...wrap("Private key: ", FileContentsWidget(key: privateKey, file: private)),
        ElevatedButton(onPressed: () => genAsymmetricKeys(), child: const Text('Asymmetric keys')),
        ...wrap("Secret key: ", FileContentsWidget(key: secretKey, file: secret)),
        ElevatedButton(onPressed: () => genSecretKey(), child: const Text('Secret Key')),
      ],
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

  (RSAKeyGeneratorParameters, FortunaRandom) _keyParameters() {
    RSAKeyGeneratorParameters keyParams = RSAKeyGeneratorParameters(BigInt.from(3), 2048, 5);
    FortunaRandom secureRandom = FortunaRandom();
    Random seedRandom = Random.secure();

    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedRandom.nextInt(256));
    }

    // alternatively, generate according to username:
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
    (RSAKeyGeneratorParameters, FortunaRandom) keyParams = _keyParameters();

    var rngParams = ParametersWithRandom(keyParams.$1, keyParams.$2);
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

  Future<void> savePublicKey(String publicKey) async {
    await FileManager.saveToFile(public, publicKey);
  }

  Future<void> savePrivateKey(String privateKey) async {
    await FileManager.saveToFile(private, privateKey);
  }

  Future<void> genSecretKey() async {
    String secretKey = Auth.currentUser.username;
    await FileManager.saveToFile(secret, secret + secretKey);
    setState(() {});
  }
}
