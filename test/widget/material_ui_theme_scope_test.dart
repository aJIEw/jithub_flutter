import 'package:flutter/material.dart' as framework;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/app_theme.dart';
import 'package:jithub_flutter/core/util/sputils.dart';
import 'package:jithub_flutter/core/widget/material_ui_theme_scope.dart';
import 'package:material_ui/material_ui.dart' as modern;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SPUtils.init();
  });

  setUp(() {
    Get.testMode = true;
  });

  testWidgets('modern theme scope supports MaterialPinField under GetX root', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.getLegacyTheme(0),
        builder: (context, child) => MaterialUiThemeScope(
          child: child ?? const framework.SizedBox.shrink(),
        ),
        home: const modern.Scaffold(body: MaterialPinField(length: 4)),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialPinField), findsOneWidget);

    final context = tester.element(find.byType(MaterialPinField));
    expect(
      modern.Theme.of(context).primaryColor.toARGB32(),
      AppTheme.materialColors.first.shade500.toARGB32(),
    );
  });
}
