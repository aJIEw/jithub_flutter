import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/data/model/github_event.dart';

void main() {
  test('Test Object', () {});

  test('GithubEvent keeps api event names stable', () {
    expect(GithubEvent.watchEvent.name, 'WatchEvent');
    expect(GithubEvent.pushEvent.name, 'PushEvent');
    expect(GithubEvent.issueCommentEvent.name, 'IssueCommentEvent');
  });
}
