import 'dart:io';

import 'package:flutter/material.dart' as framework;
import 'package:get/get.dart';
import 'package:jithub_flutter/core/util/sputils.dart';
import 'package:jithub_flutter/i18n/i18n.dart';
import 'package:material_ui/material_ui.dart';

const _appColor = 0xFF05A9F4;

const appColor = MaterialColor(_appColor, <int, Color>{
  50: Color(0xFFD4DFE5),
  100: Color(0xFF9ECCE2),
  200: Color(0xFF80CBEE),
  300: Color(0xFF55BAE7),
  400: Color(0xFF2FAFEC),
  500: Color(0xFF05A9F4), // app color
  600: Color(0xFF068FCE),
  700: Color(0xFF0471A1),
  800: Color(0xFF065B80),
  900: Color(0xFF03435F),
});

/// 主题
class AppTheme with ChangeNotifier {
  static final List<MaterialColor> materialColors = [
    appColor,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.grey,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
    Colors.lime,
  ];

  static ThemeData getDefaultTheme(int index) {
    SPUtils.saveThemeIndex(index);
    return _buildTheme(index);
  }

  static ThemeData getCurrentTheme() => _buildTheme(SPUtils.getThemeIndex());

  static ThemeData _buildTheme(int index) {
    final color = AppTheme.materialColors[index];
    final brightness = Get.isDarkMode ? Brightness.dark : Brightness.light;
    final colorScheme = ColorScheme.fromSwatch(
      primarySwatch: color,
      brightness: brightness,
    );
    if (Platform.isIOS) {
      return ThemeData(
        brightness: brightness,
        colorScheme: colorScheme,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      );
    }

    return ThemeData(brightness: brightness, colorScheme: colorScheme);
  }

  static framework.ThemeData getLegacyTheme(int index) {
    final color = materialColors[index];
    return framework.ThemeData(
      brightness: Get.isDarkMode
          ? framework.Brightness.dark
          : framework.Brightness.light,
      primarySwatch: framework.MaterialColor(color.toARGB32(), <int, Color>{
        50: color.shade50,
        100: color.shade100,
        200: color.shade200,
        300: color.shade300,
        400: color.shade400,
        500: color.shade500,
        600: color.shade600,
        700: color.shade700,
        800: color.shade800,
        900: color.shade900,
      }),
    );
  }

  static bool get isDarkMode => Get.isDarkMode;

  static void changeTheme(ThemeData theme) {
    Get.changeTheme(
      theme.brightness == Brightness.dark
          ? framework.ThemeData.dark()
          : getLegacyTheme(SPUtils.getThemeIndex()),
    );
    if (Platform.isAndroid) {
      I18n.updateLocale();
    }
  }

  MaterialColor _themeColor;

  AppTheme(this._themeColor);

  void setColor(MaterialColor color) {
    _themeColor = color;
    notifyListeners();
  }

  void changeColor(int index) {
    _themeColor = materialColors[index];
    SPUtils.saveThemeIndex(index);
    notifyListeners();
  }

  MaterialColor get themeColor => _themeColor;
}
