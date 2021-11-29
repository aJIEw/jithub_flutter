import 'package:flutter/material.dart';

class TranslucentContainer extends StatelessWidget {
  const TranslucentContainer(
      {Key? key,
      this.padding = const EdgeInsets.all(8),
      this.translucentColor = Colors.black38,
      this.borderRadius = 5,
      required this.child})
      : super(key: key);

  final EdgeInsetsGeometry padding;

  final Color translucentColor;

  final double borderRadius;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: translucentColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
