class ListInkaroHeader {
  String inkaroContractId,
      startPeriode,
      endPeriode,
      nikKTP,
      npwp,
      namaStaff,
      anRekening,
      bank,
      namaBank,
      nomorRekening,
      telpKonfirmasi,
      approvalSM,
      status;

  ListInkaroHeader.fromJson(Map json)
      : inkaroContractId = json['id_inkaro_contract'],
        startPeriode = json['start_periode'] ?? '',
        endPeriode = json['end_periode'] ?? '',
        nikKTP = json['nik_ktp'],
        npwp = json['npwp'],
        namaStaff = json['nama_staff'],
        anRekening = json['an_rekening'],
        bank = json['bank'],
        namaBank = json['nama_bank'],
        nomorRekening = json['nomor_rekening'],
        telpKonfirmasi = json['telp_konfirmasi'],
        approvalSM = json['approval_sm'],
        status = json['status'];

  Map toJson() {
    return {
      'id_inkaro_contract': inkaroContractId,
      'nama_usaha': startPeriode,
      'alamat_usaha': endPeriode,
      'nik_ktp': nikKTP,
      'npwp': npwp,
      'nama_staff': namaStaff,
      'an_rekening': anRekening,
      'bank': bank,
      'nama_bank': namaBank,
      'nomor_rekening': nomorRekening,
      'telp_konfirmasi': telpKonfirmasi,
      'approval_sm': approvalSM,
      'status': status
    };
  }
}
