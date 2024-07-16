class MarketingExpenseAttachment {
  String? id, attachment;

  MarketingExpenseAttachment({
    this.id,
    this.attachment,
  });

  MarketingExpenseAttachment.fromJson(Map json)
      : id = json['id_marketing_expense'],
        attachment = json['attachment'] ?? '';

  Map toJson() {
    return {
      'id_marketing_expense': id,
      'attachment': attachment,
    };
  }
}
