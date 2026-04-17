import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/widget/base_refresh_loadmore_viewmodel.dart';
import 'package:jithub_flutter/data/response/user_repo.dart';

class RepoListViewModel extends BaseRefreshLoadMoreViewModel<UserRepo> {
  @override
  String get requestUrl => ApiService.apiUserRepos;

  @override
  int get perPageSize => 100;

  @override
  Future<List<UserRepo>> loadData() async {
    /*if (params == null || params is! String) {
      return List.empty();
    }*/

    final param = {'page': page, 'per_page': perPageSize, 'sort': 'pushed'};
    // var url = sprintf.call(requestUrl, [params]);
    final url = requestUrl;
    final response = await HttpClient.get(url, queryParameters: param);

    if (response.ok) {
      final List<UserRepo> data = (response.data as List)
          .map((item) => UserRepo.fromJson(item))
          .toList();
      checkHasNextPage(data);
      return data;
    } else {
      logger.e('RepoListViewModel - loadData: ${response.error}: $url');
      onRequestError(response);
    }

    return const <UserRepo>[];
  }
}
