import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'toast.dart';

/// 常用工具类
class Utils {
  Utils._internal();

  static void hideStatusBarAndNavBar() {
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  static void showStatusBarAndNavBar() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  //=============url_launcher==================//

  /// 处理链接
  static void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ToastUtils.toast("暂时无法处理请求: $url");
    }
  }

  //=============package_info==================//

  /// 获取应用基本信息
  static Future<Map<String, dynamic>> getBasicPackageInfo() async {
    PackageInfo packageInfo = await getPackageInfo();
    return <String, dynamic>{
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };
  }

  static Future<PackageInfo> getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  /// 获取当前时间戳
  static String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// 格式化日期
  static String formatDateTime(DateTime dateTime) =>
      formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
}
