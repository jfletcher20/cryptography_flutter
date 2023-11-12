import 'package:cryptography_flutter/s_homepage/s_signature/w_sign.dart';
import 'package:cryptography_flutter/s_homepage/s_signature/w_verify.dart';
import 'package:flutter/material.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;

  final List<Widget> _tabs = const [Tab(text: "Sign"), Tab(text: "Verify")];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(controller: tabController, tabs: _tabs),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                Center(child: SignFileWidget()),
                Center(child: VerifySignatureWidget()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
