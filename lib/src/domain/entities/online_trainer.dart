class OnlineTrainer {
  String? idOnline, idTrainer,onlineStart, onlineUntil;

  OnlineTrainer({this.idOnline, this.idTrainer, this.onlineStart, this.onlineUntil});

  OnlineTrainer.fromJson(Map json)
      : idOnline = json['id_online'],
        idTrainer = json['id_trainer'],
        onlineStart = json['date_start'],
        onlineUntil = json['date_until'];

  Map toJson() {
    return {
      'id_online': idOnline,
      'id_trainer': idTrainer,
      'date_start': onlineStart,
      'date_until': onlineUntil,
    };
  }
}