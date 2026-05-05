import 'package:jithub_flutter/data/model/contribution_record.dart';
import 'package:jithub_flutter/data/response/contribution_calendar.dart';
import 'package:jithub_flutter/data/response/event_timeline.dart';

class ContributionCalculator {
  static const int contributionDays = 90;
  static const int contributionColumns = 15;
  static const int contributionBlocks = contributionColumns * 7;

  static List<ContributionRecord> buildContributionRecords({
    DateTime? today,
    int days = contributionDays,
  }) {
    final normalizedToday = normalizeDate(today ?? DateTime.now());
    final startDate = normalizedToday.subtract(Duration(days: days - 1));
    final oldestWeekStart = startDate.subtract(
      Duration(days: _weekdayIndex(startDate)),
    );
    final currentWeekStart = normalizedToday.subtract(
      Duration(days: _weekdayIndex(normalizedToday)),
    );
    final columns =
        currentWeekStart.difference(oldestWeekStart).inDays ~/ 7 + 1;

    final records = <ContributionRecord>[];

    void appendWeek(DateTime weekStart, {required bool allowPlaceholders}) {
      for (var day = 0; day < 7; day++) {
        final date = weekStart.add(Duration(days: day));
        final isPlaceholder =
            allowPlaceholders && date.isAfter(normalizedToday);
        records.add(
          ContributionRecord(
            index: records.length,
            date: isPlaceholder ? '' : dateKey(date),
            number: isPlaceholder ? -1 : 0,
          ),
        );
      }
    }

    for (var column = 0; column < columns; column++) {
      final weekStart = currentWeekStart.subtract(Duration(days: column * 7));
      appendWeek(weekStart, allowPlaceholders: column == 0);
    }

    return records;
  }

  static Map<String, int> buildDateIndexMap(List<ContributionRecord> records) {
    final map = <String, int>{};
    for (var i = 0; i < records.length; i++) {
      if (records[i].date.isNotEmpty) {
        map[records[i].date] = i;
      }
    }
    return map;
  }

  static void applyContributionDays(
    List<ContributionRecord> records,
    List<GithubContributionDay> days,
  ) {
    final dateIndexMap = buildDateIndexMap(records);
    for (final day in days) {
      final updateIndex = dateIndexMap[day.date];
      if (updateIndex == null) {
        continue;
      }

      records[updateIndex].number = day.contributionCount;
    }
  }

  static int countContributionCommits(Payload? payload) {
    if (payload == null) return 0;
    if (payload.size != null && payload.size! >= 0) {
      return payload.size!;
    }
    return payload.commits
            ?.where((commit) => commit.distinct != false)
            .length ??
        0;
  }

  static int countContributionForEvent(EventTimeline event) {
    switch (event.type) {
      case 'PushEvent':
        return countContributionCommits(event.payload);
      case 'IssuesEvent':
      case 'PullRequestReviewEvent':
      case 'PullRequestReviewCommentEvent':
      case 'CommitCommentEvent':
        return 1;
      case 'PullRequestEvent':
        return event.payload?.action == 'opened' ? 1 : 0;
      case 'CreateEvent':
        return event.payload?.refType == 'repository' ? 1 : 0;
      default:
        return 0;
    }
  }

  static String dateKey(DateTime date) {
    final normalized = normalizeDate(date.toLocal());
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }

  static DateTime normalizeDate(DateTime date) {
    final localDate = date.toLocal();
    return DateTime(localDate.year, localDate.month, localDate.day);
  }

  static int placeholderDaysFor(DateTime today) {
    return 6 - _weekdayIndex(normalizeDate(today));
  }

  static int _weekdayIndex(DateTime date) {
    return date.weekday % 7;
  }
}
