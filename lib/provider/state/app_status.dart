import 'package:flutter/material.dart';

/// 应用状态
class AppStatus with ChangeNotifier {
  int _tabIndex;
  int? _pendingTabIndex;

  AppStatus(this._tabIndex);

  int get tabIndex => _tabIndex;
  int? get pendingTabIndex => _pendingTabIndex;

  set tabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  void setPendingTabIndex(int? index) {
    _pendingTabIndex = index;
  }

  int? consumePendingTabIndex() {
    final index = _pendingTabIndex;
    _pendingTabIndex = null;
    return index;
  }
}
