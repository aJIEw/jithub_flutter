import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/util/sputils.dart';
import 'package:jithub_flutter/data/event/bus_event.dart';
import 'package:sprintf/sprintf.dart';

class StarButtonController extends GetxController {
  StarButtonController(this.author, this.repoName) {
    onInit();
  }

  late String _authToken;
  Options? _options;

  final String author;
  final String repoName;

  StreamSubscription? _loginSubscription;
  StreamSubscription? _logoutSubscription;

  final isLoggedIn = true.obs;
  final loading = false.obs;
  final hasStarred = false.obs;

  @override
  void onInit() {
    super.onInit();

    isLoggedIn.value = SPUtils.isLoggedIn();
    if (isLoggedIn.value) {
      _refreshStarState();
    }

    _loginSubscription = XEvent.on(BusEvent.userLoggedIn, (value) async {
      logger.d('StarButtonController: userLoggedIn');

      isLoggedIn.value = true;
      _refreshStarState();
    });

    _logoutSubscription = XEvent.on(BusEvent.userLoggedOut, (value) async {
      logger.d('StarButtonController: userLoggedOut');

      // Clear state
      _options = null;
      isLoggedIn.value = false;
      hasStarred.value = false;
      loading.value = false;
    });
  }

  void _refreshStarState() {
    _authToken = SPUtils.getAuthToken();
    _options = Options(headers: {'Authorization': 'Bearer $_authToken'});
    checkIsRepoStarred();
  }

  void checkIsRepoStarred() async {
    if (author.isEmpty || repoName.isEmpty) {
      logger.e(
        'StarButtonController - checkIsRepoStarred: param empty: author = $author, repoName = $repoName',
      );
      return;
    }

    loading.value = true;

    final url = sprintf.call(ApiService.apiStarRepo, [author, repoName]);
    final response = await HttpClient.get(url, options: _options);
    if (response.ok) {
      hasStarred.value = response.code == 204;
    } else if (response.code == 404) {
      hasStarred.value = false;
    } else {
      logger.e(
        'StarButtonController - checkIsRepoStarred: response.code = ${response.code}',
      );
    }

    loading.value = false;
  }

  void requestStarRepo() async {
    if (author.isEmpty || repoName.isEmpty) {
      logger.e(
        'StarButtonController - requestStarRepo: param empty: author = $author, repoName = $repoName',
      );
      return;
    }

    loading.value = true;

    final url = sprintf.call(ApiService.apiStarRepo, [author, repoName]);
    final response = await HttpClient.put(url, options: _options);
    if (response.ok) {
      hasStarred.value = response.code == 204;
    } else {
      logger.e('StarButtonController - requestStarRepo: $url');
    }

    loading.value = false;
  }

  void requestUnstarRepo() async {
    if (author.isEmpty || repoName.isEmpty) {
      logger.e(
        'StarButtonController - requestUnstarRepo: param empty: author = $author, repoName = $repoName',
      );
      return;
    }

    loading.value = true;

    final url = sprintf.call(ApiService.apiStarRepo, [author, repoName]);
    final response = await HttpClient.delete(url, options: _options);
    if (response.ok) {
      hasStarred.value = !(response.code == 204);
    } else {
      logger.e('StarButtonController - requestUnstarRepo: $url');
    }

    loading.value = false;
  }

  @override
  void dispose() {
    XEvent.cancel(BusEvent.userLoggedIn, _loginSubscription);
    XEvent.cancel(BusEvent.userLoggedOut, _logoutSubscription);

    super.dispose();
  }
}
