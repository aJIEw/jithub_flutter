import 'package:jithub_flutter/data/model/github_event.dart';
import 'package:jithub_flutter/data/response/event_timeline.dart';

class HomeEventGrouping {
  const HomeEventGrouping._();

  static List<EventTimeline> mergeConsecutivePushEvents(
    List<EventTimeline> events,
  ) {
    final merged = <EventTimeline>[];

    for (final event in events) {
      final last = merged.isNotEmpty ? merged.last : null;
      if (_canMergePushEvents(last, event)) {
        merged[merged.length - 1] = _mergePushEvents(last!, event);
      } else {
        merged.add(event);
      }
    }

    return merged;
  }

  static EventTimeline mergePushEventsForBoundary(
    EventTimeline previousEvent,
    EventTimeline nextEvent,
  ) => _mergePushEvents(previousEvent, nextEvent);

  static bool canMergePushEvents(
    EventTimeline? previousEvent,
    EventTimeline nextEvent,
  ) => _canMergePushEvents(previousEvent, nextEvent);

  static int pushCommitCount(EventTimeline event) {
    final size = event.payload?.size;
    if (size != null && size > 0) {
      return size;
    }

    return event.payload?.commits?.length ?? 0;
  }

  static bool _canMergePushEvents(
    EventTimeline? previousEvent,
    EventTimeline nextEvent,
  ) {
    if (previousEvent?.type != GithubEvent.pushEvent.name ||
        nextEvent.type != GithubEvent.pushEvent.name) {
      return false;
    }

    final previousActor = previousEvent?.actor?.login;
    final nextActor = nextEvent.actor?.login;
    if ((previousActor ?? '').trim().isEmpty ||
        (nextActor ?? '').trim().isEmpty) {
      return false;
    }

    final previousRef = previousEvent?.payload?.ref;
    final nextRef = nextEvent.payload?.ref;
    if ((previousRef ?? '').trim().isEmpty || (nextRef ?? '').trim().isEmpty) {
      return false;
    }

    return _sameText(previousActor, nextActor) &&
        _sameRepo(previousEvent?.repo, nextEvent.repo) &&
        _sameText(previousRef, nextRef);
  }

  static EventTimeline _mergePushEvents(
    EventTimeline previousEvent,
    EventTimeline nextEvent,
  ) {
    final previousPayload = previousEvent.payload;
    final nextPayload = nextEvent.payload;
    final commits = <Commit>[
      ...?previousPayload?.commits,
      ...?nextPayload?.commits,
    ];

    final mergedPayload = (previousPayload ?? Payload()).copyWith(
      commits: commits.isEmpty ? previousPayload?.commits : commits,
      size: pushCommitCount(previousEvent) + pushCommitCount(nextEvent),
    );

    return previousEvent.copyWith(payload: mergedPayload);
  }

  static bool _sameRepo(Repo? previousRepo, Repo? nextRepo) {
    if (previousRepo?.id != null || nextRepo?.id != null) {
      return previousRepo?.id == nextRepo?.id;
    }

    if ((previousRepo?.name ?? '').trim().isEmpty ||
        (nextRepo?.name ?? '').trim().isEmpty) {
      return false;
    }

    return _sameText(previousRepo?.name, nextRepo?.name) &&
        _sameText(previousRepo?.url, nextRepo?.url);
  }

  static bool _sameText(String? left, String? right) =>
      (left ?? '').trim().toLowerCase() == (right ?? '').trim().toLowerCase();
}
