import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  const RoundButton(
      {Key? key,
      this.size,
      this.backgroundColor,
      this.borderRadius = 5,
      this.padding = const EdgeInsets.symmetric(horizontal: 10),
      required this.onPressed,
      required this.child})
      : super(key: key);

  final Size? size;

  final Color? backgroundColor;

  final double borderRadius;

  final EdgeInsetsGeometry padding;

  final VoidCallback onPressed;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).buttonTheme;
    return ElevatedButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(
              size ?? Size(theme.minWidth, theme.height)),
          padding: MaterialStateProperty.all(padding),
          backgroundColor: MaterialStateProperty.all(
              backgroundColor ?? Theme.of(context).primaryColor),
          elevation: MaterialStateProperty.all(0),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius))),
          splashFactory: NoSplash.splashFactory,
        ),
        onPressed: onPressed,
        child: child);
  }
}
