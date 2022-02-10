class Contract {
  String idContract, idCustomer, namaPertama, jabatanPertama, alamatPertama, telpPertama, faxPertama,
  namaKedua, jabatanKedua, alamatKedua, telpKedua, faxKedua, tpNikon, tpLeinz, tpOriental, tpMoe, 
  pembNikon, pembLeinz, pembOriental, pembMoe, startContract, endContract, status;

  Contract.fromJson(Map json):
    idContract = json['id'],
    idCustomer = json['id_customer'],
    namaPertama = json['nama_pertama'],
    jabatanPertama = json['jabatan_pertama'],
    alamatPertama = json['alamat_pertama'],
    telpPertama = json['telp_pertama'],
    faxPertama = json['fax_pertama'],
    namaKedua = json['nama_kedua'],
    jabatanKedua = json['jabatan_kedua'],
    alamatKedua = json['alamat_kedua'],
    telpKedua = json['telp_kedua'],
    faxKedua = json['fax_kedua'],
    tpNikon = json['tp_nikon'],
    tpLeinz = json['tp_leinz'],
    tpOriental = json['tp_oriental'],
    tpMoe = json['tp_moe'],
    pembNikon = json['pembayaran_nikon'],
    pembLeinz = json['pembayaran_leinz'],
    pembOriental = json['pembayaran_oriental'],
    pembMoe = json['pembayaran_moe'],
    startContract = json['start_contract'],
    endContract = json['end_contract'],
    status = json['status'];

  Contract(
    this.idContract,
    this.idCustomer,
    this.namaPertama,
    this.jabatanPertama,
    this.alamatPertama,
    this.telpPertama,
    this.faxPertama,
    this.namaKedua,
    this.jabatanKedua,
    this.alamatKedua,
    this.telpKedua,
    this.faxKedua,
    this.tpNikon,
    this.tpLeinz,
    this.tpOriental,
    this.tpMoe,
    this.pembNikon,
    this.pembLeinz,
    this.pembOriental,
    this.pembMoe,
    this.startContract,
    this.endContract,
    this.status
  );

  factory Contract.singleJson(dynamic json){
    return Contract(
      json['id'] as String,
      json['id_customer'] as String,
      json['nama_pertama'] as String,
      json['jabatan_pertama'] as String,
      json['alamat_pertama'] as String,
      json['telp_pertama'] as String,
      json['fax_pertama'] as String,
      json['nama_kedua'] as String,
      json['jabatan_kedua'] as String,
      json['alamat_kedua'] as String,
      json['telp_kedua'] as String,
      json['fax_kedua'] as String,
      json['tp_nikon'] as String,
      json['tp_leinz'] as String,
      json['tp_oriental'] as String,
      json['tp_moe'] as String,
      json['pembayaran_nikon'] as String,
      json['pembayaran_leinz'] as String,
      json['pembayaran_oriental'] as String,
      json['pembayaran_moe'] as String,
      json['start_contract'] as String,
      json['end_contract'] as String,
      json['status'] as String
    );
  }
}