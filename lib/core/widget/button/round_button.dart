import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    this.size,
    this.backgroundColor,
    this.borderRadius = 5,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    required this.onPressed,
    required this.child,
  });

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
        minimumSize: WidgetStateProperty.all(
          size ?? Size(theme.minWidth, theme.height),
        ),
        padding: WidgetStateProperty.all(padding),
        backgroundColor: WidgetStateProperty.all(
          backgroundColor ?? Theme.of(context).primaryColor,
        ),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        splashFactory: NoSplash.splashFactory,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
