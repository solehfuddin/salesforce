class PosMaterialItem {
  String? productId, productName, productType, productPrice, productStatus;

  PosMaterialItem.fromJson(Map json)
      : productId = json['product_id'] ?? '',
        productName = json['product_name'] ?? '',
        productType = json['product_type'] ?? '',
        productPrice = json['product_price'] ?? '0',
        productStatus = json['product_status'] ?? 'INACTIVE';

  Map toJson() {
    return {
      'product_id'    : productId,
      'product_name'  : productName,
      'product_type'  : productType,
      'product_price' : productPrice,
      'product_status' : productStatus,
    };
  }
}
