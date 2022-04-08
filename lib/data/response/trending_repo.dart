class TrendingRepo {
  String? author;
  String? name;
  String? avatar;
  String? description;
  String? url;
  String? language;
  String? languageColor;
  int? stars;
  int? forks;
  int? currentPeriodStars;
  List<BuiltBy>? builtBy;

  TrendingRepo({
    this.author,
    this.name,
    this.avatar,
    this.description,
    this.url,
    this.language,
    this.languageColor,
    this.stars,
    this.forks,
    this.currentPeriodStars,
    this.builtBy,
  });

  TrendingRepo.fromJson(dynamic json) {
    author = json['author'];
    name = json['name'];
    avatar = json['avatar'];
    description = json['description'];
    url = json['url'];
    language = json['language'];
    languageColor = json['languageColor'];
    stars = json['stars'];
    forks = json['forks'];
    currentPeriodStars = json['currentPeriodStars'];
    if (json['builtBy'] != null) {
      builtBy = [];
      json['builtBy'].forEach((v) {
        builtBy?.add(BuiltBy.fromJson(v));
      });
    }
  }

  TrendingRepo copyWith({
    String? author,
    String? name,
    String? avatar,
    String? description,
    String? url,
    String? language,
    String? languageColor,
    int? stars,
    int? forks,
    int? currentPeriodStars,
    List<BuiltBy>? builtBy,
  }) =>
      TrendingRepo(
        author: author ?? this.author,
        name: name ?? this.name,
        avatar: avatar ?? this.avatar,
        description: description ?? this.description,
        url: url ?? this.url,
        language: language ?? this.language,
        languageColor: languageColor ?? this.languageColor,
        stars: stars ?? this.stars,
        forks: forks ?? this.forks,
        currentPeriodStars: currentPeriodStars ?? this.currentPeriodStars,
        builtBy: builtBy ?? this.builtBy,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['author'] = author;
    map['name'] = name;
    map['avatar'] = avatar;
    map['description'] = description;
    map['url'] = url;
    map['language'] = language;
    map['languageColor'] = languageColor;
    map['stars'] = stars;
    map['forks'] = forks;
    map['currentPeriodStars'] = currentPeriodStars;
    if (builtBy != null) {
      map['builtBy'] = builtBy?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class BuiltBy {
  BuiltBy({
    this.username,
    this.href,
    this.avatar,
  });

  BuiltBy.fromJson(dynamic json) {
    username = json['username'];
    href = json['href'];
    avatar = json['avatar'];
  }

  String? username;
  String? href;
  String? avatar;

  BuiltBy copyWith({
    String? username,
    String? href,
    String? avatar,
  }) =>
      BuiltBy(
        username: username ?? this.username,
        href: href ?? this.href,
        avatar: avatar ?? this.avatar,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = username;
    map['href'] = href;
    map['avatar'] = avatar;
    return map;
  }
}
