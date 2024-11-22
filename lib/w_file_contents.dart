// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:cryptography_flutter/s_auth/u_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FileContentsWidget extends StatefulWidget {
  final File? file;
  final String? fileName;
  final bool canBeCopied;
  final int? maxLines;
  final String contentOverride;
  final TextStyle? styleOverride;
  final bool useErrorStyle;
  final ({bool horizontal, bool vertical}) maxExtents;
  const FileContentsWidget({
    super.key,
    this.fileName,
    this.file,
    this.maxLines,
    this.contentOverride = "",
    this.styleOverride,
    this.canBeCopied = true,
    this.useErrorStyle = false,
    this.maxExtents = (
      horizontal: true,
      vertical: false,
    ),
  });

  @override
  State<FileContentsWidget> createState() => FileContentsWidgetState();
}

class FileContentsWidgetState extends State<FileContentsWidget> {
  String fileContents = "";

  bool get isValid =>
      !widget.useErrorStyle &&
      (widget.contentOverride.isNotEmpty ||
          widget.canBeCopied &&
              fileContents != "-1" &&
              !(widget.file == null && widget.fileName == null));

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isValid
          ? () {
              if (widget.canBeCopied) {
                Clipboard.setData(ClipboardData(text: widget.contentOverride + fileContents));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Copied to clipboard")),
                );
              }
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: isValid ? Colors.purpleAccent : Colors.red[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxHeight: 100,
          maxWidth: 300,
          minWidth: widget.maxExtents.horizontal ? 300 : 0,
          minHeight: widget.maxExtents.vertical ? 100 : 0,
        ),
        child: SingleChildScrollView(
          child: widget.contentOverride.isNotEmpty
              ? Text(widget.contentOverride,
                  style: widget.useErrorStyle
                      ? style.copyWith(color: Colors.red[200])
                      : widget.styleOverride ?? style)
              : _fileContents,
        ),
      ),
    );
  }

  TextStyle get style => Theme.of(context).textTheme.displaySmall!;

  Widget get _fileContents {
    if (widget.file == null && widget.fileName == null)
      return Text("No file was specified.", style: style.copyWith(color: Colors.red[200]));
    else if (widget.fileName != null)
      return FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            fileContents = snapshot.data as String;
            return (fileContents == "-1")
                ? Text(
                    maxLines: widget.maxLines,
                    "File does not exist",
                    style: style.copyWith(color: Colors.red[200]),
                  )
                : Text(
                    maxLines: widget.maxLines,
                    fileContents,
                    style: widget.useErrorStyle ? style.copyWith(color: Colors.red[200]) : style,
                  );
          } else {
            return const CircularProgressIndicator();
          }
        },
        future: _readFileContents(),
      );
    else {
      fileContents = widget.file!.readAsStringSync();
      return Text(
        fileContents,
        style: widget.useErrorStyle ? style.copyWith(color: Colors.red[200]) : style,
      );
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
