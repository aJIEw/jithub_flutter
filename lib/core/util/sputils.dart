import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '/data/model/user.dart';

class SPUtils {
  /// 创建一个内部构造方法，防止被外部实例化
  SPUtils._internal();

  static SharedPreferences? _spf;

  static Future<SharedPreferences> init() async {
    _spf ??= await SharedPreferences.getInstance();
    return _spf!;
  }

  /// 主题
  static Future<bool> saveThemeIndex(int value) {
    return _spf!.setInt('key_theme_color', value);
  }

  static int getThemeIndex() {
    if (_spf!.containsKey('key_theme_color')) {
      return _spf!.getInt('key_theme_color') ?? 0;
    }
    return 0;
  }

  /// 语言
  static Future<bool> saveLocale(String locale) {
    return _spf!.setString('key_locale', locale);
  }

  static String getLocale() {
    return _spf!.getString('key_locale') ?? 'auto';
  }

  /// 隐私协议
  static Future<bool> saveIsAgreePrivacy(bool isAgree) {
    return _spf!.setBool('key_agree_privacy', isAgree);
  }

  static bool isAgreePrivacy() {
    if (!_spf!.containsKey('key_agree_privacy')) {
      return false;
    }
    return _spf!.getBool('key_agree_privacy') ?? true;
  }

  /// 是否已登陆
  static bool isLoggedIn() {
    return getAuthToken().isNotEmpty;
  }

  static Future<bool> saveAuthToken(String authToken) {
    return _spf!.setString('key_auth_token', authToken);
  }

  static String getAuthToken() {
    return _spf!.getString('key_auth_token') ?? '';
  }

  static Future<bool> saveUser(User user) {
    return _spf!.setString('key_user', json.encode(user));
  }

  static String getUser() {
    return _spf!.getString('key_user') ?? '';
  }

  static Future<bool> reset() {
    return _spf!.clear();
  }
}
