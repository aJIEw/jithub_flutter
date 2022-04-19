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
    payload =
        json['payload'] != null ? Payload.fromJson(json['payload']) : null;
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
  }) =>
      EventTimeline(
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
  }) =>
      Actor(
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
  String? ref_type; // create event
  ReleaseRepo? release; // release event
  List<Commit>? commits; // push event
  int? size; // commits number

  Payload({
    this.action,
    this.forkee,
    this.ref_type,
    this.release,
    this.commits,
    this.size,
  });

  Payload.fromJson(dynamic json) {
    action = json['action'];
    forkee = json['forkee'] != null ? GithubUser.fromJson(json['forkee']) : null;
    ref_type = json['ref_type'];
    release = json['release'] != null ? ReleaseRepo.fromJson(json['release']) : null;
    if (json['commits'] != null) {
      commits = [];
      for (dynamic item in json['commits']) {
        commits?.add(Commit.fromJson(item));
      }
    }
    size = json['size'];
  }

  Payload copyWith({
    String? action,
    GithubUser? forkee,
    String? ref_type,
    ReleaseRepo? release,
    List<Commit>? commits,
    int? size,
  }) =>
      Payload(
        action: action ?? this.action,
        forkee: forkee ?? this.forkee,
        ref_type: ref_type ?? this.ref_type,
        release: release ?? this.release,
        commits: commits ?? this.commits,
        size: size ?? this.size,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['action'] = action;
    map['forkee'] = forkee;
    map['ref_type'] = ref_type;
    map['release'] = release;
    map['commits'] = commits?.map((dynamic item) => item?.toJson())?.toList();
    map['size'] = size;
    return map;
  }
}

class Commit {
  Author? author;
  bool? distinct;
  String? message;
  String? sha;
  String? url;

  Commit({
    this.author,
    this.distinct,
    this.message,
    this.sha,
    this.url,
  });

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
  }) =>
      Commit(
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
  Author({
    this.email,
    this.name,});

  Author.fromJson(dynamic json) {
    email = json['email'];
    name = json['name'];
  }
  String? email;
  String? name;
  Author copyWith({  String? email,
    String? name,
  }) => Author(  email: email ?? this.email,
    name: name ?? this.name,
  );
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

  Repo({
    this.id,
    this.name,
    this.url,
  });

  Repo.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    url = json['url'];
  }

  Repo copyWith({
    int? id,
    String? name,
    String? url,
  }) =>
      Repo(
        id: id ?? this.id,
        name: name ?? this.name,
        url: url ?? this.url,
      );

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

  ReleaseRepo({
    this.body,
    this.id,
    this.name,
    this.tagName,
    this.url,
  });

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
  }) =>
      ReleaseRepo(
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

