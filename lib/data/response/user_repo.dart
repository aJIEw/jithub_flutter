class UserRepo {
  int? id;
  String? name;
  String? fullName;
  bool? private;
  String? htmlUrl;
  String? description;
  bool? fork;
  String? url;
  int? size;
  int? stargazersCount;
  int? watchersCount;
  String? language;
  int? forksCount;
  int? openIssuesCount;
  String? visibility;
  int? forks;
  int? openIssues;
  int? watchers;

  UserRepo({
    this.id,
    this.name,
    this.fullName,
    this.private,
    this.htmlUrl,
    this.description,
    this.fork,
    this.url,
    this.size,
    this.stargazersCount,
    this.watchersCount,
    this.language,
    this.forksCount,
    this.openIssuesCount,
    this.visibility,
    this.forks,
    this.openIssues,
    this.watchers,
  });

  UserRepo.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    fullName = json['full_name'];
    private = json['private'];
    htmlUrl = json['html_url'];
    description = json['description'];
    fork = json['fork'];
    url = json['url'];
    size = json['size'];
    stargazersCount = json['stargazers_count'];
    watchersCount = json['watchers_count'];
    language = json['language'];
    forksCount = json['forks_count'];
    openIssuesCount = json['open_issues_count'];
    visibility = json['visibility'];
    forks = json['forks'];
    openIssues = json['open_issues'];
    watchers = json['watchers'];
  }

  UserRepo copyWith({
    int? id,
    String? name,
    String? fullName,
    bool? private,
    String? htmlUrl,
    String? description,
    bool? fork,
    String? url,
    int? size,
    int? stargazersCount,
    int? watchersCount,
    String? language,
    int? forksCount,
    int? openIssuesCount,
    String? license,
    String? visibility,
    int? forks,
    int? openIssues,
    int? watchers,
  }) =>
      UserRepo(
        id: id ?? this.id,
        name: name ?? this.name,
        fullName: fullName ?? this.fullName,
        private: private ?? this.private,
        htmlUrl: htmlUrl ?? this.htmlUrl,
        description: description ?? this.description,
        fork: fork ?? this.fork,
        url: url ?? this.url,
        size: size ?? this.size,
        stargazersCount: stargazersCount ?? this.stargazersCount,
        watchersCount: watchersCount ?? this.watchersCount,
        language: language ?? this.language,
        forksCount: forksCount ?? this.forksCount,
        openIssuesCount: openIssuesCount ?? this.openIssuesCount,
        visibility: visibility ?? this.visibility,
        forks: forks ?? this.forks,
        openIssues: openIssues ?? this.openIssues,
        watchers: watchers ?? this.watchers,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['full_name'] = fullName;
    map['private'] = private;
    map['html_url'] = htmlUrl;
    map['description'] = description;
    map['fork'] = fork;
    map['url'] = url;
    map['size'] = size;
    map['stargazers_count'] = stargazersCount;
    map['watchers_count'] = watchersCount;
    map['language'] = language;
    map['forks_count'] = forksCount;
    map['open_issues_count'] = openIssuesCount;
    map['visibility'] = visibility;
    map['forks'] = forks;
    map['open_issues'] = openIssues;
    map['watchers'] = watchers;
    return map;
  }
}
