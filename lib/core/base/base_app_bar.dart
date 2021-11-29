import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/router/router.dart';

/// Custom app bar
class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  final VoidCallback? onBackPressed;

  final double? elevation;

  final bool useThemeColor;

  final bool useCloseIcon;

  final List<Widget>? actions;

  const BaseAppBar({
    Key? key,
    this.title,
    this.onBackPressed,
    this.elevation,
    this.useThemeColor = false,
    this.useCloseIcon = false,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actionsIconTheme: const IconThemeData(color: Colors.black),
      backgroundColor:
          useThemeColor ? Theme.of(context).primaryColor : Colors.white,
      elevation: elevation ?? (Platform.isAndroid ? 0.2 : 0.5),
      leading: IconButton(
        icon: Icon(
          useCloseIcon ? Icons.close : Icons.chevron_left,
          size: useCloseIcon ? 28 : 32,
          color: useThemeColor ? Colors.white : Colors.grey[850],
        ),
        onPressed: onBackPressed ?? () => XRouter.pop(),
      ),
      centerTitle: true,
      title: Text(title ?? '',
          style: TextStyle(
              color: useThemeColor ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500)),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
