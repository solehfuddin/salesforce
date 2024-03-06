class OpticWithAddress {
  String? namaUsaha, alamatUsaha, noAccount, typeAccount;
  bool isChecked = false;

  OpticWithAddress.fromJson(Map json)
      : namaUsaha = json['nama_usaha'] ?? '',
        alamatUsaha = json['alamat_usaha'] ?? '',
        noAccount = json['no_account'] ?? '',
        typeAccount = json['type_account'] ?? '';

  Map toJson() {
    return {
      'nama_usaha': namaUsaha,
      'alamat_usaha': alamatUsaha,
      'no_account': noAccount,
      'type_account': typeAccount,
    };
  }
}
