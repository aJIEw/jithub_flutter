class UserFeeds {
  String? currentUserPublicUrl;
  String? securityAdvisoriesUrl;
  String? timelineUrl;
  String? userUrl;

  UserFeeds({
    this.currentUserPublicUrl,
    this.securityAdvisoriesUrl,
    this.timelineUrl,
    this.userUrl,
  });

  UserFeeds.fromJson(dynamic json) {
    currentUserPublicUrl = json['current_user_public_url'];
    securityAdvisoriesUrl = json['security_advisories_url'];
    timelineUrl = json['timeline_url'];
    userUrl = json['user_url'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current_user_public_url'] = currentUserPublicUrl;
    map['security_advisories_url'] = securityAdvisoriesUrl;
    map['timeline_url'] = timelineUrl;
    map['user_url'] = userUrl;
    return map;
  }

  UserFeeds copyWith({
    String? currentUserPublicUrl,
    String? securityAdvisoriesUrl,
    String? timelineUrl,
    String? userUrl,
  }) =>
      UserFeeds(
        currentUserPublicUrl: currentUserPublicUrl ?? this.currentUserPublicUrl,
        securityAdvisoriesUrl:
            securityAdvisoriesUrl ?? this.securityAdvisoriesUrl,
        timelineUrl: timelineUrl ?? this.timelineUrl,
        userUrl: userUrl ?? this.userUrl,
      );
}
