import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

// import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:date_field/date_field.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:fl_toast/fl_toast.dart';
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
import 'package:sample/src/domain/entities/customer_noimage.dart';
import 'package:sample/src/domain/entities/oldcustomer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

import '../../../domain/entities/contract_duration.dart';
import '../../../domain/entities/region_city.dart';
import '../../../domain/entities/region_district.dart';
import '../../../domain/entities/region_province.dart';
import '../../../domain/entities/region_subdistrict.dart';

// ignore: must_be_immutable
class NewcustScreen extends StatefulWidget {
  bool isNewCust, isNewEntry;
  OldCustomer? oldCustomer;
  CustomerNoImage? newCustomer;

  NewcustScreen({
    Key? key,
    this.isNewCust = false,
    this.isNewEntry = true,
    this.oldCustomer,
    this.newCustomer,
  }) : super(key: key);

  @override
  State<NewcustScreen> createState() => _NewcustScreenState();
}

class _NewcustScreenState extends State<NewcustScreen> {
  TextEditingController textNamaOptik = new TextEditingController();
  TextEditingController textAliasOptik = new TextEditingController();
  TextEditingController textAlamatOptik = new TextEditingController();
  TextEditingController textKotaOptik = new TextEditingController();
  TextEditingController textJenisUsaha = new TextEditingController();
  TextEditingController textProvinceOptik = new TextEditingController();
  TextEditingController textCityOptik = new TextEditingController();
  TextEditingController textDistrictOptik = new TextEditingController();
  TextEditingController textSubdistrictOptik = new TextEditingController();
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
  List<ContractDuration> durContract = List.empty(growable: true);
  List<DropdownMenuItem<String>> durDropdown = [];
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
  String tmpSelect = '';
  String tmpIdSelect = '';
  String tmpIdProvince = '';
  String tmpIdCity = '';
  String tmpIdDistrict = '';
  String tmpIdSubdistrict = '';
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
  bool _isProvinceUsaha = false;
  bool _isCityUsaha = false;
  bool _isDistrictUsaha = false;
  bool _isSubdistrictUsaha = false;
  bool _isTlpUsaha = false;
  bool _isTlpUsahaValid = false;
  bool _isFaxUsahaValid = false;
  bool _isNamaPic = false;
  bool _isEmailValid = true;
  bool _isFotoKtp = false;
  bool _isFotoPendukung = false;
  bool _isChecked = false;
  bool _isHorizontal = false;
  late Map<String, TextEditingController> myMap;
  List<RegionProvince> itemProvince = List.empty(growable: true);
  List<RegionCity> itemCity = List.empty(growable: true);
  List<RegionDistrict> itemDistrict = List.empty(growable: true);
  List<RegionSubdistrict> itemSubdistrict = List.empty(growable: true);

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
    getDurationContract();
    selectOptic();

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

  getDurationContract() async {
    const timeout = 15;
    var url = '$API_URL/contract/durasi_kontrak';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          durContract = rest
              .map<ContractDuration>((json) => ContractDuration.fromJson(json))
              .toList();
          print("List Size: ${durContract.length}");

          durContract.forEach((element) {
            var item = DropdownMenuItem(
              value: element.title,
              child: Text(
                element.title ?? '',
                style: TextStyle(color: Colors.black54),
              ),
            );
            durDropdown.add(item);
          });
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  Future<List<RegionProvince>> getSearchProvince(String input) async {
    List<RegionProvince> list = List.empty(growable: true);

    const timeout = 15;
    var url = '$API_URL/region/province?search=$input';
    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest
              .map<RegionProvince>((json) => RegionProvince.fromJson(json))
              .toList();
          itemProvince = rest
              .map<RegionProvince>((json) => RegionProvince.fromJson(json))
              .toList();

          print("List Size: ${list.length}");
          print("Product Size: ${itemProvince.length}");
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }

    return list;
  }

  Future<List<RegionCity>> getSearchCity(
      String input, String idProvince) async {
    List<RegionCity> list = List.empty(growable: true);

    const timeout = 15;
    var url = '$API_URL/region/city?id_province=$idProvince&search=$input';
    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest
              .map<RegionCity>((json) => RegionCity.fromJson(json))
              .toList();
          itemCity = rest
              .map<RegionCity>((json) => RegionCity.fromJson(json))
              .toList();

          print("List Size: ${list.length}");
          print("Product Size: ${itemCity.length}");
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }

