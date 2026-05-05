import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/data/response/contribution_calendar.dart';

void main() {
  group('GithubContributionCalendar', () {
    test('parses contribution days across multiple weeks', () {
      final calendar = GithubContributionCalendar.fromGraphqlData(
        <String, dynamic>{
          'user': <String, dynamic>{
            'contributionsCollection': <String, dynamic>{
              'contributionCalendar': <String, dynamic>{
                'weeks': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'contributionDays': <Map<String, dynamic>>[
                      <String, dynamic>{
                        'date': '2026-04-12',
                        'contributionCount': 2,
                      },
                    ],
                  },
                  <String, dynamic>{
                    'contributionDays': <Map<String, dynamic>>[
                      <String, dynamic>{
                        'date': '2026-04-19',
                        'contributionCount': 0,
                      },
                    ],
                  },
                ],
              },
            },
          },
        },
      );

      expect(calendar.days.length, 2);
      expect(calendar.days.first.date, '2026-04-12');
      expect(calendar.days.first.contributionCount, 2);
      expect(calendar.days.last.date, '2026-04-19');
      expect(calendar.days.last.contributionCount, 0);
    });

    test('fails when user is missing', () {
      expect(
        () => GithubContributionCalendar.fromGraphqlData(<String, dynamic>{}),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'GraphQL response missing user',
          ),
        ),
      );
    });

    test('fails when contributionsCollection is missing', () {
      expect(
        () => GithubContributionCalendar.fromGraphqlData(<String, dynamic>{
          'user': <String, dynamic>{},
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'GraphQL response missing contributionsCollection',
          ),
        ),
      );
    });

    test('fails when contributionCalendar is missing', () {
      expect(
        () => GithubContributionCalendar.fromGraphqlData(<String, dynamic>{
          'user': <String, dynamic>{
            'contributionsCollection': <String, dynamic>{},
          },
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'GraphQL response missing contributionCalendar',
          ),
        ),
      );
    });
  });
}
