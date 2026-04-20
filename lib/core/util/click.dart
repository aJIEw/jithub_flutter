import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'package:jithub_flutter/core/util/toast.dart';

class ClickUtils {
  ClickUtils._internal();

  static DateTime? _lastPressedAt;
  static final Map<String, DateTime> _lastActionAt = {};

  // 双击返回
  static Future<bool> exitBy2Click({
    int duration = 1000,
    ScaffoldState? status,
  }) async {
    if (status != null && status.isDrawerOpen) {
      return Future.value(true);
    }

    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt!) >
            Duration(milliseconds: duration)) {
      ToastUtils.toast('click_twice_to_exit'.tr);
      _lastPressedAt = DateTime.now();
      return Future.value(false);
    }
    return Future.value(true);
  }

  static bool allowAction(String key, {int duration = 800}) {
    final lastTriggeredAt = _lastActionAt[key];
    final now = DateTime.now();
    if (lastTriggeredAt != null &&
        now.difference(lastTriggeredAt) <= Duration(milliseconds: duration)) {
      return false;
    }

    _lastActionAt[key] = now;
    return true;
  }
}
