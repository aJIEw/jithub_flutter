import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/util/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubAuthService {
  static const String _deviceCodeGrantType =
      'urn:ietf:params:oauth:grant-type:device_code';

  static Future<String?> authenticate() async {
    final session = await _requestDeviceCode();
    if (session == null) {
      return null;
    }

    var cancelled = false;
    String? accessToken;
    String? errorMessage;

    unawaited(
      _pollForAccessToken(
        session,
        isCancelled: () => cancelled,
        onSuccess: (token) {
          accessToken = token;
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
        },
        onError: (message) {
          errorMessage = message;
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
        },
      ),
    );

    await Get.dialog(
      _GitHubDeviceLoginDialog(
        session: session,
        onOpenBrowser: () => _openVerificationPage(session.verificationUri),
        onCopyCode: () => _copyUserCode(session.userCode),
        onCancel: () {
          cancelled = true;
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
        },
      ),
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 150),
      transitionCurve: Curves.easeOut,
    );

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      ToastUtils.toast(errorMessage!);
    }

    return accessToken;
  }

  static Future<_GitHubDeviceSession?> _requestDeviceCode() async {
    final response = await HttpClient.post(
      ApiService.githubUrl + ApiService.apiDeviceCode,
      queryParameters: {
        'client_id': ApiService.clientId,
        'scope': ApiService.githubOauthScopes,
      },
      options: Options(headers: {'Accept': 'application/json'}),
    );

    if (!response.ok || response.data is! Map) {
      ToastUtils.toast('github_login_start_failed'.tr);
      return null;
    }

    final data = Map<String, dynamic>.from(response.data as Map);
    final error = data['error'];
    if (error is String) {
      ToastUtils.toast(_mapDeviceFlowError(error).tr);
      return null;
    }

    try {
      return _GitHubDeviceSession.fromJson(data);
    } catch (_) {
      ToastUtils.toast('message_data_error'.tr);
      return null;
    }
  }

  static Future<void> _pollForAccessToken(
    _GitHubDeviceSession session, {
    required bool Function() isCancelled,
    required void Function(String token) onSuccess,
    required void Function(String message) onError,
  }) async {
    var interval = session.interval;
    final deadline = DateTime.now().add(Duration(seconds: session.expiresIn));

    while (!isCancelled() && DateTime.now().isBefore(deadline)) {
      await Future.delayed(Duration(seconds: interval));
      if (isCancelled()) {
        return;
      }

      final response = await HttpClient.post(
        ApiService.githubUrl + ApiService.apiAccessToken,
        queryParameters: {
          'client_id': ApiService.clientId,
          'device_code': session.deviceCode,
          'grant_type': _deviceCodeGrantType,
        },
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (!response.ok || response.data is! Map) {
        onError('github_login_poll_failed'.tr);
        return;
      }

      final data = Map<String, dynamic>.from(response.data as Map);
      final accessToken = data['access_token'];
      if (accessToken is String && accessToken.isNotEmpty) {
        onSuccess(accessToken);
        return;
      }

      final error = data['error'];
      if (error is! String || error.isEmpty) {
        onError('github_login_poll_failed'.tr);
        return;
      }

      switch (error) {
        case 'authorization_pending':
          continue;
        case 'slow_down':
          interval += 5;
          continue;
        default:
          onError(_mapDeviceFlowError(error).tr);
          return;
      }
    }

    if (!isCancelled()) {
      onError('github_device_code_expired'.tr);
    }
  }

  static Future<void> _openVerificationPage(String verificationUri) async {
    final uri = Uri.parse(verificationUri);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      ToastUtils.toast('github_open_browser_failed'.tr);
    }
  }

  static Future<void> _copyUserCode(String userCode) async {
    await Clipboard.setData(ClipboardData(text: userCode));
    ToastUtils.toast('github_device_code_copied'.tr);
  }

  static String _mapDeviceFlowError(String errorCode) {
    switch (errorCode) {
      case 'slow_down':
        return 'github_login_slow_down';
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

class _GitHubDeviceSession {
  _GitHubDeviceSession({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.expiresIn,
    required this.interval,
  });

  factory _GitHubDeviceSession.fromJson(Map<String, dynamic> json) {
    return _GitHubDeviceSession(
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

class _GitHubDeviceLoginDialog extends StatelessWidget {
  const _GitHubDeviceLoginDialog({
    required this.session,
    required this.onOpenBrowser,
    required this.onCopyCode,
    required this.onCancel,
  });

  final _GitHubDeviceSession session;
  final VoidCallback onOpenBrowser;
  final VoidCallback onCopyCode;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'github_device_login_title'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text('github_device_login_desc'.tr, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  session.userCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onCopyCode,
                child: Text('github_device_copy_code'.tr),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onOpenBrowser,
                child: Text('github_device_open_browser'.tr),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onCancel,
                child: Text('dialog_cancel_text'.tr),
              ),
              const SizedBox(height: 4),
              Text(
                'github_device_login_hint'.trParams({
                  'minutes': (session.expiresIn / 60).ceil().toString(),
                }),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
