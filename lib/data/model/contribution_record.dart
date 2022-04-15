class ContributionRecord {
  var index;
  var date;
  var number;

  ContributionRecord({this.index, this.date, this.number});

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
