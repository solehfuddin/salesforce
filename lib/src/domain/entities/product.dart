class Product {
  String categoryid, proddiv, prodcat, proddesc, status;
  String diskon;
  bool ischecked = false;
  
  Product(this.categoryid, this.proddiv, this.prodcat, this.proddesc, this.diskon, this.status);

  Product.fromJson(Map json):
    categoryid = json['category_id'],
    proddiv = json['prod_div'],
    prodcat = json['prodcat'],
    proddesc = json['prodcat_description'],
    status = json['status'];

  Map toJson() {
    return {
      'category_id' : categoryid,
      'prod_div' : proddiv,
      'prodcat' : prodcat,
      'prodcat_description' : proddesc,
      'status' : status
    };
  }
}