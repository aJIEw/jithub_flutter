import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/widget/base_refresh_loadmore_viewmodel.dart';
import 'package:jithub_flutter/data/response/user_repo.dart';
import 'package:sprintf/sprintf.dart';

class RepoListViewModel extends BaseRefreshLoadMoreViewModel {
  @override
  String get requestUrl => ApiService.apiUserRepos;

  @override
  int get perPageSize => 100;

  @override
  Future<List> loadData() async {
    /*if (params == null || params is! String) {
      return List.empty();
    }*/

    var param = {
      'page': page,
      'per_page': perPageSize,
      'sort': 'pushed',
    };
    // var url = sprintf.call(requestUrl, [params]);
    var url = requestUrl;
    var response = await HttpClient.get(url, queryParameters: param);

    var list = [];
    if (response.ok) {
      List<UserRepo> data = (response.data as List)
          .map((item) => UserRepo.fromJson(item))
          .toList();
      checkHasNextPage(data);

      list = data;
    } else {
      logger.e('RepoListViewModel - loadData: ${response.error}: $url');
      onRequestError(response);
    }

    return list;
  }
}
