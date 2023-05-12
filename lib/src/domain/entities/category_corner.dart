import 'package:sample/src/domain/entities/subcategory_corner.dart';

class CategoryCorner {
  String? idCategory, titleCategory, slugCategory, typeCategory;
  bool isExpanded = false;
  List<SubcategoryCorner> subcategoryList = List.empty(growable: true);

  // CategoryCorner.fromJson(Map json):
  //   idCategory = json['id_category'] ?? "",
  //   titleCategory = json['title_category'] ?? "",
  //   slugCategory = json['slug_category'] ?? "",
  //   typeCategory = json['type_category'] ?? "";

  CategoryCorner.fromJson(Map json) {
    idCategory = json['id_category'] ?? "";
    titleCategory = json['title_category'] ?? "";
    slugCategory = json['slug_category'] ?? "";
    typeCategory = json['type_category'] ?? "";
    if (json['subcategory'] != null) {
      json['subcategory'].forEach((v) {
        subcategoryList.add(new SubcategoryCorner.fromJson(v));
      });
    }
  }

  Map toJson() {
    return {
      'id_category'     : idCategory,
      'title_category'  : titleCategory,
      'slug_category'   : slugCategory,
      'type_category'   : typeCategory,
      'subcategory'     : subcategoryList.map((e) => e.toJson()).toList(),
    };
  }
}