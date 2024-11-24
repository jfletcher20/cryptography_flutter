import 'package:cryptography_flutter/s_homepage/s_encryption/w_decrypt.dart';
import 'package:cryptography_flutter/s_homepage/s_encryption/w_encrypt.dart';
import 'package:cryptography_flutter/s_homepage/s_encryption/w_encrypt_folder.dart';
import 'package:cryptography_flutter/s_homepage/s_tab_screen.dart';

import 'package:flutter/material.dart';

class EncryptionScreen extends StatelessWidget {
  const EncryptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScreen(
      tabNames: const ["Encrypt", "Decrypt", "Encrypt Folder"],
      tabIcons: const [
        Icon(Icons.enhanced_encryption),
        Icon(Icons.no_encryption),
        Icon(Icons.folder_special)
      ],
      children: const [EncryptWidget(), DecryptWidget(), EncryptFolderWidget()],
    );
  }
}
