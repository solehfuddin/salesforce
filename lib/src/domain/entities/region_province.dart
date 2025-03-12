class RegionProvince {
  String? id, desc;
  bool ischecked = false;

  RegionProvince.fromJson(Map json) : 
    id = json['province_code'],
    desc = json['province_name'];

  Map toJson() {
    return {
      'province_code' : id,
      'province_name' : desc
    };
  }
}