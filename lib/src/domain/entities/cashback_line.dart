class CashbackLine {
  String? idCashback,
      categoryId,
      prodDiv,
      prodCat,
      prodCatDescription,
      cashback,
      status;

  CashbackLine(
      {this.idCashback,
      this.categoryId,
      this.prodDiv,
      this.prodCat,
      this.prodCatDescription,
      this.cashback,
      this.status});

  String get getIdCashback {
    return idCashback ?? "";
  }

  String get getCategoryId {
    return categoryId ?? "";
  }

  String get getProdDiv {
    return prodDiv ?? "";
  }

  String get getProdCat {
    return prodCat ?? "";
  }

  String get getProdCatDescription {
    return prodCatDescription ?? "";
  }

  String get getCashback {
    return cashback ?? "";
  }

  String get getStatus {
    return status ?? "";
  }

  set setIdCashback(String _value) {
    idCashback = _value;
  }

  set setCategoryId(String _value) {
    categoryId = _value;
  }

  set setProdDiv(String _value) {
    prodDiv = _value;
  }

  set setProdCat(String _value) {
    prodCat = _value;
  }

  set setProdcatDescription(String _value) {
    prodCatDescription = _value;
  }

  set setCashback(String _value) {
    cashback = _value;
  }

  set setStatus(String _value) {
    status = _value;
  }

  CashbackLine.fromJson(Map json)
      : idCashback = json['id_cashback'],
        categoryId = json['category_id'],
        prodDiv = json['prod_div'],
        prodCat = json['prodcat'],
        prodCatDescription = json['prodcat_description'],
        cashback = json['cashback'] ?? "0",
        status = json['status'];

  Map toJson() {
    return {
      'id_cashback': idCashback,
      'category_id': categoryId,
      'prod_div': prodDiv,
      'prodcat': prodCat,
      'prodcat_description': prodCatDescription,
      'cashback': cashback,
      'status': status,
    };
  }
}
