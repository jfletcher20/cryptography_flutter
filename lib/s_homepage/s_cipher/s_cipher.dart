import 'package:cryptography_flutter/s_homepage/s_cipher/w_decode_text.dart';
import 'package:cryptography_flutter/s_homepage/s_cipher/w_encode_text.dart';
import 'package:cryptography_flutter/s_homepage/s_tab_screen.dart';
import 'package:flutter/material.dart';

class CipherScreen extends StatelessWidget {
  const CipherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScreen(
      tabNames: const ["Encode", "Decode"],
      tabIcons: const [Icon(Icons.lock), Icon(Icons.lock_open)],
      children: const [EncodeTextWidget(), DecodeTextWidget()],
    );
  }
}
