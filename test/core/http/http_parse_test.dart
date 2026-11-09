import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/core/http/http_exceptions.dart';
import 'package:jithub_flutter/core/http/http_parse.dart';

void main() {
  test('maps DNS SocketException to NetworkException', () {
    final response = handleException(
      DioException(
        requestOptions: RequestOptions(
          path: 'https://github.com/login/oauth/access_token',
        ),
        type: DioExceptionType.connectionError,
        message: "Failed host lookup: 'github.com'",
        error: SocketException(
          "Failed host lookup: 'github.com'",
          osError: const OSError('No address associated with hostname', 7),
        ),
      ),
    );

    expect(response.error, isA<NetworkException>());
    expect(response.error?.message, "Failed host lookup: 'github.com'");
  });
}
