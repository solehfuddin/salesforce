class Jenisact {
  String description;
  bool ischecked = false;

  Jenisact(this.description);

  Jenisact.fromJson(Map json) : description = json['description'] ?? '';

  Map toJson() {
    return {
      'description': description,
    };
  }
}
