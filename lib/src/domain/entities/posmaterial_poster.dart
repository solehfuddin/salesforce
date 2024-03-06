class PosMaterialPoster {
  String? posterMaterialId, posterMaterial, posterStatus;

  PosMaterialPoster.fromJson(Map json)
      : posterMaterialId = json['poster_material_id'] ?? '',
        posterMaterial = json['poster_material'] ?? '',
        posterStatus = json['poster_status'] ?? '';

  Map toJson() {
    return {
      'poster_material_id': posterMaterialId,
      'poster_material': posterMaterial,
      'poster_status': posterStatus,
    };
  }
}
