
import 'change_customer.dart';

class ChangeResCustomer {
  dynamic status;
  String? message;
  int? count, total;

  List<ChangeCustomer> customer = List.empty(growable: true);

  ChangeResCustomer({this.status, this.message, this.count, this.total, required this.customer});

  ChangeResCustomer.fromJson(Map<String, dynamic> json)
  {
    status = json['status'] ?? false;
    message = json['message'] ?? '';
    count = json['count'] ?? 0;
    total = json['total'] ?? 0;

    if (json['data'] != null)
    {
      json['data'].forEach((v) {
        customer.add(ChangeCustomer.fromJson(v));
      });
    }
  }

  Map toJson() {
    final Map<String, dynamic> map = new Map();

    map['status'] = status;
    map['message'] = message;
    map['count'] = count;
    map['total'] = total;

    map['data'] = customer.map((e) => e.toJson()).toList();

    return map;
  }
}