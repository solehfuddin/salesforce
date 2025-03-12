class OfflineTrainer {
  String? idOffline, idTrainer, offlineStart, offlineUntil, offlineReason;

  OfflineTrainer({
    this.idOffline,
    this.idTrainer,
    this.offlineStart,
    this.offlineUntil,
    this.offlineReason,
  });

  OfflineTrainer.fromJson(Map json)
      : idOffline = json['id_offline'],
        idTrainer = json['id_trainer'],
        offlineStart = json['date_start'],
        offlineUntil = json['date_until'],
        offlineReason = json['reason'];

  Map toJson() {
    return {
      'id_offline': idOffline,
      'id_trainer': idTrainer,
      'date_start': offlineStart,
      'date_until': offlineUntil,
      'reason': offlineReason
    };
  }
}
