import 'package:flutter_test/flutter_test.dart';
import 'package:jithub_flutter/data/model/github_event.dart';
import 'package:jithub_flutter/data/response/event_timeline.dart';
import 'package:jithub_flutter/page/home/home_event_grouping.dart';

void main() {
  test('merges consecutive push events for same actor repo and ref', () {
    final events = [
      _push(id: '1', size: 1),
      _push(id: '2', size: 2),
      _push(id: '3', size: 3),
    ];

    final grouped = HomeEventGrouping.mergeConsecutivePushEvents(events);

    expect(grouped, hasLength(1));
    expect(grouped.single.id, '1');
    expect(grouped.single.payload?.size, 6);
  });

  test('keeps non-consecutive and different push events separate', () {
    final events = [
      _push(id: '1', size: 1),
      EventTimeline(type: GithubEvent.watchEvent.name),
      _push(id: '2', size: 2),
      _push(id: '3', repoName: 'UserA/RepoC', size: 3),
    ];

    final grouped = HomeEventGrouping.mergeConsecutivePushEvents(events);

    expect(grouped, hasLength(4));
    expect(grouped[0].payload?.size, 1);
    expect(grouped[2].payload?.size, 2);
    expect(grouped[3].payload?.size, 3);
  });

  test('uses commit list length when payload size is missing', () {
    final event = _push(size: null, commits: 3);

    expect(HomeEventGrouping.pushCommitCount(event), 3);
  });
}

EventTimeline _push({
  String id = '1',
  String actorLogin = 'UserA',
  String repoName = 'UserA/RepoB',
  String ref = 'refs/heads/main',
  int? size = 1,
  int commits = 0,
}) => EventTimeline(
  id: id,
  type: GithubEvent.pushEvent.name,
  actor: Actor(login: actorLogin),
  repo: Repo(id: repoName.hashCode, name: repoName, url: repoName),
  payload: Payload(
    ref: ref,
    size: size,
    commits: List.generate(commits, (_) => Commit()),
  ),
);
