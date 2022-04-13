import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/http/http_response.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/widget/base_refresh_loadmore_viewmodel.dart';
import 'package:jithub_flutter/data/model/user.dart';
import 'package:jithub_flutter/data/response/event_timeline.dart';
import 'package:jithub_flutter/data/response/user_repo.dart';
import 'package:sprintf/sprintf.dart';

class HomeViewModel extends BaseRefreshLoadMoreViewModel {
  List<Future<UserRepo>> userRepoRequests = [];

  @override
  String get requestUrl => ApiService.apiReceivedEvents;

  List<EventTimeline> cachedList = [];

  @override
  Future<List> loadData() async {
    if (params == null || params is! User) {
      return List.empty();
    }

    var param = <String, dynamic>{};
    param["page"] = page;
    var url = sprintf.call(requestUrl, [params.name]);
    HttpResponse response = await HttpClient.get(url, queryParameters: param);
    // HttpResponse response = await Future.delayed(const Duration(seconds: 3))
    //     .then((value) => HttpResponse.failureFromError(HttpException("Network error")));

    var list = [];
    if (response.ok) {
      List<EventTimeline> data = (response.data as List)
          .map((item) => EventTimeline.fromJson(item))
          .toList();
      checkHasNextPage(data);

      list = data;
      cachedList = data;
    } else {
      logger.e('HomeViewModel - loadData: ${response.error}: $url');

      if (response.error?.code == 304 && cachedList.isNotEmpty) {
        list = cachedList;
      } else {
        onRequestError(response);
      }
    }

    return list;
  }

  @override
  Future<List> onRefresh() {
    userRepoRequests.clear();
    return super.onRefresh();
  }

  Future<UserRepo> getUserRepoRequest(int index, String url) async {
    HttpResponse response = await HttpClient.get(url);

    if (response.ok) {
      var result = UserRepo.fromJson(response.data);

      // 缓存请求
      userRepoRequests.add(Future.value(result));

      return result;
    } else {
      logger.e('HomeViewModel - getUserRepo: ${response.error}: $url');

      if (response.error?.code == 304 && userRepoRequests.length > index) {
        // 如果是 304，则直接返回缓存的数据
        return userRepoRequests[index];
      } else {
        onRequestError(response);
        return Future.error(response.error ?? "Network error");
      }
    }
  }
}
