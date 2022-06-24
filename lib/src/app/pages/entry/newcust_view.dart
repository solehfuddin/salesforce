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

  Widget showKtp({bool isHorizontal}) {
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
        style: TextStyle(
          fontSize: isHorizontal ? 24.sp : 14.sp,
          fontFamily: 'Segoe Ui',
        ),
      ),
    );
  }

  Widget showSiup({bool isHorizontal}) {
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
        style: TextStyle(
          fontSize: isHorizontal ? 24.sp : 14.sp,
          fontFamily: 'Segoe Ui',
        ),
      ),
    );
  }

  Widget showKartuNama({bool isHorizontal}) {
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
        style: TextStyle(
          fontSize: isHorizontal ? 24.sp : 14.sp,
          fontFamily: 'Segoe Ui',
        ),
      ),
    );
  }

  Widget showPendukung({bool isHorizontal}) {
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
        style: TextStyle(
          fontSize: isHorizontal ? 24.sp : 14.sp,
          fontFamily: 'Segoe Ui',
        ),
      ),
    );
  }

  checkEntry(Function stop, {bool isHorizontal}) async {
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
      _chosenValue = 'ISLAM';
    }

    if (_chosenBilling == null) {
      _chosenBilling = 'CASH & CARRY';
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
        handleStatus(
          context,
          'Silahkan foto ktp terlebih dahulu',
          false,
          isHorizontal: isHorizontal,
        );
        stop();
      } else if (_signController.isEmpty) {
        handleStatus(
          context,
          'Silahkan tanda tangan terlebih dahulu',
          false,
          isHorizontal: isHorizontal,
        );
        stop();
      } else {
        var data = await _signController.toPngBytes();
        signedImage = base64Encode(data);
        print(signedImage);

        if (base64ImageSiup == null) {
          base64ImageSiup = 'kosong';
        }
        simpanData(stop, isHorizontal: isHorizontal);
      }
    } else {
      handleStatus(
        context,
        'Harap lengkapi data terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
      );
      stop();
    }
  }

  simpanData(Function stop, {bool isHorizontal}) async {
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

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (mounted) {
          handleStatus(
            context,
            capitalize(msg),
            sts,
            isHorizontal: isHorizontal,
          );
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
        if (mounted) {
          handleStatus(
            context,
            e.toString(),
            false,
            isHorizontal: isHorizontal,
          );
        }
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : $e');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
        );
      }
    }

    stop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childNewcust(isHorizontal: true);
      }

      return childNewcust(isHorizontal: false);
    });
  }

  Widget childNewcust({bool isHorizontal}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Data Entry Customer Baru',
          style: TextStyle(
            color: Colors.black54,
            fontSize: isHorizontal ? 28.sp : 18.sp,
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
            size: isHorizontal ? 28.sp : 18.r,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _areaBadanUsaha(isHorizontal: isHorizontal),
            _areaDataPribadi(isHorizontal: isHorizontal),
            _areaDataTambahan(isHorizontal: isHorizontal),
            _areaDokumenPelengkap(isHorizontal: isHorizontal),
            _areaSignSubmit(isHorizontal: isHorizontal),
          ],
        ),
      ),
    );
  }

  Widget _areaBadanUsaha({bool isHorizontal}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 30.r : 15.r,
        vertical: isHorizontal ? 20.r : 10.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A. DATA BADAN USAHA',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 25.h : 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nama Optik/Dr/RS/Klinik/PT/dll',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'OPTIK TIMUR',
              // labelText: 'Nama Optik/Dr/RS/Klinik/PT/dll',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isNamaOptik ? 'Data wajib diisi' : null,
              // errorText: textNamaOptik.text.isEmpty ? 'Data wajib diisi' : null,
            ),
            maxLength: 100,
            controller: textNamaOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.sp : 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alamat',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'JL KEBANGSAAN NO XXX JAKARTA',
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
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nomor Telp',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
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
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 15.h : 5.h,
          ),
          Text(
            'Nomor Fax',
            style: TextStyle(
              fontSize: isHorizontal ? 22.sp : 12.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
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
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          Text(
            'Alamat Email',
            style: TextStyle(
              fontSize: isHorizontal ? 22.sp : 12.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.none,
            decoration: InputDecoration(
              hintText: 'NAMA@EMAIL.COM',
              // labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: !_isEmailValid ? 'Alamat email salah' : null,
            ),
            maxLength: 40,
            controller: textEmailOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nama Penanggung Jawab di tempat',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'JOHN DOE',
              // labelText: 'Nama Penanggung Jawab di tempat',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isNamaPic ? 'Data wajib diisi' : null,
            ),
            maxLength: 50,
            controller: textPicOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 15.h : 5.h,
          ),
        ],
      ),
    );
  }

  Widget _areaDataPribadi({bool isHorizontal}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 30.r : 15.r,
        vertical: isHorizontal ? 20.r : 10.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'B. DATA PRIBADI',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 30.h : 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nomor SIM/KTP',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
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
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nama Pelanggan/Pemilik',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'JOHN DOE',
              // labelText: 'Nama Pelanggan/Pemilik',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isNamaUser ? 'Data wajib diisi' : null,
            ),
            maxLength: 50,
            controller: textNamaUser,
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          Text(
            'Agama',
            style: TextStyle(
              fontSize: isHorizontal ? 22.sp : 12.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
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
              style: TextStyle(
                color: Colors.black54,
                fontFamily: 'Segoe Ui',
                fontSize: isHorizontal ? 24.sp : 14.sp,
                fontWeight: FontWeight.w600,
              ),
              items: [
                'ISLAM',
                'KATHOLIK',
                'PROTESTAN',
                'HINDU',
                'BUDHA',
                'KONGHUCU',
                'ATHEIS',
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
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Segoe Ui'),
              ),
              onChanged: (String value) {
                setState(() {
                  _chosenValue = value;
                });
              },
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tempat Lahir',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'JAKARTA',
              // labelText: 'Tempat Lahir',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isTempatLahir ? 'Data wajib diisi' : null,
            ),
            maxLength: 25,
            controller: textTempatLahir,
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tanggal Lahir',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          DateTimeField(
            decoration: InputDecoration(
              hintText: 'yyyy-mm-dd',
              // labelText: 'Tanggal Lahir',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isTanggalLahir ? 'Data wajib diisi' : null,
              hintStyle: TextStyle(
                fontSize: isHorizontal ? 24.sp : 14.sp,
                fontFamily: 'Segoe Ui',
              ),
            ),
            maxLength: 10,
            format: format,
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                initialDate: currentValue ?? DateTime.now(),
                lastDate: DateTime(2100),
              );
            },
            controller: textTanggalLahir,
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alamat Tempat Tinggal',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'JL KEBANGSAAN NO XXX JAKARTA',
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
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.sp : 12.sp,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nomor Hp',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
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
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          Text(
            'Fax',
            style: TextStyle(
              fontSize: isHorizontal ? 22.sp : 12.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '021100XXX',
              labelText: 'Fax',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isFaxUserValid ? 'Nomor fax salah' : null,
            ),
            maxLength: 10,
            controller: textFaxUser,
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 15.h : 5.h,
          ),
        ],
      ),
    );
  }

  Widget _areaDataTambahan({bool isHorizontal}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 30.r : 15.r,
        vertical: isHorizontal ? 20.r : 10.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'C. DATA TAMBAHAN',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 10.h,
          ),
          Text(
            'Jenis Pembayaran',
            style: TextStyle(
              fontSize: isHorizontal ? 22.sp : 12.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
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
              style: TextStyle(
                color: Colors.black54,
                fontFamily: 'Segoe Ui',
                fontSize: isHorizontal ? 24.sp : 14.sp,
                fontWeight: FontWeight.w600,
              ),
              items: [
                'CASH & CARRY',
                'TRANSFER',
                'DEPOSIT',
                'BULANAN',
              ].map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: TextStyle(
                        color: Colors.black54,
                      )),
                );
              }).toList(),
              hint: Text(
                "Pilih Sistem Pembayaran",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: isHorizontal ? 24.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Segoe Ui',
                ),
              ),
              onChanged: (String value) {
                setState(() {
                  _chosenBilling = value;
                });
              },
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          Text(
            'Kredit Limit',
            style: TextStyle(
              fontSize: isHorizontal ? 22.sp : 12.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
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
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          Text(
            'Catatan',
            style: TextStyle(
              fontSize: isHorizontal ? 22.sp : 12.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'ISI CATATAN',
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
            style: TextStyle(
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 15.h : 5.h,
          ),
        ],
      ),
    );
  }

  Widget _areaDokumenPelengkap({bool isHorizontal}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 30.r : 15.r,
        vertical: isHorizontal ? 20.r : 10.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'D. DOKUMEN PELENGKAP',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 30.h : 20.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showKtp(isHorizontal: isHorizontal),
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
                  iconSize: isHorizontal ? 45.r : 27.r,
                  onPressed: () {
                    chooseImage();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 30.h : 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showSiup(isHorizontal: isHorizontal),
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
                  iconSize: isHorizontal ? 45.r : 27.r,
                  onPressed: () {
                    chooseSiup();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 30.h : 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showKartuNama(isHorizontal: isHorizontal),
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
                  iconSize: isHorizontal ? 45.r : 27.r,
                  onPressed: () {
                    chooseKartuNama();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 30.h : 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showPendukung(isHorizontal: isHorizontal),
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
                  iconSize: isHorizontal ? 45.r : 27.r,
                  onPressed: () {
                    choosePendukung();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 10.h : 5.h,
          ),
        ],
      ),
    );
  }

  Widget _areaSignSubmit({bool isHorizontal}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 30.r : 15.r,
        vertical: isHorizontal ? 20.r : 10.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'E. TTD CUSTOMER',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 30.h : 15.h,
          ),
          Signature(
            controller: _signController,
            height: isHorizontal ? 250.h : 150.h,
            backgroundColor: Colors.blueGrey.shade50,
          ),
          SizedBox(
            height: isHorizontal ? 30.h : 15.h,
          ),
          Text(
            'Dengan menandatangani dokumen ini secara elektronik, saya setuju bahwa tanda tangan tersebut akan sama validnya dengan tanda tangan tulisan sesuai hukum setempat',
            style: TextStyle(
                fontSize: isHorizontal ? 22.sp : 13.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                color: Colors.black87),
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: isHorizontal ? 30.h : 20.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  primary: Colors.orange[800],
                  padding: EdgeInsets.symmetric(
                    horizontal: isHorizontal ? 40.r : 20.r,
                    vertical: isHorizontal ? 20.r : 10.r,
                  ),
                ),
                child: Text(
                  'Hapus Ttd',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Segoe ui',
                  ),
                ),
                onPressed: () {
                  _signController.clear();
                },
              ),
              ArgonButton(
                height: isHorizontal ? 60.h : 40.h,
                width: isHorizontal ? 90.w : 100.w,
                borderRadius: isHorizontal ? 60.r : 30.r,
                color: Colors.blue[700],
                child: Text(
                  "Simpan",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isHorizontal ? 24.sp : 14.sp,
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
                      checkEntry(
                        stopLoading,
                        isHorizontal: isHorizontal,
                      );
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
