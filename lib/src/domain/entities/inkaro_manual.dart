class InkaroManual {
  String idSubcategory = '';
  String descSubcategory = '';
  String hpp = '';
  String inkaroPercent = '';
  String inkaroProgram = '';
  String inkaroValue = '';
  String idInkaroCategory = '';
  String descCategory = '';
  bool ischecked = false;

  InkaroManual(
      this.idSubcategory,
      this.descSubcategory,
      this.hpp,
      this.inkaroPercent,
      this.inkaroProgram,
      this.inkaroValue,
      this.idInkaroCategory,
      this.descCategory);

  InkaroManual.fromJson(Map json)
      : idSubcategory = json['SUBCATEGORY_ID'].toString(),
        descSubcategory = json['DESC_SUBCATEGORY'].toString(),
        hpp = json['hpp'].toString(),
        inkaroPercent = json['inkaro_percent'].toString(),
        inkaroProgram = json['inkaro_program'].toString(),
        inkaroValue = json['inkaro_value'].toString(),
        idInkaroCategory = json['CATEGORY_ID'].toString(),
        descCategory = json['DESC_CATEGORY'].toString();

  Map toJson() {
    return {
      'SUBCATEGORY_ID': idSubcategory,
      'DESC_SUBCATEGORY': descSubcategory,
      'hpp': hpp,
      'inkaro_percent': inkaroPercent,
      'inkaro_program': inkaroProgram,
      'inkaro_value': inkaroValue,
      'CATEGORY_ID': idInkaroCategory,
      'DESC_CATEGORY': descCategory
    };
  }
}
