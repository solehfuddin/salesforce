import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/customer_inkaro.dart';
import 'package:sample/src/domain/entities/inkaro_manual.dart';
import 'package:sample/src/domain/entities/inkaro_program.dart';
import 'package:sample/src/domain/entities/inkaro_reguler.dart';
import 'package:sample/src/domain/entities/list_inkaro_header.dart';
import 'package:sample/src/domain/entities/master_bank.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditInkaroHeaderScreen extends StatefulWidget {
  final List<ListInkaroHeader> inkaroHeaderList;
  final int position;

  @override
  _EditInkaroHeaderState createState() => _EditInkaroHeaderState();

  EditInkaroHeaderScreen(this.inkaroHeaderList, this.position);
}

class _EditInkaroHeaderState extends State<EditInkaroHeaderScreen> {
  TextEditingController textNamaStaff = new TextEditingController();
  TextEditingController textNikKTP = new TextEditingController();
  TextEditingController textNpwp = new TextEditingController();
  TextEditingController textNomorRekening = new TextEditingController();
  TextEditingController textMulaiPeriode = new TextEditingController();
  TextEditingController textSelesaiPeriode = new TextEditingController();
  TextEditingController textAtasNama = new TextEditingController();
  TextEditingController textTelpKonfirmasi = new TextEditingController();
  final formKeyInkaroManual = GlobalKey<FormState>();

  String? id = '';
  String? role = '';
  String? username = '';
  String searchInkaroProgram = '';
  String searchInkaroManual = '';
  final format = DateFormat("dd MMM yyyy");
  bool _isEmpty = false;

  String? namaStaff,
      nikKTP,
      npwp,
      nomorRekening,
      mulaiPeriode,
      selesaiPeriode,
      atasNama,
      telpKonfirmasi,
      _choosenBank,
      _choosenFilterSubcatProg,
      _choosenFilterSubcatManual;
  bool _emptyNamaStaff = false,
      _emptyNikKTP = false,
      _emptyNpwp = false,
      _emptyNomorRekening = false,
      _emptyMulaiPeriode = false,
      _emptySelesaiPeriode = false,
      _emptyAtasNama = false,
      _emptyTelpKonfirmasi = false;

