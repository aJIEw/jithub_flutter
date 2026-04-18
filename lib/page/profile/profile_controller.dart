import 'dart:convert';
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/base/base_controller.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/util/sputils.dart';
import 'package:jithub_flutter/data/event/bus_event.dart';
import 'package:jithub_flutter/data/model/contribution_record.dart';
import 'package:jithub_flutter/data/model/user.dart';
import 'package:jithub_flutter/data/response/event_timeline.dart';
import 'package:jithub_flutter/data/response/github_repo.dart';
import 'package:jithub_flutter/page/profile/contribution_calculator.dart';
import 'package:sprintf/sprintf.dart';

class ProfileController extends BaseController {
  static const int _maxUserEventsPages = 3;

  late String _userName;
  late String _authToken;
  Options? _options;

  final contributionList = <ContributionRecord>[].obs;
  final totalContribution = 0.obs;
  final maxDailyContribution = 0.obs;
  final minDailyContribution = 0.obs;

  var canShowPopup = false; // 是否可显示弹窗
  var popupShown = false;

  final List<ContributionRecord> _contributionRecords = [];
  final Map<String, int> _contributionDateIndexMap = {};
  int _userEventsPage = 1;
  int contributionPlaceholderDays = 0;
  late DateTime _contributionStartDate;

  @override
  void initParams() {
    super.initParams();

    final userJson = SPUtils.getUser();
    _userName = userJson.isNotEmpty
        ? User.fromJson(json.decode(userJson)).name ?? ''
        : '';

    _authToken = SPUtils.getAuthToken();
    if (_authToken.isNotEmpty) {
      _options = Options(headers: {'Authorization': 'Bearer $_authToken'});
    }
  }

  @override
  void registerBusEvent() {
    XEvent.on(BusEvent.userLoggedIn, (value) async {
      initParams();

      append(() => loadData);

      getUserEventsRequest();
    });
  }

  @override
  void onInit() {
    super.onInit();

    _initContributionData();

    if (_options != null) {
      getUserEventsRequest();
    }
  }

  @override
  Future<GithubUser> loadData() async {
    final response = await HttpClient.get(
      sprintf(ApiService.apiUserInfo, [_userName]),
      options: _options,
    );

    if (response.ok) {
      final user = GithubUser.fromJson(response.data);
      return user;
    } else {
      onRequestError(response);
      return Future.error(response.error?.message ?? '');
    }
  }

  void _initContributionData() {
    final today = DateTime.now();
    contributionPlaceholderDays = ContributionCalculator.placeholderDaysFor(
      today,
    );
    _contributionStartDate = ContributionCalculator.normalizeDate(
      today.subtract(
        const Duration(days: ContributionCalculator.contributionDays - 1),
      ),
    );

    _contributionRecords
      ..clear()
      ..addAll(ContributionCalculator.buildContributionRecords(today: today));
    _contributionDateIndexMap
      ..clear()
      ..addAll(ContributionCalculator.buildDateIndexMap(_contributionRecords));

    logger.d(
      'ProfileController - _initContributionData: ${_contributionRecords.length}',
    );
  }

  Future<void> getUserEventsRequest() async {
    final param = {'page': _userEventsPage, 'per_page': 100};
    final response = await HttpClient.get(
      sprintf(ApiService.apiUserEvents, [_userName]),
      queryParameters: param,
      options: _options,
    );

    if (response.ok) {
      final list = (response.data as List)
          .map((item) => EventTimeline.fromJson(item))
          .toList();

      _applyContributionEvents(list);

      if (_shouldLoadMoreEvents(list)) {
        _userEventsPage++;
        await getUserEventsRequest();
      } else {
        _initObservableData();
      }
    } else {
      onRequestError(response);
      return Future.error(response.error?.message ?? '');
    }
  }

  /// We can only load 300 events or events created within the past 30 days
  /// See <https://docs.github.com/en/rest/activity/events>
  bool _shouldLoadMoreEvents(List<EventTimeline> events) {
    if (events.isEmpty || events.length < 100) {
      return false;
    }

    if (_userEventsPage >= _maxUserEventsPages) {
      return false;
    }

    DateTime? oldestEventDate;
    for (final event in events) {
      if (event.createdAt == null || event.createdAt!.isEmpty) {
        continue;
      }

      final eventDate = DateTime.tryParse(event.createdAt!);
      if (eventDate == null) {
        continue;
      }

      final normalizedEventDate = ContributionCalculator.normalizeDate(
        eventDate,
      );
      if (oldestEventDate == null ||
          normalizedEventDate.isBefore(oldestEventDate)) {
        oldestEventDate = normalizedEventDate;
      }
    }

    if (oldestEventDate == null) {
      return false;
    }

    return !oldestEventDate.isBefore(_contributionStartDate);
  }

  void _applyContributionEvents(List<EventTimeline> events) {
    for (final event in events) {
      if (event.createdAt == null || event.createdAt!.isEmpty) {
        continue;
      }

      final contributionCount =
          ContributionCalculator.countContributionForEvent(event);
      if (contributionCount <= 0) {
        continue;
      }

      final eventDate = DateTime.tryParse(event.createdAt!);
      if (eventDate == null) {
        continue;
      }

      final updateIndex =
          _contributionDateIndexMap[ContributionCalculator.dateKey(eventDate)];
      if (updateIndex == null) {
        continue;
      }

      _updateContributionNumber(updateIndex, contributionCount);
    }
  }

  void _updateContributionNumber(int updateIndex, int contributionCount) {
    if (updateIndex < 0 || updateIndex >= _contributionRecords.length) {
      logger.e(
        'ProfileController - updateContributionNumber: index out of range: $updateIndex',
      );
      return;
    }

    final contribution = _contributionRecords[updateIndex];
    contribution.number += contributionCount;
    _contributionRecords[updateIndex] = contribution;
  }

  void _initObservableData() {
    contributionList.value = _contributionRecords;

    int total = 0, max = 0, min = 0;
    for (final i in contributionList) {
      if (i.number > 0) {
        total += i.number;
      }

      if (i.number > max) {
        max = i.number;
      }

      min = min == 0 && i.number > 0 ? i.number : min;
      if (i.number > 0 && i.number < min) {
        min = i.number;
      }
    }

    totalContribution.value = total;
    maxDailyContribution.value = max;
    minDailyContribution.value = min;
    canShowPopup = true;
  }
}
