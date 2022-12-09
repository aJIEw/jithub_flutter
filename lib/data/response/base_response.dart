class BaseResponse<T> {
  int? code;
  String? message;
  T? data;

  BaseResponse({
    this.code,
    this.message,
    this.data,
  });

  BaseResponse.fromJson(dynamic json, ResultBuilder<T> create) {
    code = json['code'];
    message = json['message'];
    data = create(json['data']);
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['code'] = code;
    map['message'] = message;
    map['data'] = data;
    return map;
  }
}

class BaseListResponse<T> {
  List<T>? results;
  int? totalElements;
  int? totalPages;
  int? currentPage;

  BaseListResponse(
      {this.results, this.totalElements, this.totalPages, this.currentPage});

  BaseListResponse.fromJson(dynamic json, ResultBuilder<T> create) {
    if (json["results"] != null) {
      results = [];
      json["results"].forEach((v) {
        results!.add(create(v));
      });
    }
    totalElements = json["totalElements"];
    totalPages = json["totalPages"];
    currentPage = json["currentPage"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["results"] = results;
    map["totalElements"] = totalElements;
    map["totalPages"] = totalPages;
    map["currentPage"] = currentPage;
    return map;
  }
}

class BaseErrorResponse<T> {
  T? result;
  int? code;
  String? message;

  BaseErrorResponse({this.result, this.code, this.message});

  BaseErrorResponse.fromJson(dynamic json, ResultBuilder<T> create) {
    result = create(json["result"]);
    code = json["code"];
    message = json["message"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["result"] = result;
    map["code"] = code;
    map["message"] = message;
    return map;
  }
}

typedef ResultBuilder<T> = T Function(dynamic result);
