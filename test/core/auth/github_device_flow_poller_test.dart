import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/core/auth/github_device_flow_poller.dart';
import 'package:jithub_flutter/core/http/http_exceptions.dart';
import 'package:jithub_flutter/core/http/http_response.dart';

void main() {
  group('GitHubDeviceFlowPoller', () {
    late DateTime currentTime;
    late List<Duration> delays;

    setUp(() {
      currentTime = DateTime(2026);
      delays = <Duration>[];
    });

    Future<void> delay(Duration duration) async {
      delays.add(duration);
      currentTime = currentTime.add(duration);
    }

    GitHubDeviceFlowPoller createPoller({
      required Future<HttpResponse> Function(
        String url, {
        required Map<String, dynamic> queryParameters,
        required Options options,
      })
      post,
      bool Function()? isAppActive,
      Future<void> Function()? waitForAppActive,
      VoidCallback? onTransientFailure,
    }) {
      return GitHubDeviceFlowPoller(
        post: post,
        isAppActive: isAppActive ?? () => true,
        waitForAppActive: waitForAppActive ?? () async {},
        onTransientFailure: onTransientFailure,
        delay: delay,
        now: () => currentTime,
      );
    }

    test(
      'waits while app is backgrounded and polls immediately on resume',
      () async {
        var appIsActive = false;
        final resume = Completer<void>();
        var requestCount = 0;
        final poller = createPoller(
          isAppActive: () => appIsActive,
          waitForAppActive: () => resume.future,
          post:
              (
                String url, {
                required Map<String, dynamic> queryParameters,
                required Options options,
              }) async {
                requestCount++;
                return _success('token');
              },
        );

        final resultFuture = poller.poll(
          _session(interval: 1),
          isCancelled: () => false,
        );
        await Future<void>.delayed(Duration.zero);

        expect(requestCount, 0);

        appIsActive = true;
        resume.complete();

        final result = await resultFuture;
        expect(result, isA<GitHubDevicePollSuccess>());
        expect((result as GitHubDevicePollSuccess).accessToken, 'token');
        expect(requestCount, 1);
      },
    );

    test('retries transient network failures without ending login', () async {
      var resetCount = 0;
      final responses = <HttpResponse>[
        HttpResponse.failureFromError(
          NetworkException(message: "Failed host lookup: 'github.com'"),
        ),
        _pending(),
        _success('token-after-retry'),
      ];
      final poller = createPoller(
        onTransientFailure: () => resetCount++,
        post:
            (
              String url, {
              required Map<String, dynamic> queryParameters,
              required Options options,
            }) async {
              return responses.removeAt(0);
            },
      );

      final result = await poller.poll(
        _session(interval: 1),
        isCancelled: () => false,
      );

      expect(result, isA<GitHubDevicePollSuccess>());
      expect(
        (result as GitHubDevicePollSuccess).accessToken,
        'token-after-retry',
      );
      expect(resetCount, 1);
      expect(responses, isEmpty);
    });

    test('applies slow_down interval before polling again', () async {
      final responses = <HttpResponse>[
        _response(<String, dynamic>{'error': 'slow_down'}),
        _success('token'),
      ];
      final poller = createPoller(
        post:
            (
              String url, {
              required Map<String, dynamic> queryParameters,
              required Options options,
            }) async {
              return responses.removeAt(0);
            },
      );

      final result = await poller.poll(
        _session(interval: 1),
        isCancelled: () => false,
      );

      expect(result, isA<GitHubDevicePollSuccess>());
      expect(delays, <Duration>[
        const Duration(seconds: 1),
        const Duration(seconds: 6),
      ]);
    });

    test('returns terminal GitHub error without retrying', () async {
      var requestCount = 0;
      final poller = createPoller(
        post:
            (
              String url, {
              required Map<String, dynamic> queryParameters,
              required Options options,
            }) async {
              requestCount++;
              return _response(<String, dynamic>{'error': 'access_denied'});
            },
      );

      final result = await poller.poll(
        _session(interval: 1),
        isCancelled: () => false,
      );

      expect(result, isA<GitHubDevicePollFailure>());
      expect(
        (result as GitHubDevicePollFailure).messageKey,
        'github_login_access_denied',
      );
      expect(requestCount, 1);
    });

    test(
      'returns network error when code expires after network failures',
      () async {
        final poller = createPoller(
          post:
              (
                String url, {
                required Map<String, dynamic> queryParameters,
                required Options options,
              }) async {
                return HttpResponse.failureFromError(
                  NetworkException(message: "Failed host lookup: 'github.com'"),
                );
              },
        );

        final result = await poller.poll(
          _session(expiresIn: 3, interval: 2),
          isCancelled: () => false,
        );

        expect(result, isA<GitHubDevicePollFailure>());
        expect(
          (result as GitHubDevicePollFailure).messageKey,
          'github_login_network_error',
        );
      },
    );

    test('stops silently when cancelled', () async {
      var requestCount = 0;
      final poller = createPoller(
        post:
            (
              String url, {
              required Map<String, dynamic> queryParameters,
              required Options options,
            }) async {
              requestCount++;
              return _pending();
            },
      );

      final result = await poller.poll(
        _session(interval: 1),
        isCancelled: () => true,
      );

      expect(result, isA<GitHubDevicePollCancelled>());
      expect(requestCount, 0);
    });
  });

  testWidgets('lifecycle gate pauses and wakes after resume', (tester) async {
    final binding = tester.binding;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    var resumeCount = 0;
    final gate = GitHubAuthLifecycleGate(
      binding: binding,
      resumeCallback: () => resumeCount++,
    );
    addTearDown(gate.dispose);

    expect(gate.isActive, isTrue);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    expect(gate.isActive, isFalse);

    final resumed = gate.waitUntilActive();
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await resumed;

    expect(gate.isActive, isTrue);
    expect(resumeCount, 1);
  });
}

GitHubDeviceSession _session({int expiresIn = 60, int interval = 5}) {
  return GitHubDeviceSession(
    deviceCode: 'device-code',
    userCode: 'ABCD-EFGH',
    verificationUri: 'https://github.com/login/device',
    expiresIn: expiresIn,
    interval: interval,
  );
}

HttpResponse _pending() {
  return _response(<String, dynamic>{'error': 'authorization_pending'});
}

HttpResponse _success(String token) {
  return _response(<String, dynamic>{'access_token': token});
}

HttpResponse _response(Map<String, dynamic> data) {
  return HttpResponse.success(data, 200);
}
