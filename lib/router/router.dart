import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/page/main_page.dart';
import 'package:jithub_flutter/page/login/login_page.dart';
import 'package:jithub_flutter/page/settings/language_page.dart';
import 'package:jithub_flutter/page/settings/settings_page.dart';
import 'package:jithub_flutter/page/settings/theme_page.dart';
import 'package:jithub_flutter/page/splash_page.dart';

import '/core/widget/webview/common_webview.dart';

/// Router manager
class XRouter {
  static const String loginPage = '/login';
  static const String homePage = '/home';
  static const String settingsPage = '/settings-page';
  static const String languagePage = '/language-page';
  static const String themePage = '/theme-page';

  static List<GetPage> getPages = [
    GetPage(name: '/', page: () => const SplashPage()),
    GetPage(
        name: loginPage,
        page: () => const LoginPage(),
        transition: Transition.rightToLeft,
        transitionDuration: 200.milliseconds),
    GetPage(
        name: homePage,
        page: () => const MainPage(),
        transition: Transition.fadeIn),
    GetPage(
        name: settingsPage,
        page: () => const SettingsPage(),
        binding: SettingsBinding()),
    GetPage(name: languagePage, page: () => const LanguagePage()),
    GetPage(name: themePage, page: () => const ThemePage()),
  ];

  static Future<dynamic>? goWeb(
      BuildContext context, String url, String title) {
    return Get.to(() => CommonWebView(url, title),
        transition: Transition.cupertino);
  }

  /// go to a new page
  static Future<T?>? to<T>(dynamic page,
      {Bindings? binding, dynamic arguments, bool popGesture = true}) {
    return Get.to(page,
        binding: binding, arguments: arguments, popGesture: popGesture);
  }

  /// push a new named page
  static Future<T?>? push<T>(String page,
      {Map<String, String>? parameters, dynamic arguments}) {
    return Get.toNamed(page, parameters: parameters, arguments: arguments);
  }

  /// replaces last entry in stack, throws an error if stack is empty
  static Future<T?>? replace<T>(String page,
      {Map<String, String>? parameters, dynamic arguments}) {
    return Get.offNamed(page, parameters: parameters, arguments: arguments);
  }

  /// pops until provided route, if it already exists in stack
  /// else adds it to the stack (good for web Apps).
  static Future<T?>? navigate<T>(String page, RoutePredicate predicate,
      {Map<String, String>? parameters, dynamic arguments}) {
    return Get.offNamedUntil(page, predicate,
        parameters: parameters, arguments: arguments);
  }

  /// pops the last page unless stack has 1 entry
  static void pop<T>({T? result}) {
    Get.back(result: result);
  }
}
