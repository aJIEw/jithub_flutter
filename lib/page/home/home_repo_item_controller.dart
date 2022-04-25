import 'package:get/get.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/data/response/user_repo.dart';

class HomeRepoItemController extends GetxController {
  HomeRepoItemController(this.repoUrl) {
    onInit();
  }

  var repoUrl = '';

  var loading = false.obs;
  var repo = Rx<UserRepo>(UserRepo());

  @override
  void onInit() {
    super.onInit();

    getRepoDetail(repoUrl);
  }

  void getRepoDetail(String repoUrl) async {
    loading.value = true;

    var response = await HttpClient.get(repoUrl);
    if (response.ok) {
      var result = UserRepo.fromJson(response.data);

      repo.value = result;
    } else {
      logger.e(
          'HomeRepoItemController - getRepoDetail: ${response.error}: $repoUrl');
    }

    loading.value = false;
  }
}
