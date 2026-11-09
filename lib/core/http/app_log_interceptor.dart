import 'package:dio/dio.dart';

class AppLogInterceptor extends LogInterceptor {
  AppLogInterceptor({
    super.request,
    super.requestUrl,
    super.requestHeader,
    super.requestBody,
    super.responseUrl,
    super.responseHeader,
    super.responseBody,
    super.error,
    super.logPrint,
  });

  static const String redactSensitiveDataKey = 'redactSensitiveData';
  static const String _redactedValue = '[REDACTED]';
  static const Set<String> _sensitiveQueryKeys = <String>{
    'access_token',
    'device_code',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isSensitive(options)) {
      super.onRequest(options, handler);
      return;
    }

    if (requestUrl || request || requestHeader || requestBody) {
      if (requestUrl) {
        logPrint('*** Request ***');
        logPrint('uri: ${_redactUri(options.uri)}');
      }
      if (request) {
        logPrint('method: ${options.method}');
      }
      if (requestHeader) {
        logPrint('headers: $_redactedValue');
      }
      if (requestBody) {
        logPrint('data: $_redactedValue');
      }
      logPrint('');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_isSensitive(response.requestOptions)) {
      super.onResponse(response, handler);
      return;
    }

    _printRedactedResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_isSensitive(err.requestOptions)) {
      super.onError(err, handler);
      return;
    }

    logRedactedError(err);
    handler.next(err);
  }

  void logRedactedError(DioException err) {
    if (error) {
      logPrint('*** DioException ***:');
      logPrint('uri: ${_redactUri(err.requestOptions.uri)}');
      logPrint('type: ${err.type}');
      if (err.message != null) {
        logPrint('message: ${err.message}');
      }
      if (err.response != null) {
        _printRedactedResponse(err.response!);
      }
      logPrint('');
    }
  }

  bool _isSensitive(RequestOptions options) {
    return options.extra[redactSensitiveDataKey] == true;
  }

  Uri _redactUri(Uri uri) {
    if (!_sensitiveQueryKeys.any(uri.queryParameters.containsKey)) {
      return uri;
    }
    final queryParameters = Map<String, String>.from(uri.queryParameters);
    for (final key in _sensitiveQueryKeys) {
      if (queryParameters.containsKey(key)) {
        queryParameters[key] = _redactedValue;
      }
    }
    return uri.replace(queryParameters: queryParameters);
  }

  void _printRedactedResponse(Response response) {
    if (responseUrl || responseHeader || responseBody) {
      logPrint('*** Response ***');
    }
    if (responseUrl) {
      logPrint('uri: ${_redactUri(response.realUri)}');
    }
    if (responseHeader) {
      logPrint('statusCode: ${response.statusCode}');
      logPrint('headers: $_redactedValue');
    }
    if (responseBody) {
      logPrint('Response Text: $_redactedValue');
    }
    if (responseUrl || responseHeader || responseBody) {
      logPrint('');
    }
  }
}
