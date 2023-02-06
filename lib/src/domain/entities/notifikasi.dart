class Notifikasi {
  String idNotif = '';
  String idUser = '';
  String typeTemplate = '';
  String typeNotif = '';
  String judul = '';
  String isi = '';
  String tanggal = '';
  String isRead = '';

  Notifikasi();

  //API REMOTE
  Notifikasi.fromJson(Map json)
      : idNotif = json['id_notifikasi'],
        idUser = json['id_user'] ?? '0',
        typeTemplate = json['type_template'] ?? '10',
        typeNotif = json['type_notifikasi'],
        judul = json['judul'],
        isi = json['isi'],
        tanggal = json['tanggal'],
        isRead = json['is_read'];

  Map toJson() {
    return {
      'id_notifikasi': idNotif,
      'id_user': idUser,
      'type_template': typeTemplate,
      'type_notifikasi': typeNotif,
      'judul': judul,
      'isi': isi,
      'tanggal': tanggal,
      'is_read': isRead,
    };
  }

  //Lokal DB
  Notifikasi.fromMap(Map<String, dynamic> map) {
    idNotif = map['id_notifikasi'];
    idUser = map['id_user'] ?? '0';
    typeTemplate = map['type_template'] ?? '10';
    typeNotif = map['type_notifikasi'];
    judul = map['judul'];
    isi = map['isi'];
    tanggal = map['tanggal'];
    isRead = map['is_read'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id_notifikasi'] = idNotif;
    map['id_user'] = idUser;
    map['type_template'] = typeTemplate;
    map['type_notifikasi'] = typeNotif;
    map['judul'] = judul;
    map['isi'] = isi;
    map['tanggal'] = tanggal;
    map['is_read'] = isRead;
    return map;
  }
}
