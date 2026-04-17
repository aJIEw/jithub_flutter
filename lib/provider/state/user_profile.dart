import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/util/sputils.dart';
import 'package:jithub_flutter/data/model/user.dart';

class UserProfile with ChangeNotifier {
  String? authToken;
  User? user;

  void init(String token, String userJson) {
    authToken = token;
    HttpClient.setAuthToken(token);

    user = User.fromJson(json.decode(userJson));

    if (kDebugMode) {
      logger.d('========= Token and User is set ========');
    }
  }

  void initWithLoginInfo(dynamic info) {
    authToken = info['token'];
    HttpClient.setAuthToken(authToken!);
    SPUtils.saveAuthToken(authToken!);

    user = User(name: info['name']);
    SPUtils.saveUser(user!);

    if (kDebugMode) {
      logger.d('========= Token and User is set ========');
    }

    notifyListeners();
  }

  void clear() {
    authToken = null;
    user = null;

    HttpClient.setAuthToken('');
    SPUtils.saveAuthToken('');
    SPUtils.saveUser(User.emptyUser());

    notifyListeners();
  }
}
