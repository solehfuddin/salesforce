class Contract {
  String idContract, idCustomer, namaPertama, jabatanPertama, alamatPertama, telpPertama, faxPertama,
  namaKedua, jabatanKedua, alamatKedua, telpKedua, faxKedua, tpNikon, tpNikonSt, tpLeinz, tpLeinzSt,
  tpOriental, tpOrientalSt, tpMoe, pembNikon, pembLeinz, pembOriental, pembMoe, pembNikonSt, pembLeinzSt, 
  pembOrientalSt, startContract, endContract, typeContract, isFrame, isPartai, status, 
  catatan, customerShipName, customerShipNumber, dateAdded, approvalSm, reasonSm, approvalAm, reasonAm,
  dateApprovalSm, dateApprovalAm, hasParent, idParent, idContractParent, createdBy;

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
    tpNikonSt = json['tp_nikon_stock'],
    tpLeinz = json['tp_leinz'],
    tpLeinzSt = json['tp_leinz_stock'],
    tpOriental = json['tp_oriental'],
    tpOrientalSt = json['tp_oriental_stock'],
    tpMoe = json['tp_moe'],
    pembNikon = json['pembayaran_nikon'],
    pembLeinz = json['pembayaran_leinz'],
    pembOriental = json['pembayaran_oriental'],
    pembMoe = json['pembayaran_moe'],
    pembNikonSt = json['pembayaran_nikon_stock'],
    pembLeinzSt = json['pembayaran_leinz_stock'],
    pembOrientalSt = json['pembayaran_oriental_stock'],
    startContract = json['start_contract'],
    endContract = json['end_contract'],
    typeContract = json['type_contract'],
    isFrame = json['is_frame'],
    isPartai = json['is_partai'],
    status = json['status'],
    catatan = json['catatan'],
    customerShipName = json['customer_ship_name'],
    customerShipNumber = json['customer_ship_number'],
    dateAdded = json['date_added'],
    approvalAm = json['approval_am'],
    reasonAm = json['reason_am'],
    approvalSm = json['approval_sm'],
    reasonSm = json['reason_sm'],
    dateApprovalAm = json['date_approval_am'],
    dateApprovalSm = json['date_approval_sm'],
    hasParent = json['has_parent'],
    idParent = json['id_parent'],
    idContractParent = json['id_contract_parent'],
    createdBy = json['created_by'];

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
    this.tpNikonSt,
    this.tpLeinz,
    this.tpLeinzSt,
    this.tpOriental,
    this.tpOrientalSt,
    this.tpMoe,
    this.pembNikon,
    this.pembLeinz,
    this.pembOriental,
    this.pembMoe,
    this.pembNikonSt,
    this.pembLeinzSt,
    this.pembOrientalSt,
    this.startContract,
    this.endContract,
    this.typeContract,
    this.isFrame,
    this.isPartai,
    this.status,
    this.catatan,
    this.customerShipName,
    this.customerShipNumber,
    this.dateAdded,
    this.approvalAm,
    this.reasonAm,
    this.approvalSm,
    this.reasonSm,
    this.dateApprovalAm,
    this.dateApprovalSm,
    this.hasParent,
    this.idParent,
    this.idContractParent,
    this.createdBy,
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
      json['tp_nikon_stock'] as String,
      json['tp_leinz'] as String,
      json['tp_leinz_stock'] as String,
      json['tp_oriental'] as String,
      json['tp_oriental_stock'] as String,
      json['tp_moe'] as String,
      json['pembayaran_nikon'] as String,
      json['pembayaran_leinz'] as String,
      json['pembayaran_oriental'] as String,
      json['pembayaran_moe'] as String,
      json['pembayaran_nikon_stock'] as String,
      json['pembayaran_leinz_stock'] as String,
      json['pembayaran_oriental_stock'] as String,
      json['start_contract'] as String,
      json['end_contract'] as String,
      json['type_contract'] as String,
      json['is_frame'] as String,
      json['is_partai'] as String,
      json['status'] as String,
      json['catatan'] as String,
      json['customer_ship_name'] as String,
      json['customer_ship_number'] as String,
      json['date_added'] as String,
      json['approval_am'] as String,
      json['reason_am'] as String,
      json['approval_sm'] as String,
      json['reason_sm'] as String,
      json['date_approval_am'] as String,
      json['date_approval_sm'] as String,
      json['has_parent'] as String,
      json['id_parent'] as String,
      json['id_contract_parent'] as String,
      json['created_by'] as String,
    );
  }
}