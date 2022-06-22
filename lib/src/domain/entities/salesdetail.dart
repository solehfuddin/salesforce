class SalesDetail {
  dynamic area,
      salesPerson,
      penjualan,
      cakupan;
  SalesDetail({this.area, this.salesPerson, this.penjualan, this.cakupan});

  SalesDetail.fromJson(Map json)
      : area = json['AREA'],
        salesPerson = json['SALESPERSON'],
        penjualan = json['PENJUALAN'];

  Map toJson() {
    return {
      'SALESREP_ID' : area,
      'SALESPERSON': salesPerson,
      'PENJUALAN': penjualan,
    };
  }
}
