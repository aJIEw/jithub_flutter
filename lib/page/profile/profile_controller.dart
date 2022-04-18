import 'dart:convert';

import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/base/base_controller.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/util/sputils.dart';
import 'package:jithub_flutter/data/model/user.dart';
import 'package:jithub_flutter/data/response/github_repo.dart';
import 'package:sprintf/sprintf.dart';

class ProfileController extends BaseController {
  late String userName;

  @override
  void initParams() {
    super.initParams();

    var userJson = SPUtils.getUser();
    userName = userJson.isNotEmpty
        ? User.fromJson(json.decode(userJson)).name ?? ''
        : '';
  }

  @override
  Future loadData() async {
    var response = await HttpClient.get(sprintf(ApiService.apiUserInfo, [userName]));

    if (response.ok) {
      var user = GithubUser.fromJson(response.data);
      return user;
    } else {
      onRequestError(response);
      return Future.error(response.error?.message ?? '');
    }
  }
}
