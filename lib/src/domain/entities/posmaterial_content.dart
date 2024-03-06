class PosMaterialContent {
  String? posterContentId, posterContent, posterStatus;

  PosMaterialContent.fromJson(Map json)
      : posterContentId = json['poster_content_id'] ?? '',
        posterContent = json['poster_content'] ?? '',
        posterStatus = json['poster_status'] ?? '';

  Map toJson() {
    return {
      'poster_content_id': posterContentId,
      'poster_content': posterContent,
      'poster_status': posterStatus,
    };
  }
}
