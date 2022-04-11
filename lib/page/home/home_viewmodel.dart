import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/http/http_exceptions.dart';
import 'package:jithub_flutter/core/http/http_response.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/widget/base_refresh_loadmore_viewmodel.dart';
import 'package:jithub_flutter/data/model/user.dart';
import 'package:jithub_flutter/data/response/event_timeline.dart';
import 'package:sprintf/sprintf.dart';

class HomeViewModel extends BaseRefreshLoadMoreViewModel {
  @override
  String get requestUrl => ApiService.apiReceivedEvents;

  @override
  Future<List> loadData({dynamic data}) async {
    if (data == null || data is! User) {
      return List.empty();
    }

    var param = <String, dynamic>{};
    param["page"] = page;
    var url = sprintf.call(requestUrl, [data.name]);
    HttpResponse response = await HttpClient.get(url, queryParameters: param);
    // HttpResponse response = await Future.delayed(const Duration(seconds: 3))
    //     .then((value) => HttpResponse.failureFromError(HttpException("网络错误")));

    var list = [];
    if (response.ok) {
      List<EventTimeline> data = (response.data as List)
          .map((item) => EventTimeline.fromJson(item))
          .toList();
      checkHasNextPage(data);

      list = data;
    } else {
      logger.e('HomeViewModel - loadData: ${response.error}');
      onRequestError(response);
    }

    return list;
  }
}
