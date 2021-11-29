class User {
  int? id;
  String? name;
  String? displayName;
  String? avatar;

  User.emptyUser();

  User({this.id, this.name, this.displayName, this.avatar});

  User.fromJson(dynamic json) {
    id = json["id"];
    name = json["name"];
    displayName = json["displayName"];
    avatar = json["avatar"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    map["displayName"] = displayName;
    map["avatar"] = avatar;
    return map;
  }
}
