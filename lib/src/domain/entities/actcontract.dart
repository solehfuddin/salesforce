class ActContract {
  String idContract,
      idCustomer,
      namaPertama,
      jabatanPertama,
      alamatPertama,
      telpPertama,
      faxPertama,
      namaKedua,
      jabatanKedua,
      alamatKedua,
      telpKedua,
      faxKedua,
      tpNikon,
      tpLeinz,
      tpOriental,
      tpMoe,
      pembNikon,
      pembLeinz,
      pembOriental,
      pembMoe,
      startContract,
      endContract,
      typeContract,
      noAccount,
      ttdPertama,
      ttdKedua,
      approvalSm,
      approverSm,
      reasonSm,
      dateApprovalSm,
      approvalAm,
      approverAm,
      reasonAm,
      dateApprovalAm,
      status,
      createdBy,
      updatedBy,
      dateAdded,
      dateUpdated,
      dateDeleted,
      customerBillName;

  ActContract.fromJson(Map json)
      : idContract = json['id'],
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
        pembNikon = json['pembayaran_nikon'] ?? '',
        pembLeinz = json['pembayaran_leinz'] ?? '',
        pembOriental = json['pembayaran_oriental'] ?? '',
        pembMoe = json['pembayaran_moe'] ?? '',
        startContract = json['start_contract'],
        endContract = json['end_contract'],
        typeContract = json['type_contract'],
        noAccount = json['no_account'],
        ttdPertama = json['ttd_pertama'],
        ttdKedua = json['ttd_kedua'],
        approvalSm = json['approval_sm'],
        approverSm = json['approver_sm'],
        reasonSm = json['reason_sm'] ?? '',
        dateApprovalSm = json['date_approval_sm'],
        approvalAm = json['approval_am'],
        approverAm = json['approver_am'],
        reasonAm = json['reason_am'] ?? '',
        dateApprovalAm = json['date_approval_am'],
        status = json['status'],
        createdBy = json['created_by'],
        updatedBy = json['updated_by'] ?? '',
        dateAdded = json['date_added'],
        dateUpdated = json['date_updated'] ?? '',
        dateDeleted = json['date_deleted'] ?? '',
        customerBillName = json['customer_bill_name'];

  Map toJson() {
    return {
      'id': idContract,
      'id_customer': idCustomer,
      'nama_pertama': namaPertama,
      'jabatan_pertama': jabatanPertama,
      'alamat_pertama': alamatPertama,
      'telp_pertama': telpPertama,
      'fax_pertama': faxPertama,
      'nama_kedua': namaKedua,
      'jabatan_kedua': jabatanKedua,
      'alamat_kedua': alamatKedua,
      'telp_kedua': telpKedua,
      'fax_kedua': faxKedua,
      'tp_nikon': tpNikon,
      'tp_leinz': tpLeinz,
      'tp_oriental': tpOriental,
      'tp_moe': tpMoe,
      'pembayaran_nikon': pembNikon,
      'pembayaran_leinz': pembLeinz,
      'pembayaran_oriental': pembOriental,
      'pembayaran_moe': pembMoe,
      'start_contract': startContract,
      'end_contract': endContract,
      'type_contract': typeContract,
      'no_account': noAccount,
      'ttd_pertama': ttdPertama,
      'ttd_kedua': ttdKedua,
      'approval_sm': approvalSm,
      'approver_sm': approverSm,
      'reason_sm': reasonSm,
      'date_approval_sm': dateApprovalSm,
      'approval_am': approvalAm,
      'approver_am': approverAm,
      'reason_am': reasonAm,
      'date_approval_am': dateApprovalAm,
      'status': status,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'date_added': dateAdded,
      'date_updated': dateUpdated,
      'date_deleted': dateDeleted,
      'customer_bill_name' : customerBillName,
    };
  }
}
