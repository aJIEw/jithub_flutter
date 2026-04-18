import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/page/profile/contribution_calculator.dart';
import 'package:jithub_flutter/data/response/event_timeline.dart';

void main() {
  group('ContributionCalculator', () {
    test('builds only the needed columns for the 90-day range', () {
      final records = ContributionCalculator.buildContributionRecords(
        today: DateTime(2026, 4, 18),
      );

      final activeRecords = records.where((record) => record.number == 0);
      final placeholderRecords = records.where((record) => record.number == -1);

      expect(records.length, 91);
      expect(activeRecords.length, 91);
      expect(placeholderRecords, isEmpty);
      expect(records.first.date, '2026-04-12');
      expect(records.last.date, '2026-01-24');
    });

    test('uses placeholders only after today within current week', () {
      final records = ContributionCalculator.buildContributionRecords(
        today: DateTime(2026, 4, 15),
      );

      final placeholderRecords = records.where((record) => record.number == -1);

      expect(records.length, 98);
      expect(placeholderRecords.length, 3);
      expect(records[0].date, '2026-04-12');
      expect(records[3].date, '2026-04-15');
      expect(records[4].date, '');
      expect(records[5].date, '');
      expect(records[6].date, '');
      expect(records.last.date, '2026-01-17');
    });

    test('maps dates across years without relying on dayOfYear math', () {
      final records = ContributionCalculator.buildContributionRecords(
        today: DateTime(2026, 1, 3),
      );
      final dateIndexMap = ContributionCalculator.buildDateIndexMap(records);

      expect(dateIndexMap.containsKey('2026-01-03'), isTrue);
      expect(dateIndexMap.containsKey('2025-12-31'), isTrue);
      expect(dateIndexMap.containsKey('2025-10-06'), isTrue);
      expect(dateIndexMap.containsKey('2025-10-05'), isTrue);
      expect(dateIndexMap.containsKey('2025-10-04'), isFalse);
    });

    test(
      'counts push commits from payload size before fragile author names',
      () {
        final payload = Payload(
          size: 3,
          commits: [
            Commit(author: Author(name: 'someone-else'), distinct: true),
            Commit(author: Author(name: 'another-user'), distinct: true),
          ],
        );

        expect(ContributionCalculator.countContributionCommits(payload), 3);
      },
    );

    test('counts pull requests, issues and reviews as contributions', () {
      final openedPullRequest = EventTimeline(
        type: 'PullRequestEvent',
        payload: Payload(action: 'opened'),
      );
      final openedIssue = EventTimeline(
        type: 'IssuesEvent',
        payload: Payload(action: 'opened'),
      );
      final review = EventTimeline(type: 'PullRequestReviewEvent');
      final repoCreate = EventTimeline(
        type: 'CreateEvent',
        payload: Payload(refType: 'repository'),
      );

      expect(
        ContributionCalculator.countContributionForEvent(openedPullRequest),
        1,
      );
      expect(ContributionCalculator.countContributionForEvent(openedIssue), 1);
      expect(ContributionCalculator.countContributionForEvent(review), 1);
      expect(ContributionCalculator.countContributionForEvent(repoCreate), 1);
    });

    test('ignores non-contribution or non-open follow-up events', () {
      final closedPullRequest = EventTimeline(
        type: 'PullRequestEvent',
        payload: Payload(action: 'closed'),
      );
      final branchCreate = EventTimeline(
        type: 'CreateEvent',
        payload: Payload(refType: 'branch'),
      );
      final watch = EventTimeline(type: 'WatchEvent');

      expect(
        ContributionCalculator.countContributionForEvent(closedPullRequest),
        0,
      );
      expect(ContributionCalculator.countContributionForEvent(branchCreate), 0);
      expect(ContributionCalculator.countContributionForEvent(watch), 0);
    });
  });
}
