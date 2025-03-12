class OmzetOptic {
  String? leinzRx, leinzStock, oriRx, oriStock, totalPenjualan, maxPos;

  OmzetOptic({this.leinzRx, this.leinzStock, this.oriRx, this.oriStock, this.totalPenjualan, this.maxPos});

  OmzetOptic.fromJson(Map<String, dynamic> json) 
  : leinzRx = json['leinzrx'] ?? '',
    leinzStock = json['leinzstock'] ?? '',
    oriRx = json['orirx'] ?? '',
    oriStock = json['orist'] ?? '',
    totalPenjualan = json['total_penjualan'] ?? '',
    maxPos = json['max_pos'] ?? '';
    
  Map toJson() {
    return {
      'leinzrx'         : leinzRx,
      'leinzstock'      : leinzStock,
      'orirx'           : oriRx,
      'orist'           : oriStock,
      'total_penjualan' : totalPenjualan,
      'max_pos'         : maxPos,
    };
  }
}