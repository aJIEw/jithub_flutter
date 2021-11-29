import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DefaultDivider extends StatelessWidget {
  static const defaultColor = Color(0xFFC7C7C7);

  final double height;

  final double thickness;

  final Color color;

  const DefaultDivider(this.thickness,
      {Key? key, this.height = 1, this.color = defaultColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Divider(color: Colors.grey[300], thickness: 0.1);
    }
    return Divider(height: height, thickness: thickness, color: color);
  }
}

class DefaultVerticalDivider extends StatelessWidget {
  static const defaultColor = Color(0xFFF4F4F4);

  final double width;

  final double thickness;

  final Color color;

  const DefaultVerticalDivider(this.thickness,
      {Key? key, this.width = 1, this.color = defaultColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return VerticalDivider(color: Colors.grey[300], thickness: 0.1);
    }
    return VerticalDivider(width: width, thickness: thickness, color: color);
  }
}
