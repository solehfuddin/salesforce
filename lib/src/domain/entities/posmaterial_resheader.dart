import 'package:sample/src/domain/entities/posmaterial_header.dart';

class PosMaterialResHeader {
  bool? status;
  String? message;
  int? count, total;

  List<PosMaterialHeader> header = List.empty(growable: true);

  PosMaterialResHeader({this.status, this.message, this.count, this.total, required this.header});

  PosMaterialResHeader.fromJson(Map<String, dynamic> json) 
  {
    status = json['status'] ?? false;
    message = json['message'] ?? '';
    count = json['count'] ?? 0;
    total = json['total'] ?? 0;
    
    if (json['data'] != null)
    {
      json['data'].forEach((v) {
        header.add(PosMaterialHeader.fromJson(v));
      });
    }
  }

  Map toJson() {
    final Map<String, dynamic> map = new Map();

    map['status'] = status;
    map['message'] = message;
    map['count'] = count;
    map['total'] = total;

    map['data'] = header.map((e) => e.toJson()).toList();

    return map;
  }
}