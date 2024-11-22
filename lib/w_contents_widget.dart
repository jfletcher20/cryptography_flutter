import 'package:flutter/material.dart';

class ContentsWidget extends StatelessWidget {
  final Widget child;
  final bool isValid;
  final ({bool horizontal, bool vertical}) maxExtents;
  const ContentsWidget({
    super.key,
    required this.child,
    this.isValid = true,
    this.maxExtents = (
      horizontal: true,
      vertical: false,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: isValid ? Colors.purpleAccent : Colors.red[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: BoxConstraints(
        maxHeight: 100,
        maxWidth: 300,
        minWidth: maxExtents.horizontal ? 300 : 0,
        minHeight: maxExtents.vertical ? 100 : 0,
      ),
      child: SingleChildScrollView(child: child),
    );
  }
}
