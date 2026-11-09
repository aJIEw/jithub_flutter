import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/core/http/app_dio.dart';

void main() {
  test('resetConnections replaces the underlying HttpClient adapter', () {
    final dio = AppDio();
    final oldAdapter = dio.httpClientAdapter;

    dio.resetConnections();

    expect(dio.httpClientAdapter, isNot(same(oldAdapter)));
    dio.close(force: true);
  });
}
