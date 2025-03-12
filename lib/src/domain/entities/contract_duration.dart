class ContractDuration {
  String? id, title, status;

  ContractDuration.fromJson(Map json) :
    id = json['id'],
    title = json['title'] ?? '',
    status = json['status'] ?? 'INACTIVE';

  ContractDuration(
    this.id,
    this.title,
    this.status
  );

  factory ContractDuration.singleJson(dynamic json) {
    return ContractDuration(json['id'] as String, json['title'] as String, json['status'] as String);
  }
}