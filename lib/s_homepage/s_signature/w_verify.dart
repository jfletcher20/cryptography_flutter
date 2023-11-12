import 'package:flutter/material.dart';

class VerifySignatureWidget extends StatefulWidget {
  const VerifySignatureWidget({super.key});

  @override
  State<VerifySignatureWidget> createState() => _VerifySignatureWidgetState();
}

class _VerifySignatureWidgetState extends State<VerifySignatureWidget> {
  @override
  Widget build(BuildContext context) {
    return Text("Verify a signature.");
  }
}
