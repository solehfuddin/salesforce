class ListMasterBank {
  String idBank, shortName, longName;

  ListMasterBank.fromJson(Map json)
      : idBank = json['id_bank'] ?? '',
        shortName = json['shortname_bank'] ?? '',
        longName = json['longname_bank'];

  Map toJson() {
    return {
      'id_bank': idBank,
      'shortname_bank': shortName,
      'longname_bank': longName,
    };
  }
}
