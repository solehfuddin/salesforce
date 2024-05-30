import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
// import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/app/widgets/syaratketentuan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class NewcustScreen extends StatefulWidget {
  @override
  _NewcustScreenState createState() => _NewcustScreenState();
}

class _NewcustScreenState extends State<NewcustScreen> {
  TextEditingController textNamaOptik = new TextEditingController();
  TextEditingController textAliasOptik = new TextEditingController();
  TextEditingController textAlamatOptik = new TextEditingController();
  TextEditingController textKotaOptik = new TextEditingController();
  TextEditingController textJenisUsaha = new TextEditingController();
  TextEditingController textTelpOptik = new TextEditingController();
  TextEditingController textFaxOptik = new TextEditingController();
  TextEditingController textEmailOptik = new TextEditingController();
  TextEditingController textPicOptik = new TextEditingController();
  TextEditingController textIdentitas = new TextEditingController();
  TextEditingController textNpwp = new TextEditingController();
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
  String _chosenValue = 'ISLAM';
  String _choosenUsaha = 'OPTIK';
  String _chosenBilling = 'COD';
  String _chosenKredit = '7 HARI';
  final format = DateFormat("dd MMM yyyy");
  String base64ImageKtp = '';
  String signedImage = '';
  late File tmpFile;
  late File tmpSiupFile;
  late File tmpKartuFile;
  late File tmpPendukungFile;
  String tmpName = '';
  String tmpNameSiup = '';
  String jenisUsaha = '';
  String tmpKartuNama = '';
  String tmpPendukung = '';
  String namaUser = '';
  String tempatLahir = '';
  String tanggalLahir = '';
  String alamat = '';
  String tlpHp = '';
  String faxUsaha = '';
  String noIdentitas = '';
  String noNpwp = '';
  String namaOptik = '';
  String kota = '';
  String alamatUsaha = '';
  String tlpUsaha = '';
  String emailUsaha = '';
  String namaPic = '';
  String fax = '';
  String sistemPembayaran = '';
  String kreditLimit = '';
  String note = '';
  String errMessage = 'Error Uploading Image';
  String? id = '';
  String? role = '';
  String? username = '';
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
  bool _isPlafonValid = false;
  bool _isNoIdentitas = false;
  bool _isNoIdentitasValid = false;
  bool _isNoNpwpValid = false;
  bool _isNamaOptik = false;
  bool _isKota = false;
  bool _isAlamatUsaha = false;
  bool _isTlpUsaha = false;
  bool _isTlpUsahaValid = false;
  bool _isFaxUsahaValid = false;
  bool _isNamaPic = false;
  bool _isEmailValid = true;
  bool _isFotoKtp = false;
  bool _isFotoPendukung = false;
  bool _isChecked = false;
  late Map<String, TextEditingController> myMap;

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
    var imgFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    setState(() {
      if (imgFile != null) {
        tmpFile = File(imgFile.path);
        tmpName = tmpFile.path.split('/').last;
        compressImage(File(imgFile.path)).then((value) {
          setState(() {
            base64ImageKtp =
                base64Encode(Io.File(value!.path).readAsBytesSync());
          });
        });

        print(imgFile.path);
        print(base64ImageKtp);
      }
    });
  }

  Future chooseSiup() async {
    var imgFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    setState(() {
      if (imgFile != null) {
        tmpSiupFile = File(imgFile.path);
        tmpNameSiup = tmpSiupFile.path.split('/').last;
        compressImage(File(imgFile.path)).then((value) {
          setState(() {
            base64ImageSiup =
                base64Encode(Io.File(value!.path).readAsBytesSync());
          });
        });

        // base64ImageSiup = base64Encode(Io.File(imgFile.path).readAsBytesSync());

        print(imgFile.path);
        print(base64ImageSiup);
      }
    });
  }

  Future chooseKartuNama() async {
    var imgFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    setState(() {
      if (imgFile != null) {
        tmpKartuFile = File(imgFile.path);
        tmpKartuNama = tmpKartuFile.path.split('/').last;
        compressImage(File(imgFile.path)).then((value) {
          setState(() {
            base64ImageKartuNama =
                base64Encode(Io.File(value!.path).readAsBytesSync());
          });
        });

        // base64ImageKartuNama =
        //     base64Encode(Io.File(imgFile.path).readAsBytesSync());
        print(imgFile.path);
        print(base64ImageKartuNama);
      }
    });
  }

  Future choosePendukung() async {
    var imgFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    setState(() {
      if (imgFile != null) {
        tmpPendukungFile = File(imgFile.path);
        tmpPendukung = tmpPendukungFile.path.split('/').last;
        compressImage(File(imgFile.path)).then((value) {
          setState(() {
            base64ImagePendukung =
                base64Encode(Io.File(value!.path).readAsBytesSync());
          });
        });

        // base64ImagePendukung =
        //     base64Encode(Io.File(imgFile.path).readAsBytesSync());

        print(imgFile.path);
        print(base64ImagePendukung);
      }
    });
  }

  Widget showKtp({bool isHorizontal = false}) {
    tmpName == ''
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
          fontSize: isHorizontal ? 18.sp : 14.sp,
          fontFamily: 'Segoe Ui',
        ),
      ),
    );
  }

  Widget showSiup({bool isHorizontal = false}) {
    tmpNameSiup == ''
        ? textPathSiup.text = 'Gambar siup / npwp belum dipilih'
        : textPathSiup.text = tmpNameSiup;

    return Flexible(
      child: TextFormField(
        enabled: false,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Dokumen Siup / Npwp',
          labelText: 'Dokumen Siup / Npwp',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        controller: textPathSiup,
        style: TextStyle(
          fontSize: isHorizontal ? 18.sp : 14.sp,
          fontFamily: 'Segoe Ui',
        ),
      ),
    );
  }

  Widget showKartuNama({bool isHorizontal = false}) {
    tmpKartuNama == ''
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
          fontSize: isHorizontal ? 18.sp : 14.sp,
          fontFamily: 'Segoe Ui',
        ),
      ),
    );
  }

  Widget showPendukung({bool isHorizontal = false}) {
    tmpPendukung == ''
        ? textPathPendukung.text = 'Gambar tampak depan optik belum dipilih'
        : textPathPendukung.text = tmpPendukung;

    return Flexible(
      child: TextFormField(
        enabled: false,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Dokumen Tampak Depan',
          labelText: 'Dokumen Tampak Depan',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        controller: textPathPendukung,
        style: TextStyle(
          fontSize: isHorizontal ? 18.sp : 14.sp,
          fontFamily: 'Segoe Ui',
        ),
      ),
    );
  }

  checkEntry(Function stop, {bool isHorizontal = false}) async {
    textNamaUser.text.isEmpty ? _isNamaUser = true : _isNamaUser = false;
    textKreditLimit.text.isEmpty
        ? _isPlafonValid = true
        : _isPlafonValid = false;
    textTempatLahir.text.isEmpty
        ? _isTempatLahir = true
        : _isTempatLahir = false;
    textTanggalLahir.text.isEmpty
        ? _isTanggalLahir = true
        : _isTanggalLahir = false;
    textAlamatUser.text.isEmpty ? _isAlamat = true : _isAlamat = false;
    textTelpUser.text.isEmpty ? _isTlpHp = true : _isTlpHp = false;
    textTelpUser.text.length >= 10
        ? _isTlpHpValid = false
        : _isTlpHpValid = true;
    textIdentitas.text.isEmpty ? _isNoIdentitas = true : _isNoIdentitas = false;
    textIdentitas.text.length < 16
        ? _isNoIdentitasValid = true
        : _isNoIdentitasValid = false;
    textNpwp.text.length > 0 && textNpwp.text.length < 15
        ? _isNoNpwpValid = true
        : _isNoNpwpValid = false;

    textNamaOptik.text.isEmpty ? _isNamaOptik = true : _isNamaOptik = false;
    textKotaOptik.text.isEmpty ? _isKota = true : _isKota = false;
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

    tmpName == '' ? _isFotoKtp = true : _isFotoKtp = false;
    tmpPendukung == '' ? _isFotoPendukung = true : _isFotoPendukung = false;
    if (base64ImageSiup == '') {
      base64ImageSiup = kosong;
    }

    namaUser = textNamaUser.text;
    tempatLahir = textTempatLahir.text;
    alamat = textAlamatUser.text;
    tlpHp = textTelpUser.text;
    faxUsaha = textFaxOptik.text;
    noIdentitas = textIdentitas.text;
    noNpwp = textNpwp.text;

    namaOptik = textNamaOptik.text;
    alamatUsaha = textAlamatOptik.text;
    kota = textKotaOptik.text;
    tlpUsaha = textTelpOptik.text;
    emailUsaha = textEmailOptik.text;
    namaPic = textPicOptik.text;
    fax = textFaxUser.text;

    if (emailUsaha.isNotEmpty) {
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(emailUsaha)
          ? _isEmailValid = true
          : _isEmailValid = false;
    } else {
      _isEmailValid = true;
    }

    if (_chosenValue == '') {
      _chosenValue = 'ISLAM';
    }

    if (_choosenUsaha == '') {
      _choosenUsaha = 'OPTIK';
    }

    if (_chosenBilling == '') {
      _chosenBilling = 'COD';
    }

    if (_chosenKredit == '') {
      _chosenKredit = '7 HARI';
    }

    sistemPembayaran = _chosenBilling == 'KREDIT'
        ? _chosenBilling + '-' + _chosenKredit
        : _chosenBilling;
    kreditLimit = textKreditLimit.text.length > 0
        ? '${textKreditLimit.text}.000.000'
        : '0';
    note = textCatatan.text;

    if (_signController.isNotEmpty) {
      var data = await _signController.toPngBytes();
      signedImage = base64Encode(data!);
      print(signedImage);
    }

    if (_choosenUsaha == "DLL") {
      jenisUsaha = textJenisUsaha.text.toUpperCase();
    } else {
      jenisUsaha = _choosenUsaha.toUpperCase();
    }

    if (!_isNamaUser &&
        !_isTempatLahir &&
        !_isTanggalLahir &&
        !_isAlamat &&
        !_isTlpHp &&
        !_isTlpHpValid &&
        !_isNoIdentitas &&
        !_isNoIdentitasValid &&
        !_isNoNpwpValid &&
        !_isNamaOptik &&
        !_isKota &&
        !_isAlamatUsaha &&
        !_isTlpUsaha &&
        !_isTlpUsahaValid &&
        !_isFaxUsahaValid &&
        !_isFaxUserValid &&
        !_isPlafonValid &&
        !_isNamaPic) {
      if (_isFotoKtp) {
        handleStatus(
          context,
          'Silahkan foto ktp terlebih dahulu',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
        stop();
      } else if (_isFotoPendukung) {
        handleStatus(
          context,
          'Silahkan foto tampak depan terlebih dahulu',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
        stop();
      } else if (_signController.isEmpty) {
        handleStatus(
          context,
          'Silahkan tanda tangan dahulu',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
        stop();
      } else {
        var data = await _signController.toPngBytes();
        signedImage = base64Encode(data!);
        print(signedImage);

        if (base64ImageSiup == '') {
          base64ImageSiup = kosong;
        }

        if (_isChecked) {
          simpanData(stop, isHorizontal: isHorizontal);
        } else {
          handleStatus(
            context,
            'Harap ceklist syarat dan ketentuan',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );

          stop();
        }
      }
    } else {
      handleStatus(
        context,
        'Harap lengkapi data terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
      stop();
    }
  }

  simpanData(Function stop, {bool isHorizontal = false}) async {
    const timeout = 15;
    var url = '$API_URL/customers';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'nama': namaUser.toUpperCase(),
          'agama': _chosenValue.toUpperCase(),
          'tempat_lahir': tempatLahir.toUpperCase(),
          'tanggal_lahir': tanggalLahir,
          'alamat': alamat.toUpperCase(),
          'no_telp': tlpHp,
          'fax': fax,
          'no_identitas': noIdentitas,
          'no_npwp': noNpwp,
          'upload_identitas': base64ImageKtp,
          'nama_usaha':
              '${textAliasOptik.text.toUpperCase()} ${kota.toUpperCase()}',
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
          'nama_salesman': username?.toUpperCase(),
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
            isLogout: false,
            isNewCust: true,
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
            isLogout: false,
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
          isLogout: false,
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

  Widget childNewcust({bool isHorizontal = false}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Entri Kustomer Baru',
          style: TextStyle(
            color: Colors.black54,
            fontSize: isHorizontal ? 20.sp : 18.sp,
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
            size: isHorizontal ? 20.sp : 18.r,
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

  Widget _areaBadanUsaha({bool isHorizontal = false}) {
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
              fontSize: isHorizontal ? 20.sp : 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 15.h,
          ),
          Text(
            'Kategori Usaha',
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 12.sp,
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
              value: _choosenUsaha,
              style: TextStyle(
                color: Colors.black54,
                fontFamily: 'Segoe Ui',
                fontSize: isHorizontal ? 18.sp : 14.sp,
                fontWeight: FontWeight.w600,
              ),
              items: [
                'OPTIK',
                'DR',
                'RS',
                'KLINIK',
                'PT',
                'DLL',
              ].map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(color: Colors.black54)),
                );
              }).toList(),
              hint: Text(
                "Pilih Kategori Usaha",
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: isHorizontal ? 18.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Segoe Ui'),
              ),
              onChanged: (String? value) {
                setState(() {
                  _choosenUsaha = value!;

                  if (_choosenUsaha == "DLL") {
                    jenisUsaha = textJenisUsaha.text.toUpperCase();
                  } else {
                    jenisUsaha = _choosenUsaha.toUpperCase();
                  }
                  String namaUsaha = textNamaOptik.text;

                  textAliasOptik.text = "$namaUsaha $jenisUsaha -";
                });
              },
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          _choosenUsaha == "DLL"
              ? _areaDll(
                  isHorizontal: isHorizontal,
                )
              : SizedBox(
                  width: 10.w,
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nama Usaha',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
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
              hintText: 'TIMUR RAYA',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isNamaOptik ? 'Data wajib diisi' : null,
            ),
            maxLength: 50,
            controller: textNamaOptik,
            onChanged: (value) {
              if (_choosenUsaha == "DLL") {
                jenisUsaha = textJenisUsaha.text.toUpperCase();
              } else {
                jenisUsaha = _choosenUsaha.toUpperCase();
              }

              textAliasOptik.text = "$value $jenisUsaha -";
            },
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                'Alias Usaha',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(Nama optik tertera pada sistem)',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 7,
                child: TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    errorText: _isNamaOptik ? 'Data wajib diisi' : null,
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLength: 50,
                  readOnly: true,
                  controller: textAliasOptik,
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Segoe Ui',
                  ),
                ),
              ),
              SizedBox(
                width: 10.r,
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    errorText: _isKota ? 'Wajib diisi' : null,
                  ),
                  maxLength: 50,
                  controller: textKotaOptik,
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Segoe Ui',
                  ),
                ),
              ),
            ],
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
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
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
              hintText: 'JL KEBANGSAAN NO XXX',
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
              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                'Nomor Telp / Hp',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
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
            maxLength: 13,
            controller: textTelpOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 15.h : 5.h,
          ),
          Text(
            'Nomor WA / Fax',
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 12.sp,
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
              hintText: '08**********',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isFaxUsahaValid ? 'Nomor fax salah' : null,
            ),
            maxLength: 13,
            controller: textFaxOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          Text(
            'Alamat Email',
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 12.sp,
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: !_isEmailValid ? 'Alamat email salah' : null,
            ),
            maxLength: 40,
            controller: textEmailOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isNamaPic ? 'Data wajib diisi' : null,
            ),
            maxLength: 50,
            controller: textPicOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
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

  Widget _areaDataPribadi({bool isHorizontal = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 30.r : 15.r,
        vertical: isHorizontal ? 10.r : 10.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'B. DATA PRIBADI',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 20.sp : 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nomor KTP',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
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
              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                'Nomor NPWP / SIUP',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
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
              hintText: '0925429XXXXXXXX',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isNoNpwpValid ? 'Nomor npwp / siup salah' : null,
            ),
            maxLength: 15,
            controller: textNpwp,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isNamaUser ? 'Data wajib diisi' : null,
            ),
            maxLength: 50,
            controller: textNamaUser,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          Text(
            'Agama',
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 12.sp,
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
                fontSize: isHorizontal ? 18.sp : 14.sp,
                fontWeight: FontWeight.w600,
              ),
              items: [
                'ISLAM',
                'KATHOLIK',
                'PROTESTAN',
                'HINDU',
                'BUDHA',
                'KONGHUCU',
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
                    fontSize: isHorizontal ? 18.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Segoe Ui'),
              ),
              onChanged: (String? value) {
                setState(() {
                  _chosenValue = value!;
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
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
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
              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
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
          DateTimeFormField(
            decoration: InputDecoration(
              hintText: 'dd mon yyyy',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isTanggalLahir ? 'Data wajib diisi' : null,
              hintStyle: TextStyle(
                fontSize: isHorizontal ? 24.sp : 14.sp,
                fontFamily: 'Segoe Ui',
              ),
            ),
            dateFormat: format,
            mode: DateTimeFieldPickerMode.date,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            initialDate: DateTime.now(),
            autovalidateMode: AutovalidateMode.always,
            // validator: (DateTime? e) =>
            //     (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
            onDateSelected: (DateTime value) {
              print('before date : $value');
              tanggalLahir = DateFormat('yyyy-MM-dd').format(value);
              textTanggalLahir.text = tanggalLahir;
              print('after date : $tanggalLahir');
            },
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
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
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
              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
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
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          Text(
            'Fax',
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 12.sp,
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
              fontSize: isHorizontal ? 18.sp : 14.sp,
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

  Widget _areaDataTambahan({bool isHorizontal = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 30.r : 15.r,
        vertical: isHorizontal ? 10.r : 10.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'C. DATA TAMBAHAN',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 20.sp : 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 10.h,
          ),
          Text(
            'Jenis Pembayaran',
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 12.sp,
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
                fontSize: isHorizontal ? 18.sp : 14.sp,
                fontWeight: FontWeight.w600,
              ),
              items: [
                'COD',
                'TRANSFER',
                'DEPOSIT',
                'KREDIT',
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
                  fontSize: isHorizontal ? 18.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Segoe Ui',
                ),
              ),
              onChanged: (String? value) {
                setState(() {
                  _chosenBilling = value!;
                });
              },
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          _chosenBilling == "KREDIT"
              ? _areaKredit(
                  isHorizontal: isHorizontal,
                )
              : SizedBox(
                  width: 20.w,
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kredit Limit',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '(Dalam Satuan Juta)',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 12.sp,
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
              hintText: 'XXXX',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isPlafonValid ? 'Data wajib diisi' : null,
            ),
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            maxLength: 5,
            controller: textKreditLimit,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 22.h : 12.h,
          ),
          Text(
            'Catatan',
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 12.sp,
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
              fontSize: isHorizontal ? 18.sp : 14.sp,
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

  Widget _areaDll({bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Isi Jenis Usaha',
              style: TextStyle(
                fontSize: isHorizontal ? 18.sp : 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: Colors.black,
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
            ),
          ),
          maxLength: 25,
          controller: textJenisUsaha,
          onChanged: (value) {
            if (_choosenUsaha == "DLL") {
              jenisUsaha = textJenisUsaha.text.toUpperCase();
            } else {
              jenisUsaha = _choosenUsaha.toUpperCase();
            }
            String namaUsaha = textNamaOptik.text;

            textAliasOptik.text = "$namaUsaha $jenisUsaha -";
          },
          style: TextStyle(
            fontSize: isHorizontal ? 18.sp : 14.sp,
            fontFamily: 'Segoe Ui',
          ),
        ),
        SizedBox(
          height: isHorizontal ? 22.sp : 12.h,
        ),
      ],
    );
  }

  Widget _areaKredit({bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durasi Kredit',
          style: TextStyle(
            fontSize: isHorizontal ? 18.sp : 12.sp,
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
            value: _chosenKredit,
            style: TextStyle(
              color: Colors.black54,
              fontFamily: 'Segoe Ui',
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontWeight: FontWeight.w600,
            ),
            items: [
              '7 HARI',
              '14 HARI',
              '30 HARI',
              '45 HARI',
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
              "Pilih Durasi Kredit",
              style: TextStyle(
                color: Colors.black54,
                fontSize: isHorizontal ? 18.sp : 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Segoe Ui',
              ),
            ),
            onChanged: (String? value) {
              setState(() {
                _chosenKredit = value!;
              });
            },
          ),
        ),
        SizedBox(
          height: isHorizontal ? 22.h : 12.h,
        ),
      ],
    );
  }

  Widget _areaDokumenPelengkap({bool isHorizontal = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 30.r : 15.r,
        vertical: isHorizontal ? 10.r : 10.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'D. DOKUMEN PELENGKAP',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 20.sp : 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 20.h,
          ),
          Container(
            width: double.infinity,
            child: Text(
              '(wajib diisi)',
              style: TextStyle(
                fontSize: isHorizontal ? 18.sp : 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(
            height: 10.h,
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
                  iconSize: isHorizontal ? 40.r : 27.r,
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
                  iconSize: isHorizontal ? 40.r : 27.r,
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
                  iconSize: isHorizontal ? 40.r : 27.r,
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
          Container(
            width: double.infinity,
            child: Text(
              '(wajib diisi)',
              style: TextStyle(
                fontSize: isHorizontal ? 18.sp : 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(
            height: 10.h,
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
                  iconSize: isHorizontal ? 40.r : 27.r,
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

  Widget _areaSignSubmit({bool isHorizontal = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 30.r : 15.r,
        vertical: isHorizontal ? 10.r : 10.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'E. PERSETUJUAN CUSTOMER',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 20.sp : 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 15.h,
          ),
          Signature(
            controller: _signController,
            height: isHorizontal ? 180.h : 150.h,
            backgroundColor: Colors.blueGrey.shade50,
          ),
          SizedBox(
            height: isHorizontal ? 30.h : 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value: this._isChecked,
                checkColor: Colors.white,
                activeColor: Colors.blue.shade700,
                autofocus: this._isChecked ? false : true,
                onChanged: (bool? value) {
                  setState(() {
                    this._isChecked = value!;
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: 'Saya telah membaca dan setuju dengan ',
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontFamily: 'Segoe Ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                        children: [
                          TextSpan(
                            text: ' syarat dan ketentuan',
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Segoe Ui',
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                showKetentuan(
                                  isHorizontal: isHorizontal,
                                );
                              },
                          ),
                          TextSpan(
                            text: ' yang berlaku.',
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Segoe Ui',
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                    horizontal: isHorizontal ? 30.r : 20.r,
                    vertical: isHorizontal ? 15.r : 10.r,
                  ),
                ),
                child: Text(
                  'Hapus Ttd',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 18.sp : 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Segoe ui',
                  ),
                ),
                onPressed: () {
                  _signController.clear();
                },
              ),
              ArgonButton(
                height: isHorizontal ? 50.h : 40.h,
                width: isHorizontal ? 90.w : 100.w,
                borderRadius: isHorizontal ? 60.r : 30.r,
                color: _isChecked ? Colors.blue[700] : Colors.blue[200],
                child: Text(
                  "Simpan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 18.sp : 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                loader: Container(
                  padding: EdgeInsets.all(8.r),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                onTap: (startLoading, stopLoading, btnState) {
                  if (_isChecked) {
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

  showKetentuan({bool isHorizontal = false}) {
    return showModalBottomSheet(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isHorizontal ? 25.r : 15.r),
          topRight: Radius.circular(isHorizontal ? 25.r : 15.r),
        ),
      ),
      context: context,
      builder: (context) {
        return SyaratKetentuan();
      },
    );
  }
}
