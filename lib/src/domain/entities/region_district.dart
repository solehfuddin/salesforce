class RegionDistrict {
  String? id, desc;
  bool ischecked = false;

  RegionDistrict.fromJson(Map json) :
    id = json['district_code'],
    desc = json['district_name'];

  Map toJson() {
    return {
      'district_code' : id,
      'district_name' : desc
    };
  }
}