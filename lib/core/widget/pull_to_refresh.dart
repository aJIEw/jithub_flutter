import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefreshHelper {
  static Widget getClassicI18nHeader(BuildContext context) {
    return ClassicHeader(
      textStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      idleIcon: const Icon(Icons.arrow_downward, color: Colors.grey, size: 20),
      releaseIcon: const Icon(Icons.refresh, color: Colors.grey, size: 20),
      refreshingIcon: const CupertinoActivityIndicator(radius: 8),
      completeIcon: const Icon(Icons.done, color: Colors.grey, size: 18),
      idleText: 'list_pull_down_to_refresh'.tr,
      releaseText: 'list_release_to_refresh'.tr,
      refreshingText: 'list_refreshing'.tr,
      completeText: 'list_refreshed'.tr,
      failedText: 'list_refresh_failed'.tr,
    );
  }

  static Widget getClassicI18nFooter(BuildContext context) {
    return ClassicFooter(
      textStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      idleIcon: const Icon(Icons.arrow_upward, color: Colors.grey, size: 20),
      loadingIcon: const CupertinoActivityIndicator(radius: 8),
      idleText: 'list_pull_up_to_load'.tr,
      canLoadingText: 'list_release_load_more'.tr,
      loadingText: 'request_loading'.tr,
      noDataText: 'request_no_data'.tr,
      loadStyle: LoadStyle.ShowWhenLoading,
    );
  }
}
