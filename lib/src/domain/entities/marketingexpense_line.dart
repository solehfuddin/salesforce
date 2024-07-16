class MarketingExpenseLine {
  String? id, judul, status, price, adjustment;

  MarketingExpenseLine({
    this.id,
    this.judul,
    this.price,
    this.adjustment,
    this.status,
  });

  MarketingExpenseLine.fromJson(Map json) : 
    id = json['id_marketing_expense'],
    judul = json['marketing_expense'],
    price = json['price_estimate'] ?? '0',
    adjustment = json['price_adjustment'] ?? '0',
    status = json['status'];

  Map toJson() {
    return {
      'id_marketing_expense' : id,
      'marketing_expense' : judul,
      'price_estimate' : price,
      'price_adjustment' : adjustment,
      'status' : status,
    };
  }
}
