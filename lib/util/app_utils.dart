import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/page/main_page.dart';
import '/provider/state/app_status.dart';
import '/provider/state/user_profile.dart';

class AppUtils {
  static void logout(BuildContext context) async {
    _moveToExplore(context);
    _clearPendingTab(context);
    _clearUserProfile(context);
  }

  static void redirectToLoginSafeTab(
    BuildContext context, {
    int? pendingTabIndex,
    bool clearUserProfile = false,
  }) {
    var appStatus = context.read<AppStatus>();
    var targetTabIndex =
        pendingTabIndex ??
        (appStatus.tabIndex == tabIndexExplore ? null : appStatus.tabIndex);

    _moveToExplore(context);
    appStatus.setPendingTabIndex(targetTabIndex);
    if (clearUserProfile) {
      _clearUserProfile(context);
    }
  }

  static void clearPendingTab(BuildContext context) {
    _clearPendingTab(context);
  }

  static void restorePendingTabAfterLogin(BuildContext context) {
    var appStatus = context.read<AppStatus>();
    var targetTabIndex = appStatus.consumePendingTabIndex();
    if (targetTabIndex != null) {
      appStatus.tabIndex = targetTabIndex;
    }
  }

  static void _moveToExplore(BuildContext context) {
    context.read<AppStatus>().tabIndex = tabIndexExplore;
  }

  static void _clearPendingTab(BuildContext context) {
    context.read<AppStatus>().setPendingTabIndex(null);
  }

  static void _clearUserProfile(BuildContext context) {
    context.read<UserProfile>().clear();
  }
}
