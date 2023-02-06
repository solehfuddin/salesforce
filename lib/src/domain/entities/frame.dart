class Frame {
  String? frameid, frameName, status, qty;
  bool ischecked = false;
  
  Frame(this.frameid, this.frameName, this.status, this.qty);

  Frame.fromJson(Map json):
    frameid = json['id'],
    frameName = json['nama_brand'],
    status = json['status'];

  Map toJson() {
    return {
      'id' : frameid,
      'nama_brand' : frameName,
      'status' : status
    };
  }
}