import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class NewcustScreen extends StatefulWidget {
  @override
  _NewcustScreenState createState() => _NewcustScreenState();
}

class _NewcustScreenState extends State<NewcustScreen> {
  TextEditingController textNamaOptik = new TextEditingController();
  TextEditingController textAlamatOptik = new TextEditingController();
  TextEditingController textTelpOptik = new TextEditingController();
  TextEditingController textFaxOptik = new TextEditingController();
  TextEditingController textEmailOptik = new TextEditingController();
  TextEditingController textPicOptik = new TextEditingController();
  TextEditingController textIdentitas = new TextEditingController();
  TextEditingController textNamaUser = new TextEditingController();
  TextEditingController textAlamatUser = new TextEditingController();
  TextEditingController textTempatLahir = new TextEditingController();
  TextEditingController textTanggalLahir = new TextEditingController();
  TextEditingController textTelpUser = new TextEditingController();
  TextEditingController textFaxUser = new TextEditingController();
  TextEditingController textKreditLimit = new TextEditingController();
  TextEditingController textCatatan = new TextEditingController();
  String _chosenValue;
  String _chosenBilling;
  final format = DateFormat("yyyy-MM-dd");

  saveData() async {
    // textUsername.text.isEmpty ? _isUsername = true : _isUsername = false;
    // textPassword.text.isEmpty ? _isPassword = true : _isPassword = false;

    // print(textUsername.text);
    // print(textPassword.text);

    // username = textUsername.text;
    // password = textPassword.text;
    var url = 'http://timurrayalab.com/salesforce/server/api/customers';
    var response = await http.post(
      url,
      body: {
        'nama': textNamaUser.text,
        'agama': _chosenValue,
        'tempat_lahir': textTempatLahir.text,
        'tanggal_lahir': textTanggalLahir.text,
        'alamat': textAlamatUser.text,
        'no_telp': textTelpUser.text,
        'fax': textFaxUser.text,
        'no_identitas': textIdentitas.text,
        'nama_usaha': textNamaOptik.text,
        'alamat_usaha': textAlamatOptik.text,
        'telp_usaha': textTelpOptik.text,
        'email_usaha': textEmailOptik.text,
        'nama_pj': textPicOptik.text,
      },
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Create New Customer',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black54,
            size: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A. DATA BADAN USAHA',
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Segoe ui',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Nama',
                      labelText: 'Nama Optik/Dr/RS/Klinik/PT/dll',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    controller: textNamaOptik,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Alamat',
                      labelText: 'Alamat',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 3,
                    controller: textAlamatOptik,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Telp',
                      labelText: 'Telp',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    controller: textTelpOptik,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Fax',
                      labelText: 'Fax',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    controller: textFaxOptik,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    controller: textEmailOptik,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Nama Penanggung Jawab di tempat',
                      labelText: 'Nama Penanggung Jawab di tempat',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    controller: textPicOptik,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'B. DATA PRIBADI',
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Segoe ui',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Nomor SIM/KTP',
                      labelText: 'Nomor SIM/KTPk',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    controller: textIdentitas,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Nama Pelanggan/Pemilik',
                      labelText: 'Nama Pelanggan/Pemilik',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    controller: textNamaUser,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5)),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      value: _chosenValue,
                      style: TextStyle(color: Colors.black54),
                      items: [
                        'Islam',
                        'Katholik',
                        'Protestan',
                        'Hindu',
                        'Budha',
                        'Konghucu',
                        'Atheis',
                      ].map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child:
                              Text(e, style: TextStyle(color: Colors.black54)),
                        );
                      }).toList(),
                      hint: Text(
                        "Pilih Agama",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _chosenValue = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Tempat Lahir',
                      labelText: 'Tempat Lahir',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    controller: textTempatLahir,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DateTimeField(
                    decoration: InputDecoration(
                      hintText: 'Tanggal Lahir',
                      labelText: 'Tanggal Lahir',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    format: format,
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                    controller: textTanggalLahir,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Alamat Tempat Tinggal',
                      labelText: 'Alamat Tempat Tinggal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 3,
                    controller: textAlamatUser,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Telp / Hp',
                      labelText: 'Telp / Hp',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    controller: textTelpUser,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Fax',
                      labelText: 'Fax',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    controller: textFaxUser,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'C. DATA TAMBAHAN',
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Segoe ui',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5)),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      value: _chosenBilling,
                      style: TextStyle(color: Colors.black54),
                      items: [
                        'Cash & Carry',
                        'Transfer',
                        'Deposit',
                        'Bulanan',
                      ].map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child:
                              Text(e, style: TextStyle(color: Colors.black54)),
                        );
                      }).toList(),
                      hint: Text(
                        "Pilih Sistem Pembayaran",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _chosenBilling = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Kredit Limit',
                      labelText: 'Kredit Limit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    minLines: 1,
                    maxLines: 3,
                    controller: textKreditLimit,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Catatan',
                        labelText: 'Catatan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 3,
                      controller: textCatatan),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        primary: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onPressed: () {
                        saveData();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
