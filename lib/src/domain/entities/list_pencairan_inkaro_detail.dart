class ListPencairanInkaroDetail {
  String nomorPencairan, namaPenerima, noRekening, bank, descBank, totalInkaro;

  ListPencairanInkaroDetail.fromJson(Map json)
      : nomorPencairan = json['ID_PENCAIRAN'] ?? '',
        namaPenerima = json['NAMA_PENERIMA'] ?? '',
        noRekening = json['NO_REKENING'] ?? '',
        bank = json['BANK'] ?? '',
        descBank = json['DESC_BANK'] ?? '',
        totalInkaro = json['TOTAL_INKARO'] ?? '';

  Map toJson() {
    return {
      'ID_PENCAIRAN': nomorPencairan,
      'NAMA_PENERIMA': namaPenerima,
      'NO_REKENING': noRekening,
      'BANK': bank,
      'DESC_BANK': descBank,
      'TOTAL_INKARO': totalInkaro
    };
  }
}
