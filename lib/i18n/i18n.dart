import 'package:jithub_flutter/core/util/sputils.dart';
import 'package:jithub_flutter/i18n/en_US/translation.dart';
import 'package:jithub_flutter/i18n/zh_CN/translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

class I18n extends Translations {
  static const fallbackLocale = Locale('zh', 'CN');

  /// App 支持的语言列表，第一个是默认语言
  static List<Locale> get supportedLocales {
    return const <Locale>[
      fallbackLocale,
      Locale("en", "US"),
    ];
  }

  static Locale? get locale => Get.deviceLocale;

  static Locale? get appLocale {
    if (appLocaleString.isEmpty || !appLocaleString.contains('_')) return null;

    var s = appLocaleString.split("_");
    return Locale(s[0], s[1]);
  }

  static String get appLocaleString => SPUtils.getLocale();

  static Future<bool> setAppLocaleString(String localeString) => SPUtils.saveLocale(localeString);

  static List<LocalizationsDelegate<dynamic>> get delegates => [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': zh_CN,
        'en_US': en_US,
      };

  static Locale? isSupported(Locale? locale) {
    for (var i = 0; i < supportedLocales.length && locale != null; i++) {
      final l = supportedLocales[i];
      if (l.languageCode == locale.languageCode) {
        return l;
      }
    }
    return null;
  }

  /// 获取应用当前语言设置
  static Locale getLocale() {
    if (appLocale != null) {
      // 如果已经选定语言，则使用该语言
      return appLocale!;
    } else {
      // 如果没有选择语言且多语言中包含当前系统语言，则跟随系统；不包含则使用默认语言
      return I18n.isSupported(locale) ?? supportedLocales.first;
    }
  }

  static void updateLocale() {
    Get.updateLocale(getLocale());
  }
}
