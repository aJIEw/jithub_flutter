import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/util/sputils.dart';
import 'package:sprintf/sprintf.dart';

class StarButtonController extends GetxController {
  StarButtonController(this.author, this.repoName) {
    onInit();
  }

  late String _authToken;
  Options? _options;
  String author;
  String repoName;

  var notLoggedIn = true.obs;
  var loading = false.obs;
  var hasStarred = false.obs;

  @override
  void onInit() {
    super.onInit();

    _authToken = SPUtils.getAuthToken();

    if (_authToken.isNotEmpty) {
      checkIsRepoStarred();
      notLoggedIn.value = false;
      _options = Options(
        headers: {
          'Authorization': 'token $_authToken',
        },
      );
    }
  }

  void checkIsRepoStarred() async {
    if (author.isEmpty || repoName.isEmpty) {
      logger.e(
          'StarButtonController - checkIsRepoStarred: param empty: author = $author, repoName = $repoName');
      return;
    }

    loading.value = true;

    var url = sprintf.call(ApiService.apiStarRepo, [author, repoName]);
    var response = await HttpClient.get(url, options: _options);
    if (response.ok) {
      hasStarred.value = response.code == 204;
    } else {
      logger.e('StarButtonController - checkIsRepoStarred: $url');
    }

    loading.value = false;
  }

  void requestStarRepo() async {
    if (author.isEmpty || repoName.isEmpty) {
      logger.e(
          'StarButtonController - requestStarRepo: param empty: author = $author, repoName = $repoName');
      return;
    }

    loading.value = true;

    var url = sprintf.call(ApiService.apiStarRepo, [author, repoName]);
    var response = await HttpClient.put(url, options: _options);
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
          'StarButtonController - requestUnstarRepo: param empty: author = $author, repoName = $repoName');
      return;
    }

    loading.value = true;

    var url = sprintf.call(ApiService.apiStarRepo, [author, repoName]);
    var response = await HttpClient.delete(url, options: _options);
    if (response.ok) {
      hasStarred.value = !(response.code == 204);
    } else {
      logger.e('StarButtonController - requestUnstarRepo: $url');
    }

    loading.value = false;
  }
}
