import 'dart:io';

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
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data.toString());
        } else {
          return const CircularProgressIndicator();
        }
      },
      future: _readFileContents(),
    );
  }

  Future<String> _readFileContents() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/${widget.file}');
      return file.readAsString();
    } catch (e) {
      return 'File does not exist';
    }
  }
}
