import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/core/http/http_client.dart';
import '/core/util/logger.dart';
import '/core/util/sputils.dart';
import '/core/util/toast.dart';
import '/provider/provider.dart';
import 'app.dart';

void main() => AppInit.run();

class AppInit {
  static void run() {
    handleError(() {
      WidgetsFlutterBinding.ensureInitialized();
      SPUtils.init()
          .then((value) => runApp(Store.init(ToastUtils.init(const AppEntrance()))));

      HttpClient.init();
    });
  }

  /// 异常处理
  static void handleError<T>(T Function() callback) {
    // Flutter 捕获到的异常
    FlutterError.onError = (FlutterErrorDetails details) {
      reportErrorAndLog(details);
    };
    // 创建一个新 Zone 作为运行环境，并对异常进行处理
    runZonedGuarded<Future<void>>(
      () async {
        callback();
      },
      // 未捕获的异常
      (Object obj, StackTrace stack) {
        var details = makeDetails(obj, stack);
        reportErrorAndLog(details);
      },
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          // 收集日志
          collectLog(parent, zone, line);
        },
      ),
    );
  }

  // 上报错误和日志
  static void reportErrorAndLog(FlutterErrorDetails details) {
    // 开发环境下打印日志内容
    logger.d('错误日志: $details');
  }

  // 构建错误信息
  static FlutterErrorDetails makeDetails(Object obj, StackTrace stack) {
    return FlutterErrorDetails(exception: obj, stack: stack);
  }

  // 日志拦截
  static void collectLog(ZoneDelegate parent, Zone zone, String line) {
    parent.print(zone, '日志拦截: $line');
  }
}
