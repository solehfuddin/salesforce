class ChangeCustomerFile {
  String ktp, npwp, tampakDepan, kartuNama;

  ChangeCustomerFile.fromJson(Map json)
      : ktp = json['upload_identitas'] ?? '',
        npwp = json['upload_dokumen'] ?? '',
        tampakDepan = json['gambar_pendukung'] ?? '',
        kartuNama = json['gambar_kartu_nama'] ?? '';

  Map toJson() {
    return {
      'upload_identitas' : ktp,
      'upload_dokumen' : npwp,
      'gambar_pendukung' : tampakDepan,
      'gambar_kartu_nama' : kartuNama
    };
  }
}
