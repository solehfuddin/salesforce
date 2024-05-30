import 'package:sample/src/domain/entities/cashback_header.dart';

class CashbackResHeader {
  dynamic status;
  String? message;
  int? count, total;

  List<CashbackHeader> cashback = List.empty(growable: true);

  CashbackResHeader({this.status, this.message, this.count, this.total, required this.cashback});

  CashbackResHeader.fromJson(Map<String, dynamic> json)
  {
    status = json['status'] ?? false;
    message = json['message'] ?? '';
    count = json['count'] ?? 0;
    total = json['total'] ?? 0;

    if (json['data'] != null)
    {
      json['data'].forEach((v) {
        cashback.add(CashbackHeader.fromJson(v));
      });
    }
  }

  Map toJson() {
    final Map<String, dynamic> map = new Map();

    map['status'] = status;
    map['message'] = message;
    map['count'] = count;
    map['total'] = total;

    map['data'] = cashback.map((e) => e.toJson()).toList();

    return map;
  }
}