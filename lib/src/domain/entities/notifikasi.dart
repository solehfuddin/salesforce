class Notifikasi {
  String idNotif, idUser, typeTemplate, typeNotif, judul, isi, tanggal, isRead;

  Notifikasi();

  //Dari API REMOTE
  Notifikasi.fromJson(Map json): 
    idNotif = json['id_notifikasi'],
    idUser = json['id_user'],
    typeTemplate = json['type_template'],
    typeNotif = json['type_notifikasi'],
    judul = json['judul'],
    isi = json['isi'],
    tanggal = json['tanggal'],
    isRead = json['is_read'];

  Map toJson(){
    return {
      'id_notifikasi' : idNotif,
      'id_user' : idUser,
      'type_template' : typeTemplate,
      'type_notifikasi' : typeNotif,
      'judul' : judul,
      'isi' : isi,
      'tanggal' : tanggal,
      'is_read' : isRead,
    };
  }

  //SQLITE DB LOKAL
  Notifikasi.fromMap(Map<String, dynamic> map) {
    idNotif = map['id_notifikasi'];
    idUser = map['id_user'];
    typeTemplate = map['type_template'];
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