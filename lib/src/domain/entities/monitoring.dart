class Monitoring {
  String idContract, idCustomer, namaKedua, alamatKedua, telpKedua, startDateContract, endDateContract,
  namaUsaha, customerShipName, status;

  Monitoring.fromJson(Map json):
   idContract = json['id'],
   idCustomer = json['id_customer'],
   namaKedua = json['nama_kedua'],
   alamatKedua = json['alamat_kedua'],
   telpKedua = json['telp_kedua'],
   startDateContract = json['start_contract'],
   endDateContract = json['end_contract'],
   namaUsaha = json['nama_usaha'],
   customerShipName = json['customer_ship_name'],
   status = json['status'];

   Map toJson(){
     return {
       'id' : idContract,
       'id_customer' : idCustomer,
       'nama_kedua' : namaKedua,
       'alamat_kedua' : alamatKedua,
       'telp_kedua' : telpKedua,
       'start_contract' : startDateContract,
       'end_contract' : endDateContract,
       'nama_usaha' : namaUsaha,
       'customer_ship_name' : customerShipName,
       'status': status
     };
   }
}