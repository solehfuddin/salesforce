class InkaroReguler {
  String idKategori = '';
  String descKategori = '';
  String hpp = '';
  String inkaroPercent = '';
  String inkaroValue = '';
  bool ischecked = false;

  InkaroReguler(this.idKategori, this.descKategori, this.hpp,
      this.inkaroPercent, this.inkaroValue);

  InkaroReguler.fromJson(Map json)
      : idKategori = json['CATEGORY_ID'],
        descKategori = json['DESC_CATEGORY'],
        hpp = json['hpp'],
        inkaroPercent = json['inkaro_percent'],
        inkaroValue = json['inkaro_value'];

  Map toJson() {
    return {
      'CATEGORY_ID': idKategori,
      'DESC_CATEGORY': descKategori,
      'hpp': hpp,
      'inkaro_percent': inkaroPercent,
      'inkaro_value': inkaroValue
    };
  }
}
