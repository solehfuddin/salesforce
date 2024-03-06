class PosMaterialAttachment {
  String? id,
      attachmentParaf,
      attachmentKtp,
      attachmentNpwp,
      attachmentOmzet,
      attachmentLokasi;

  PosMaterialAttachment({
    this.id,
    this.attachmentParaf,
    this.attachmentKtp,
    this.attachmentNpwp,
    this.attachmentOmzet,
    this.attachmentLokasi,
  });

  PosMaterialAttachment.fromJson(Map json)
      : id = json['id_pos_material'],
        attachmentParaf = json['attachment_desain_paraf'],
        attachmentKtp = json['attachment_ktp'],
        attachmentNpwp = json['attachment_npwp'],
        attachmentOmzet = json['attachment_omzet'],
        attachmentLokasi = json['attachment_rencana_lokasi'];

  Map toJson() {
    return {
      'id_pos_material': id,
      'attachment_desain_paraf': attachmentParaf,
      'attachment_ktp': attachmentKtp,
      'attachment_npwp': attachmentNpwp,
      'attachment_omzet': attachmentOmzet,
      'attachment_rencana_lokasi': attachmentLokasi
    };
  }
}
