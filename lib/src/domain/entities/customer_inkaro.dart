class ListCustomerInkaro {
  String noAccount = '';
  String customerId, billToSiteUseId, namaUsaha, alamatUsaha, tlpUsaha, namaPj;

  ListCustomerInkaro.fromJson(Map json)
      : noAccount = json['customer_ship_number'] ?? '',
        customerId = json['CUSTOMER_ID'],
        billToSiteUseId = json['BILL_TO_SITE_USE_ID'],
        namaUsaha = json['nama_usaha'] ?? '',
        alamatUsaha = json['alamat_usaha'],
        tlpUsaha = json['telp_usaha'],
        namaPj = json['nama_pj'];
  // dateAdded = json['date_added'];

  Map toJson() {
    return {
      'customer_ship_number': noAccount,
      'CUSTOMER_ID': customerId,
      'BILL_TO_SITE_USE_ID': billToSiteUseId,
      'nama_usaha': namaUsaha,
      'alamat_usaha': alamatUsaha,
      'telp_usaha': tlpUsaha,
      'nama_pj': namaPj,
      // 'date_added': dateAdded,
    };
  }
}
