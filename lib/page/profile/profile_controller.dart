import 'dart:convert';
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/base/base_controller.dart';
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

  var contributionList = <ContributionRecord>[].obs;
  var totalContribution = 0.obs;
  int _userEventsPage = 1;
  int _contributionPlaceholderDays = 0;
  final List<ContributionRecord> _contributionRecords = [];

  @override
  void initParams() {
    super.initParams();

    var userJson = SPUtils.getUser();
    userName = userJson.isNotEmpty
        ? User.fromJson(json.decode(userJson)).name ?? ''
        : '';
  }

  @override
  void onInit() {
    super.onInit();

    _initContributionData();

    getUserEventsRequest();
  }

  @override
  Future loadData() async {
    var response = await HttpClient.get(sprintf(ApiService.apiUserInfo, [userName]));

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
        _contributionPlaceholderDays = 6;
        break;
      case DateTime.monday:
        _contributionPlaceholderDays = 5;
        break;
      case DateTime.tuesday:
        _contributionPlaceholderDays = 4;
        break;
      case DateTime.wednesday:
        _contributionPlaceholderDays = 3;
        break;
      case DateTime.thursday:
        _contributionPlaceholderDays = 2;
        break;
      case DateTime.friday:
        _contributionPlaceholderDays = 1;
        break;
      case DateTime.saturday:
        _contributionPlaceholderDays = 0;
        break;
    }

    var startIndex = 7;
    var dateFormat = "MMM dd, yyyy";
    if (_contributionPlaceholderDays > 0) {
      var totalOffset = 6 - _contributionPlaceholderDays;
      for (var i = 0; i <= totalOffset; i++) {
        var offset = totalOffset - i;
        var date = Jiffy().subtract(days: offset).format(dateFormat);
        _contributionRecords
            .add(ContributionRecord(index: i, date: date, number: 0));
      }

      for (var i = (7 - _contributionPlaceholderDays); i < 7; i++) {
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
            .subtract(days: offset - _contributionPlaceholderDays)
            .format("MMM dd, yyyy");
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
    var response = await HttpClient.get(
        sprintf(ApiService.apiUserEvents, [userName]),
        queryParameters: param);

    if (response.ok) {
      var list = (response.data as List)
          .map((item) => EventTimeline.fromJson(item))
          .toList();

      _filterPushEvent(list);

      if (contributionList.isNotEmpty) {
        contributionList.addAll(_contributionRecords);
      } else {
        contributionList.value = _contributionRecords;
      }

      int total = 0;
      for (var item in contributionList) {
        total += item.number;
      }
      totalContribution.value = total;

      if (list.length > 99) {
        _userEventsPage++;
        await getUserEventsRequest();
      }
    } else {
      onRequestError(response);
      return Future.error(response.error?.message ?? '');
    }
  }

  void _filterPushEvent(List<EventTimeline> events) {
    var firstWeekDays = 7 - _contributionPlaceholderDays;
    for (var event in events) {
      if (event.type == GithubEvent.PushEvent.name) {
        var date = Jiffy(event.createdAt).dateTime;
        var daysInBetween = Jiffy().diff(date, Units.DAY).toInt();
        if (daysInBetween > 0 && daysInBetween <= firstWeekDays) {
          var updateIndex = firstWeekDays - 1 - daysInBetween;
          updateContributionNumber(updateIndex, event.payload?.commits);
        } else if (daysInBetween >= firstWeekDays) {
          var total = daysInBetween + _contributionPlaceholderDays;
          var updateIndex = ((total / 7.0) * 7 - 1 - (total % 7)).ceil();
          updateContributionNumber(updateIndex.toInt(), event.payload?.commits);
        }
      }
    }
  }

  void updateContributionNumber(int updateIndex, List<Commit>? commits) {
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
}
