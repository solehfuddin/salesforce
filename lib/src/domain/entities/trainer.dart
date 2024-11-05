class Trainer {
  String? id, nip, name, username, isTrainer, isOnlne, offlineStart, offlineUntil, trainerRole, trainerProfile, 
          offlineReason, imgprofile;

  Trainer({this.id, this.nip, this.name, this.username, this.isTrainer, this.isOnlne, this.offlineStart,
  this.offlineUntil, this.trainerRole, this.trainerProfile, this.offlineReason, this.imgprofile});

  Trainer.fromJson(Map json) : 
    id = json['id'] ?? '',
    nip = json['nip'] ?? '',
    name = json['name'] ?? '',
    username = json['username'] ?? '',
    isTrainer = json['is_trainer'] ?? '',
    isOnlne = json['is_online'] ?? '',
    offlineStart = json['offline_start'] ?? '',
    offlineUntil = json['offline_until'] ?? '',
    offlineReason = json['offline_reason'] ?? '',
    trainerRole = json['trainer_role'] ?? '',
    trainerProfile = json['trainer_profile'] ?? '',
    imgprofile = json['imgprofile'] ?? '';

  
  Map toJson() {
    return {
      'id' : id,
      'nip' : nip,
      'name' : name,
      'username' : username,
      'is_trainer' : isTrainer,
      'is_online' : isOnlne,
      'offline_start' : offlineStart,
      'offline_until' : offlineUntil,
      'offline_reason' : offlineReason,
      'trainer_role' : trainerRole,
      'trainer_profile' : trainerProfile,
      'imgprofile' : imgprofile,
    };
  }
}