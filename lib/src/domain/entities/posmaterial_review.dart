class PosMaterialReview {
  String? total, posAllocation, review;
  bool? status;
  double? posEstimation;

  PosMaterialReview({this.total, this.posAllocation, this.posEstimation, this.status, this.review});

  PosMaterialReview.fromJson(Map<String, dynamic> json) 
  : total = json['total_penjualan'] ?? '',
    posAllocation = json['max_alokasipos'] ?? '',
    posEstimation = json['perc_estimasipos'] ?? 0,
    status = json['status_pos'] ?? false,
    review = json['kesimpulan_pos'] ?? '';
    
  Map toJson() {
    return {
      'total_penjualan' : total,
      'max_alokasipos'  : posAllocation,
      'perc_estimasipos': posEstimation,
      'status_pos'      : status,
      'kesimpulan_pos'  : review,
    };
  }
}