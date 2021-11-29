import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/provider/state/app_status.dart';
import '/provider/state/user_profile.dart';

class AppUtils {
  static void logout(BuildContext context) async {
    var appStatus = context.read<AppStatus>();
    var userProfile = context.read<UserProfile>();

    appStatus.tabIndex = 0;
    userProfile.clear();
  }
}
