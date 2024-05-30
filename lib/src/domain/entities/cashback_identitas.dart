class CashbackIdentitas {
  String? nama, noKtp, noNpwp;

  CashbackIdentitas({this.nama, this.noKtp, this.noNpwp});

  String get getKtp {
    return noKtp ?? "";
  }

  String get getCreatedBy {
    return noNpwp ?? "";
  }

  String get getNama {
    return nama ?? "";
  }

  CashbackIdentitas.fromJson(Map json) 
  : nama = json['nama'],
    noKtp = json['no_identitas'],
    noNpwp = json['no_npwp'];

  Map toJson() {
    return {
      'nama' : nama,
      'no_identitas' : noKtp,
      'no_npwp' : noNpwp,
    };
  }
}