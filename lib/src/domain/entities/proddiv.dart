class Proddiv {
  String proddiv = '';
  String alias = '';
  String diskon = '';
  bool ischecked = false;

  Proddiv(this.alias, this.proddiv, this.diskon);

  Proddiv.fromJson(Map json): 
    proddiv = json['prod_div'],
    alias = json['alias'];

  Map toJson() {
    return {
      'prod_div' : proddiv,
      'alias' : alias
    };
  }
}