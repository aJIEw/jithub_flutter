class UserRepo {
  String? login;
  int? id;
  String? avatarUrl;
  String? gravatarId;
  String? type;
  String? company;
  String? blog;
  String? location;
  String? email;
  String? bio;
  String? twitterUsername;
  int? publicRepos;
  int? publicGists;
  int? followers;
  int? following;
  String? createdAt;
  String? updatedAt;
  int? privateGists;
  int? totalPrivateRepos;
  int? ownedPrivateRepos;
  int? collaborators;

  UserRepo({
    this.login,
    this.id,
    this.avatarUrl,
    this.gravatarId,
    this.type,
    this.company,
    this.blog,
    this.location,
    this.email,
    this.bio,
    this.twitterUsername,
    this.publicRepos,
    this.publicGists,
    this.followers,
    this.following,
    this.createdAt,
    this.updatedAt,
    this.privateGists,
    this.totalPrivateRepos,
    this.ownedPrivateRepos,
    this.collaborators,
  });

  UserRepo.fromJson(dynamic json) {
    login = json['login'];
    id = json['id'];
    avatarUrl = json['avatar_url'];
    gravatarId = json['gravatar_id'];
    type = json['type'];
    company = json['company'];
    blog = json['blog'];
    location = json['location'];
    email = json['email'];
    bio = json['bio'];
    twitterUsername = json['twitter_username'];
    publicRepos = json['public_repos'];
    publicGists = json['public_gists'];
    followers = json['followers'];
    following = json['following'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    privateGists = json['private_gists'];
    totalPrivateRepos = json['total_private_repos'];
    ownedPrivateRepos = json['owned_private_repos'];
    collaborators = json['collaborators'];
  }

  UserRepo copyWith({
    String? login,
    int? id,
    String? avatarUrl,
    String? gravatarId,
    String? type,
    String? company,
    String? blog,
    String? location,
    String? email,
    String? bio,
    String? twitterUsername,
    int? publicRepos,
    int? publicGists,
    int? followers,
    int? following,
    String? createdAt,
    String? updatedAt,
    int? privateGists,
    int? totalPrivateRepos,
    int? ownedPrivateRepos,
    int? collaborators,
  }) =>
      UserRepo(
        login: login ?? this.login,
        id: id ?? this.id,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        gravatarId: gravatarId ?? this.gravatarId,
        type: type ?? this.type,
        company: company ?? this.company,
        blog: blog ?? this.blog,
        location: location ?? this.location,
        email: email ?? this.email,
        bio: bio ?? this.bio,
        twitterUsername: twitterUsername ?? this.twitterUsername,
        publicRepos: publicRepos ?? this.publicRepos,
        publicGists: publicGists ?? this.publicGists,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        privateGists: privateGists ?? this.privateGists,
        totalPrivateRepos: totalPrivateRepos ?? this.totalPrivateRepos,
        ownedPrivateRepos: ownedPrivateRepos ?? this.ownedPrivateRepos,
        collaborators: collaborators ?? this.collaborators,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['login'] = login;
    map['id'] = id;
    map['avatar_url'] = avatarUrl;
    map['gravatar_id'] = gravatarId;
    map['type'] = type;
    map['company'] = company;
    map['blog'] = blog;
    map['location'] = location;
    map['email'] = email;
    map['bio'] = bio;
    map['twitter_username'] = twitterUsername;
    map['public_repos'] = publicRepos;
    map['public_gists'] = publicGists;
    map['followers'] = followers;
    map['following'] = following;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['private_gists'] = privateGists;
    map['total_private_repos'] = totalPrivateRepos;
    map['owned_private_repos'] = ownedPrivateRepos;
    map['collaborators'] = collaborators;
    return map;
  }
}
