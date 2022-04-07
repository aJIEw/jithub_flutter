class AuthToken {
  String? accessToken;
  String? scope;
  String? tokenType;

  AuthToken({
    this.accessToken,
    this.scope,
    this.tokenType,
  });

  AuthToken.fromJson(dynamic json) {
    accessToken = json['access_token'];
    scope = json['scope'];
    tokenType = json['token_type'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['access_token'] = accessToken;
    map['scope'] = scope;
    map['token_type'] = tokenType;
    return map;
  }

  AuthToken copyWith({
    String? accessToken,
    String? scope,
    String? tokenType,
  }) =>
      AuthToken(
        accessToken: accessToken ?? this.accessToken,
        scope: scope ?? this.scope,
        tokenType: tokenType ?? this.tokenType,
      );
}
