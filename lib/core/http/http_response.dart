import 'http_exceptions.dart';

class HttpResponse {
  late bool ok;
  dynamic data;
  int code = -1;
  HttpException? error;

  HttpResponse._internal({this.ok = false});

  HttpResponse.success(this.data, this.code) {
    ok = true;
  }

  HttpResponse.failure({String? errorMsg, int? errorCode}) {
    error = BadRequestException(message: errorMsg, code: errorCode);
    ok = false;
    code = errorCode ?? -1;
  }

  HttpResponse.failureFormResponse({dynamic data, int? errorCode}) {
    error = BadResponseException(data);
    ok = false;
    code = errorCode ?? -1;
  }

  HttpResponse.failureFromError([HttpException? error, int? errorCode]) {
    this.error = error ?? UnknownException();
    ok = false;
    code = errorCode ?? -1;
  }
}