  checkEntry(Function stop, {bool isHorizontal = false}) {
    setState(() {
      textNamaStaff.text.isEmpty
          ? _emptyNamaStaff = true
          : _emptyNamaStaff = false;
      textNikKTP.text.isEmpty ? _emptyNikKTP = true : _emptyNikKTP = false;
      // textNpwp.text.isEmpty ? _emptyNpwp = true : _emptyNpwp = false;
      textTelpKonfirmasi.text.isEmpty
          ? _emptyTelpKonfirmasi = true
          : _emptyTelpKonfirmasi = false;
      textNomorRekening.text.isEmpty
          ? _emptyNomorRekening = true
          : _emptyNomorRekening = false;
      textMulaiPeriode.text.isEmpty
          ? _emptyMulaiPeriode = true
          : _emptyMulaiPeriode = false;
      textSelesaiPeriode.text.isEmpty
          ? _emptySelesaiPeriode = true
          : _emptySelesaiPeriode = false;
      textAtasNama.text.isEmpty
          ? _emptyAtasNama = true
          : _emptyAtasNama = false;
      mulaiPeriode != ''
          ? _emptyMulaiPeriode = false
          : _emptyMulaiPeriode = true;
      selesaiPeriode != ''
          ? _emptySelesaiPeriode = false
          : _emptySelesaiPeriode = true;
    });
    bool validationInkaroManual = false;
    for (int loopManual = 0;
        loopManual < inkaroManualSelected.length;
        loopManual++) {
      if (inkaroManualSelected[loopManual].inkaroValue == '0' ||
          inkaroManualSelected[loopManual].inkaroValue == '') {
        validationInkaroManual = true;
        stop();
        break;
      }
    }

    if (_emptyNamaStaff ||
        _emptyNikKTP ||
        _emptyNomorRekening ||
        _emptyMulaiPeriode ||
        _emptySelesaiPeriode ||
        _emptyAtasNama ||
        _emptyTelpKonfirmasi ||
        _choosenBank == '' ||
        _choosenBank == null) {
      handleStatus(
        context,
        'Harap lengkapi isian yang telah disediakan.',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
      stop();
    } else {
      if (inkaroRegSelected.isEmpty &&
          inkaroProgSelected.isEmpty &&
          inkaroManualSelected.isEmpty) {
        handleStatus(
          context,
          'Silahkan Tambahkan Inkaro Terlebih Dahulu.',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
        stop();
      } else {
        if (validationInkaroManual) {
          handleStatus(
            context,
            'Harap Lengkapi Nilai Inkaro untuk Tipe Inkaro Manual.',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
          stop();
        } else {
          simpanData(stop, isHorizontal: isHorizontal);
        }

        stop();
      }
    }
  }

  simpanData(Function stop, {bool isHorizontal = false}) async {
    const timeout = 15;
    var url = '$API_URL/inkaro/';

    try {
      var response = await http.post(Uri.parse(url), body: {
        'idContract': widget.inkaroHeaderList[widget.position].inkaroContractId,
        'start_periode': mulaiPeriode,
        'end_periode': selesaiPeriode,
        'npwp': npwp != null ? npwp : '',
        'nik_ktp': nikKTP,
        'nama_staff': namaStaff,
        'bank': _choosenBank,
        'nomor_rekening': nomorRekening,
        'an_rekening': atasNama,
        'telp_konfirmasi': telpKonfirmasi,
        'update_by': id,
      }, headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      // RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      // print(response.body.replaceAll(exp, ''));
      // print('test');

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'].toString();

      if (mounted) {
        handleStatus(
          context,
          msg,
          sts,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      }
    } on FormatException catch (e) {
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
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

  List<ListMasterBank> _dataBank = List.empty(growable: true);
  List<InkaroReguler> _dataFilterSubcat = List.empty(growable: true);

  List<InkaroReguler> itemInkaroReguler = List.empty(growable: true);
  List<InkaroReguler> inkaroRegSelected = List.empty(growable: true);

  List<InkaroProgram> itemInkaroProgram = List.empty(growable: true);
  List<InkaroProgram> listInkaroProgram = List.empty(growable: true);
  List<InkaroProgram> inkaroProgSelected = List.empty(growable: true);
  List<String> indexInkaroProgSelected = List.empty(growable: true);

  List<InkaroManual> itemInkaroManual = List.empty(growable: true);
  List<InkaroManual> listInkaroManual = List.empty(growable: true);
  List<InkaroManual> inkaroManualSelected = List.empty(growable: true);
  List<String> indexInkaroManualSelected = List.empty(growable: true);

  Future<List<ListMasterBank>> getOptionBank() async {
    const timeout = 15;
    var url = '$API_URL/inkaro/master_bank';
    List<ListMasterBank> list = List.empty(growable: true);
    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          list = rest
              .map<ListMasterBank>((json) => ListMasterBank.fromJson(json))
              .toList();
          setState(() {
            _dataBank = list;
          });
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

  @override
  void initState() {
    super.initState();
    getRole();
    getOptionBank();
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childCreateInkaro(isHorizontal: true);
      }

      return childCreateInkaro(isHorizontal: false);
    });
  }

  Widget childCreateInkaro({bool isHorizontal = false}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Entri Inkaro Baru',
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
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 30.r : 15.r,
                vertical: isHorizontal ? 20.r : 10.r,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DATA STAFF
                  Text(
                    'A. STAFF',
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Montserrat',
                      fontSize: isHorizontal ? 20.sp : 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 22.h : 12.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nama Staff',
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
                    height: isHorizontal ? 22.h : 12.h,
                  ),
                  TextFormField(
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        errorText: _emptyNamaStaff ? 'Data wajib diisi' : null,
                      ),
                      maxLength: 50,
                      controller: textNamaStaff,
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 14.sp,
                        fontFamily: 'Segoe Ui',
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          namaStaff = value!;
                          if (value == '') {
                            _emptyNamaStaff = true;
                          } else {
                            _emptyNamaStaff = false;
                          }
                        });
                      }),
                  SizedBox(
                    height: isHorizontal ? 22.h : 12.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NIK',
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
                    height: isHorizontal ? 22.h : 12.h,
                  ),
                  TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        errorText: _emptyNikKTP ? 'Data wajib diisi' : null,
                      ),
                      maxLength: 16,
                      controller: textNikKTP,
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 14.sp,
                        fontFamily: 'Segoe Ui',
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          nikKTP = value!;
                          if (value == '') {
                            _emptyNikKTP = true;
                          } else {
                            _emptyNikKTP = false;
                          }
                        });
                      }),
                  SizedBox(
                    height: isHorizontal ? 22.h : 12.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NPWP',
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        // errorText: _emptyNpwp ? 'Data wajib diisi' : null,
                      ),
                      maxLength: 16,
                      controller: textNpwp,
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 14.sp,
                        fontFamily: 'Segoe Ui',
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          npwp = value!;
                          // if (value == '') {
                          //   _emptyNpwp = true;
                          // } else {
                          //   _emptyNpwp = false;
                          // }
                        });
                      }),
                  SizedBox(
                    height: isHorizontal ? 20.h : 15.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mulai Periode',
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Selesai Periode',
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Container(
                            child: DateTimeFormField(
                              decoration: InputDecoration(
                                hintText: 'dd mon yyyy',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                errorText: _emptyMulaiPeriode
                                    ? 'Data wajib diisi'
                                    : null,
                                hintStyle: TextStyle(
                                  fontSize: isHorizontal ? 24.sp : 14.sp,
                                  fontFamily: 'Segoe Ui',
                                ),
                              ),
                              dateFormat: format,
                              mode: DateTimeFieldPickerMode.date,
                              firstDate: DateTime(1945),
                              lastDate: DateTime.now(),
                              initialDate: DateTime.now(),
                              autovalidateMode: AutovalidateMode.always,
                              onDateSelected: (DateTime value) {
                                setState(() {
                                  mulaiPeriode =
                                      DateFormat('yyyy-MM-dd').format(value);
                                  if (mulaiPeriode == '') {
                                    _emptyMulaiPeriode = true;
                                  } else {
                                    _emptyMulaiPeriode = false;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.r,
                        ),
                        Expanded(
                          flex: 6,
                          child: Container(
                            child: DateTimeFormField(
                              decoration: InputDecoration(
                                hintText: 'dd mon yyyy',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                errorText: _emptySelesaiPeriode
                                    ? 'Data wajib diisi'
                                    : null,
                                hintStyle: TextStyle(
                                  fontSize: isHorizontal ? 24.sp : 14.sp,
                                  fontFamily: 'Segoe Ui',
                                ),
                              ),
                              dateFormat: format,
                              mode: DateTimeFieldPickerMode.date,
                              firstDate: DateTime(1945),
                              // lastDate: DateTime.now(),
                              initialDate: DateTime.now(),
                              autovalidateMode: AutovalidateMode.always,
                              onDateSelected: (DateTime value) {
                                setState(() {
                                  selesaiPeriode =
                                      DateFormat('yyyy-MM-dd').format(value);
                                  if (selesaiPeriode == '') {
                                    _emptySelesaiPeriode = true;
                                  } else {
                                    _emptySelesaiPeriode = false;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ]),
                  SizedBox(
                    height: isHorizontal ? 22.sp : 12.h,
                  ),
                  // DATA REKENING
                  Text(
                    'B. DATA REKENING PENERIMA',
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Montserrat',
                      fontSize: isHorizontal ? 20.sp : 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 22.h : 12.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Bank / e-Wallet',
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Atas Nama',
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.r, vertical: 7.r),
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(5.r)),
                            child: DropdownButton(
                              underline: SizedBox(),
                              isExpanded: true,
                              value: _choosenBank,
                              style: TextStyle(
                                color: Colors.black54,
                                fontFamily: 'Segoe Ui',
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              items: _dataBank.map((e) {
                                return DropdownMenuItem(
                                  value: e.idBank,
                                  child: Text(e.shortName,
                                      style: TextStyle(color: Colors.black54)),
                                );
                              }).toList(),
                              hint: Text(
                                "Pilih Bank",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: isHorizontal ? 18.sp : 14.sp,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Segoe Ui'),
                              ),
                              onChanged: (String? value) {
                                setState(() {
                                  _choosenBank = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.r,
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            margin: EdgeInsets.only(top: 15.0),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                errorText:
                                    _emptyAtasNama ? 'Wajib diisi' : null,
                              ),
                              maxLength: 50,
                              controller: textAtasNama,
                              style: TextStyle(
                                fontSize: isHorizontal ? 24.sp : 14.sp,
                                fontFamily: 'Segoe Ui',
                              ),
                              onChanged: (String? value) {
                                setState(() {
                                  atasNama = value!;
                                  if (value == '') {
                                    _emptyAtasNama = true;
                                  } else {
                                    _emptyAtasNama = false;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ]),
                  SizedBox(
                    height: isHorizontal ? 22.sp : 12.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nomor Rekening / e-Wallet',
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Telp/HP Konfirmasi',
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            margin: EdgeInsets.only(top: 15.0),
                            child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  errorText: _emptyNomorRekening
                                      ? 'Data wajib diisi'
                                      : null,
                                ),
                                maxLength: 50,
                                controller: textNomorRekening,
                                style: TextStyle(
                                  fontSize: isHorizontal ? 18.sp : 14.sp,
                                  fontFamily: 'Segoe Ui',
                                ),
                                onChanged: (String? value) {
                                  setState(() {
                                    nomorRekening = value!;
                                    if (value == '') {
                                      _emptyNomorRekening = true;
                                    } else {
                                      _emptyNomorRekening = false;
                                    }
                                  });
                                }),
                          ),
                        ),
                        SizedBox(
                          width: 10.r,
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            margin: EdgeInsets.only(top: 15.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                errorText:
                                    _emptyTelpKonfirmasi ? 'Wajib diisi' : null,
                              ),
                              maxLength: 50,
                              controller: textTelpKonfirmasi,
                              style: TextStyle(
                                fontSize: isHorizontal ? 24.sp : 14.sp,
                                fontFamily: 'Segoe Ui',
                              ),
                              onChanged: (String? value) {
                                setState(() {
                                  telpKonfirmasi = value!;
                                  if (value == '') {
                                    _emptyTelpKonfirmasi = true;
                                  } else {
                                    _emptyTelpKonfirmasi = false;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ]),
                ],
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 30.r : 15.r,
                vertical: isHorizontal ? 20.r : 10.r,
              ),
              child: Column(
                children: [
                  ArgonButton(
                    height: isHorizontal ? 50.h : 40.h,
                    width: isHorizontal ? 90.w : 100.w,
                    borderRadius: isHorizontal ? 60.r : 30.r,
                    color: Colors.blue[700],
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
            )
          ],
        ),
      ),
    );
  }
}