    return list;
  }

  Future<List<RegionDistrict>> getSearchDistrict(
      String input, String idProvince, String idCity) async {
    List<RegionDistrict> list = List.empty(growable: true);

    const timeout = 15;
    var url =
        '$API_URL/region/district?id_city=$idCity&id_province=$idProvince&search=$input';
    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest
              .map<RegionDistrict>((json) => RegionDistrict.fromJson(json))
              .toList();
          itemDistrict = rest
              .map<RegionDistrict>((json) => RegionDistrict.fromJson(json))
              .toList();

          print("List Size: ${list.length}");
          print("Product Size: ${itemDistrict.length}");
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }

    return list;
  }

  Future<List<RegionSubdistrict>> getSearchSubdistrict(
      String input, String idProvince, String idCity, String idDistrict) async {
    List<RegionSubdistrict> list = List.empty(growable: true);

    const timeout = 15;
    var url =
        '$API_URL/region/subdistrict?id_district=$idDistrict&id_city=$idCity&id_province=$idProvince&search=$input';
    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest
              .map<RegionSubdistrict>(
                  (json) => RegionSubdistrict.fromJson(json))
              .toList();
          itemSubdistrict = rest
              .map<RegionSubdistrict>(
                  (json) => RegionSubdistrict.fromJson(json))
              .toList();

          print("List Size: ${list.length}");
          print("Product Size: ${itemSubdistrict.length}");
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }

    return list;
  }

  selectOptic() {
    if (!widget.isNewEntry) {
      if (widget.isNewCust) {
        var opticName;
        if (widget.newCustomer?.namaUsaha.contains("-") == true) {
          opticName =
              widget.newCustomer?.namaUsaha.replaceAll("OPTIK", "").split("-");
        } else {
          opticName = widget.newCustomer?.namaUsaha ?? '';
        }

        setCategoryOptic(widget.newCustomer?.namaUsaha.toUpperCase() ?? '');
        textNamaOptik.text = widget.newCustomer?.namaUsaha.contains("-") == true
            ? opticName[0].trim()
            : opticName;
        setAliasOptic(widget.newCustomer?.namaUsaha ?? '');
        textProvinceOptik.text = widget.newCustomer?.provinsiUsaha ?? '';
        textCityOptik.text = widget.newCustomer?.kotaUsaha ?? '';
        textDistrictOptik.text = widget.newCustomer?.kecamatanUsaha ?? '';
        textSubdistrictOptik.text = widget.newCustomer?.kelurahanUsaha ?? '';
        textAlamatOptik.text = widget.newCustomer?.alamatUsaha ?? '';
        textTelpOptik.text = widget.newCustomer?.tlpUsaha ?? '';
        textFaxOptik.text = widget.newCustomer?.faxUsaha ?? '';
        textEmailOptik.text = widget.newCustomer?.emailUsaha ?? '';
        textPicOptik.text = widget.newCustomer?.namaPj ?? '';
        textIdentitas.text = widget.newCustomer?.noIdentitas ?? '';
        textNpwp.text = widget.newCustomer?.noNpwp ?? '';
        textNamaUser.text = widget.newCustomer?.nama ?? '';
        _chosenValue = widget.newCustomer?.agama ?? '';
        textTempatLahir.text = widget.newCustomer?.tempatLahir ?? '';
        textTanggalLahir.text = widget.newCustomer?.tanggalLahir ?? '';
        textAlamatUser.text = widget.newCustomer?.alamat ?? '';
        textTelpUser.text = widget.newCustomer?.noTlp ?? '';
        textFaxUser.text = widget.newCustomer?.fax ?? '';

        if (widget.newCustomer?.sistemPembayaran.contains("-") == true) {
          var paymentType = widget.newCustomer?.sistemPembayaran.split("-");
          print("Sistem pembyaran : $paymentType");
          _chosenBilling = paymentType?[0].trim() ?? '';
          _chosenKredit = paymentType?[1].trim() ?? '';
        } else {
          _chosenBilling = widget.newCustomer?.sistemPembayaran ?? '';
        }

        int kreditLimit = int.parse(widget.newCustomer?.kreditLimit ?? '0');
        int output = kreditLimit ~/ 1000000;
        textKreditLimit.text = output.toString();
        textCatatan.text = widget.newCustomer?.note ?? '';
      } else {
        var opticName;
        if (widget.oldCustomer?.customerShipName.contains("-") == true) {
          opticName = widget.oldCustomer?.customerShipName
              .replaceAll("OPTIK", "")
              .split("-");
        } else {
          opticName = widget.oldCustomer?.customerShipName ?? '';
        }

        setCategoryOptic(
            widget.oldCustomer?.customerShipName.toUpperCase() ?? '');
        textNamaOptik.text =
            widget.oldCustomer?.customerShipName.contains("-") == true
                ? opticName[0]
                : opticName;
        setAliasOptic(widget.oldCustomer?.customerShipName ?? '');
        List<String> address = [
          widget.oldCustomer?.address2 ?? '',
          ' ',
          widget.oldCustomer?.address3 ?? '',
          ' ',
          widget.oldCustomer?.address4 ?? '',
          ' ',
          widget.oldCustomer?.city ?? '',
          ' ',
          widget.oldCustomer?.province ?? ''
        ];
        textAlamatOptik.text = address.join();
        textTelpOptik.text = widget.oldCustomer?.phone ?? '';
        textPicOptik.text = widget.oldCustomer?.contactPerson ?? '';
        textNamaUser.text = widget.oldCustomer?.contactPerson ?? '';
      }
    }
  }

  setCategoryOptic(String namaOptik) {
    if (namaOptik.contains("OPTIC") || namaOptik.contains("OPTIK")) {
      _choosenUsaha = "OPTIK";
    } else if (namaOptik.contains("DR")) {
      _choosenUsaha = "DR";
    } else if (namaOptik.contains("RS")) {
      _choosenUsaha = "RS";
    } else if (namaOptik.contains("KLINIK")) {
      _choosenUsaha = "KLINIK";
    } else if (namaOptik.contains("PT")) {
      _choosenUsaha = "PT";
    } else {
      _choosenUsaha = "DLL";
    }
  }

  setAliasOptic(String namaOptik) {
    if (namaOptik.contains("-")) {
      var data = namaOptik.split("-");

      textAliasOptik.text = "${data[0].trim()} -";
      textKotaOptik.text = data[1].trim();
    } else {
      textAliasOptik.text = "$namaOptik -";
      textKotaOptik.text = "";
    }
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

  onButtonPressed() async {
    if (_isChecked) {
      await Future.delayed(
        const Duration(milliseconds: 3000),
        () => checkEntry(isHorizontal: _isHorizontal),
      );

      return () {};
    }
  }

  checkEntry({bool isHorizontal = false}) async {
    textNamaUser.text.isEmpty ? _isNamaUser = true : _isNamaUser = false;
    if (widget.isNewEntry) {
      textKreditLimit.text.isEmpty
          ? _isPlafonValid = true
          : _isPlafonValid = false;
    }
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
    textProvinceOptik.text.isEmpty
        ? _isProvinceUsaha = true
        : _isProvinceUsaha = false;
    textCityOptik.text.isEmpty
        ? _isCityUsaha = true
        : _isCityUsaha = false;
    textDistrictOptik.text.isEmpty
        ? _isDistrictUsaha = true
        : _isDistrictUsaha = false;
    textSubdistrictOptik.text.isEmpty
        ? _isSubdistrictUsaha = true
        : _isSubdistrictUsaha = false;    
    textTelpOptik.text.isEmpty ? _isTlpUsaha = true : _isTlpUsaha = false;
    textTelpOptik.text.length < 10
        ? _isTlpUsahaValid = true
        : _isTlpUsahaValid = false;
    // textFaxOptik.text.isEmpty
    //     ? _isFaxUsahaValid = false
    //     : textFaxOptik.text.length < 10
    //         ? _isFaxUsahaValid = true
    //         : _isFaxUsahaValid = false;
    // textFaxUser.text.isEmpty
    //     ? _isFaxUserValid = false
    //     : textFaxUser.text.length < 10
    //         ? _isFaxUserValid = true
    //         : _isFaxUserValid = false;
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
        !_isProvinceUsaha &&
        !_isCityUsaha &&
        !_isDistrictUsaha &&
        !_isSubdistrictUsaha &&
        !_isTlpUsaha &&
        !_isTlpUsahaValid &&
        !_isFaxUsahaValid &&
        !_isFaxUserValid &&
        !_isPlafonValid &&
        !_isNamaPic) {
      if (!widget.isNewEntry) {
        bool isEditOptic = false;
        bool isEditPerson = false;
        bool skipEditOptic = false;
        bool skipEditPerson = false;

        if (widget.isNewCust) {
          if (widget.newCustomer?.nama != namaUser.toUpperCase() ||
              widget.newCustomer?.noIdentitas != noIdentitas) {
            isEditPerson = true;
          }

          if (widget.newCustomer?.namaUsaha !=
                  '${textAliasOptik.text.toUpperCase()} ${kota.toUpperCase()}' ||
              widget.newCustomer?.alamatUsaha != alamatUsaha.toUpperCase()) {
            isEditOptic = true;
          }

          print("Is edit person : $isEditPerson");
          print("Is edit optic : $isEditOptic");

          if (isEditOptic) {
            if (_isFotoPendukung) {
              handleStatus(
                context,
                'Silahkan foto tampak depan terlebih dahulu',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );

              skipEditOptic = false;
            } else {
              skipEditOptic = true;
            }
          } else {
            skipEditOptic = true;
          }

          if (isEditPerson) {
            if (_isFotoKtp) {
              handleStatus(
                context,
                'Silahkan foto ktp terlebih dahulu',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );

              skipEditPerson = false;
            } else {
              skipEditPerson = true;
            }
          } else {
            skipEditPerson = true;
          }

          if (skipEditOptic && skipEditPerson) {
            if (_signController.isEmpty) {
              handleStatus(
                context,
                'Silahkan tanda tangan dahulu',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );
            } else {
              var data = await _signController.toPngBytes();
              signedImage = base64Encode(data!);
              print(signedImage);

              if (base64ImageSiup == '') {
                base64ImageSiup = kosong;
              }

              changeData(isHorizontal: isHorizontal);
            }
          }
        } else {
          List<String> address = [
            widget.oldCustomer?.address2 ?? '',
            ' ',
            widget.oldCustomer?.address3 ?? '',
            ' ',
            widget.oldCustomer?.address4 ?? '',
            ' ',
            widget.oldCustomer?.city ?? '',
            ' ',
            widget.oldCustomer?.province ?? ''
          ];

          var entryName =
              "${textAliasOptik.text.toUpperCase()} ${kota.toUpperCase()}";

          if (widget.oldCustomer?.contactPerson.toUpperCase() !=
              namaUser.toUpperCase()) {
            isEditPerson = true;
          }

          if (entryName.toUpperCase() !=
                  widget.oldCustomer?.customerShipName.toUpperCase() ||
              address.join() != alamatUsaha.toUpperCase()) {
            isEditOptic = true;
          }

          print("Shipname Default : ${widget.oldCustomer?.customerShipName}");
          print("Shipname Entry : $entryName");
          print("Is edit person : $isEditPerson");
          print("Is edit optic : $isEditOptic");

          if (isEditOptic) {
            if (_isFotoPendukung) {
              handleStatus(
                context,
                'Silahkan foto tampak depan terlebih dahulu',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );

              skipEditOptic = false;
            } else {
              skipEditOptic = true;
            }
          } else {
            skipEditOptic = true;
          }

          if (isEditPerson) {
            if (_isFotoKtp) {
              handleStatus(
                context,
                'Silahkan foto ktp terlebih dahulu',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );

              skipEditPerson = false;
            } else {
              skipEditPerson = true;
            }
          } else {
            skipEditPerson = true;
          }

          if (skipEditOptic && skipEditPerson) {
            if (_signController.isEmpty) {
              handleStatus(
                context,
                'Silahkan tanda tangan dahulu',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );
            } else {
              var data = await _signController.toPngBytes();
              signedImage = base64Encode(data!);
              print(signedImage);

              if (base64ImageSiup == '') {
                base64ImageSiup = kosong;
              }

              changeData(isHorizontal: isHorizontal);
            }
          }
        }
      } else {
        if (_isFotoKtp) {
          handleStatus(
            context,
            'Silahkan foto ktp terlebih dahulu',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        } else if (_isFotoPendukung) {
          handleStatus(
            context,
            'Silahkan foto tampak depan terlebih dahulu',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        } else if (_signController.isEmpty) {
          handleStatus(
            context,
            'Silahkan tanda tangan dahulu',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        } else {
          var data = await _signController.toPngBytes();
          signedImage = base64Encode(data!);
          print(signedImage);

          if (base64ImageSiup == '') {
            base64ImageSiup = kosong;
          }

          if (_isChecked) {
            simpanData(isHorizontal: isHorizontal);
          } else {
            handleStatus(
              context,
              'Harap ceklist syarat dan ketentuan',
              false,
              isHorizontal: isHorizontal,
              isLogout: false,
            );
          }
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

      setState(() {});
    }
  }

  simpanData({bool isHorizontal = false}) async {
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
          'provinsi_usaha' : textProvinceOptik.text.toUpperCase(),
          'kota_usaha' : textCityOptik.text.toUpperCase(),
          'kecamatan_usaha' : textDistrictOptik.text.toUpperCase(),
          'kelurahan_usaha' : textSubdistrictOptik.text.toUpperCase(),
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
  }

  changeData({bool isHorizontal = false}) async {
    const timeout = 15;
    var url = '$API_URL/customers/changeCustomer';

    try {
      List<String> address = [
        widget.oldCustomer?.address2 ?? '',
        ' ',
        widget.oldCustomer?.address3 ?? '',
        ' ',
        widget.oldCustomer?.address4 ?? '',
        ' ',
        widget.oldCustomer?.city ?? '',
        ' ',
        widget.oldCustomer?.province ?? ''
      ];

      var response = await http.post(
        Uri.parse(url),
        body: {
          'type_customer': widget.isNewCust ? 'NEW' : 'OLD',
          'no_account': widget.isNewCust
              ? widget.newCustomer!.noAccount.isNotEmpty
                  ? widget.newCustomer?.noAccount
                  : widget.newCustomer?.id
              : widget.oldCustomer?.customerShipNumber,
          'nama': widget.isNewCust
              ? widget.newCustomer?.nama
              : widget.oldCustomer?.contactPerson,
          'nama_update': widget.isNewCust
              ? widget.newCustomer?.nama == namaUser.toUpperCase()
                  ? ""
                  : namaUser.toUpperCase()
              : widget.oldCustomer?.contactPerson == namaUser.toUpperCase()
                  ? ""
                  : namaUser.toUpperCase(),
          'agama': widget.isNewCust ? widget.newCustomer?.agama : '',
          'agama_update': widget.isNewCust
              ? widget.newCustomer?.agama == _chosenValue.toUpperCase()
                  ? ""
                  : _chosenValue.toUpperCase()
              : _chosenValue.toUpperCase(),
          'tempat_lahir':
              widget.isNewCust ? widget.newCustomer?.tempatLahir : '',
          'tempat_lahir_update': widget.isNewCust
              ? widget.newCustomer?.tempatLahir == tempatLahir.toUpperCase()
                  ? ""
                  : tempatLahir.toUpperCase()
              : tempatLahir.toUpperCase(),
          'tanggal_lahir':
              widget.isNewCust ? widget.newCustomer?.tanggalLahir : '',
          'tanggal_lahir_update': widget.isNewCust
              ? widget.newCustomer?.tanggalLahir == tanggalLahir
                  ? ''
                  : tanggalLahir
              : tanggalLahir,
          'alamat': widget.isNewCust ? widget.newCustomer?.alamat : '',
          'alamat_update': widget.isNewCust
              ? widget.newCustomer?.alamat == alamat.toUpperCase()
                  ? ""
                  : alamat.toUpperCase()
              : alamat.toUpperCase(),
          'no_telp': widget.isNewCust
              ? widget.newCustomer?.noTlp
              : widget.oldCustomer?.phone,
          'no_telp_update': widget.isNewCust
              ? widget.newCustomer?.noTlp == tlpHp
                  ? ""
                  : tlpHp
              : tlpHp,
          'fax': widget.isNewCust ? widget.newCustomer?.fax : '',
          'fax_update': widget.isNewCust
              ? widget.newCustomer?.fax == fax
                  ? ""
                  : fax
              : fax,
          'no_identitas':
              widget.isNewCust ? widget.newCustomer?.noIdentitas : '',
          'no_identitas_update': widget.isNewCust
              ? widget.newCustomer?.noIdentitas == noIdentitas
                  ? ""
                  : noIdentitas
              : noIdentitas,
          'no_npwp': widget.isNewCust ? widget.newCustomer?.noNpwp : '',
          'no_npwp_update': widget.isNewCust
              ? widget.newCustomer?.noNpwp == noNpwp
                  ? ""
                  : noNpwp
              : noNpwp,
          'nama_usaha': widget.isNewCust
              ? widget.newCustomer?.namaUsaha
              : widget.oldCustomer?.customerShipName,
          'nama_usaha_update': widget.isNewCust
              ? widget.newCustomer?.namaUsaha ==
                      '${textAliasOptik.text.toUpperCase()} ${kota.toUpperCase()}'
                  ? ""
                  : '${textAliasOptik.text.toUpperCase()} ${kota.toUpperCase()}'
              : widget.oldCustomer?.customerShipName ==
                      '${textAliasOptik.text.toUpperCase()} ${kota.toUpperCase()}'
                  ? ""
                  : '${textAliasOptik.text.toUpperCase()} ${kota.toUpperCase()}',
          // 'nama_usaha_update': '${textAliasOptik.text.toUpperCase()} ${kota.toUpperCase()}',
          'provinsi_usaha' : widget.isNewCust
              ? widget.newCustomer?.provinsiUsaha
              : '',
          'provinsi_usaha_update' : textProvinceOptik.text.toUpperCase(),
          'kota_usaha' : widget.isNewCust
              ? widget.newCustomer?.kotaUsaha
              : '',
          'kota_usaha_update' : textCityOptik.text.toUpperCase(),
          'kecamatan_usaha' : widget.isNewCust
              ? widget.newCustomer?.kecamatanUsaha
              : '',
          'kecamatan_usaha_update' : textDistrictOptik.text.toUpperCase(),
          'kelurahan_usaha' : widget.isNewCust
              ? widget.newCustomer?.kelurahanUsaha
              : '',
          'kelurahan_usaha_update' : textSubdistrictOptik.text.toUpperCase(),  
          'alamat_usaha': widget.isNewCust
              ? widget.newCustomer?.alamatUsaha
              : address.join(),
          'alamat_usaha_update': widget.isNewCust
              ? widget.newCustomer?.alamatUsaha == alamatUsaha.toUpperCase()
                  ? ""
                  : alamatUsaha.toUpperCase()
              : address.join() == alamatUsaha.toUpperCase()
                  ? ""
                  : alamatUsaha.toUpperCase(),
          'telp_usaha': widget.isNewCust
              ? widget.newCustomer?.tlpUsaha
              : widget.oldCustomer?.phone,
          'telp_usaha_update': widget.isNewCust
              ? widget.newCustomer?.tlpUsaha == tlpUsaha
                  ? ""
                  : tlpUsaha
              : widget.oldCustomer?.phone == tlpUsaha
                  ? ""
                  : tlpUsaha,
          'fax_usaha': widget.isNewCust ? widget.newCustomer?.faxUsaha : '',
          'fax_usaha_update': widget.isNewCust
              ? widget.newCustomer?.faxUsaha == faxUsaha
                  ? ""
                  : faxUsaha
              : faxUsaha,
          'email_usaha': widget.isNewCust ? widget.newCustomer?.emailUsaha : '',
          'email_usaha_update': widget.isNewCust
              ? widget.newCustomer?.emailUsaha == emailUsaha
                  ? ""
                  : emailUsaha
              : emailUsaha,
          'nama_pj': widget.isNewCust
              ? widget.newCustomer?.namaPj
              : widget.oldCustomer?.contactPerson,
          'nama_pj_update': widget.isNewCust
              ? widget.newCustomer?.namaPj == namaPic.toUpperCase()
                  ? ""
                  : namaPic.toUpperCase()
              : widget.oldCustomer?.contactPerson == namaPic.toUpperCase()
                  ? ""
                  : namaPic.toUpperCase(),
          'nama_salesman': username?.toUpperCase(),
          'ttd_customer': signedImage,
          'created_by': id,
          'upload_identitas': base64ImageKtp,
          'upload_dokumen': base64ImageSiup,
          'gambar_pendukung': base64ImagePendukung,
          'gambar_kartu_nama': base64ImageKartuNama,
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
            isNewCust: false,
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
          widget.isNewEntry ? 'Entri Kustomer Baru' : 'Perubahan Data Kustomer',
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
          _choosenUsaha == "DLL" && widget.isNewEntry
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

              setState(() {
                if (value.isNotEmpty) {
                  _isNamaOptik = false;
                } else {
                  _isNamaOptik = true;
                }
              });
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
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        _isNamaOptik = false;
                      } else {
                        _isNamaOptik = true;
                      }
                    });
                  },
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
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        _isKota = false;
                      } else {
                        _isKota = true;
                      }
                    });
                  },
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
                'Provinsi',
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
            decoration: InputDecoration(
              hintText: 'Pilih Provinsi',
              suffixIcon: Icon(Icons.arrow_drop_down_rounded),
              suffixIconColor: Colors.black54,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isProvinceUsaha ? 'Data wajib diisi' : null,
            ),
            readOnly: true,
            controller: textProvinceOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
            onTap: () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return dialogProvince(
                      isHorizontal: isHorizontal,
                    );
                  }).then((value) {
                setState(() {
                  print("Close Dialog province");
                  textProvinceOptik.text.isEmpty
                      ? _isProvinceUsaha = true
                      : _isProvinceUsaha = false;
                });
              });
            },
          ),
          SizedBox(
            height: isHorizontal ? 22.sp : 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kota',
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
            decoration: InputDecoration(
              hintText: 'Pilih Kota',
              suffixIcon: Icon(Icons.arrow_drop_down_rounded),
              suffixIconColor: Colors.black54,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isCityUsaha ? 'Data wajib diisi' : null,
            ),
            readOnly: true,
            controller: textCityOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
            onTap: () {
              if (textProvinceOptik.text.isNotEmpty && tmpIdProvince.isNotEmpty) {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return dialogCity(
                        isHorizontal: isHorizontal,
                      );
                    }).then((value) {
                  setState(() {
                    print("Close Dialog city");
                    textCityOptik.text.isEmpty
                        ? _isCityUsaha = true
                        : _isCityUsaha = false;
                  });
                });
              } else {
                showStyledToast(
                  child: Text('Harap lengkapi data provinsi'),
                  context: context,
                  backgroundColor: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(15.r),
                  duration: Duration(seconds: 3),
                );
              }
            },
          ),
          SizedBox(
            height: isHorizontal ? 22.sp : 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kecamatan',
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
            decoration: InputDecoration(
              hintText: 'Pilih Kecamatan',
              suffixIcon: Icon(Icons.arrow_drop_down_rounded),
              suffixIconColor: Colors.black54,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isDistrictUsaha ? 'Data wajib diisi' : null,
            ),
            readOnly: true,
            controller: textDistrictOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
            onTap: () {
              if (textCityOptik.text.isNotEmpty && tmpIdCity.isNotEmpty) {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return dialogDistrict(
                        isHorizontal: isHorizontal,
                      );
                    }).then((value) {
                  setState(() {
                    print("Close Dialog district");
                    textDistrictOptik.text.isEmpty
                        ? _isDistrictUsaha = true
                        : _isDistrictUsaha = false;
                  });
                });
              } else {
                showStyledToast(
                  child: Text('Harap lengkapi data kota'),
                  context: context,
                  backgroundColor: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(15.r),
                  duration: Duration(seconds: 3),
                );
              }
            },
          ),
          SizedBox(
            height: isHorizontal ? 22.sp : 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kelurahan',
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
            decoration: InputDecoration(
              hintText: 'Pilih Kelurahan',
              suffixIcon: Icon(Icons.arrow_drop_down_rounded),
              suffixIconColor: Colors.black54,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: _isSubdistrictUsaha ? 'Data wajib diisi' : null,
            ),
            readOnly: true,
            controller: textSubdistrictOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
            onTap: () {
              if (textDistrictOptik.text.isNotEmpty && tmpIdDistrict.isNotEmpty) {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return dialogSubdistrict(
                        isHorizontal: isHorizontal,
                      );
                    }).then((value) {
                  setState(() {
                    print("Close Dialog subdistrict");
                    textSubdistrictOptik.text.isEmpty
                        ? _isSubdistrictUsaha = true
                        : _isSubdistrictUsaha = false;
                  });
                });
              } else {
                showStyledToast(
                  child: Text('Harap lengkapi data kecamatan'),
                  context: context,
                  backgroundColor: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(15.r),
                  duration: Duration(seconds: 3),
                );
              }
            },
          ),
          SizedBox(
            height: isHorizontal ? 15.h : 5.h,
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
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty) {
                  _isAlamatUsaha = false;
                } else {
                  _isAlamatUsaha = true;
                }
              });
            },
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
                      : textTelpOptik.text.length > 13
                          ? 'Nomor telpon max 13 karakter'
                          : null,
            ),
            maxLength: 13,
            controller: textTelpOptik,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty) {
                  _isTlpUsaha = false;
                  if (value.length < 10) {
                    _isTlpUsahaValid = true;
                  } else {
                    _isTlpUsahaValid = false;
                  }
                } else {
                  _isTlpUsaha = true;
                }
              });
            },
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
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty) {
                  _isNamaPic = false;
                } else {
                  _isNamaPic = true;
                }
              });
            },
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
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty) {
                  _isNoIdentitas = false;
                  if (value.length < 16) {
                    _isNoIdentitasValid = true;
                  } else {
                    _isNoIdentitasValid = false;
                  }
                } else {
                  _isNoIdentitas = true;
                }
              });
            },
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
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
            controller: textNamaUser,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _isNamaUser = true;
                } else {
                  _isNamaUser = false;
                }
              });
            },
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
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _isTempatLahir = true;
                } else {
                  _isTempatLahir = false;
                }
              });
            },
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
              hintText: widget.isNewEntry
                  ? 'dd mon yyyy'
                  : widget.isNewCust
                      ? widget.newCustomer?.tanggalLahir
                      : 'dd mon yyyy',
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
            initialDate: widget.isNewEntry
                ? DateTime.now()
                : widget.isNewCust
                    ? DateTime.parse(widget.newCustomer?.tanggalLahir ?? '')
                    : DateTime.now(),
            autovalidateMode: AutovalidateMode.always,
            // validator: (DateTime? e) =>
            //     (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
            onDateSelected: (DateTime value) {
              print('before date : $value');
              tanggalLahir = DateFormat('yyyy-MM-dd').format(value);
              textTanggalLahir.text = tanggalLahir;
              print('after date : $tanggalLahir');

              setState(() {
                // ignore: unrelated_type_equality_checks
                if (value == "") {
                  _isTanggalLahir = true;
                } else {
                  _isTanggalLahir = false;
                }
              });
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
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _isAlamat = true;
                } else {
                  _isAlamat = false;
                }
              });
            },
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
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _isTlpHp = true;
                } else {
                  _isTlpHp = false;
                  if (value.length >= 10) {
                    _isTlpHpValid = false;
                  } else {
                    _isTlpHpValid = true;
                  }
                }
              });
            },
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
              onChanged: !widget.isNewEntry
                  ? null
                  : (String? value) {
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
            enabled: widget.isNewEntry,
            decoration: InputDecoration(
              hintText: 'XXXX',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: widget.isNewEntry
                  ? null
                  : _isPlafonValid
                      ? 'Data wajib diisi'
                      : null,
            ),
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            maxLength: 5,
            controller: textKreditLimit,
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 14.sp,
              fontFamily: 'Segoe Ui',
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                _isPlafonValid = false;
              } else {
                _isPlafonValid = true;
              }
            },
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
            // items: [
            //   '7 HARI',
            //   '14 HARI',
            //   '30 HARI',
            //   '45 HARI',
            // ].map((e) {
            //   return DropdownMenuItem(
            //     value: e,
            //     child: Text(e,
            //         style: TextStyle(
            //           color: Colors.black54,
            //         )),
            //   );
            // }).toList(),
            items: durDropdown,
            hint: Text(
              _chosenKredit.isNotEmpty ? _chosenKredit : "Pilih Durasi Kredit",
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
    _isHorizontal = isHorizontal;
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
                  backgroundColor: Colors.orange[800],
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
              EasyButton(
                idleStateWidget: Text(
                  "Simpan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 18.sp : 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                loadingStateWidget: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
                useEqualLoadingStateWidgetDimension: true,
                useWidthAnimation: true,
                height: isHorizontal ? 50.h : 40.h,
                width: isHorizontal ? 90.w : 100.w,
                borderRadius: isHorizontal ? 60.r : 30.r,
                buttonColor:
                    _isChecked ? Colors.blue.shade600 : Colors.blue.shade200,
                elevation: 2.0,
                contentGap: 6.0,
                onPressed: onButtonPressed,
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

  Widget dialogProvince({bool isHorizontal = false}) {
    String search = '';
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: Center(
          child: Text('Pilih Provinsi'),
        ),
        content: Container(
          height: MediaQuery.of(context).size.height / 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 350.w,
                padding: EdgeInsets.symmetric(
                  horizontal: 5.r,
                  vertical: 10.r,
                ),
                color: Colors.white,
                height: 80.h,
                child: TextField(
                  textInputAction: TextInputAction.search,
                  autocorrect: true,
                  decoration: InputDecoration(
                    hintText: 'Pencarian data ...',
                    prefixIcon: Icon(Icons.search),
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white70,
                    contentPadding: EdgeInsets.symmetric(vertical: 3.r),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
                      borderSide: BorderSide(color: Colors.grey, width: 2.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0.r)),
                      borderSide: BorderSide(color: Colors.blue, width: 2.r),
                    ),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      search = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 100.h,
                  child: FutureBuilder(
                      future: search.isNotEmpty
                          ? getSearchProvince(search)
                          : getSearchProvince(''),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            return snapshot.data != null
                                ? listParentWidget(itemProvince)
                                : Center(
                                    child: Text('Data tidak ditemukan'),
                                  );
                        }
                      }),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          textProvinceOptik.text = tmpSelect;
                          tmpIdProvince = tmpIdSelect;

                          textCityOptik.text = "";
                          tmpIdCity = "";

                          textDistrictOptik.text = "";
                          tmpIdDistrict = "";

                          textSubdistrictOptik.text = "";
                          tmpIdSubdistrict = "";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text("Pilih"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget dialogCity({bool isHorizontal = false}) {
    String search = '';
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: Center(
          child: Text('Pilih Kota'),
        ),
        content: Container(
          height: MediaQuery.of(context).size.height / 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 350.w,
                padding: EdgeInsets.symmetric(
                  horizontal: 5.r,
                  vertical: 10.r,
                ),
                color: Colors.white,
                height: 80.h,
                child: TextField(
                  textInputAction: TextInputAction.search,
                  autocorrect: true,
                  decoration: InputDecoration(
                    hintText: 'Pencarian data ...',
                    prefixIcon: Icon(Icons.search),
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white70,
                    contentPadding: EdgeInsets.symmetric(vertical: 3.r),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
                      borderSide: BorderSide(color: Colors.grey, width: 2.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0.r)),
                      borderSide: BorderSide(color: Colors.blue, width: 2.r),
                    ),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      search = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 100.h,
                  child: FutureBuilder(
                      future: search.isNotEmpty
                          ? getSearchCity(search, tmpIdProvince)
                          : getSearchCity('', tmpIdProvince),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            return snapshot.data != null
                                ? listParentWidget(itemCity)
                                : Center(
                                    child: Text('Data tidak ditemukan'),
                                  );
                        }
                      }),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          textCityOptik.text = tmpSelect;
                          tmpIdCity = tmpIdSelect;

                          textDistrictOptik.text = "";
                          tmpIdDistrict = "";

                          textSubdistrictOptik.text = "";
                          tmpIdSubdistrict = "";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text("Pilih"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget dialogDistrict({bool isHorizontal = false}) {
    String search = '';
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: Center(
          child: Text('Pilih Kecamatan'),
        ),
        content: Container(
          height: MediaQuery.of(context).size.height / 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 350.w,
                padding: EdgeInsets.symmetric(
                  horizontal: 5.r,
                  vertical: 10.r,
                ),
                color: Colors.white,
                height: 80.h,
                child: TextField(
                  textInputAction: TextInputAction.search,
                  autocorrect: true,
                  decoration: InputDecoration(
                    hintText: 'Pencarian data ...',
                    prefixIcon: Icon(Icons.search),
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white70,
                    contentPadding: EdgeInsets.symmetric(vertical: 3.r),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
                      borderSide: BorderSide(color: Colors.grey, width: 2.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0.r)),
                      borderSide: BorderSide(color: Colors.blue, width: 2.r),
                    ),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      search = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 100.h,
                  child: FutureBuilder(
                      future: search.isNotEmpty
                          ? getSearchDistrict(search, tmpIdProvince, tmpIdCity)
                          : getSearchDistrict('', tmpIdProvince, tmpIdCity),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            return snapshot.data != null
                                ? listParentWidget(itemDistrict)
                                : Center(
                                    child: Text('Data tidak ditemukan'),
                                  );
                        }
                      }),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          textDistrictOptik.text = tmpSelect;
                          tmpIdDistrict = tmpIdSelect;

                          textSubdistrictOptik.text = "";
                          tmpIdSubdistrict = "";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text("Pilih"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget dialogSubdistrict({bool isHorizontal = false}) {
    String search = '';
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: Center(
          child: Text('Pilih Kelurahan'),
        ),
        content: Container(
          height: MediaQuery.of(context).size.height / 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 350.w,
                padding: EdgeInsets.symmetric(
                  horizontal: 5.r,
                  vertical: 10.r,
                ),
                color: Colors.white,
                height: 80.h,
                child: TextField(
                  textInputAction: TextInputAction.search,
                  autocorrect: true,
                  decoration: InputDecoration(
                    hintText: 'Pencarian data ...',
                    prefixIcon: Icon(Icons.search),
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white70,
                    contentPadding: EdgeInsets.symmetric(vertical: 3.r),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
                      borderSide: BorderSide(color: Colors.grey, width: 2.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0.r)),
                      borderSide: BorderSide(color: Colors.blue, width: 2.r),
                    ),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      search = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 100.h,
                  child: FutureBuilder(
                      future: search.isNotEmpty
                          ? getSearchSubdistrict(search, tmpIdProvince, tmpIdCity, tmpIdDistrict)
                          : getSearchSubdistrict('', tmpIdProvince, tmpIdCity, tmpIdDistrict),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            return snapshot.data != null
                                ? listParentWidget(itemSubdistrict)
                                : Center(
                                    child: Text('Data tidak ditemukan'),
                                  );
                        }
                      }),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          textSubdistrictOptik.text = tmpSelect;
                          tmpIdSubdistrict = tmpIdSelect;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text("Pilih"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget listParentWidget(dynamic item) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
          width: double.minPositive.w,
          height: 350.h,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: item.length,
            itemBuilder: (BuildContext context, int index) {
              String _key = item[index].desc;
              return InkWell(
                onTap: () {
                  setState(() {
                    item.forEach((element) {
                      element.ischecked = false;
                    });
                    item[index].ischecked = true;
                    tmpIdSelect = item[index].id;
                    tmpSelect = item[index].desc;
                  });
                },
                child: ListTile(
                  title: Text(_key),
                  trailing: Visibility(
                    visible: item[index].ischecked,
                    child: Icon(
                      Icons.check,
                      color: Colors.green.shade600,
                      size: 22.r,
                    ),
                    replacement: SizedBox(
                      width: 5.w,
                    ),
                  ),
                ),
              );
            },
          ));
    });
  }
}
