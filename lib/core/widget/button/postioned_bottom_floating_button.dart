import 'dart:io';

import 'package:flutter/material.dart';

import '/core/widget/clickable.dart';
import '/core/widget/container/shadow_container.dart';
import '../../app_theme.dart';

class PositionedBottomFloatingButton extends StatelessWidget {
  const PositionedBottomFloatingButton(this.text,
      {Key? key, this.onPressed, this.containerDecoration})
      : super(key: key);

  final String text;

  final VoidCallback? onPressed;

  final BoxDecoration? containerDecoration;

  @override
  Widget build(BuildContext context) {
    var paddingBottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 30,
      right: 30,
      bottom: paddingBottom + (Platform.isAndroid ? 10 : 0),
      child: ShadowContainer(
        color: appColor[50],
        child: Clickable(
          onPressed: () {
            onPressed?.call();
          },
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: containerDecoration ??
                BoxDecoration(
                  color: appColor,
                  borderRadius: BorderRadius.circular(8),
                ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
