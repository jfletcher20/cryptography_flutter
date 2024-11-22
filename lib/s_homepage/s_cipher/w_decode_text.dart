import 'package:cryptography_flutter/data/u_cipher.dart';
import 'package:cryptography_flutter/w_contents_widget.dart';
import 'package:cryptography_flutter/w_file_contents.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DecodeTextWidget extends StatefulWidget {
  const DecodeTextWidget({super.key});

  @override
  State<DecodeTextWidget> createState() => _DecodeTextWidgetState();
}

class _DecodeTextWidgetState extends State<DecodeTextWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController tc = TextEditingController();
  String decodedText = "";

  @override
  void initState() {
    super.initState();
    tc.addListener(_decodeText);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        cipherShiftController,
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ContentsWidget(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Text to decode",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              controller: tc,
              maxLines: 3,
            ),
          ),
          _inputOptions,
          FileContentsWidget(
            contentOverride: decodedText.isEmpty ? "No text has been decoded" : decodedText,
            canBeCopied: decodedText.isNotEmpty,
            useErrorStyle: decodedText.isEmpty,
            maxExtents: (horizontal: true, vertical: true),
          ),
          _outputOptions,
        ])
      ],
    );
  }

  Widget get cipherShiftController {
    return SizedBox(
      width: 600,
      child: Column(
        children: [
          const Text("Cipher shift value", style: TextStyle(fontSize: 20)),
          Slider(
            label: Cipher.shift.toString(),
            divisions: 16,
            value: Cipher.shift.toDouble(),
            min: 0,
            max: 16,
            onChanged: (value) {
              setState(() => Cipher.shift = value.toInt());
              _decodeText();
            },
          ),
        ],
      ),
    );
  }

  Widget get _inputOptions {
    return Column(
      children: [
        IconButton(
          onPressed: () async {
            final ClipboardData? data = await Clipboard.getData("text/plain");
            if (data != null) setState(() => tc.text = data.text ?? "");
          },
          icon: const Icon(Icons.paste),
        ),
        if (tc.text.isNotEmpty)
          IconButton(
            onPressed: () {
              tc.clear();
              setState(() => decodedText = "");
            },
            icon: Icon(Icons.clear, color: Colors.red[200]!),
          ),
      ],
    );
  }

  Widget get _outputOptions {
    return IconButton(
      onPressed: decodedText.isEmpty
          ? null
          : () {
              Clipboard.setData(ClipboardData(text: decodedText));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Copied $decodedText to clipboard")),
              );
            },
      icon: const Icon(Icons.copy),
    );
  }

  void _decodeText() => setState(() => decodedText = Cipher.decode(tc.text));
}
