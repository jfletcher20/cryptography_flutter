import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography_flutter/file_management/u_file_creation.dart';
import 'package:pointycastle/export.dart';

class KeysManager {
  static Future<PublicKey> publicKey() async {
    String publicKey;
    (publicKey, _) = await FileManager.readAsymmetricKeyFromFile();
    BigInt publicExp = BigInt.parse(publicKey.split(",").first);
    BigInt publicMod = BigInt.parse(publicKey.split(",").last);
    return RSAPublicKey(publicMod, publicExp);
  }

  static Future<PrivateKey> privateKey() async {
    String privateKey;
    (_, privateKey) = await FileManager.readAsymmetricKeyFromFile();
    List<String> privateKeyList = privateKey.split(",");
    BigInt exp = BigInt.parse(privateKeyList[0]);
    BigInt mod = BigInt.parse(privateKeyList[1]);
    BigInt? p = BigInt.parse(privateKeyList[2]);
    BigInt? q = BigInt.parse(privateKeyList[3]);
    return RSAPrivateKey(mod, exp, p, q);
  }

  static Future<Uint8List> secretKey() async {
    String secretKey = await FileManager.readSecretKeyFromFile();
    Uint8List decodedKeyBytes = base64.decode(secretKey);
    return decodedKeyBytes;
  }
}
