import 'dart:io' hide HttpResponse;

import 'package:dio/dio.dart';
import 'package:jithub_flutter/core/http/http_exceptions.dart';
import 'package:jithub_flutter/core/http/http_response.dart';
import 'package:jithub_flutter/core/http/http_transformer.dart';
import 'package:jithub_flutter/data/response/base_response.dart';

HttpResponse handleResponse(
  Response? response, {
  HttpTransformer? httpTransformer,
}) {
  httpTransformer ??= DefaultHttpTransformer.getInstance();

  // 返回值异常
  if (response == null) {
    return HttpResponse.failureFromError();
  }

  // token失效
  if (_isTokenTimeout(response.statusCode)) {
    return HttpResponse.failureFromError(
      UnauthorisedException(message: '没有权限', code: response.statusCode),
      401,
    );
  }
  // 接口调用成功
  if (_isRequestSuccess(response.statusCode)) {
    return httpTransformer.parse(response);
  } else {
    // 接口调用失败
    return HttpResponse.failure(
      errorMsg: response.statusMessage,
      errorCode: response.statusCode,
    );
  }
}

HttpResponse handleException(Exception exception) {
  final HttpException parseException = _parseException(exception);
  return HttpResponse.failureFromError(parseException, parseException.code);
}

/// 鉴权失败
bool _isTokenTimeout(int? code) {
  return code == 401;
}

/// 请求成功
bool _isRequestSuccess(int? statusCode) {
  return (statusCode != null && statusCode >= 200 && statusCode < 300 ||
      statusCode == 304);
}

HttpException _parseException(Exception error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException(message: '请求超时');
      case DioExceptionType.cancel:
        return CancelException('请求已取消');
      case DioExceptionType.badResponse:
        try {
          final int? errCode = error.response?.statusCode;
          switch (errCode) {
            case 400:
              return BadRequestException(message: '请求语法错误', code: errCode);
            case 401:
              return UnauthorisedException(message: '没有权限', code: errCode);
            case 403:
              return BadRequestException(message: '服务器拒绝执行', code: errCode);
            case 404:
              final data = BaseErrorResponse.fromJson(
                error.response?.data,
                (t) => null,
              );
              return BadRequestException(
                message: data.message ?? '无法连接服务器',
                code: errCode,
              );
            case 405:
              return BadRequestException(message: '请求方法被禁止', code: errCode);
            case 500:
              return BadServiceException(message: '服务器内部错误', code: errCode);
            case 502:
              return BadServiceException(message: '请求无效', code: errCode);
            case 503:
              return BadServiceException(message: '服务当前不可用', code: errCode);
            case 505:
              return BadServiceException(message: '不支持HTTP协议请求', code: errCode);
            default:
              return UnknownException('出现未知错误');
          }
        } on Exception catch (_) {
          return UnknownException('出现未知错误');
        }

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException(message: error.message);
        } else {
          return UnknownException(error.message);
        }
      case DioExceptionType.badCertificate:
        return BadRequestException(message: '证书校验失败');
    }
  } else {
    return UnknownException(error.toString());
  }
}
