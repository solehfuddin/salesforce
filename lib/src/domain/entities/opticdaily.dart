class OpticDaily {
  String namaUsaha;
  bool ischecked = false;

  OpticDaily.fromJson(Map json):
    namaUsaha = json['nama_usaha'] ?? '';

  Map toJson(){
    return {
      'nama_usaha' : namaUsaha,
    };
  }
}