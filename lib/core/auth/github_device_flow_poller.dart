import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/http/app_log_interceptor.dart';
import 'package:jithub_flutter/core/http/http_exceptions.dart';
import 'package:jithub_flutter/core/http/http_response.dart';

typedef GitHubDeviceFlowPost = Future<HttpResponse> Function(
  String url, {
  required Map<String, dynamic> queryParameters,
  required Options options,
});

typedef GitHubDeviceFlowDelay = Future<void> Function(Duration duration);

sealed class GitHubDevicePollResult {
  const GitHubDevicePollResult();
}

final class GitHubDevicePollSuccess extends GitHubDevicePollResult {
  const GitHubDevicePollSuccess(this.accessToken);

  final String accessToken;
}

final class GitHubDevicePollFailure extends GitHubDevicePollResult {
  const GitHubDevicePollFailure(this.messageKey);

  final String messageKey;
}

final class GitHubDevicePollCancelled extends GitHubDevicePollResult {
  const GitHubDevicePollCancelled();
}

class GitHubDeviceSession {
  const GitHubDeviceSession({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.expiresIn,
    required this.interval,
  });

  factory GitHubDeviceSession.fromJson(Map<String, dynamic> json) {
    return GitHubDeviceSession(
      deviceCode: json['device_code'] as String,
      userCode: json['user_code'] as String,
      verificationUri: json['verification_uri'] as String,
      expiresIn: json['expires_in'] as int,
      interval: json['interval'] as int,
    );
  }

  final String deviceCode;
  final String userCode;
  final String verificationUri;
  final int expiresIn;
  final int interval;
}

class GitHubAuthLifecycleGate {
  GitHubAuthLifecycleGate({
    WidgetsBinding? binding,
    VoidCallback? resumeCallback,
  }) : _onResume = resumeCallback {
    _binding = binding ?? WidgetsBinding.instance;
    _isActive = _binding.lifecycleState == AppLifecycleState.resumed;
    _listener = AppLifecycleListener(
      binding: _binding,
      onResume: resume,
      onInactive: pause,
      onHide: pause,
      onPause: pause,
    );
  }

  late final WidgetsBinding _binding;
  late final AppLifecycleListener _listener;
  final VoidCallback? _onResume;
  bool _isActive = false;
  Completer<void>? _resumeCompleter;

  bool get isActive => _isActive;

  void pause() {
    _isActive = false;
  }

  void resume() {
    _isActive = true;
    _onResume?.call();
    final completer = _resumeCompleter;
    _resumeCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  Future<void> waitUntilActive() {
    if (_isActive) {
      return Future<void>.value();
    }
    return (_resumeCompleter ??= Completer<void>()).future;
  }

  void dispose() {
    _listener.dispose();
    _isActive = false;
    final completer = _resumeCompleter;
    _resumeCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }
}

class GitHubDeviceFlowPoller {
  static const String _deviceCodeGrantType =
      'urn:ietf:params:oauth:grant-type:device_code';

  GitHubDeviceFlowPoller({
    required this.post,
    required this.isAppActive,
    required this.waitForAppActive,
    this.onTransientFailure,
    GitHubDeviceFlowDelay? delay,
    DateTime Function()? now,
  }) : _delay = delay ?? ((duration) => Future<void>.delayed(duration)),
       _now = now ?? DateTime.now;

  final GitHubDeviceFlowPost post;
  final bool Function() isAppActive;
  final Future<void> Function() waitForAppActive;
  final VoidCallback? onTransientFailure;
  final GitHubDeviceFlowDelay _delay;
  final DateTime Function() _now;

  Future<GitHubDevicePollResult> poll(
    GitHubDeviceSession session, {
    required bool Function() isCancelled,
  }) async {
    var interval = Duration(seconds: session.interval);
    final deadline = _now().add(Duration(seconds: session.expiresIn));
    var lastFailureWasNetwork = false;

    while (!isCancelled() && _now().isBefore(deadline)) {
      await _delay(interval);
      if (isCancelled()) {
        return const GitHubDevicePollCancelled();
      }

      if (!isAppActive()) {
        await waitForAppActive();
        if (isCancelled()) {
          return const GitHubDevicePollCancelled();
        }
      }

      if (!_now().isBefore(deadline)) {
        break;
      }

      final response = await post(
        ApiService.githubUrl + ApiService.apiAccessToken,
        queryParameters: <String, dynamic>{
          'client_id': ApiService.clientId,
          'device_code': session.deviceCode,
          'grant_type': _deviceCodeGrantType,
        },
        options: Options(
          headers: const <String, String>{'Accept': 'application/json'},
          extra: const <String, dynamic>{
            AppLogInterceptor.redactSensitiveDataKey: true,
          },
          connectTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (!response.ok && _isTransientFailure(response)) {
        lastFailureWasNetwork = true;
        onTransientFailure?.call();
        continue;
      }

      if (!response.ok || response.data is! Map) {
        return const GitHubDevicePollFailure('github_login_poll_failed');
      }

      lastFailureWasNetwork = false;
      final data = Map<String, dynamic>.from(response.data as Map);
      final accessToken = data['access_token'];
      if (accessToken is String && accessToken.isNotEmpty) {
        return GitHubDevicePollSuccess(accessToken);
      }

      final error = data['error'];
      if (error is! String || error.isEmpty) {
        return const GitHubDevicePollFailure('github_login_poll_failed');
      }

      switch (error) {
        case 'authorization_pending':
          continue;
        case 'slow_down':
          interval += const Duration(seconds: 5);
          continue;
        default:
          return GitHubDevicePollFailure(_mapDeviceFlowError(error));
      }
    }

    if (isCancelled()) {
      return const GitHubDevicePollCancelled();
    }
    return GitHubDevicePollFailure(
      lastFailureWasNetwork
          ? 'github_login_network_error'
          : 'github_device_code_expired',
    );
  }

  bool _isTransientFailure(HttpResponse response) {
    if (response.error is NetworkException) {
      return true;
    }
    return response.code == 408 ||
        response.code == 429 ||
        (response.code >= 500 && response.code < 600);
  }

  String _mapDeviceFlowError(String errorCode) {
    switch (errorCode) {
      case 'expired_token':
      case 'token_expired':
        return 'github_device_code_expired';
      case 'access_denied':
        return 'github_login_access_denied';
      case 'device_flow_disabled':
        return 'github_device_flow_disabled';
      case 'incorrect_client_credentials':
        return 'github_login_client_config_error';
      case 'unsupported_grant_type':
      case 'incorrect_device_code':
      default:
        return 'github_login_poll_failed';
    }
  }
}
