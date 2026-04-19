import 'package:jithub_flutter/data/response/github_repo.dart';

class EventTimeline {
  String? id;
  String? type;
  Actor? actor;
  Repo? repo;
  Payload? payload;
  bool? public;
  String? createdAt;

  EventTimeline({
    this.id,
    this.type,
    this.actor,
    this.repo,
    this.payload,
    this.public,
    this.createdAt,
  });

  EventTimeline.fromJson(dynamic json) {
    id = json['id'];
    type = json['type'];
    actor = json['actor'] != null ? Actor.fromJson(json['actor']) : null;
    repo = json['repo'] != null ? Repo.fromJson(json['repo']) : null;
    payload = json['payload'] != null
        ? Payload.fromJson(json['payload'])
        : null;
    public = json['public'];
    createdAt = json['created_at'];
  }

  EventTimeline copyWith({
    String? id,
    String? type,
    Actor? actor,
    Repo? repo,
    Payload? payload,
    bool? public,
    String? createdAt,
  }) => EventTimeline(
    id: id ?? this.id,
    type: type ?? this.type,
    actor: actor ?? this.actor,
    repo: repo ?? this.repo,
    payload: payload ?? this.payload,
    public: public ?? this.public,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['type'] = type;
    if (actor != null) {
      map['actor'] = actor?.toJson();
    }
    if (repo != null) {
      map['repo'] = repo?.toJson();
    }
    if (payload != null) {
      map['payload'] = payload?.toJson();
    }
    map['public'] = public;
    map['created_at'] = createdAt;
    return map;
  }
}

class Actor {
  int? id;
  String? login;
  String? displayLogin;
  String? gravatarId;
  String? url;
  String? avatarUrl;

  Actor({
    this.id,
    this.login,
    this.displayLogin,
    this.gravatarId,
    this.url,
    this.avatarUrl,
  });

  Actor.fromJson(dynamic json) {
    id = json['id'];
    login = json['login'];
    displayLogin = json['display_login'];
    gravatarId = json['gravatar_id'];
    url = json['url'];
    avatarUrl = json['avatar_url'];
  }

  Actor copyWith({
    int? id,
    String? login,
    String? displayLogin,
    String? gravatarId,
    String? url,
    String? avatarUrl,
  }) => Actor(
    id: id ?? this.id,
    login: login ?? this.login,
    displayLogin: displayLogin ?? this.displayLogin,
    gravatarId: gravatarId ?? this.gravatarId,
    url: url ?? this.url,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['login'] = login;
    map['display_login'] = displayLogin;
    map['gravatar_id'] = gravatarId;
    map['url'] = url;
    map['avatar_url'] = avatarUrl;
    return map;
  }
}

class Payload {
  String? action; // watch event
  GithubUser? forkee; // fork event
  String? refType; // create event
  String? ref; // branch or tag name
  ReleaseRepo? release; // release event
  List<Commit>? commits; // push event
  int? size; // commits number
  IssuePayloadItem? issue; // issue event
  PullRequestPayloadItem? pullRequest; // pull request event
  CommentPayloadItem? comment; // comment event
  ReviewPayloadItem? review; // review event

  Payload({
    this.action,
    this.forkee,
    this.refType,
    this.ref,
    this.release,
    this.commits,
    this.size,
    this.issue,
    this.pullRequest,
    this.comment,
    this.review,
  });

  Payload.fromJson(dynamic json) {
    action = json['action'];
    forkee = json['forkee'] != null
        ? GithubUser.fromJson(json['forkee'])
        : null;
    refType = json['ref_type'];
    ref = json['ref'];
    release = json['release'] != null
        ? ReleaseRepo.fromJson(json['release'])
        : null;
    if (json['commits'] != null) {
      commits = [];
      for (final dynamic item in json['commits']) {
        commits?.add(Commit.fromJson(item));
      }
    }
    size = json['size'];
    issue = json['issue'] != null
        ? IssuePayloadItem.fromJson(json['issue'])
        : null;
    pullRequest = json['pull_request'] != null
        ? PullRequestPayloadItem.fromJson(json['pull_request'])
        : null;
    comment = json['comment'] != null
        ? CommentPayloadItem.fromJson(json['comment'])
        : null;
    review = json['review'] != null
        ? ReviewPayloadItem.fromJson(json['review'])
        : null;
  }

  Payload copyWith({
    String? action,
    GithubUser? forkee,
    String? refType,
    String? ref,
    ReleaseRepo? release,
    List<Commit>? commits,
    int? size,
    IssuePayloadItem? issue,
    PullRequestPayloadItem? pullRequest,
    CommentPayloadItem? comment,
    ReviewPayloadItem? review,
  }) => Payload(
    action: action ?? this.action,
    forkee: forkee ?? this.forkee,
    refType: refType ?? this.refType,
    ref: ref ?? this.ref,
    release: release ?? this.release,
    commits: commits ?? this.commits,
    size: size ?? this.size,
    issue: issue ?? this.issue,
    pullRequest: pullRequest ?? this.pullRequest,
    comment: comment ?? this.comment,
    review: review ?? this.review,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['action'] = action;
    map['forkee'] = forkee;
    map['ref_type'] = refType;
    map['ref'] = ref;
    map['release'] = release;
    map['commits'] = commits?.map((dynamic item) => item.toJson()).toList();
    map['size'] = size;
    map['issue'] = issue?.toJson();
    map['pull_request'] = pullRequest?.toJson();
    map['comment'] = comment?.toJson();
    map['review'] = review?.toJson();
    return map;
  }
}

