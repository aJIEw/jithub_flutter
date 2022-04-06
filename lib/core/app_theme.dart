import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../i18n/i18n.dart';
import '/core/util/sputils.dart';

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
    Colors.lime
  ];

  static ThemeData getDefaultTheme(int index) {
    SPUtils.saveThemeIndex(index);

    var color = AppTheme.materialColors[index];
    if (Platform.isIOS) {
      return ThemeData(
        primarySwatch: color,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      );
    }

    return ThemeData(
      primarySwatch: color,
    );
  }

  static bool get isDarkMode => Get.isDarkMode;

  static void changeTheme(ThemeData theme) {
    Get.changeTheme(theme);
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

  get themeColor => _themeColor;
}
