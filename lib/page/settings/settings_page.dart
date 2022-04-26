import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/base/base_app_bar.dart';
import 'package:jithub_flutter/core/base/base_controller.dart';
import 'package:jithub_flutter/core/base/base_page.dart';
import 'package:jithub_flutter/core/widget/common_dialogs.dart';
import 'package:jithub_flutter/core/widget/divider.dart';
import 'package:jithub_flutter/router/router.dart';
import 'package:jithub_flutter/util/app_utils.dart';

class SettingsController extends BaseController {
  @override
  Future loadData() {
    return Future.delayed(200.milliseconds);
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SettingsController>(SettingsController());
  }
}

class SettingsPage extends BaseView<SettingsController> {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  NotifierBuilder buildContent(BuildContext context) {
    return (state) {
      return Scaffold(
        appBar: BaseAppBar(title: 'title_settings'.tr),
        body: Container(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              _buildListItem('choose_language'.tr, '', onPress: () {
                XRouter.push(XRouter.languagePage);
              }),
              _buildListItem('choose_theme'.tr, '', onPress: () {
                XRouter.push(XRouter.themePage);
              }),
              /*_buildListItem('privacy_policy'.tr, '', onPress: () {
                    XRouter.goWeb(
                        context,
                        'http://your.domain.com/privacy_policy',
                        'privacy_policy'.tr);
                  }),*/
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 60),
                child: ElevatedButton(
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0.2),
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor),
                      minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 50)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ))),
                  onPressed: () {
                    onPressLogout(context);
                  },
                  child: Text(
                    'btn_logout'.tr,
                    style: Theme.of(context).textTheme.bodyText1?.merge(
                        const TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    };
  }

  Widget _buildListItem(String title, String rightText,
      {bool hasRightArrow = true,
      VoidCallback? onPress,
      bool hasDividerLine = true}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPress,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(title),
                  Expanded(
                      child: Text(rightText,
                          textAlign: TextAlign.end,
                          style: const TextStyle(color: Colors.grey))),
                  Icon(Icons.chevron_right,
                      size: 24,
                      color: hasRightArrow
                          ? Colors.grey[350]
                          : Colors.transparent),
                ],
              ),
            ),
            if (hasDividerLine) const DefaultDivider(0.2),
          ],
        ),
      ),
    );
  }

  void onPressLogout(BuildContext context) {
    showAlertDialog('logout_confirm_title'.tr,
        confirmText: 'dialog_confirm_text'.tr,
        cancelText: 'dialog_cancel_text'.tr, onConfirm: () {
      AppUtils.logout(context);
      XRouter.pop();
    });
  }
}
