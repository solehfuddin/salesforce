class AppConfig {
  String? id, title, status;

  AppConfig.fromJson(Map json):
    id = json['id'] ?? '',
    title = json['title'] ?? '',
    status = json['status'] ?? '0';

 Map toJson() {
  return {
    'id' : id,
    'title' : title,
    'status' : status
  };
 }
}