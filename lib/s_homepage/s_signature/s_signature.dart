import 'package:cryptography_flutter/s_homepage/s_signature/w_verify.dart';
import 'package:cryptography_flutter/s_homepage/s_signature/w_sign.dart';
import 'package:cryptography_flutter/s_homepage/s_tab_screen.dart';
import 'package:flutter/material.dart';

class SignatureScreen extends StatelessWidget {
  const SignatureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabScreen(
      tabNames: const ["Sign", "Verify"],
      children: const [
        SignFileWidget(),
        VerifySignatureWidget(),
      ],
    );
  }
}
