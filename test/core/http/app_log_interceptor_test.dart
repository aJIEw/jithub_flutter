import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/core/http/app_log_interceptor.dart';

void main() {
  test('redacts sensitive OAuth query values and response bodies', () {
    final logs = <String>[];
    final interceptor = AppLogInterceptor(
      logPrint: (Object value) => logs.add(value.toString()),
      request: false,
      requestUrl: true,
      requestBody: true,
      responseBody: true,
    );
    final request = RequestOptions(
      path: 'https://github.com/login/oauth/access_token',
      queryParameters: <String, dynamic>{
        'device_code': 'device-secret',
        'grant_type': 'device_code',
      },
      extra: <String, dynamic>{AppLogInterceptor.redactSensitiveDataKey: true},
    );

    interceptor.onRequest(request, RequestInterceptorHandler());
    interceptor.onResponse(
      Response<Map<String, dynamic>>(
        requestOptions: request,
        data: <String, dynamic>{'access_token': 'token-secret'},
        statusCode: 200,
      ),
      ResponseInterceptorHandler(),
    );

    final output = logs.join('\n');
    expect(output, contains('[REDACTED]'));
    expect(output, isNot(contains('device-secret')));
    expect(output, isNot(contains('token-secret')));
  });

  test('redacts sensitive request URI from Dio exceptions', () {
    final logs = <String>[];
    final interceptor = AppLogInterceptor(
      logPrint: (Object value) => logs.add(value.toString()),
      request: false,
      requestUrl: true,
    );
    final request = RequestOptions(
      path: 'https://github.com/login/device/code',
      queryParameters: <String, dynamic>{'device_code': 'device-secret'},
      extra: <String, dynamic>{AppLogInterceptor.redactSensitiveDataKey: true},
    );

    interceptor.logRedactedError(
      DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
        message: 'connection failed',
      ),
    );

    final output = logs.join('\n');
    expect(output, contains('connection failed'));
    expect(output, isNot(contains('device-secret')));
  });
}
