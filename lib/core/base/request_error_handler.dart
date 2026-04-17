import 'package:jithub_flutter/core/http/http_response.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/core/util/logger.dart';

mixin RequestErrorHandler {
  void onRequestError(HttpResponse response) {
    if (response.error?.message.isNotEmpty ?? false) {
      logger.e(response.error?.message, error: response.error);

      if (response.error!.code == 401) {
        handleTokenExpiration(response.error!.message);
      } else {
        handleErrorMessage(response.error!.message);
      }
    }
  }

  void handleTokenExpiration(String message) {
    XEvent.post('RequestTokenExpired', message);
  }

  void handleErrorMessage(String message) {
    XEvent.post('RequestErrorMessage', message);
  }
}
