import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '/core/constants.dart';
import '/core/util/sputils.dart';
import '/i18n/i18n.dart';
import 'core/app_theme.dart';
import '/router/router.dart';

const bool showDebugBanner = false;

class AppEntrance extends StatelessWidget with WidgetsBindingObserver {
  const AppEntrance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // based on iPhone 13
      builder: () => GetMaterialApp(
        title: Constants.appTitle,
        debugShowCheckedModeBanner: kDebugMode && showDebugBanner,
        theme: AppTheme.getDefaultTheme(SPUtils.getThemeIndex()),
        locale: I18n.getLocale(),
        // Must non-null!
        supportedLocales: I18n.supportedLocales,
        fallbackLocale: I18n.fallbackLocale,
        localizationsDelegates: I18n.delegates,
        translations: I18n(),
        getPages: XRouter.getPages,
        transitionDuration: 250.milliseconds,
        defaultTransition: Transition.rightToLeft,
      ),
    );
  }
}
