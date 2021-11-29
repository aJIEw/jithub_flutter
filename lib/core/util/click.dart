import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'toast.dart';

class ClickUtils {
  ClickUtils._internal();

  static DateTime? _lastPressedAt;

  // 双击返回
  static Future<bool> exitBy2Click(
      {int duration = 1000, ScaffoldState? status}) async {
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
}
