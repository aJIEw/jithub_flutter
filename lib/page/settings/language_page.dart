import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/core/util/sputils.dart';
import '../../core/base/base_app_bar.dart';
import '/i18n/i18n.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    String localeString = SPUtils.getLocale();

    Widget _buildLanguageItem(String lan, String locale) {
      return ListTile(
        title: Text(
          lan,
          style: TextStyle(color: localeString == locale ? color : null),
        ),
        trailing:
            localeString == locale ? Icon(Icons.done, color: color) : null,
        onTap: () async {
          await I18n.setAppLocaleString(locale);
          I18n.updateLocale();
        },
      );
    }

    return Scaffold(
        appBar: BaseAppBar(title: 'choose_language'.tr),
        body: ListView(
          children: <Widget>[
            _buildLanguageItem('auto_language'.tr, "auto"),
            _buildLanguageItem('中文', "zh_CN"),
            _buildLanguageItem('English', "en_US"),
          ],
        ));
  }
}
