import 'dart:convert';

import '/core/http/http_client.dart';
import '/core/util/logger.dart';
import '/core/util/sputils.dart';
import '/data/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserProfile with ChangeNotifier {
  String? authToken;
  User? user;

  init(String token, String userJson) {
    authToken = token;
    HttpClient.setAuthToken(token);

    user = User.fromJson(json.decode(userJson));

    if (kDebugMode) {
      logger.d('========= Token and User is set ========');
    }
  }

  initWithLoginInfo(dynamic info) {
    authToken = info['token'];
    HttpClient.setAuthToken(authToken!);
    SPUtils.saveAuthToken(authToken!);

    user = User(
      name: info['name'],
    );
    SPUtils.saveUser(user!);

    if (kDebugMode) {
      logger.d('========= Token and User is set ========');
    }

    notifyListeners();
  }

  clear() {
    authToken = null;
    user = null;

    HttpClient.setAuthToken('');
    SPUtils.saveAuthToken('');
    SPUtils.saveUser(User.emptyUser());

    notifyListeners();
  }
}
