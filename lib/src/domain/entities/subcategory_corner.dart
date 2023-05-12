class SubcategoryCorner {
  String? idSubcategory, titleSubcategory, slugSubcategory, typeSubcategory, descriptionSubcategory;

  SubcategoryCorner.fromJson(Map json):
    idSubcategory = json['id_subcategory'] ?? "",
    titleSubcategory = json['title_subcategory'] ?? "",
    slugSubcategory = json['slug_subcategory'] ?? "",
    typeSubcategory = json['type_subcategory'] ?? "",
    descriptionSubcategory = json['description_subcategory'] ?? "";

  Map toJson() {
    return {
      'id_subcategory'    : idSubcategory,
      'title_subcategory' : titleSubcategory,
      'slug_subcategory'  : slugSubcategory,
      'type_subcategory'  : typeSubcategory,
      'description_subcategory' : descriptionSubcategory
    };
  }
}