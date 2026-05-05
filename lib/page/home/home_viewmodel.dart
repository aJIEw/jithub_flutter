import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/http/http_response.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/widget/base_refresh_loadmore_viewmodel.dart';
import 'package:jithub_flutter/data/model/github_event.dart';
import 'package:jithub_flutter/data/model/user.dart';
import 'package:jithub_flutter/data/response/event_timeline.dart';
import 'package:jithub_flutter/page/home/home_event_grouping.dart';
import 'package:sprintf/sprintf.dart';

class HomeViewModel extends BaseRefreshLoadMoreViewModel<EventTimeline> {
  static final Set<String> _allowedEventTypes = GithubEvent.values
      .map((event) => event.name)
      .toSet();

  @override
  String get requestUrl => ApiService.apiReceivedEvents;

  @override
  Future<List<EventTimeline>> loadData() async {
    if (params == null || params is! User) {
      return const <EventTimeline>[];
    }

    final currentUser = params as User;
    final currentLogin = currentUser.name?.trim().toLowerCase();
    final param = <String, dynamic>{};
    param['page'] = page;
    final url = sprintf.call(requestUrl, [currentUser.name]);
    final HttpResponse response = await HttpClient.get(
      url,
      queryParameters: param,
    );
    // HttpResponse response = await Future.delayed(const Duration(seconds: 3))
    //     .then((value) => HttpResponse.failureFromError(HttpException("Network error")));

    if (response.ok) {
      final List<EventTimeline> data = (response.data as List)
          .map((item) => EventTimeline.fromJson(item))
          .toList();
      checkHasNextPage(data);
      final filteredData = data.where((item) {
        final actorLogin = item.actor?.login?.trim().toLowerCase();
        final isCurrentUser =
            currentLogin != null &&
            currentLogin.isNotEmpty &&
            actorLogin == currentLogin;
        return !isCurrentUser && _allowedEventTypes.contains(item.type);
      }).toList();

      final groupedData = HomeEventGrouping.mergeConsecutivePushEvents(
        filteredData,
      );
      if (!isRefreshing && dataList.isNotEmpty && groupedData.isNotEmpty) {
        final lastExisting = dataList.last;
        final firstNew = groupedData.first;
        if (HomeEventGrouping.canMergePushEvents(lastExisting, firstNew)) {
          dataList[dataList.length -
              1] = HomeEventGrouping.mergePushEventsForBoundary(
            lastExisting,
            firstNew,
          );
          groupedData.removeAt(0);
        }
      }

      return groupedData;
    } else {
      logger.e('HomeViewModel - loadData: ${response.error}: $url');
      onRequestError(response);
    }

    return const <EventTimeline>[];
  }
}
