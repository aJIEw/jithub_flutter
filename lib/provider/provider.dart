import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/page/main_page.dart';
import '/provider/state/app_status.dart';
import '/provider/state/user_profile.dart';

/// 状态管理
class Store {
  Store._internal();

  /// App 全局状态初始化，注入全局使用到的状态
  static init(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppStatus(tabIndexExplore)),
        ChangeNotifierProvider.value(value: UserProfile()),
      ],
      child: child,
    );
  }

  /// 获取值 of(context)，监听状态变化
  static T of<T>(BuildContext context) {
    return Provider.of<T>(context, listen: true);
  }

  /// 获取值 value(context)，不监听状态变化。
  /// 在 build 方法之外，使用 context.read<T>() 代替。
  static T value<T>(BuildContext context) {
    return Provider.of<T>(context, listen: false);
  }

  /// 消费状态事件，只刷新 Consumer 的部分，缩小控件刷新范围
  /// 在 build 方法中，使用 context.watch<T>() 代替。
  static Consumer connect<T>({builder, child}) {
    return Consumer<T>(builder: builder, child: child);
  }
}
