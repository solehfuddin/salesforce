class Trainer {
  String? id, nip, name, username, isTrainer, isOnlne, offlineUntil, offlineReason, imgprofile;

  Trainer.fromJson(Map json) : 
    id = json['id'] ?? '',
    nip = json['nip'] ?? '',
    name = json['name'] ?? '',
    username = json['username'] ?? '',
    isTrainer = json['is_trainer'] ?? '',
    isOnlne = json['is_online'] ?? '',
    offlineUntil = json['offline_until'] ?? '',
    offlineReason = json['offline_reason'] ?? '',
    imgprofile = json['imgprofile'] ?? '';

  
  Map toJson() {
    return {
      'id' : id,
      'nip' : nip,
      'name' : name,
      'username' : username,
      'is_trainer' : isTrainer,
      'is_online' : isOnlne,
      'offline_until' : offlineUntil,
      'offline_reason' : offlineReason,
      'imgprofile' : imgprofile,
    };
  }
}