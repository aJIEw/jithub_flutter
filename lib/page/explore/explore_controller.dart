import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/base/base_controller.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/http/http_exceptions.dart';
import 'package:jithub_flutter/core/http/http_response.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/data/response/trending_repo.dart';

class ExploreController extends BaseController {
  List<TrendingRepo> trendingRepos = [];

  @override
  Future loadData() async {
    var response = await HttpClient.get(
        ApiService.trendingUrl + ApiService.apiTrendingRepos);

    // var response = await Future.delayed(const Duration(seconds: 3)).then(
    //         (value) => HttpResponse.failureFromError(NetworkException(message: "Network Error")));
    if (response.ok) {
      trendingRepos = (response.data as List)
          .map((item) => TrendingRepo.fromJson(item))
          .toList();
      return trendingRepos;
    } else {
      logger.d('ExploreController - fetchTrendingRepos: ${response.error}');
      return Future.error(response.error?.message ?? '');
    }
  }
}
