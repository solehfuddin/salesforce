import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  TextEditingController textPathKartuNama = new TextEditingController();
  TextEditingController textPathPendukung = new TextEditingController();
  String _chosenValue;
  String _chosenBilling;
  final format = DateFormat("yyyy-MM-dd");
  String base64ImageKtp, signedImage;
  File tmpFile, tmpSiupFile, tmpKartuFile, tmpPendukungFile;
  String tmpName,
      tmpNameSiup,
      tmpKartuNama,
      tmpPendukung,
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
  String base64ImageKartuNama = '';
  String base64ImagePendukung = '';
  String kosong = "";
  bool _isNamaUser = false;
  bool _isTanggalLahir = false;
  bool _isTempatLahir = false;
  bool _isAlamat = false;
  bool _isTlpHp = false;
  bool _isTlpHpValid = false;
  bool _isFaxUserValid = false;
  bool _isNoIdentitas = false;
  bool _isNoIdentitasValid = false;
  bool _isNamaOptik = false;
  bool _isAlamatUsaha = false;
  bool _isTlpUsaha = false;
  bool _isTlpUsahaValid = false;
  bool _isFaxUsahaValid = false;
  bool _isNamaPic = false;
  bool _isEmailValid = true;
  bool _isFotoKtp = false;
  Map<String, TextEditingController> myMap;

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

    myMap = {'nama': textNamaOptik};
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
      source: ImageSource.gallery,
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
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    setState(() {
      if (imgFile != null) {
        tmpSiupFile = File(imgFile.path);
        tmpNameSiup = tmpSiupFile.path.split('/').last;
        base64ImageSiup = base64Encode(Io.File(imgFile.path).readAsBytesSync());

        print(imgFile.path);
        print(base64ImageSiup);
      }
    });
  }

  Future chooseKartuNama() async {
    var imgFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    setState(() {
      if (imgFile != null) {
        tmpKartuFile = File(imgFile.path);
        tmpKartuNama = tmpKartuFile.path.split('/').last;
        base64ImageKartuNama =
            base64Encode(Io.File(imgFile.path).readAsBytesSync());

        print(imgFile.path);
        print(base64ImageKartuNama);
      }
    });
  }

  Future choosePendukung() async {
    var imgFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    setState(() {
      if (imgFile != null) {
        tmpPendukungFile = File(imgFile.path);
        tmpPendukung = tmpPendukungFile.path.split('/').last;
        base64ImagePendukung =
            base64Encode(Io.File(imgFile.path).readAsBytesSync());

        print(imgFile.path);
        print(base64ImagePendukung);
      }
    });
  }

  Widget showKtp() {
    tmpName == null
        ? textPathKtp.text = 'Gambar ktp belum dipilih'
        : textPathKtp.text = tmpName;

    return Flexible(
      child: TextFormField(
        enabled: false,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Dokumen Ktp  (Wajib diisi)',
          labelText: 'Dokumen Ktp  (Wajib diisi)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        controller: textPathKtp,
      ),
    );
  }

  Widget showSiup() {
    tmpNameSiup == null
        ? textPathSiup.text = 'Gambar siup belum dipilih'
        : textPathSiup.text = tmpNameSiup;

    return Flexible(
      child: TextFormField(
        enabled: false,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Dokumen Siup',
          labelText: 'Dokumen Siup',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        controller: textPathSiup,
      ),
    );
  }

  Widget showKartuNama() {
    tmpKartuNama == null
        ? textPathKartuNama.text = 'Gambar kartu nama belum dipilih'
        : textPathKartuNama.text = tmpKartuNama;

    return Flexible(
      child: TextFormField(
        enabled: false,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Dokumen Kartu Nama',
          labelText: 'Dokumen Kartu Nama',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        controller: textPathKartuNama,
      ),
    );
  }

  Widget showPendukung() {
    tmpPendukung == null
        ? textPathPendukung.text = 'Gambar pendukung belum dipilih'
        : textPathPendukung.text = tmpPendukung;

    return Flexible(
      child: TextFormField(
        enabled: false,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Dokumen Pendukung',
          labelText: 'Dokumen Pendukung',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        controller: textPathPendukung,
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
    textTelpUser.text.length >= 12
        ? _isTlpHpValid = false
        : _isTlpHpValid = true;
    textIdentitas.text.isEmpty ? _isNoIdentitas = true : _isNoIdentitas = false;
    textIdentitas.text.length < 16
        ? _isNoIdentitasValid = true
        : _isNoIdentitasValid = false;

    textNamaOptik.text.isEmpty ? _isNamaOptik = true : _isNamaOptik = false;
    textAlamatOptik.text.isEmpty
        ? _isAlamatUsaha = true
        : _isAlamatUsaha = false;
    textTelpOptik.text.isEmpty ? _isTlpUsaha = true : _isTlpUsaha = false;
    textTelpOptik.text.length < 10
        ? _isTlpUsahaValid = true
        : _isTlpUsahaValid = false;
    textFaxOptik.text.isEmpty
        ? _isFaxUsahaValid = false
        : textFaxOptik.text.length < 10
            ? _isFaxUsahaValid = true
            : _isFaxUsahaValid = false;
    textFaxUser.text.isEmpty
        ? _isFaxUserValid = false
        : textFaxUser.text.length < 10
            ? _isFaxUserValid = true
            : _isFaxUserValid = false;
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

    print(textNamaOptik.text);

    if (!_isNamaUser &&
        !_isTempatLahir &&
        !_isTanggalLahir &&
        !_isAlamat &&
        !_isTlpHp &&
        !_isTlpHpValid &&
        !_isNoIdentitas &&
        !_isNoIdentitasValid &&
        !_isNamaOptik &&
        !_isAlamatUsaha &&
        !_isTlpUsaha &&
        !_isTlpUsahaValid &&
        !_isFaxUsahaValid &&
        !_isFaxUserValid &&
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
      }
    } else {
      handleStatus(context, 'Harap lengkapi data terlebih dahulu', false);
      stop();
    }
  }

  simpanData(Function stop) async {
    const timeout = 15;
    var url = 'http://timurrayalab.com/salesforce/server/api/customers';

    try {
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
        'gambar_kartu_nama': base64ImageKartuNama,
        'gambar_pendukung': base64ImagePendukung,
        'upload_dokumen': base64ImageSiup,
        'ttd_customer': signedImage,
        'nama_salesman': username.toUpperCase(),
        'note': note.toUpperCase(),
        'created_by': id,
      },
    ).timeout(Duration(seconds: timeout));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    var res = json.decode(response.body);
    final bool sts = res['status'];
    final String msg = res['message'];

    handleStatus(context, capitalize(msg), sts);
    } on TimeoutException catch(e){
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch(e){
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch(e){
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }

    stop();
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
            fontSize: 18.sp,
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
            size: 18.r,
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
        15.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A. DATA BADAN USAHA',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Segoe ui',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nama Optik/Dr/RS/Klinik/PT/dll',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Optik Timur',
              // labelText: 'Nama Optik/Dr/RS/Klinik/PT/dll',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isNamaOptik ? 'Data wajib diisi' : null,
              // errorText: textNamaOptik.text.isEmpty ? 'Data wajib diisi' : null,
            ),
            maxLength: 100,
            controller: textNamaOptik,
          ),
          SizedBox(
            height: 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alamat',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  // color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Jl Kebangsaan no 57 Jakarta',
              // labelText: 'Alamat',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isAlamatUsaha ? 'Data wajib diisi' : null,
            ),
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 4,
            maxLength: 250,
            controller: textAlamatOptik,
          ),
          SizedBox(
            height: 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nomor Telp',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  // color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '02112XXX',
              // labelText: 'Telp',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isTlpUsaha
                  ? 'Data wajib diisi'
                  : _isTlpUsahaValid
                      ? 'Nomor telpon salah'
                      : null,
            ),
            maxLength: 10,
            controller: textTelpOptik,
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            'Nomor Fax',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '02112XXX',
              // labelText: 'Fax',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isFaxUsahaValid ? 'Nomor fax salah' : null,
            ),
            maxLength: 10,
            controller: textFaxOptik,
          ),
          SizedBox(
            height: 3.h,
          ),
          Text(
            'Alamat Email',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.none,
            decoration: InputDecoration(
              hintText: 'nama@email.com',
              // labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: !_isEmailValid ? 'Alamat email salah' : null,
            ),
            maxLength: 40,
            controller: textEmailOptik,
          ),
          SizedBox(
            height: 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nama Penanggung Jawab di tempat',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  // color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'John Doe',
              // labelText: 'Nama Penanggung Jawab di tempat',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isNamaPic ? 'Data wajib diisi' : null,
            ),
            maxLength: 50,
            controller: textPicOptik,
          ),
          SizedBox(
            height: 5.h,
          ),
        ],
      ),
    );
  }

  Widget _areaDataPribadi() {
    return Container(
      padding: EdgeInsets.all(15.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'B. DATA PRIBADI',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Segoe ui',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nomor SIM/KTP',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  // color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '317210XXXXXXXXXXX',
              // labelText: 'Nomor SIM/KTP',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isNoIdentitas
                  ? 'Data wajib diisi'
                  : _isNoIdentitasValid
                      ? 'Nomor ktp salah'
                      : null,
            ),
            maxLength: 16,
            controller: textIdentitas,
          ),
          SizedBox(
            height: 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nama Pelanggan/Pemilik',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  // color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'John Doe',
              // labelText: 'Nama Pelanggan/Pemilik',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isNamaUser ? 'Data wajib diisi' : null,
            ),
            maxLength: 50,
            controller: textNamaUser,
          ),
          SizedBox(
            height: 12.h,
          ),
          Text(
            'Agama',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 7.r),
            decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(5.r)),
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
                    fontSize: 16.sp,
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
            height: 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tempat Lahir',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  // color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Jakarta',
              // labelText: 'Tempat Lahir',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isTempatLahir ? 'Data wajib diisi' : null,
            ),
            maxLength: 25,
            controller: textTempatLahir,
          ),
          SizedBox(
            height: 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tanggal Lahir',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  // color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          DateTimeField(
            decoration: InputDecoration(
              hintText: 'yyyy-mm-dd',
              // labelText: 'Tanggal Lahir',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isTanggalLahir ? 'Data wajib diisi' : null,
            ),
            maxLength: 10,
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
            height: 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alamat Tempat Tinggal',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  // color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Jl Kebangsaan no 57 Jakarta',
              // labelText: 'Alamat Tempat Tinggal',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isAlamat ? 'Data wajib diisi' : null,
            ),
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 4,
            maxLength: 250,
            controller: textAlamatUser,
          ),
          SizedBox(
            height: 12.sp,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nomor Hp',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  // color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '0857XXXXXXXX',
              // labelText: 'Telp / Hp',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isTlpHp
                  ? 'Data wajib diisi'
                  : _isTlpHpValid
                      ? 'Nomor hp salah'
                      : null,
            ),
            maxLength: 13,
            controller: textTelpUser,
          ),
          SizedBox(
            height: 3.h,
          ),
          Text(
            'Fax',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Fax',
              labelText: 'Fax',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isFaxUserValid ? 'Nomor fax salah' : null,
            ),
            maxLength: 10,
            controller: textFaxUser,
          ),
          SizedBox(
            height: 5.h,
          ),
        ],
      ),
    );
  }

  Widget _areaDataTambahan() {
    return Container(
      padding: EdgeInsets.all(
        15.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'C. DATA TAMBAHAN',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Segoe ui',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            'Jenis Pembayaran',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 7.r),
            decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(5.r)),
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
                    fontSize: 16.sp,
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
            height: 12.h,
          ),
          Text(
            'Kredit Limit',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'XX.XXX.XXX',
              // labelText: 'Kredit Limit',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            minLines: 1,
            maxLines: 3,
            maxLength: 15,
            controller: textKreditLimit,
          ),
          SizedBox(
            height: 12.h,
          ),
          Text(
            'Catatan',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Isi catatan',
              // labelText: 'Catatan',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 4,
            maxLength: 250,
            controller: textCatatan,
          ),
          SizedBox(
            height: 5.h,
          ),
        ],
      ),
    );
  }

  Widget _areaDokumenPelengkap() {
    return Container(
      padding: EdgeInsets.all(
        15.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'D. DOKUMEN PELENGKAP',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Segoe ui',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showKtp(),
              SizedBox(
                width: 15.w,
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
                  iconSize: 27.r,
                  onPressed: () {
                    chooseImage();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showSiup(),
              SizedBox(
                width: 15.w,
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
                  iconSize: 27.r,
                  onPressed: () {
                    chooseSiup();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showKartuNama(),
              SizedBox(
                width: 15.w,
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
                  iconSize: 27.r,
                  onPressed: () {
                    chooseKartuNama();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showPendukung(),
              SizedBox(
                width: 15.w,
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
                  iconSize: 27.r,
                  onPressed: () {
                    choosePendukung();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5.h,
          ),
        ],
      ),
    );
  }

  Widget _areaSignSubmit() {
    return Container(
      padding: EdgeInsets.all(15.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'E. TTD CUSTOMER',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Segoe ui',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          Signature(
            controller: _signController,
            height: 150.h,
            backgroundColor: Colors.blueGrey.shade50,
          ),
          SizedBox(
            height: 15.h,
          ),
          Text(
            'Dengan menandatangani dokumen ini secara elektronik, saya setuju bahwa tanda tangan tersebut akan sama validnya dengan tanda tangan tulisan sesuai hukum setempat',
            style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                color: Colors.black87),
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: 20.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  primary: Colors.orange[800],
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.r, vertical: 10.r),
                ),
                child: Text(
                  'Hapus Ttd',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Segoe ui',
                  ),
                ),
                onPressed: () {
                  _signController.clear();
                },
              ),
              ArgonButton(
                height: 40.h,
                width: 100.w,
                borderRadius: 30.0.r,
                color: Colors.blue[700],
                child: Text(
                  "Simpan",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700),
                ),
                loader: Container(
                  padding: EdgeInsets.all(8.r),
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
            height: 10.h,
          ),
        ],
      ),
    );
  }
}
