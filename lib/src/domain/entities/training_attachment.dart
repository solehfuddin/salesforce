class TrainingAttachment {
  String? id, attachment;

  TrainingAttachment({
    this.id,
    this.attachment,
  });

  TrainingAttachment.fromJson(Map json)
      : id = json['id_training'],
        attachment = json['attachment'] ?? '';

  Map toJson() {
    return {
      'id_training': id,
      'attachment': attachment,
    };
  }
}