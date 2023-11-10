// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:cryptography_flutter/s_auth/u_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileContentsWidget extends StatefulWidget {
  final String file;
  const FileContentsWidget({super.key, required this.file});

  @override
  State<FileContentsWidget> createState() => _FileContentsWidgetState();
}

class _FileContentsWidgetState extends State<FileContentsWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) =>
          snapshot.hasData ? Text(snapshot.data.toString()) : const CircularProgressIndicator(),
      future: _readFileContents(),
    );
  }

  Future<String> _readFileContents() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/${Auth.userPath}/${widget.file}');
      final String data = await file.readAsString();
      return data;
    } catch (e) {
      return 'File does not exist';
    }
  }
}
