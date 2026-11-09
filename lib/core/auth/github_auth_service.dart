import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/auth/github_device_flow_poller.dart';
import 'package:jithub_flutter/core/http/app_log_interceptor.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/http/http_response.dart';
import 'package:jithub_flutter/core/util/toast.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubAuthService {
  static const Duration _oauthConnectTimeout = Duration(seconds: 15);
  static const Duration _oauthSendTimeout = Duration(seconds: 15);
  static const Duration _oauthReceiveTimeout = Duration(seconds: 60);

  static Future<String?> authenticate() async {
    final session = await _requestDeviceCode();
    if (session == null) {
      return null;
    }

    var cancelled = false;
    String? accessToken;
    String? errorMessage;
    final lifecycleGate = GitHubAuthLifecycleGate(
      resumeCallback: HttpClient.resetConnections,
    );
    final poller = GitHubDeviceFlowPoller(
      post: _postOAuth,
      isAppActive: () => lifecycleGate.isActive,
      waitForAppActive: lifecycleGate.waitUntilActive,
      onTransientFailure: HttpClient.resetConnections,
    );

    unawaited(
      poller.poll(session, isCancelled: () => cancelled).then((result) {
        if (cancelled) {
          return;
        }
        switch (result) {
          case GitHubDevicePollSuccess(accessToken: final token):
            accessToken = token;
          case GitHubDevicePollFailure(:final messageKey):
            errorMessage = messageKey.tr;
          case GitHubDevicePollCancelled():
            return;
        }
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      }),
    );

    try {
      await Get.dialog(
        _GitHubDeviceLoginDialog(
          session: session,
          onOpenBrowser: () {
            lifecycleGate.pause();
            unawaited(
              _openVerificationPage(
                session.verificationUri,
                onOpenFailed: lifecycleGate.resume,
              ),
            );
          },
          onCopyCode: () => _copyUserCode(session.userCode),
          onCancel: () {
            cancelled = true;
            lifecycleGate.resume();
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
    } finally {
      cancelled = true;
      lifecycleGate.dispose();
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      ToastUtils.toast(errorMessage!);
    }

    return accessToken;
  }

  static Future<HttpResponse> _postOAuth(
    String url, {
    required Map<String, dynamic> queryParameters,
    required Options options,
  }) {
    return HttpClient.post(
      url,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static Future<GitHubDeviceSession?> _requestDeviceCode() async {
    final response = await HttpClient.post(
      ApiService.githubUrl + ApiService.apiDeviceCode,
      queryParameters: {
        'client_id': ApiService.clientId,
        'scope': ApiService.githubOauthScopes,
      },
      options: _oauthRequestOptions(),
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
      return GitHubDeviceSession.fromJson(data);
    } catch (_) {
      ToastUtils.toast('message_data_error'.tr);
      return null;
    }
  }

  static Future<void> _openVerificationPage(
    String verificationUri, {
    required VoidCallback onOpenFailed,
  }) async {
    final uri = Uri.parse(verificationUri);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      onOpenFailed();
      ToastUtils.toast('github_open_browser_failed'.tr);
    }
  }

  static Future<void> _copyUserCode(String userCode) async {
    await Clipboard.setData(ClipboardData(text: userCode));
    ToastUtils.toast('github_device_code_copied'.tr);
  }

  static Options _oauthRequestOptions() {
    return Options(
      headers: const <String, String>{'Accept': 'application/json'},
      extra: const <String, dynamic>{
        AppLogInterceptor.redactSensitiveDataKey: true,
      },
      connectTimeout: _oauthConnectTimeout,
      sendTimeout: _oauthSendTimeout,
      receiveTimeout: _oauthReceiveTimeout,
    );
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

class _GitHubDeviceLoginDialog extends StatelessWidget {
  const _GitHubDeviceLoginDialog({
    required this.session,
    required this.onOpenBrowser,
    required this.onCopyCode,
    required this.onCancel,
  });

  final GitHubDeviceSession session;
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
