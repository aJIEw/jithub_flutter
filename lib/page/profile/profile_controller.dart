import 'dart:convert';
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/core/api_service.dart';
import 'package:jithub_flutter/core/base/base_controller.dart';
import 'package:jithub_flutter/core/http/http_client.dart';
import 'package:jithub_flutter/core/http/http_response.dart';
import 'package:jithub_flutter/core/util/event.dart';
import 'package:jithub_flutter/core/util/logger.dart';
import 'package:jithub_flutter/core/util/sputils.dart';
import 'package:jithub_flutter/data/event/bus_event.dart';
import 'package:jithub_flutter/data/model/contribution_record.dart';
import 'package:jithub_flutter/data/model/user.dart';
import 'package:jithub_flutter/data/response/contribution_calendar.dart';
import 'package:jithub_flutter/data/response/github_repo.dart';
import 'package:jithub_flutter/page/profile/contribution_calculator.dart';
import 'package:sprintf/sprintf.dart';

class ProfileController extends BaseController {
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
  int contributionPlaceholderDays = 0;
  late DateTime _contributionStartDate;
  late DateTime _contributionEndDate;

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

      getUserContributionsRequest();
    });
  }

  @override
  void onInit() {
    super.onInit();

    _initContributionData();

    if (_options != null) {
      getUserContributionsRequest();
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
    _contributionEndDate = ContributionCalculator.normalizeDate(today);

    _contributionRecords
      ..clear()
      ..addAll(ContributionCalculator.buildContributionRecords(today: today));

    logger.d(
      'ProfileController - _initContributionData: ${_contributionRecords.length}',
    );
  }

  Future<void> getUserContributionsRequest() async {
    final response = await HttpClient.graphql(
      GithubContributionQueries.userContributions,
      variables: <String, dynamic>{
        'login': _userName,
        'from': _toGraphqlDateTime(_contributionStartDate),
        'to': _toGraphqlDateTime(
          DateTime(
              _contributionEndDate.year,
              _contributionEndDate.month,
              _contributionEndDate.day,
              23,
              59,
              59,
          ),
        ),
      },
      options: _options,
    );

    if (response.ok) {
      try {
        final responseData = response.data;
        if (responseData is! Map<String, dynamic>) {
          throw const FormatException('GraphQL response missing data');
        }

        final calendar = GithubContributionCalendar.fromGraphqlData(
          responseData,
        );
        ContributionCalculator.applyContributionDays(
          _contributionRecords,
          calendar.days,
        );
        _initObservableData();
      } on FormatException catch (e) {
        final failure = HttpResponse.failure(
          errorMsg: e.message,
          errorCode: response.code,
        );
        onRequestError(failure);
        return Future.error(e.message);
      }
    } else {
      onRequestError(response);
      return Future.error(response.error?.message ?? '');
    }
  }

  String _toGraphqlDateTime(DateTime date) {
    return date.toLocal().toUtc().toIso8601String();
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
