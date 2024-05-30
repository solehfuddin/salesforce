class CashbackRekening {
  String? idRekening, idBank, bankName, nomorRekening, namaRekening, billNumber, shipNumber;
  bool isChecked = false;

  CashbackRekening();

  String get getIdRekening {
    return idRekening ?? "";
  }

  String get getIdBank {
    return idBank ?? "";
  }

  String get getBankName {
    return bankName ?? "";
  }

  String get getNomorRekening {
    return nomorRekening ?? "";
  }

  String get getNamaRekening {
    return namaRekening ?? "";
  }

  String get getBillNumber {
    return billNumber ?? "";
  }

  String get getShipNumber {
    return shipNumber ?? "";
  }

  set setIdRekening(String _value){
    idRekening = _value;
  }

  set setIdBank(String _value) {
    idBank = _value;
  }

  set setBankName(String _value) {
    bankName = _value;
  }

  set setNomorRekening(String _value) {
    nomorRekening = _value;
  }

  set setNamaRekening(String _value) {
    namaRekening = _value;
  }

  set setBillNumber(String _value) {
    billNumber = _value;
  }

  set setShipNumber(String _value) {
    shipNumber = _value;
  }


  CashbackRekening.fromJson(Map json)
    : idRekening = json['id'],
      idBank = json['bank_id'],
      nomorRekening = json['account_number'],
      namaRekening = json['account_name'],
      billNumber = json['bill_number'],
      shipNumber = json['ship_number'],
      bankName = json['bank_name'];

  Map toJson() {
    return {
      'id' : idRekening,
      'bank_id' : idBank,
      'account_number' : nomorRekening,
      'account_name' : namaRekening,
      'bill_number' : billNumber,
      'ship_number' : shipNumber,
      'bank_name' : bankName,
    };
  }
}