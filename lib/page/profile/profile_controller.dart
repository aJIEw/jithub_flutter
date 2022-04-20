import 'dart:convert';
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/base/base_controller.dart';
import 'package:jithub_flutter/core/constants.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/util/sputils.dart';
import 'package:jithub_flutter/data/model/contribution_record.dart';
import 'package:jithub_flutter/data/model/github_event.dart';
import 'package:jithub_flutter/data/model/user.dart';
import 'package:jithub_flutter/data/response/event_timeline.dart';
import 'package:jithub_flutter/data/response/github_repo.dart';
import 'package:sprintf/sprintf.dart';

class ProfileController extends BaseController {
  late String userName;
  late String authToken;

  var contributionList = <ContributionRecord>[].obs;
  var totalContribution = 0.obs;
  var maxDailyContribution = 0.obs;
  var minDailyContribution = 0.obs;

  var canShowPopup = false; // 是否可显示弹窗
  var popupShown = false;

  final List<ContributionRecord> _contributionRecords = [];
  int _userEventsPage = 1;
  int contributionPlaceholderDays = 0;

  @override
  void initParams() {
    super.initParams();

    var userJson = SPUtils.getUser();
    userName = userJson.isNotEmpty
        ? User.fromJson(json.decode(userJson)).name ?? ''
        : '';

    authToken = SPUtils.getAuthToken();
  }

  @override
  void onInit() {
    super.onInit();

    _initContributionData();

    getUserEventsRequest();
  }

  @override
  Future loadData() async {
    var response =
        await HttpClient.get(sprintf(ApiService.apiUserInfo, [userName]),
            options: Options(headers: {
              'Authorization': 'Bearer $authToken',
            }));

    if (response.ok) {
      var user = GithubUser.fromJson(response.data);
      return user;
    } else {
      onRequestError(response);
      return Future.error(response.error?.message ?? '');
    }
  }

  void _initContributionData() {
    var today = DateTime.now();
    switch (today.weekday) {
      case DateTime.sunday:
        contributionPlaceholderDays = 6;
        break;
      case DateTime.monday:
        contributionPlaceholderDays = 5;
        break;
      case DateTime.tuesday:
        contributionPlaceholderDays = 4;
        break;
      case DateTime.wednesday:
        contributionPlaceholderDays = 3;
        break;
      case DateTime.thursday:
        contributionPlaceholderDays = 2;
        break;
      case DateTime.friday:
        contributionPlaceholderDays = 1;
        break;
      case DateTime.saturday:
        contributionPlaceholderDays = 0;
        break;
    }

    var startIndex = 7;
    if (contributionPlaceholderDays > 0) {
      var totalOffset = 6 - contributionPlaceholderDays;
      for (var i = 0; i <= totalOffset; i++) {
        var offset = totalOffset - i;
        var date =
            Jiffy().subtract(days: offset).format(Constants.dateDefaultFormat);
        _contributionRecords
            .add(ContributionRecord(index: i, date: date, number: 0));
      }

      for (var i = (7 - contributionPlaceholderDays); i < 7; i++) {
        _contributionRecords
            .add(ContributionRecord(index: i, date: "", number: -1));
      }
    } else {
      startIndex = 0;
    }

    // 15 weeks at most
    for (var i = startIndex, j = 1; i <= 105; i = 7 * (++j)) {
      var weekEndIndex = i + 6;
      var weekStartIndex = i;
      for (var offset = weekEndIndex; offset >= i; offset--) {
        var date = Jiffy()
            .subtract(days: offset - contributionPlaceholderDays)
            .format(Constants.dateDefaultFormat);
        _contributionRecords.add(
            ContributionRecord(index: weekStartIndex, date: date, number: 0));
        weekStartIndex++;
      }
    }

    logger.d(
        'ProfileController - _initContributionData: ${_contributionRecords.length}');
  }

  Future getUserEventsRequest() async {
    var param = {
      'page': _userEventsPage,
      'per_page': 100,
    };
    var response =
        await HttpClient.get(sprintf(ApiService.apiUserEvents, [userName]),
            queryParameters: param,
            options: Options(headers: {
              'Authorization': 'Bearer $authToken',
            }));

    if (response.ok) {
      var list = (response.data as List)
          .map((item) => EventTimeline.fromJson(item))
          .toList();

      _filterPushEvent(list);

      if (list.length > 99) {
        _userEventsPage++;
        await getUserEventsRequest();
      } else {
        initObservableData();
      }
    } else {
      onRequestError(response);
      return Future.error(response.error?.message ?? '');
    }
  }

  void _filterPushEvent(List<EventTimeline> events) {
    var firstWeekDays = 7 - contributionPlaceholderDays;
    for (var event in events) {
      if (event.type == GithubEvent.PushEvent.name) {
        var date = Jiffy(event.createdAt).dateTime;
        var daysInBetween = Jiffy().diff(date, Units.DAY, true).ceil().toInt();
        if (daysInBetween > 0 && daysInBetween < firstWeekDays) {
          var updateIndex = firstWeekDays - 1 - daysInBetween;
          updateContributionNumber(updateIndex, event.payload?.commits);
        } else if (daysInBetween >= firstWeekDays) {
          var total = daysInBetween + contributionPlaceholderDays;
          var mid = (total / 7.0).floor() * 7 + 3;
          var updateIndex = mid;
          if (total > mid) {
            updateIndex = mid - (total - mid);
          } else {
            updateIndex = mid + (mid - total);
          }
          updateContributionNumber(updateIndex.toInt(), event.payload?.commits);
        }
      }
    }
  }

  void updateContributionNumber(int updateIndex, List<Commit>? commits) {
    if (updateIndex < 0 || updateIndex >= _contributionRecords.length) {
      logger.e(
          'ProfileController - updateContributionNumber: index out of range: $updateIndex');
      return;
    }

    var contribution = _contributionRecords[updateIndex];
    contribution.number += filterCurrentUserCommits(commits);
    _contributionRecords[updateIndex] = contribution;
  }

  int filterCurrentUserCommits(List<Commit>? commits) {
    if (commits == null) return 0;

    int count = 0;
    for (var commit in commits) {
      if (commit.author?.name == userName) {
        count++;
      }
    }

    return count;
  }

  void initObservableData() {
    contributionList.value = _contributionRecords;

    int total = 0;
    for (var item in contributionList) {
      total += item.number;
    }
    totalContribution.value = total;

    int max = 0, min = 0;
    for (var i in contributionList) {
      min = min == 0 ? i.number : min;
      if (i.number > max) {
        max = i.number;
      }

      if (i.number < min) {
        min = i.number;
      }
    }

    maxDailyContribution.value = max;
    minDailyContribution.value = min;
    canShowPopup = true;
  }
}
