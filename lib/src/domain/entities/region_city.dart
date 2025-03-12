class RegionCity {
  String? id, desc;
  bool ischecked = false;

  RegionCity.fromJson(Map json) :
    id = json['city_code'],
    desc = json['city_name'];

  Map toJson() {
    return {
      'city_code' : id,
      'city_name' : desc
    };
  }
}