import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String base64ImageKtp, signedImage;
  File tmpFile, tmpSiupFile;
  String tmpName,
      tmpNameSiup,
      namaUser,
      tempatLahir,
      tanggalLahir,
      alamat,
      tlpHp,
      faxUsaha,
      noIdentitas;
  String namaOptik, alamatUsaha, tlpUsaha, emailUsaha, namaPic, fax;
  String sistemPembayaran, kreditLimit, note;
  String errMessage = 'Error Uploading Image';
  String id = '';
  String role = '';
  String username = '';
  String base64ImageSiup = '';
  String kosong = "";
  bool _isNamaUser = false;
  bool _isTanggalLahir = false;
  bool _isTempatLahir = false;
  bool _isAlamat = false;
  bool _isTlpHp = false;
  bool _isNoIdentitas = false;
  bool _isNamaOptik = false;
  bool _isAlamatUsaha = false;
  bool _isTlpUsaha = false;
  bool _isNamaPic = false;
  bool _isEmailValid = true;
  bool _isFotoKtp = false;

  final SignatureController _signController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    getRole();
    _signController.addListener(() => print('Value changed'));
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");

      print("Dashboard : $role");
    });
  }

  Future chooseImage() async {
    var imgFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      imageQuality: 25,
    );
    setState(() {
      if (imgFile != null) {
        tmpFile = File(imgFile.path);
        tmpName = tmpFile.path.split('/').last;
        base64ImageKtp = base64Encode(Io.File(imgFile.path).readAsBytesSync());

        print(imgFile.path);
        print(base64ImageKtp);
      }
    });
  }

  Future chooseSiup() async {
    var imgFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      imageQuality: 25,
    );
    setState(() {
      if (imgFile != null) {
        tmpSiupFile = File(imgFile.path);
        tmpNameSiup = tmpFile.path.split('/').last;
        base64ImageSiup = base64Encode(Io.File(imgFile.path).readAsBytesSync());

        print(imgFile.path);
        print(base64ImageSiup);
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
          // errorText: _isFotoKtp ? 'Harap ambil foto ktp' : null,
        ),
        controller: textPathKtp,
      ),
    );
  }

  Widget showSiup() {
    tmpNameSiup == null
        ? textPathSiup.text = 'Foto siup belum dipilih'
        : textPathSiup.text = tmpNameSiup;

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
        controller: textPathSiup,
      ),
    );
  }

  checkEntry(Function stop) async {
    textNamaUser.text.isEmpty ? _isNamaUser = true : _isNamaUser = false;
    textTempatLahir.text.isEmpty
        ? _isTempatLahir = true
        : _isTempatLahir = false;
    textTanggalLahir.text.isEmpty
        ? _isTanggalLahir = true
        : _isTanggalLahir = false;
    textAlamatUser.text.isEmpty ? _isAlamat = true : _isAlamat = false;
    textTelpUser.text.isEmpty ? _isTlpHp = true : _isTlpHp = false;
    textIdentitas.text.isEmpty ? _isNoIdentitas = true : _isNoIdentitas = false;

    textNamaOptik.text.isEmpty ? _isNamaOptik = true : _isNamaOptik = false;
    textAlamatOptik.text.isEmpty
        ? _isAlamatUsaha = true
        : _isAlamatUsaha = false;
    textTelpOptik.text.isEmpty ? _isTlpUsaha = true : _isTlpUsaha = false;
    textPicOptik.text.isEmpty ? _isNamaPic = true : _isNamaPic = false;

    tmpName == null ? _isFotoKtp = true : _isFotoKtp = false;
    if (base64ImageSiup == null) {
      base64ImageSiup = kosong;
    }

    namaUser = textNamaUser.text;
    tempatLahir = textTempatLahir.text;
    tanggalLahir = textTanggalLahir.text;
    alamat = textAlamatUser.text;
    tlpHp = textTelpUser.text;
    faxUsaha = textFaxOptik.text;
    noIdentitas = textIdentitas.text;

    namaOptik = textNamaOptik.text;
    alamatUsaha = textAlamatOptik.text;
    tlpUsaha = textTelpOptik.text;
    emailUsaha = textEmailOptik.text;
    namaPic = textPicOptik.text;
    fax = textFaxUser.text;

    if (emailUsaha.isNotEmpty) {
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(emailUsaha)
          ? _isEmailValid = true
          : _isEmailValid = false;
    }

    if (_chosenValue == null) {
      _chosenValue = 'Islam';
    }

    if (_chosenBilling == null) {
      _chosenBilling = 'Cash & Carry';
    }

    sistemPembayaran = _chosenBilling;
    kreditLimit = textKreditLimit.text;
    note = textCatatan.text;

    if (_signController.isNotEmpty) {
      var data = await _signController.toPngBytes();
      signedImage = base64Encode(data);
      print(signedImage);
    }

    if (!_isNamaUser &&
        !_isTempatLahir &&
        !_isTanggalLahir &&
        !_isAlamat &&
        !_isTlpHp &&
        !_isNoIdentitas &&
        !_isNamaOptik &&
        !_isAlamatUsaha &&
        !_isTlpUsaha &&
        !_isNamaPic) {
      if (_isFotoKtp) {
        handleStatus(context, 'Silahkan foto ktp terlebih dahulu', false);
        stop();
      } else if (_signController.isEmpty) {
        handleStatus(context, 'Silahkan tanda tangan terlebih dahulu', false);
        stop();
      } else {
        var data = await _signController.toPngBytes();
        signedImage = base64Encode(data);
        print(signedImage);

        if (base64ImageSiup == null) {
          base64ImageSiup = 'kosong';
        }
        simpanData(stop);

        // stop();
        // print(kreditLimit.replaceAll('.', ''));
      }
    } else {
      handleStatus(context, 'Harap lengkapi data terlebih dahulu', false);
      stop();
    }
  }

  simpanData(Function stop) async {
    var url = 'http://timurrayalab.com/salesforce/server/api/customers';
    var response = await http.post(
      url,
      body: {
        'nama': namaUser.toUpperCase(),
        'agama': _chosenValue.toUpperCase(),
        'tempat_lahir': tempatLahir.toUpperCase(),
        'tanggal_lahir': tanggalLahir,
        'alamat': alamat.toUpperCase(),
        'no_telp': tlpHp,
        'fax': fax,
        'no_identitas': noIdentitas,
        'upload_identitas': base64ImageKtp,
        'nama_usaha': namaOptik.toUpperCase(),
        'alamat_usaha': alamatUsaha.toUpperCase(),
        'telp_usaha': tlpUsaha,
        'fax_usaha': faxUsaha,
        'email_usaha': emailUsaha,
        'nama_pj': namaPic.toUpperCase(),
        'sistem_pembayaran': sistemPembayaran,
        'kredit_limit': kreditLimit.replaceAll('.', ''),
        'upload_dokumen': base64ImageSiup,
        'ttd_customer': signedImage,
        'nama_salesman': username.toUpperCase(),
        'note': note.toUpperCase(),
        'created_by': id,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    var res = json.decode(response.body);
    final bool sts = res['status'];
    final String msg = res['message'];

    stop();
    handleStatus(context, capitalize(msg), sts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Data Entry Customer Baru',
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
              hintText: 'Nama *',
              labelText: 'Nama Optik/Dr/RS/Klinik/PT/dll *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              errorText: _isNamaOptik ? 'Data wajib diisi' : null,
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
              errorText: _isAlamatUsaha ? 'Data wajib diisi' : null,
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
              errorText: _isTlpUsaha ? 'Data wajib diisi' : null,
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
              errorText: !_isEmailValid ? 'Alamat email salah' : null,
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
              errorText: _isNamaPic ? 'Data wajib diisi' : null,
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
              labelText: 'Nomor SIM/KTP',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              errorText: _isNoIdentitas ? 'Data wajib diisi' : null,
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
              errorText: _isNamaUser ? 'Data wajib diisi' : null,
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
              errorText: _isTempatLahir ? 'Data wajib diisi' : null,
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
              errorText: _isTanggalLahir ? 'Data wajib diisi' : null,
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
              errorText: _isAlamat ? 'Data wajib diisi' : null,
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
              errorText: _isTlpHp ? 'Data wajib diisi' : null,
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
            inputFormatters: [ThousandsSeparatorInputFormatter()],
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
                  iconSize: 27,
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
                  iconSize: 27,
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
            height: 15,
          ),
          Signature(
            controller: _signController,
            height: 150,
            backgroundColor: Colors.blueGrey.shade50,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Dengan menandatangani dokumen ini secara elektronik, saya setuju bahwa tanda tangan tersebut akan sama validnya dengan tanda tangan tulisan sesuai hukum setempat',
            style: TextStyle(
                fontSize: 13,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                color: Colors.black87),
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  primary: Colors.orange[800],
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Hapus Ttd',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Segoe ui',
                  ),
                ),
                onPressed: () {
                  _signController.clear();
                },
              ),
              ArgonButton(
                height: 40,
                width: 100,
                borderRadius: 30.0,
                color: Colors.blue[700],
                child: Text(
                  "Simpan",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                loader: Container(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                onTap: (startLoading, stopLoading, btnState) {
                  if (btnState == ButtonState.Idle) {
                    setState(() {
                      startLoading();
                      waitingLoad();
                      checkEntry(stopLoading);
                      // stopLoading();
                    });
                  }
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
