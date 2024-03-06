class ManagerToken {
  String? id, name, username, role, divisi, token;

  ManagerToken({this.id, this.name, this.username, this.role, this.divisi, this.token});

  ManagerToken.fromJson(Map<String, dynamic> json)
  {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    username = json['username'] ?? '';
    role = json['role'] ?? '';
    divisi = json['divisi'] ?? '';
    token = json['gentoken'] ?? '';
  }

  Map toJson() {
    return {
      'id' : id,
      'name' : name,
      'username' : username,
      'role' : role,
      'divisi' : divisi,
      'gentoken' : token,
    };
  }
}