import 'package:flutter/material.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/data/event/bus_event.dart';
import 'package:jithub_flutter/page/main_page.dart';
import 'package:jithub_flutter/provider/state/app_status.dart';
import 'package:jithub_flutter/provider/state/user_profile.dart';
import 'package:provider/provider.dart';

class AppUtils {
  static void logout(BuildContext context) async {
    _moveToExplore(context);
    _clearPendingTab(context);
    _clearUserProfile(context);
    XEvent.post(BusEvent.userLoggedOut, true);
  }

  static void redirectToLoginSafeTab(
    BuildContext context, {
    int? pendingTabIndex,
    bool clearUserProfile = false,
  }) {
    final appStatus = context.read<AppStatus>();
    final targetTabIndex =
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
    final appStatus = context.read<AppStatus>();
    final targetTabIndex = appStatus.consumePendingTabIndex();
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
