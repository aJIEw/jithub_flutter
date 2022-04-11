import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/base/refresh_loadmore_viewmodel.dart';

abstract class BaseRefreshLoadMoreViewModel extends RefreshLoadMoreViewModel {
  int page = 1;

  String get requestUrl;

  /// 是否存在下一页数据，在 [loadData] 方法中调用
  void checkHasNextPage(List data) {
    if (data.length >= ApiService.perPageSize) {
      nextPageUrl = requestUrl;
      page++;
    } else {
      nextPageUrl = "";
    }
  }

  @override
  Future<List> onRefresh() {
    isRefreshing = true;
    page = 1;
    return loadRemoteData();
  }

  @override
  Future<List> onLoadMore() {
    isRefreshing = false;
    return loadRemoteData();
  }
}
