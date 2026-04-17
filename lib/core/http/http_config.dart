import 'package:dio/dio.dart';

class HttpConfig {
  final String? baseUrl;
  final String? proxy;
  final String? cookiesPath;
  final List<Interceptor>? interceptors;
  final Duration connectTimeout;
  final Duration sendTimeout;
  final Duration receiveTimeout;

  HttpConfig({
    this.baseUrl,
    this.proxy,
    this.cookiesPath,
    this.interceptors,
    this.connectTimeout = const Duration(minutes: 1),
    this.sendTimeout = const Duration(minutes: 1),
    this.receiveTimeout = const Duration(minutes: 1),
  });

  // static DioConfig of() => Get.find<DioConfig>();
}
