import 'package:sample/src/domain/entities/marketingexpense_header.dart';

class MarketingExpenseResHeader {
  bool? status;
  String? message;
  int? count, total;

  List<MarketingExpenseHeader> list = List.empty(growable: true);

  MarketingExpenseResHeader({this.status, this.message, this.count, this.total, required this.list});

  MarketingExpenseResHeader.fromJson(Map json) {
    status = json['status'] ?? false;
    message = json['message'] ?? '';
    count = json['count'] ?? 0;
    total = json['total'] ?? 0;

    if (json['data'] != null) {
      json['data'].foreach((v) {
        list.add(MarketingExpenseHeader.fromJson(v));
      });
    }
  }

  Map toJson() {
    Map<String, dynamic> map = new Map();

    map['status'] = status;
    map['message'] = message;
    map['count'] = count;
    map['total'] = total;

    map['data'] = list.map((e) => e.toJson()).toList();

    return map;
  }
}