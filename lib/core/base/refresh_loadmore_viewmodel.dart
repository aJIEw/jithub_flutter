import 'package:pull_to_refresh/pull_to_refresh.dart';

import '/core/util/logger.dart';
import '/core/base/base_viewmodel.dart';

/// 带下拉刷新、上拉加载页的 ViewModel
abstract class RefreshLoadMoreViewModel<T> extends BaseViewModel {
  RefreshController refreshController = RefreshController(
    initialRefresh: false,
    initialLoadStatus: LoadStatus.noMore,
  );

  /// 下一页的请求地址
  String? nextPageUrl;

  /// 请求所需要的参数
  dynamic params;

  /// 是否刷新中
  /// 当用户首次进入页面/手动下拉刷新时 ---> true
  /// 手动上拉加载 ---> false
  bool isRefreshing = true;

  /// 请求结果
  List<T> dataList = [];

  init({dynamic param}) async {
    isLoading = true;
    params = param;
    await loadRemoteData();
  }

  Future<List<T>> loadRemoteData() async {
    try {
      var response = await loadData();

      if (isLoading) {
        isLoading = false;
      }

      if (isRefreshing) {
        if (dataList.isNotEmpty) {
          dataList.clear();
        }
        refreshController.refreshCompleted();
        if (null != nextPageUrl && nextPageUrl!.isNotEmpty) {
          refreshController.loadComplete();
        }
      } else {
        if (null != nextPageUrl && nextPageUrl!.isNotEmpty) {
          refreshController.loadComplete();
        } else {
          refreshController.loadNoData();
        }
      }

      dataList.addAll(response);
      notifyListeners();

      return dataList;
    } catch (error, stackTrace) {
      logger.e('load failed', error, stackTrace);
      refreshController.loadFailed();
      return [];
    }
  }

  /// 加载数据
  Future<List<T>> loadData();

  /// 下拉刷新
  Future<List<T>> onRefresh();

  /// 上拉加载
  Future<List<T>> onLoadMore();
}
