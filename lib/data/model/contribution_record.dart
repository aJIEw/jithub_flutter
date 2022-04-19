class ContributionRecord {
  int index = 0;
  String date = '';
  int number = -1;

  ContributionRecord({this.index = 0, this.date = '', this.number = -1});

  ContributionRecord.fromJson(dynamic json) {
    index = json["index"];
    date = json["date"];
    number = json["number"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["index"] = index;
    map["date"] = date;
    map["number"] = number;
    return map;
  }
}
