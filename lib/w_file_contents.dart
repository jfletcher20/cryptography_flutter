// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:cryptography_flutter/s_auth/u_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileContentsWidget extends StatefulWidget {
  final File? file;
  final String? fileName;
  final bool canBeCopied;
  const FileContentsWidget({super.key, this.fileName, this.file, this.canBeCopied = true});

  @override
  State<FileContentsWidget> createState() => FileContentsWidgetState();
}

class FileContentsWidgetState extends State<FileContentsWidget> {
  String fileContents = "";

  @override
  Widget build(BuildContext context) {
    final TextStyle style = Theme.of(context).textTheme.displaySmall!;
    if (widget.file == null && widget.fileName == null)
      return Text("No file was specified.", style: style.copyWith(color: Colors.red[200]));
    else if (widget.fileName != null)
      return FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            fileContents = snapshot.data as String;
            if (fileContents == "-1") {
              return Text(
                "File does not exist",
                style: style.copyWith(color: Colors.red[200]),
              );
            } else {
              fileContents = snapshot.data as String;
              return Text(fileContents, style: style);
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
        future: _readFileContents(),
      );
    else {
      fileContents = widget.file!.readAsStringSync();
      return Text(fileContents, style: style);
    }
  }

  Future<String> _readFileContents() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File("${directory.path}/${Auth.userPath}/${widget.fileName}");
      final String data = await file.readAsString();
      return data;
    } catch (e) {
      return "-1";
    }
  }
}
