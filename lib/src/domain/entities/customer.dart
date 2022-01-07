class Customer {
  String id, nama, agama, tempatLahir, tanggalLahir, alamat, noTlp, fax, noIdentitas, uploadIdentitas,
  namaUsaha, alamatUsaha, tlpUsaha, faxUsaha, emailUsaha, namaPj, sistemPembayaran, kreditLimit, 
  uploadDokumen, ttdCustomer, namaSalesman, namaArManager, note, createdBy, dateAdded;

  Customer.fromJson(Map json): 
    id = json['id'],
    nama = json['nama'],
    agama = json['agama'],
    tempatLahir = json['tempat_lahir'],
    tanggalLahir = json['tanggal_lahir'],
    alamat = json['alamat'],
    noTlp = json['no_telp'],
    fax = json['fax'],
    noIdentitas = json['no_identitas'],
    uploadIdentitas = json['upload_identitas'],
    namaUsaha = json['nama_usaha'],
    alamatUsaha = json['alamat_usaha'],
    tlpUsaha = json['telp_usaha'],
    faxUsaha = json['fax_usaha'],
    emailUsaha = json['email_usaha'],
    namaPj = json['nama_pj'],
    sistemPembayaran = json['sistem_pembayaran'],
    kreditLimit = json['kredit_limit'],
    uploadDokumen = json['upload_dokumen'],
    ttdCustomer = json['ttd_customer'],
    namaSalesman = json['nama_salesman'],
    namaArManager = json['nama_ar_manager'],
    note = json['note'],
    createdBy = json['created_by'],
    dateAdded = json['date_added'];

  Map toJson(){
    return {
      'id' : id,
      'nama' : nama,
      'agama' : agama,
      'tempat_lahir' : tempatLahir,
      'tanggal_lahir' : tanggalLahir,
      'alamat' : alamat,
      'no_telp' : noTlp,
      'fax' : fax,
      'no_identitas' : noIdentitas,
      'upload_identitas' : uploadIdentitas,
      'nama_usaha' : namaUsaha,
      'alamat_usaha' : alamatUsaha,
      'telp_usaha' : tlpUsaha,
      'fax_usaha' : faxUsaha,
      'email_usaha' : emailUsaha,
      'nama_pj' : namaPj,
      'sistem_pembayaran' : sistemPembayaran,
      'kredit_limit' : kreditLimit,
      'upload_dokumen' : uploadDokumen,
      'ttd_customer' : ttdCustomer,
      'nama_salesman' : namaSalesman,
      'nama_ar_manager' : namaArManager,
      'note' : note,
      'created_by' : createdBy,
      'date_added' : dateAdded
    };
  }
}