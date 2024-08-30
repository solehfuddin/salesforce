class ContractPromo {
  String? id, promoName, promoDescription, promoStart, promoUntil, createdBy;
  bool isChecked = false;

  ContractPromo();

  ContractPromo.fromJson(Map json) : 
    id = json['id_contract_promo'],
    promoName = json['promo'],
    promoDescription = json['description'],
    promoStart = json['promo_start'],
    promoUntil = json['promo_until'],
    createdBy = json['created_by'];

  Map toJson() {
    return {
      'id_contract_promo' : id,
      'promo' : promoName,
      'description' : promoDescription,
      'promo_start' : promoStart,
      'promo_until' : promoUntil,
      'created_by' : createdBy,
    };
  }
}