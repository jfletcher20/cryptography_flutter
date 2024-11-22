import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:file_picker/file_picker.dart';
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

class _KeysScreenState extends State<KeysScreen> with SingleTickerProviderStateMixin {
  String public = "public_key.txt";
  String private = "private_key.txt";
  String secret = "secret_key.txt";

  GlobalKey<FileContentsWidgetState> publicKey = GlobalKey();
  GlobalKey<FileContentsWidgetState> privateKey = GlobalKey();
  GlobalKey<FileContentsWidgetState> secretKey = GlobalKey();

  late TabController tabController;
  final List<Widget> _tabs = const [Tab(text: "Asymmetric Keys"), Tab(text: "Symmetric Keys")];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(controller: tabController, tabs: _tabs),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Column(children: [
                      wrap("Public key: ", FileContentsWidget(key: publicKey, fileName: public)),
                      wrap("Private key: ", FileContentsWidget(key: privateKey, fileName: private)),
                    ]),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        Row(children: [
                          const Icon(Icons.create),
                          ElevatedButton(
                            onPressed: () => genAsymmetricKeys(),
                            child: const Text("Generate Asymmetric Keys"),
                          ),
                        ]),
                        Row(children: [
                          const Icon(Icons.public),
                          ElevatedButton(
                            onPressed: () => importPublicKey(),
                            child: const Text("Import Public Key"),
                          ),
                        ]),
                        Row(
                          children: [
                            const Icon(Icons.security_rounded),
                            ElevatedButton(
                              onPressed: () => importPrivateKey(),
                              child: const Text("Import Private Key"),
                            ),
                          ],
                        )
                      ]),
                    ),
                  ]),
                ],
              ),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  wrap("Secret key: ", FileContentsWidget(key: secretKey, fileName: secret)),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.create),
                        ElevatedButton(
                          onPressed: () async => await genSecretKey(),
                          child: const Text("Generate Secret Key"),
                        ),
                      ]),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.import_export),
                        ElevatedButton(
                          onPressed: () async => await importSecretKey(),
                          child: const Text("Import Secret Key"),
                        ),
                      ]),
                    ]),
                  ),
                ]),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget wrap(String label, Widget child) {
    return Column(children: [Text(label), child]);
  }

  (RSAKeyGeneratorParameters, FortunaRandom) _keyParametersRSA() {
    RSAKeyGeneratorParameters keyParams = RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 5);
    FortunaRandom secureRandom = FortunaRandom();
    Random seedRandom = Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) seeds.add(seedRandom.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return (keyParams, secureRandom);
  }

  Future<void> genAsymmetricKeys() async {
    bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Generate Asymmetric Keys"),
          content: const Text("Are you sure you want to generate new asymmetric keys? "
              "This will overwrite any existing keys."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmation != true) return;

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
    bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Generate Secret Key"),
          content: const Text("Are you sure you want to generate a new secret key? "
              "This will overwrite any existing key."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmation != true) return;

    SecureRandom secureRandom = FortunaRandom();
    Random seedRandom = Random.secure();

    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedRandom.nextInt(256));
    }

    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    KeyParameter params = KeyParameter(secureRandom.nextBytes(32));
    String encodedKey = base64.encode(params.key);

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

  Future<void> importPublicKey() async {
    String? publicKey = await _importKey();
    if (publicKey != null && isValidPublicKey(publicKey)) {
      await savePublicKey(publicKey);
    } else {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid public key")));
    }
    setState(() {});
  }

  Future<void> importPrivateKey() async {
    String? privateKey = await _importKey();
    if (privateKey != null && isValidPrivateKey(privateKey)) {
      await savePrivateKey(privateKey);
    } else {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid private key")));
    }
    setState(() {});
  }

  Future<void> importSecretKey() async {
    String? secretKey = await _importKey();
    if (secretKey != null && isValidSecretKey(secretKey)) {
      await saveSecretKey(secretKey);
    } else {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid secret key")));
    }
    setState(() {});
  }

  bool isValidPrivateKey(String key) {
    List<String> parts = key.split(",");
    if (parts.length != 4) return false;
    try {
      BigInt.parse(parts[0].trim());
      BigInt.parse(parts[1]);
      BigInt.parse(parts[2].trim());
    } catch (e) {
      return false;
    }
    return true;
  }

  bool isValidPublicKey(String key) {
    List<String> parts = key.split(",");
    if (parts.length != 2) return false;
    try {
      BigInt.parse(parts[0]);
      BigInt.parse(parts[1]);
    } catch (e) {
      return false;
    }
    return true;
  }

  bool isValidSecretKey(String key) {
    try {
      base64.decode(key);
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<String?> _importKey() async {
    String? key;
    try {
      key = await FilePicker.platform.pickFiles().then((result) async {
        if (result != null) return File(result.files.single.path!).readAsString();
        return null;
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    return key;
  }
}
