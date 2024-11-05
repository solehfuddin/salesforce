class PosMaterialLinePoster {
  String? idPos, materialId, material, width, height, contentId, content, qty, estimatePrice;
  bool? validateProductWidth, validateProductHeight, validateQtyItem;

  PosMaterialLinePoster({
    this.materialId,
    this.material,
    this.width,
    this.height,
    this.contentId,
    this.content,
    this.qty,
    this.validateProductWidth = false,
    this.validateProductHeight = false,
    this.validateQtyItem = false,
  });

  String get getIdPosMaterial {
    return idPos ?? "";
  }

  set setIdPosMaterial(String _value) {
    idPos = _value;
  }

  PosMaterialLinePoster.fromJson(Map json) : 
    idPos = json['id_pos_material'],
    materialId = json['poster_material_id'],
    material = json['poster_material'],
    width = json['poster_width'],
    height = json['poster_height'],
    contentId = json['poster_content_id'],
    content = json['poster_content'],
    qty = json['product_qty'] ?? "1",
    estimatePrice = json['price_estimate'] ?? "0"
  ;

  Map toJson() {
    return {
      'id_pos_material': idPos,
      'poster_material_id': materialId,
      'poster_material': material,
      'poster_width': width,
      'poster_height': height,
      'poster_content_id': contentId,
      'poster_content': content,
      'product_qty': qty,
    };
  }
}
