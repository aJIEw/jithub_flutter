class GithubEvent {
  final String name;

  const GithubEvent._(this.name);

  static const watchEvent = GithubEvent._('WatchEvent');
  static const forkEvent = GithubEvent._('ForkEvent');
  static const releaseEvent = GithubEvent._('ReleaseEvent');
  static const createEvent = GithubEvent._('CreateEvent');
  static const pushEvent = GithubEvent._('PushEvent');
  static const publicEvent = GithubEvent._('PublicEvent');
  static const issuesEvent = GithubEvent._('IssuesEvent');
  static const issueCommentEvent = GithubEvent._('IssueCommentEvent');

  static const values = [
    watchEvent,
    forkEvent,
    releaseEvent,
    createEvent,
    pushEvent,
    publicEvent,
    issuesEvent,
    issueCommentEvent,
  ];
}
