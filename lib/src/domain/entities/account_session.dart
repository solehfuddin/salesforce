class AccountSession {
  String? id, username, fullname, role, divisi;

  AccountSession({this.id, this.username, this.fullname, this.role, this.divisi});

  String get getId => id ?? '';
  String get getUsername => username ?? '';
  String get getFullname => fullname ?? '';
  String get getRole => role ?? '';
  String get getDivisi => divisi ?? '';

  set setId(String _id) => id = _id;
  set setUsername(String _username) => username = _username;
  set setFullname(String _fullname) => fullname = _fullname;
  set setRole(String _role) => role= _role;
  set setDivisi(String _divisi) => divisi = _divisi;
}