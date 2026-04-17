import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/base/refresh_loadmore_viewmodel.dart';

abstract class BaseRefreshLoadMoreViewModel<T>
    extends RefreshLoadMoreViewModel<T> {
  int page = 1;

  String get requestUrl;

  int perPageSize = ApiService.perPageSize;

  /// 是否存在下一页数据，在 [loadData] 方法中调用
  void checkHasNextPage(List<T> data) {
    if (data.length >= perPageSize) {
      nextPageUrl = requestUrl;
      page++;
    } else {
      nextPageUrl = '';
    }
  }

  @override
  Future<List<T>> onRefresh() {
    isRefreshing = true;
    page = 1;
    return loadRemoteData();
  }

  @override
  Future<List<T>> onLoadMore() {
    isRefreshing = false;
    return loadRemoteData();
  }
}
