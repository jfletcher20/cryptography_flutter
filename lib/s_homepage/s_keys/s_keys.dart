import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:cryptography_flutter/s_auth/u_auth.dart';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:flutter/material.dart';

class KeysScreen extends StatefulWidget {
  const KeysScreen({super.key});

  @override
  State<KeysScreen> createState() => _KeysScreenState();
}

class _KeysScreenState extends State<KeysScreen> {
  String public = "javni_kljuc.txt";
  String private = "privatni_kljuc.txt";
  String secret = "tajni_kljuc.txt";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FileContentsWidget(file: public),
        ElevatedButton(onPressed: () => genPublicKey(), child: const Text('Public Key')),
        FileContentsWidget(file: private),
        ElevatedButton(onPressed: () => genPrivateKey(), child: const Text('Private Key')),
        FileContentsWidget(file: secret),
        ElevatedButton(onPressed: () => genSecretKey(), child: const Text('Secret Key')),
      ],
    );
  }

  void genPublicKey() async {
    String publicKey = Auth.currentUser.username;
    await FileManager.saveToFile(public, public + publicKey);
    setState(() {});
  }

  void genPrivateKey() async {
    String privateKey = Auth.currentUser.username;
    await FileManager.saveToFile(private, private + privateKey);
    setState(() {});
  }

  void genSecretKey() async {
    String secretKey = Auth.currentUser.username;
    await FileManager.saveToFile(secret, secret + secretKey);
    setState(() {});
  }
}
