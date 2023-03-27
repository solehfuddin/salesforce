class TipeKontrak {
  String? id, deskripsi, flag;
  bool ischecked = false;

  TipeKontrak(this.id, this.deskripsi, this.flag);

  TipeKontrak.fromJson(Map json) : 
    id = json['id_tipe'] ?? '',
    deskripsi = json['deskripsi'] ?? '',
    flag = json['flag'] ?? '';

  Map toJson() {
    return {
      'id_tipe' : id,
      'deskripsi' : deskripsi,
      'flag' : flag
    };
  }
}