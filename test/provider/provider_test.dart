import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/core/util/sputils.dart';
import 'package:jithub_flutter/page/main_page.dart';
import 'package:jithub_flutter/provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SPUtils.init();
  });

  setUp(() async {
    await SPUtils.saveAuthToken('');
  });

  test('uses home tab as initial tab when auth token exists', () async {
    await SPUtils.saveAuthToken('token');

    expect(Store.initialTabIndex(), tabIndexHome);
  });

  test('uses explore tab as initial tab when auth token is missing', () {
    expect(Store.initialTabIndex(), tabIndexExplore);
  });
}
