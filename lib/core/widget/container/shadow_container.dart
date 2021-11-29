import 'package:flutter/material.dart';

class ShadowContainer extends StatelessWidget {
  const ShadowContainer(
      {Key? key,
      this.color = const Color(0xFFE0E0E0),
      this.offsetX = 0.0,
      this.offsetY,
      required this.child})
      : super(key: key);

  final color;

  final double offsetX;

  final double? offsetY;

  final child;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 20,
            offset:
                Offset(offsetX, offsetY ?? 10), // changes position of shadow
          ),
        ],
      ),
    );
  }
}
