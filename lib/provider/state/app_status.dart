import 'package:flutter/material.dart';

/// 应用状态
class AppStatus with ChangeNotifier {
  int _tabIndex;

  AppStatus(this._tabIndex);

  int get tabIndex => _tabIndex;

  set tabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }
}
