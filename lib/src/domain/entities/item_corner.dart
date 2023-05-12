class ItemCorner {
  String? idCorner, titleCorner, bodyCorner, titleCategories, slugCategories, titleSubcategories,
  slugSubcategories;
  var imgCorner;
  bool isImageValid = false;

  ItemCorner.fromJson(Map json) {
    idCorner = json['id_corner'] ?? "";
    titleCorner = json['title_corner'] ?? "";
    bodyCorner = json['body_corner'] ?? "";
    imgCorner = json['img_corner'];
    titleCategories = json['title_categories'] ?? "";
    slugCategories = json['slug_categories'] ?? "";
    titleSubcategories = json['title_subcategories'] ?? "";
    slugSubcategories = json['slug_subcategories'] ?? "";
  }

  Map toJson() {
    return {
      'id_corner'           : idCorner,
      'title_corner'        : titleCorner,
      'body_corner'         : bodyCorner,
      'img_corner'          : imgCorner,
      'title_categories'    : titleCategories,
      'slug_categories'     : slugCategories,
      'title_subcategories' : titleSubcategories,
      'slug_subcategories'  : slugSubcategories,
    };
  }
}