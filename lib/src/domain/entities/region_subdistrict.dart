class RegionSubdistrict {
  String? id, desc;
  bool ischecked = false;

  RegionSubdistrict.fromJson(Map json) :
    id = json['subdistrict_code'],
    desc = json['subdistrict_name'];

  Map toJson() {
    return {
      'subdistrict_code' : id,
      'subdistrict_name' : desc
    };
  }
}