class Salesact {
  String actId,
      salesId,
      salesName,
      agenda,
      optik,
      timeStart,
      spFrame,
      spLensaStock,
      lainnya,
      feedback,
      mengetahui,
      areaManager,
      salesToken;

  Salesact.fromJson(Map json)
      : actId = json['id'],
        salesId = json['sales_id'],
        salesName = json['sales_name'],
        agenda = json['agenda'],
        optik = json['optik'],
        timeStart = json['time_start'],
        spFrame = json['sp_frame'] ?? '0',
        spLensaStock = json['sp_lensa_stock'] ?? '0',
        lainnya = json['lainnya'],
        feedback = json['feedback'] ?? '',
        mengetahui = json['mengetahui'],
        areaManager = json['area_manager'] ?? '',
        salesToken = json['gentoken'] ?? '';

  Map toJson() {
    return {
      'id' : actId,
      'sales_id': salesId,
      'sales_name': salesName,
      'agenda': agenda,
      'optik': optik,
      'time_start': timeStart,
      'sp_frame': spFrame,
      'sp_lensa_stock': spLensaStock,
      'lainnya': lainnya,
      'feedback' : feedback,
      'mengetahui' : mengetahui,
      'area_manager' : areaManager,
      'gentoken' : salesToken,
    };
  }
}
