class ListInkaroDetail {
  String inkaroContractDetailId = '';
  String inkaroContractId = '';
  String idKategori = '';
  String descKategori = '';
  String idSubcategory = '';
  String descSubcategory = '';
  String hpp = '';
  String inkaroPercent = '';
  String inkaroValue = '';
  String typeInkaro = '';
  bool ischecked = false;

  ListInkaroDetail(
      this.inkaroContractDetailId,
      this.inkaroContractId,
      this.idKategori,
      this.descKategori,
      this.idSubcategory,
      this.descSubcategory,
      this.hpp,
      this.inkaroPercent,
      this.inkaroValue,
      this.typeInkaro);

  ListInkaroDetail.fromJson(Map json)
      : inkaroContractDetailId = json['id_contract_detail'],
        inkaroContractId = json['id_contract'],
        idKategori = json['CATEGORY_ID'] != null ? json['CATEGORY_ID'] : '',
        descKategori =
            json['DESC_CATEGORY'] != null ? json['DESC_CATEGORY'] : '',
        idSubcategory =
            json['SUBCATEGORY_ID'] != null ? json['SUBCATEGORY_ID'] : '',
        descSubcategory =
            json['DESC_SUBCATEGORY'] != null ? json['DESC_SUBCATEGORY'] : '',
        hpp = json['hpp'],
        inkaroPercent = json['inkaro_percent'],
        inkaroValue = json['inkaro_value'],
        typeInkaro = json['type_inkaro'];

  Map toJson() {
    return {
      'id_contract_detail': inkaroContractDetailId,
      'id_contract': inkaroContractId,
      'CATEGORY_ID': idKategori,
      'DESC_CATEGORY': descKategori,
      'SUBCATEGORY_ID': idSubcategory,
      'DESC_SUBCATEGORY': descSubcategory,
      'hpp': hpp,
      'inkaro_percent': inkaroPercent,
      'inkaro_value': inkaroValue,
      'type_inkaro': typeInkaro
    };
  }
}
