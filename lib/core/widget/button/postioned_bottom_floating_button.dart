import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jithub_flutter/core/app_theme.dart';
import 'package:jithub_flutter/core/widget/clickable.dart';
import 'package:jithub_flutter/core/widget/container/shadow_container.dart';

class PositionedBottomFloatingButton extends StatelessWidget {
  const PositionedBottomFloatingButton(
    this.text, {
    super.key,
    this.onPressed,
    this.containerDecoration,
  });

  final String text;

  final VoidCallback? onPressed;

  final BoxDecoration? containerDecoration;

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 30,
      right: 30,
      bottom: paddingBottom + (Platform.isAndroid ? 10 : 0),
      child: ShadowContainer(
        color: appColor[50] ?? appColor,
        child: Clickable(
          onPressed: () {
            onPressed?.call();
          },
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration:
                containerDecoration ??
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
