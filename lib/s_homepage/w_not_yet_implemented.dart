import 'package:flutter/material.dart';

class NotYetImplementedWidget extends StatelessWidget {
  final String text;
  const NotYetImplementedWidget({super.key, this.text = "Not yet implemented"});

  @override
  Widget build(BuildContext context) {
    TextStyle? style = Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.red[200]);
    return Center(
      child: Text(text, style: style),
    );
  }
}
