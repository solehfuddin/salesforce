class OpticWithAddress {
  String? namaUsaha,
      alamatUsaha,
      noAccount,
      billNumber,
      typeAccount,
      phone,
      contactPerson;
  bool isChecked = false;

  OpticWithAddress({
    this.namaUsaha,
    this.alamatUsaha,
    this.noAccount,
    this.billNumber,
    this.typeAccount,
    this.phone,
    this.contactPerson,
  });

  OpticWithAddress.fromJson(Map json)
      : namaUsaha = json['nama_usaha'] ?? '',
        alamatUsaha = json['alamat_usaha'] ?? '',
        noAccount = json['no_account'] ?? '',
        billNumber = json['bill_number'] ?? '',
        typeAccount = json['type_account'] ?? '',
        phone = json['phone'] ?? '',
        contactPerson = json['contact_person'] ?? '';

  Map toJson() {
    return {
      'nama_usaha': namaUsaha,
      'alamat_usaha': alamatUsaha,
      'no_account': noAccount,
      'bill_number': billNumber,
      'type_account': typeAccount,
      'phone': phone,
      'contact_person': contactPerson,
    };
  }
}
