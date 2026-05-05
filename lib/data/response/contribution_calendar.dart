class GithubContributionCalendar {
  GithubContributionCalendar({required this.days});

  final List<GithubContributionDay> days;

  factory GithubContributionCalendar.fromGraphqlData(
    Map<String, dynamic> json,
  ) {
    final user = json['user'];
    if (user is! Map<String, dynamic>) {
      throw const FormatException('GraphQL response missing user');
    }

    final contributionsCollection = user['contributionsCollection'];
    if (contributionsCollection is! Map<String, dynamic>) {
      throw const FormatException(
        'GraphQL response missing contributionsCollection',
      );
    }

    final contributionCalendar =
        contributionsCollection['contributionCalendar'];
    if (contributionCalendar is! Map<String, dynamic>) {
      throw const FormatException(
        'GraphQL response missing contributionCalendar',
      );
    }

    final weeks = contributionCalendar['weeks'];
    if (weeks is! List) {
      throw const FormatException('GraphQL response missing weeks');
    }

    final days = <GithubContributionDay>[];
    for (final week in weeks) {
      if (week is! Map<String, dynamic>) {
        continue;
      }

      final contributionDays = week['contributionDays'];
      if (contributionDays is! List) {
        continue;
      }

      for (final contributionDay in contributionDays) {
        if (contributionDay is Map<String, dynamic>) {
          days.add(GithubContributionDay.fromJson(contributionDay));
        }
      }
    }

    return GithubContributionCalendar(days: days);
  }
}

class GithubContributionDay {
  GithubContributionDay({required this.date, required this.contributionCount});

  final String date;
  final int contributionCount;

  factory GithubContributionDay.fromJson(Map<String, dynamic> json) {
    final date = json['date'];
    if (date is! String || date.isEmpty) {
      throw const FormatException('GraphQL contribution day missing date');
    }

    final contributionCount = json['contributionCount'];
    if (contributionCount is! int) {
      throw const FormatException(
        'GraphQL contribution day missing contributionCount',
      );
    }

    return GithubContributionDay(
      date: date,
      contributionCount: contributionCount,
    );
  }
}

class GithubContributionQueries {
  static const String userContributions = '''
query UserContributions(\$login: String!, \$from: DateTime!, \$to: DateTime!) {
  user(login: \$login) {
    contributionsCollection(from: \$from, to: \$to) {
      contributionCalendar {
        weeks {
          contributionDays {
            date
            contributionCount
          }
        }
      }
    }
  }
}
''';
}
