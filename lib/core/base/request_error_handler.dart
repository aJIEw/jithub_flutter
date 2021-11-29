import '/core/http/http_response.dart';
import '/core/util/event.dart';
import '/core/util/logger.dart';

mixin RequestErrorHandler {
  void onRequestError(HttpResponse response) {
    if (response.error?.message.isNotEmpty ?? false) {
      logger.e(response.error?.message, response.error);

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
