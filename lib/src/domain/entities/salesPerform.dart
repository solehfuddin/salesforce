class SalesPerform {
  dynamic salesRepId,
      salesPerson,
      penjualan,
      size;
  SalesPerform({this.size});

  SalesPerform.fromJson(Map json)
      : salesRepId = json['SALESREP_ID'],
        salesPerson = json['SALESPERSON'],
        penjualan = json['PENJUALAN'];

  Map toJson() {
    return {
      'SALESREP_ID' : salesRepId,
      'SALESPERSON': salesPerson,
      'PENJUALAN': penjualan,
    };
  }
}
