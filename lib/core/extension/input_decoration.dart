import 'package:flutter/material.dart';

extension InputDecorationExtension on InputDecoration {
  /// Add clear icon for InputDecoration
  /// Use it in a stateful widget, call setState to change [input] inside onChange,
  /// also call setState() and clear [input] in [clearText].
  InputDecoration addClearableIcon(String input, Function clearText) {
    return copyWith(
      border: const UnderlineInputBorder(),
      suffixIcon: input.isEmpty
          ? null
          : IconButton(
              onPressed: () => clearText(),
              icon: ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                child: Container(
                  color: Colors.grey,
                  width: 20,
                  height: 20,
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
    );
  }
}
