import 'package:cryptography_flutter/s_homepage/s_signature/w_sign.dart';
import 'package:cryptography_flutter/s_homepage/s_signature/w_verify.dart';
import 'package:flutter/material.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  late TabController tabController;

  final List<Widget> _tabs = const [Tab(text: "Sign"), Tab(text: "Verify")];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: NavigatorState());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: _tabs,
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [SignFileWidget(), VerifySignatureWidget()],
          ),
        ),
      ],
    );
  }
}
