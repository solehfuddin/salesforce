class ItemSp {
  String idItemSp, prodName, qty, typeSp;
  String? categoryId;

  ItemSp.fromJson(Map json):
   idItemSp     = json['id'],
   prodName     = json['product_name'] ?? '-',
   qty          = json['qty'] ?? '0',
   typeSp       = json['type'];
}