class IssuePayloadItem {
  int? id;
  int? number;
  String? title;

  IssuePayloadItem({this.id, this.number, this.title});

  IssuePayloadItem.fromJson(dynamic json) {
    id = json['id'];
    number = json['number'];
    title = json['title'];
  }

  IssuePayloadItem copyWith({int? id, int? number, String? title}) =>
      IssuePayloadItem(
        id: id ?? this.id,
        number: number ?? this.number,
        title: title ?? this.title,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['number'] = number;
    map['title'] = title;
    return map;
  }
}

class PullRequestPayloadItem {
  int? id;
  int? number;
  String? title;

  PullRequestPayloadItem({this.id, this.number, this.title});

  PullRequestPayloadItem.fromJson(dynamic json) {
    id = json['id'];
    number = json['number'];
    title = json['title'];
  }

  PullRequestPayloadItem copyWith({int? id, int? number, String? title}) =>
      PullRequestPayloadItem(
        id: id ?? this.id,
        number: number ?? this.number,
        title: title ?? this.title,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['number'] = number;
    map['title'] = title;
    return map;
  }
}

class CommentPayloadItem {
  int? id;
  String? body;
  String? commitId;
  String? path;

  CommentPayloadItem({this.id, this.body, this.commitId, this.path});

  CommentPayloadItem.fromJson(dynamic json) {
    id = json['id'];
    body = json['body'];
    commitId = json['commit_id'];
    path = json['path'];
  }

  CommentPayloadItem copyWith({
    int? id,
    String? body,
    String? commitId,
    String? path,
  }) => CommentPayloadItem(
    id: id ?? this.id,
    body: body ?? this.body,
    commitId: commitId ?? this.commitId,
    path: path ?? this.path,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['body'] = body;
    map['commit_id'] = commitId;
    map['path'] = path;
    return map;
  }
}

class ReviewPayloadItem {
  int? id;
  String? state;

  ReviewPayloadItem({this.id, this.state});

  ReviewPayloadItem.fromJson(dynamic json) {
    id = json['id'];
    state = json['state'];
  }

  ReviewPayloadItem copyWith({int? id, String? state}) =>
      ReviewPayloadItem(id: id ?? this.id, state: state ?? this.state);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['state'] = state;
    return map;
  }
}

class Commit {
  Author? author;
  bool? distinct;
  String? message;
  String? sha;
  String? url;

  Commit({this.author, this.distinct, this.message, this.sha, this.url});

  Commit.fromJson(dynamic json) {
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
    distinct = json['distinct'];
    message = json['message'];
    sha = json['sha'];
    url = json['url'];
  }

  Commit copyWith({
    Author? author,
    bool? distinct,
    String? message,
    String? sha,
    String? url,
  }) => Commit(
    author: author ?? this.author,
    distinct: distinct ?? this.distinct,
    message: message ?? this.message,
    sha: sha ?? this.sha,
    url: url ?? this.url,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['author'] = author;
    map['distinct'] = distinct;
    map['message'] = message;
    map['sha'] = sha;
    map['url'] = url;
    return map;
  }
}

class Author {
  Author({this.email, this.name});

  Author.fromJson(dynamic json) {
    email = json['email'];
    name = json['name'];
  }
  String? email;
  String? name;
  Author copyWith({String? email, String? name}) =>
      Author(email: email ?? this.email, name: name ?? this.name);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['email'] = email;
    map['name'] = name;
    return map;
  }
}

class Repo {
  int? id;
  String? name;
  String? url;

  Repo({this.id, this.name, this.url});

  Repo.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    url = json['url'];
  }

  Repo copyWith({int? id, String? name, String? url}) =>
      Repo(id: id ?? this.id, name: name ?? this.name, url: url ?? this.url);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['url'] = url;
    return map;
  }
}

class ReleaseRepo {
  String? body;
  int? id;
  String? name;
  String? tagName;
  String? url;

  ReleaseRepo({this.body, this.id, this.name, this.tagName, this.url});

  ReleaseRepo.fromJson(dynamic json) {
    body = json['body'];
    id = json['id'];
    name = json['name'];
    tagName = json['tag_name'];
    url = json['url'];
  }

  ReleaseRepo copyWith({
    String? body,
    int? id,
    String? name,
    String? tagName,
    String? url,
  }) => ReleaseRepo(
    body: body ?? this.body,
    id: id ?? this.id,
    name: name ?? this.name,
    tagName: tagName ?? this.tagName,
    url: url ?? this.url,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['body'] = body;
    map['id'] = id;
    map['name'] = name;
    map['tag_name'] = tagName;
    map['url'] = url;
    return map;
  }
}
