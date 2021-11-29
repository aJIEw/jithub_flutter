import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'container/translucent_container.dart';

class CupertinoLoadingIndicator extends StatelessWidget {
  const CupertinoLoadingIndicator({
    Key? key,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return TranslucentContainer(
        padding: padding,
        child: Theme(
            data: ThemeData(
                cupertinoOverrideTheme:
                    const CupertinoThemeData(brightness: Brightness.dark)),
            child: const CupertinoActivityIndicator()));
  }
}
