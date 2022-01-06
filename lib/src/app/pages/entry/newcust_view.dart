import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:signature/signature.dart';

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
  TextEditingController textPathKtp = new TextEditingController();
  TextEditingController textPathSiup = new TextEditingController();
  String _chosenValue;
  String _chosenBilling;
  final format = DateFormat("yyyy-MM-dd");
  String base64Image;
  File tmpFile, tmpSiupFile;
  String tmpName, tmpNameSiup;
  String errMessage = 'Error Uploading Image';
  bool _isNamaOptik = false;

  final SignatureController _signController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _signController.addListener(() => print('Value changed'));
  }

  Future chooseImage() async {
    var imgFile = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      if (imgFile != null) {
        tmpFile = File(imgFile.path);
        tmpName = tmpFile.path.split('/').last;
        base64Image = base64Encode(Io.File(imgFile.path).readAsBytesSync());

        print(imgFile.path);
        print(base64Image);
      }
    });
  }

  Future chooseSiup() async {
    var imgFile = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      if (imgFile != null) {
        tmpSiupFile = File(imgFile.path);
        tmpNameSiup = tmpFile.path.split('/').last;
        base64Image = base64Encode(Io.File(imgFile.path).readAsBytesSync());

        print(imgFile.path);
        print(base64Image);
      }
    });
  }

  Widget showKtp() {
    tmpName == null
        ? textPathKtp.text = 'Foto ktp belum dipilih'
        : textPathKtp.text = tmpName;

    return Flexible(
      child: TextFormField(
        enabled: false,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Foto Ktp',
          labelText: 'Foto Ktp',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        controller: textPathKtp,
      ),
    );
  }

  Widget showSiup() {
    tmpNameSiup == null
        ? textPathKtp.text = 'Foto siup belum dipilih'
        : textPathKtp.text = tmpNameSiup;

    return Flexible(
      child: TextFormField(
        enabled: false,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Foto Siup',
          labelText: 'Foto Siup',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        controller: textPathKtp,
      ),
    );
  }

  saveData() async {
    textNamaOptik.text.isEmpty ? _isNamaOptik = true : _isNamaOptik = false;
    // textPassword.text.isEmpty ? _isPassword = true : _isPassword = false;

    if (_isNamaOptik) {
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
          'upload_identitas': base64Image,
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
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
            _areaBadanUsaha(),
            _areaDataPribadi(),
            _areaDataTambahan(),
            _areaDokumenPelengkap(),
            _areaSignSubmit(),
          ],
        ),
      ),
    );
  }

  Widget _areaBadanUsaha() {
    return Container(
      padding: EdgeInsets.all(
        15,
      ),
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
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget _areaDataPribadi() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  child: Text(e, style: TextStyle(color: Colors.black54)),
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
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget _areaDataTambahan() {
    return Container(
      padding: EdgeInsets.all(
        15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  child: Text(e, style: TextStyle(color: Colors.black54)),
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
            controller: textCatatan,
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget _areaDokumenPelengkap() {
    return Container(
      padding: EdgeInsets.all(
        15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'D. DOKUMEN PELENGKAP',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showKtp(),
              SizedBox(
                width: 15,
              ),
              Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blue,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                  ),
                  iconSize: 30,
                  onPressed: () {
                    chooseImage();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showSiup(),
              SizedBox(
                width: 15,
              ),
              Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blue,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                  ),
                  iconSize: 30,
                  onPressed: () {
                    chooseSiup();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget _areaSignSubmit() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'E. TTD CUSTOMER',
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
          Signature(
            controller: _signController,
            height: 150,
            backgroundColor: Colors.blueGrey.shade50,
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
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
    );
  }
}
