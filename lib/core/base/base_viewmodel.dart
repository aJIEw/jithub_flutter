import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'request_error_handler.dart';

/// Not recommended, use [BaseController] instead.
abstract class BaseViewModel extends ChangeNotifier with RequestErrorHandler {
  bool _isLoading = false;

  /// 数据加载中
  bool get isLoading => _isLoading;

  set isLoading(isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
