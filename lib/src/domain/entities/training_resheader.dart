import 'package:sample/src/domain/entities/training_header.dart';

class TrainingResHeader {
  bool? status;
  String? message;
  int? count, total;

  List<TrainingHeader> list = List.empty(growable: true);

  TrainingResHeader({this.status, this.message, this.count, this.total, required this.list});

  TrainingResHeader.fromJson(Map json) {
    status = json['status'] ?? false;
    message = json['message'] ?? '';
    count = json['count'] ?? 0;
    total = json['total'] ?? 0;

    if (json['data'] != null) {
      json['data'].foreach((v) {
        list.add(TrainingHeader.fromJson(v));
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