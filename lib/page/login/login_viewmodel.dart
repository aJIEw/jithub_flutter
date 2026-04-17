import 'package:get/get_utils/src/extensions/num_extensions.dart';
import 'package:jithub_flutter/core/base/base_viewmodel.dart';
import 'package:jithub_flutter/core/http/http_response.dart';

class LoginViewModel extends BaseViewModel {
  Future<bool> getSmsCodeRequest(String phone) async {
    final param = <String, dynamic>{};
    param['phone'] = phone;

    // Todo: change to real request later
    final HttpResponse response = await Future.delayed(
      1.seconds,
    ).then((value) => HttpResponse.success('', 200));
    if (response.ok) {
      return true;
    } else {
      onRequestError(response);
    }

    return false;
  }

  Future<Object?> loginRequest(
    String phone,
    String smsCode, {
    bool isUpdatePhone = false,
  }) async {
    final param = <String, dynamic>{};
    param['phone'] = phone;
    param['code'] = smsCode;

    // Todo: change to real request later
    final HttpResponse response = await Future.delayed(
      1.seconds,
    ).then((value) => HttpResponse.success('', 200));

    dynamic loginInfo;
    if (response.ok) {
      loginInfo = {'token': 'Fake_token'};
    } else {
      onRequestError(response);
    }

    return loginInfo;
  }
}
