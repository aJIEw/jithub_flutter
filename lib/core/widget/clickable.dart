import 'package:flutter/material.dart';

class Clickable extends StatelessWidget {
  final Widget child;

  final VoidCallback onPressed;

  const Clickable({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      onTap: onPressed,
      child: child,
    );
  }
}
