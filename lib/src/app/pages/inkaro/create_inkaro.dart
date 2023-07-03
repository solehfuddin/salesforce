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
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/customer_inkaro.dart';
import 'package:sample/src/domain/entities/inkaro_manual.dart';
import 'package:sample/src/domain/entities/inkaro_program.dart';
import 'package:sample/src/domain/entities/inkaro_reguler.dart';
import 'package:sample/src/domain/entities/master_bank.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateInkaroScreen extends StatefulWidget {
  final List<ListCustomerInkaro> customerList;
  final int position;

  @override
  _CreateInkaroState createState() => _CreateInkaroState();

  CreateInkaroScreen(this.customerList, this.position);
}

class _CreateInkaroState extends State<CreateInkaroScreen> {
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

    // Merge Selected Inkaro Reguler, Program dan Manual
    List<Object> finalListInkaro = List.empty(growable: true);
    // Merge Inkaro Reguler
    for (int loopReg = 0; loopReg < inkaroRegSelected.length; loopReg++) {
      finalListInkaro.add({
        'CATEGORY_ID': inkaroRegSelected[loopReg].idKategori,
        'type_inkaro': 'reguler',
      });
    }
    // Merge Inkaro Program
    for (int loopProg = 0; loopProg < inkaroProgSelected.length; loopProg++) {
      finalListInkaro.add({
        'CATEGORY_ID': inkaroProgSelected[loopProg].idCategory,
        'SUBCATEGORY_ID': inkaroProgSelected[loopProg].idSubcategory,
        'type_inkaro': 'program',
      });
    }
    // Merge Inkaro Manual
    for (int loopManual = 0;
        loopManual < inkaroManualSelected.length;
        loopManual++) {
      finalListInkaro.add({
        'SUBCATEGORY_ID': inkaroManualSelected[loopManual].idSubcategory,
        'type_inkaro': 'manual',
        'inkaro_value': inkaroManualSelected[loopManual].inkaroValue
      });
    }

    try {
      var response = await http.post(Uri.parse(url), body: {
        'cust_ship_num': widget.customerList[widget.position].noAccount,
        'customer_id': widget.customerList[widget.position].customerId,
        'bill_to_site_use_id':
            widget.customerList[widget.position].billToSiteUseId,
        'start_periode': mulaiPeriode,
        'end_periode': selesaiPeriode,
        'npwp': npwp != null ? npwp : '',
        'nik_ktp': nikKTP,
        'nama_staff': namaStaff,
        'bank': _choosenBank,
        'nomor_rekening': nomorRekening,
        'an_rekening': atasNama,
        'telp_konfirmasi': telpKonfirmasi,
        'created_by': id,
        'detail_inkaro': json.encode(finalListInkaro)
      }, headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      // RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      // print(response.body.replaceAll(exp, ''));
      // print('test');

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'].toString();

      // print(res);
      debugPrint(response.body, wrapWidth: 10240);

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

  getKategoriInkaro() async {
    const timeout = 15;
    var url = '$API_URL/inkaro/category_inkaro';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];
        if (sts) {
          var rest = data['data'];
          setState(() {
            itemInkaroReguler = rest
                .map<InkaroReguler>((json) => InkaroReguler.fromJson(json))
                .toList();
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

  getProgramItemInkaro() async {
    const timeout = 15;
    var url = '$API_URL/inkaro/item_inkaro';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];
        if (sts) {
          var rest = data['data'];
          print(rest);
          setState(() {
            itemInkaroProgram = rest
                .map<InkaroProgram>((json) => InkaroProgram.fromJson(json))
                .toList();
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

  getSelectedInkaroReguler() {
    setState(() {
      inkaroRegSelected = List.empty(growable: true);
    });
    if (itemInkaroReguler.isNotEmpty) {
      for (int i = 0; i < itemInkaroReguler.length; i++) {
        if (itemInkaroReguler[i].ischecked) {
          setState(() {
            inkaroRegSelected.add(itemInkaroReguler[i]);
          });
        }
      }
    }
  }

  getSelectedInkaroProgram() {
    if (listInkaroProgram.isNotEmpty) {
      for (int i = 0; i < listInkaroProgram.length; i++) {
        if (listInkaroProgram[i].ischecked) {
          if (!indexInkaroProgSelected
              .contains(listInkaroProgram[i].idSubcategory)) {
            indexInkaroProgSelected.add(listInkaroProgram[i].idSubcategory);

            setState(() {
              inkaroProgSelected.add(listInkaroProgram[i]);
            });
          }
        } else {
          if (indexInkaroProgSelected
              .contains(listInkaroProgram[i].idSubcategory)) {
            indexInkaroProgSelected.remove(listInkaroProgram[i].idSubcategory);

            setState(() {
              if (inkaroProgSelected.length > 0) {
                inkaroProgSelected.removeWhere((item) =>
                    item.idSubcategory == listInkaroProgram[i].idSubcategory);
              }
            });
          }
        }
      }
    }
  }

  getSelectedInkaroManual() {
    if (listInkaroManual.isNotEmpty) {
      for (int i = 0; i < listInkaroManual.length; i++) {
        if (listInkaroManual[i].ischecked) {
          if (!indexInkaroManualSelected
              .contains(listInkaroManual[i].idSubcategory)) {
            indexInkaroManualSelected.add(listInkaroManual[i].idSubcategory);

            setState(() {
              inkaroManualSelected.add(listInkaroManual[i]);
            });
          }
        } else {
          if (indexInkaroManualSelected
              .contains(listInkaroManual[i].idSubcategory)) {
            indexInkaroManualSelected.remove(listInkaroManual[i].idSubcategory);

            setState(() {
              if (inkaroManualSelected.length > 0) {
                inkaroManualSelected.removeWhere((item) =>
                    item.idSubcategory == listInkaroManual[i].idSubcategory);
              }
            });
          }
        }
      }
    }
  }

  Future<List<InkaroProgram>> getSearchInkaroProgram(String input) async {
    List<InkaroProgram> list = List.empty(growable: true);
    const timeout = 15;
    var url =
        '$API_URL/inkaro/item_inkaro?search=$input&category_id=$_choosenFilterSubcatProg';
    print(url);
    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          setState(() {
            list = rest
                .map<InkaroProgram>((json) => InkaroProgram.fromJson(json))
                .toList();
            listInkaroProgram = rest
                .map<InkaroProgram>((json) => InkaroProgram.fromJson(json))
                .toList();
          });

          print("List Size: ${list.length}");
          print("Product Size: ${listInkaroProgram.length}");

          // CHECKLIST CHECKBOX YANG SUDAH DI CHECKLIST SEBELUMNYA BERDASARKAN indexSelected
          for (int j = 0; j < listInkaroProgram.length; j++) {
            if (indexInkaroProgSelected
                .contains(listInkaroProgram[j].idSubcategory)) {
              listInkaroProgram[j].ischecked = true;
            }
          }
        } else {
          list = List.empty(growable: true);
          listInkaroProgram = List.empty(growable: true);
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

  Future<List<InkaroManual>> getSearchInkaroManual(String input) async {
    List<InkaroManual> list = List.empty(growable: true);
    const timeout = 15;
    var url =
        '$API_URL/inkaro/item_inkaro?search=$input&category_id=$_choosenFilterSubcatManual';
    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          setState(() {
            list = rest
                .map<InkaroManual>((json) => InkaroManual.fromJson(json))
                .toList();
            listInkaroManual = rest
                .map<InkaroManual>((json) => InkaroManual.fromJson(json))
                .toList();
          });

          print("List Size: ${list.length}");
          print("Product Size: ${listInkaroManual.length}");

          // CHECKLIST CHECKBOX YANG SUDAH DI CHECKLIST SEBELUMNYA BERDASARKAN indexSelected
          for (int j = 0; j < listInkaroManual.length; j++) {
            if (indexInkaroManualSelected
                .contains(listInkaroManual[j].idSubcategory)) {
              listInkaroManual[j].ischecked = true;
            }
            listInkaroManual[j].inkaroValue = '0';
          }
        } else {
          list = List.empty(growable: true);
          listInkaroManual = List.empty(growable: true);
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

  Future<List<InkaroReguler>> getCategoryForFilterSubcat() async {
    const timeout = 15;
    var url = '$API_URL/inkaro/filter_category_inkaro';
    List<InkaroReguler> list = List.empty(growable: true);
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
              .map<InkaroReguler>((json) => InkaroReguler.fromJson(json))
              .toList();
          setState(() {
            _dataFilterSubcat = list;
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
    getKategoriInkaro();
    getCategoryForFilterSubcat();
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
            buildSelectedInkaroReguler(inkaroRegSelected,
                isHorizontal: isHorizontal),
            buildSelectedInkaroProgram(inkaroProgSelected,
                isHorizontal: isHorizontal),
            buildSelectedInkaroManual(inkaroManualSelected,
                isHorizontal: isHorizontal),
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

  Widget buildSelectedInkaroReguler(List<InkaroReguler> itemSelected,
      {bool isHorizontal = false}) {
    return Padding(
        padding: EdgeInsets.only(top: 15.r, left: 10.r, right: 10.r),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.r, vertical: 15.r),
                child: Text(
                  'C. DATA INKARO REGULER (PCS)',
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Montserrat',
                    fontSize: isHorizontal ? 20.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.r,
                ),
                child: Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.lightBlue,
                    shape: CircleBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        constraints: BoxConstraints(
                          maxHeight: isHorizontal ? 40.r : 30.r,
                          maxWidth: isHorizontal ? 40.r : 30.r,
                        ),
                        icon: const Icon(Icons.add),
                        iconSize: isHorizontal ? 20.r : 15.r,
                        color: Colors.white,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return dialogInkaroReguler(itemInkaroReguler);
                              });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: isHorizontal ? 4 : 3,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 5.r : 5.r,
                      top: 2.r,
                      bottom: 2.r,
                    ),
                    child: Text(
                      'Kategori Produk',
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                      child: Text(
                    'Percent',
                    style: TextStyle(
                      fontSize: isHorizontal ? 18.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 5.r,
                      ),
                      child: Text(
                        'Nilai',
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    )),
              ],
            ),
            itemSelected.length > 0
                ? Container(
                    padding: EdgeInsets.only(top: 10.w),
                    height: isHorizontal ? 160.h : 150.h,
                    child: ListView.builder(
                      itemCount: itemSelected.length,
                      itemBuilder: (_, index) {
                        return Row(
                          children: [
                            Expanded(
                                flex: isHorizontal ? 4 : 3,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: isHorizontal ? 5.r : 5.r,
                                      top: 2.r,
                                      bottom: 2.r,
                                    ),
                                    child: Text(
                                        itemSelected[index].descKategori))),
                            Expanded(
                                flex: 1,
                                child: Center(
                                    child: Text(
                                        itemSelected[index].inkaroPercent +
                                            '%'))),
                            Expanded(
                                flex: 2,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: 5.r,
                                    ),
                                    child: Text(
                                      convertToIdr(
                                          int.parse(
                                              itemSelected[index].inkaroValue),
                                          0),
                                      textAlign: TextAlign.end,
                                    ))),
                          ],
                        );
                      },
                    ))
                : Padding(
                    padding: EdgeInsets.only(
                        top: 70.r, bottom: 70.r, left: 10.r, right: 10.r),
                    child: Center(
                      child: Text(
                        'Tambahkan Inkaro Reguler',
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
          ],
        ));
  }

  Widget dialogInkaroReguler(List<InkaroReguler> item) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text('Pilih Inkaro Reguler'),
        actions: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                    onPressed: () {
                      getSelectedInkaroReguler();
                      print('submit');
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ],
            ),
          )
        ],
        content: Container(
          // width: double.minPositive.w,
          width: MediaQuery.of(context).size.width / 1,
          height: 300.h,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: item.length,
            itemBuilder: (BuildContext context, int index) {
              String _key = item[index].descKategori;
              return CheckboxListTile(
                value: item[index].ischecked,
                title: Text(_key),
                onChanged: (bool? val) {
                  setState(() {
                    item[index].ischecked = val!;
                  });
                },
              );
            },
          ),
        ),
      );
    });
  }

  Widget buildSelectedInkaroProgram(List<InkaroProgram> itemSelected,
      {bool isHorizontal = false}) {
    return Padding(
        padding: EdgeInsets.only(top: 15.r, left: 10.r, right: 10.r),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.r, vertical: 15.r),
                child: Text(
                  'D. DATA INKARO PROGRAM (PCS)',
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Montserrat',
                    fontSize: isHorizontal ? 20.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.r,
                ),
                child: Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.lightBlue,
                    shape: CircleBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        constraints: BoxConstraints(
                          maxHeight: isHorizontal ? 40.r : 30.r,
                          maxWidth: isHorizontal ? 40.r : 30.r,
                        ),
                        icon: const Icon(Icons.add),
                        iconSize: isHorizontal ? 20.r : 15.r,
                        color: Colors.white,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                print(itemInkaroProgram);
                                return dialogInkaroProgram(itemInkaroProgram);
                              });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: isHorizontal ? 4 : 3,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 5.r : 5.r,
                      top: 2.r,
                      bottom: 2.r,
                    ),
                    child: Text(
                      'Produk',
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                      child: Text(
                    'Percent',
                    style: TextStyle(
                      fontSize: isHorizontal ? 18.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 5.r,
                      ),
                      child: Text(
                        'Nilai',
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    )),
              ],
            ),
            itemSelected.length > 0
                ? Container(
                    padding: EdgeInsets.only(top: 10.w),
                    height: isHorizontal ? 160.h : 150.h,
                    child: ListView.builder(
                      itemCount: itemSelected.length,
                      itemBuilder: (_, index) {
                        return Padding(
                            padding: EdgeInsets.only(bottom: 5.r),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: isHorizontal ? 4 : 3,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          left: isHorizontal ? 5.r : 5.r,
                                          top: 2.r,
                                          bottom: 2.r,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              itemSelected[index]
                                                  .descSubcategory,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 3.r,
                                            ),
                                            Text('Kategori : ' +
                                                itemSelected[index]
                                                    .descCategory)
                                          ],
                                        ))),
                                Expanded(
                                    flex: 1,
                                    child: Center(
                                        child: Text(
                                            itemSelected[index].inkaroPercent +
                                                '%'))),
                                Expanded(
                                    flex: 1,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          right: 5.r,
                                        ),
                                        child: Text(
                                          convertToIdr(
                                              int.parse(itemSelected[index]
                                                  .inkaroValue),
                                              0),
                                          textAlign: TextAlign.end,
                                        ))),
                              ],
                            ));
                      },
                    ))
                : Padding(
                    padding: EdgeInsets.only(
                        top: 70.r, bottom: 70.r, left: 10.r, right: 10.r),
                    child: Center(
                      child: Text(
                        'Tambahkan Inkaro Reguler',
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
          ],
        ));
  }

  Widget dialogInkaroProgram(List<InkaroProgram> item) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text('Pilih Inkaro Program'),
        actions: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                    onPressed: () {
                      getSelectedInkaroProgram();
                      print('submit');
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ],
            ),
          )
        ],
        content: Container(
          height: MediaQuery.of(context).size.height / 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 350.w,
                color: Colors.white,
                height: 50.h,
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
                      searchInkaroProgram = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10.r),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(5.r)),
                  child: DropdownButton(
                    underline: SizedBox(),
                    isExpanded: true,
                    value: _choosenFilterSubcatProg,
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Segoe Ui',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _dataFilterSubcat.map((e) {
                      return DropdownMenuItem(
                        value: e.idKategori,
                        child: Padding(
                            padding: EdgeInsets.only(left: 5.w, right: 5.w),
                            child: Text(e.descKategori,
                                style: TextStyle(color: Colors.black54))),
                      );
                    }).toList(),
                    hint: Padding(
                        padding: EdgeInsets.only(left: 5.w, right: 5.w),
                        child: Text(
                          "Filter Kategori",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe Ui'),
                        )),
                    onChanged: (String? value) {
                      setState(() {
                        _choosenFilterSubcatProg = value!;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 100.h,
                  child: FutureBuilder(
                      future: searchInkaroProgram.isNotEmpty
                          ? getSearchInkaroProgram(searchInkaroProgram)
                          : getSearchInkaroProgram(''),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<InkaroProgram>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            print(listInkaroProgram.length);
                            return snapshot.hasData
                                ? widgetListInkaroProgram(listInkaroProgram)
                                : Center(
                                    child: Text('Data tidak ditemukan'),
                                  );
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget widgetListInkaroProgram(List<InkaroProgram> item) {
    return StatefulBuilder(builder: (context, setState) {
      return _isEmpty
          ? Center(
              child: Text("Masukkan pencarian lain"),
            )
          : Container(
              width: double.minPositive.w,
              height: 350.h,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: item.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          )),
                      margin: EdgeInsets.only(bottom: 10.h),
                      child: indexInkaroManualSelected
                              .contains(item[index].idSubcategory)
                          ? Padding(
                              padding: EdgeInsets.all(10.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item[index].descCategory,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                      'Kategori : ' + item[index].descCategory),
                                  SizedBox(height: 10.h),
                                  Text(
                                    'Sudah Dipilih di Form Inkaro Manual',
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ))
                          : CheckboxListTile(
                              value: item[index].ischecked,
                              title: Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 10.h, top: 10.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item[index].descSubcategory,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text('Kategori : ' +
                                          item[index].descCategory)
                                    ],
                                  )),
                              onChanged: (bool? val) {
                                setState(() {
                                  item[index].ischecked = val!;
                                });
                              },
                            ));
                },
              ));
    });
  }

  Widget buildSelectedInkaroManual(List<InkaroManual> itemSelected,
      {bool isHorizontal = false}) {
    return Padding(
        padding: EdgeInsets.only(top: 15.r, left: 10.r, right: 10.r),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.r, vertical: 15.r),
                child: Text(
                  'E. DATA INKARO MANUAL (PCS)',
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Montserrat',
                    fontSize: isHorizontal ? 20.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.r,
                ),
                child: Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.lightBlue,
                    shape: CircleBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        constraints: BoxConstraints(
                          maxHeight: isHorizontal ? 40.r : 30.r,
                          maxWidth: isHorizontal ? 40.r : 30.r,
                        ),
                        icon: const Icon(Icons.add),
                        iconSize: isHorizontal ? 20.r : 15.r,
                        color: Colors.white,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return dialogInkaroManual(itemInkaroManual);
                              });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: isHorizontal ? 5 : 4,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 5.r : 5.r,
                      top: 2.r,
                      bottom: 2.r,
                    ),
                    child: Text(
                      'Produk',
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Center(
                //       child: Text(
                //     'Percent',
                //     style: TextStyle(
                //       fontSize: isHorizontal ? 18.sp : 14.sp,
                //       fontFamily: 'Montserrat',
                //       fontWeight: FontWeight.w500,
                //     ),
                //   )),
                // ),
                // SizedBox(
                //   width: isHorizontal ? 5.w : 10.w,
                // ),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 5.r,
                      ),
                      child: Text(
                        'Nilai',
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )),
              ],
            ),
            itemSelected.length > 0
                ? Form(
                    key: formKeyInkaroManual,
                    child: Container(
                        padding: EdgeInsets.only(top: 10.w),
                        height: isHorizontal ? 160.h : 150.h,
                        child: ListView.builder(
                          itemCount: itemSelected.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding:
                                    EdgeInsets.only(bottom: 10.r, right: 3.r),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: isHorizontal ? 5 : 4,
                                      child: Padding(
                                          padding: EdgeInsets.only(
                                            left: isHorizontal ? 5.r : 5.r,
                                            top: 2.r,
                                            bottom: 2.r,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                itemSelected[index]
                                                    .descSubcategory,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              Text('Kategori : ' +
                                                  itemSelected[index]
                                                      .descCategory)
                                            ],
                                          )),
                                    ),
                                    // Expanded(
                                    //   flex: 1,
                                    //   child: TextFormField(
                                    //     initialValue:
                                    //         itemSelected[index].inkaroPercent,
                                    //     keyboardType: TextInputType.number,
                                    //     maxLength: 3,
                                    //     decoration: InputDecoration(
                                    //       counterText: "",
                                    //       contentPadding: EdgeInsets.symmetric(
                                    //         horizontal: isHorizontal ? 10.r : 10.r,
                                    //       ),
                                    //       border: OutlineInputBorder(
                                    //         borderRadius: BorderRadius.circular(5),
                                    //       ),
                                    //       hintStyle: TextStyle(
                                    //         fontFamily: 'Segoe Ui',
                                    //         fontSize: isHorizontal ? 18.sp : 16.sp,
                                    //         fontWeight: FontWeight.w600,
                                    //       ),
                                    //     ),
                                    //     textAlign: TextAlign.center,
                                    //     // controller: widget._discvalController,
                                    //     onChanged: (value) {
                                    //       setState(() {
                                    //         inkaroManualSelected[index]
                                    //             .inkaroPercent = value;
                                    //       });
                                    //     },
                                    //     onSaved: (value) {
                                    //       setState(() {
                                    //         inkaroManualSelected[index]
                                    //             .inkaroPercent = value!;
                                    //       });
                                    //     },
                                    //   ),
                                    // ),
                                    // SizedBox(
                                    //   width: isHorizontal ? 5.w : 10.w,
                                    // ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        inputFormatters: [
                                          ThousandsSeparatorInputFormatter()
                                        ],
                                        keyboardType: TextInputType.number,
                                        maxLength: 10,
                                        decoration: InputDecoration(
                                          counterText: "",
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal:
                                                isHorizontal ? 10.r : 10.r,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          hintStyle: TextStyle(
                                            fontFamily: 'Segoe Ui',
                                            fontSize:
                                                isHorizontal ? 18.sp : 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        textAlign: TextAlign.center,
                                        initialValue:
                                            ThousandsSeparatorInputFormatter()
                                                .formatEditUpdate(
                                                    TextEditingValue.empty,
                                                    TextEditingValue(
                                                        text:
                                                            inkaroManualSelected[
                                                                    index]
                                                                .inkaroValue
                                                                .toString()))
                                                .text,
                                        onChanged: (value) {
                                          setState(() {
                                            inkaroManualSelected[index]
                                                    .inkaroValue =
                                                value.replaceAll(".", "");
                                          });
                                        },
                                        onSaved: (value) {
                                          setState(() {
                                            inkaroManualSelected[index]
                                                    .inkaroValue =
                                                value!.replaceAll(".", "");
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ));
                          },
                        )))
                : Padding(
                    padding: EdgeInsets.only(
                        top: 70.r, bottom: 70.r, left: 10.r, right: 10.r),
                    child: Center(
                      child: Text(
                        'Tambahkan Inkaro Manual',
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
          ],
        ));
  }

  Widget dialogInkaroManual(List<InkaroManual> item) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text('Pilih Inkaro Manual'),
        actions: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        getSelectedInkaroManual();
                      });
                      formKeyInkaroManual.currentState?.reset();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ],
            ),
          )
        ],
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
                      searchInkaroManual = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10.r),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(5.r)),
                  child: DropdownButton(
                    underline: SizedBox(),
                    isExpanded: true,
                    value: _choosenFilterSubcatManual,
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Segoe Ui',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _dataFilterSubcat.map((e) {
                      return DropdownMenuItem(
                        value: e.idKategori,
                        child: Padding(
                            padding: EdgeInsets.only(left: 5.w, right: 5.w),
                            child: Text(e.descKategori,
                                style: TextStyle(color: Colors.black54))),
                      );
                    }).toList(),
                    hint: Padding(
                        padding: EdgeInsets.only(left: 5.w, right: 5.w),
                        child: Text(
                          "Filter Kategori",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe Ui'),
                        )),
                    onChanged: (String? value) {
                      setState(() {
                        _choosenFilterSubcatManual = value!;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 100.h,
                  child: FutureBuilder(
                      future: searchInkaroManual.isNotEmpty
                          ? getSearchInkaroManual(searchInkaroManual)
                          : getSearchInkaroManual(''),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<InkaroManual>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            return snapshot.hasData
                                ? widgetListInkaroManual(listInkaroManual)
                                : Center(
                                    child: Text('Data tidak ditemukan'),
                                  );
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget widgetListInkaroManual(List<InkaroManual> item) {
    return StatefulBuilder(builder: (context, setState) {
      return _isEmpty
          ? Center(
              child: Text("Masukkan pencarian lain"),
            )
          : Container(
              width: double.minPositive.w,
              height: 350.h,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: item.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          )),
                      margin: EdgeInsets.only(bottom: 10.h),
                      child: indexInkaroProgSelected
                              .contains(item[index].idSubcategory)
                          ? Padding(
                              padding: EdgeInsets.only(
                                  bottom: 10.h,
                                  top: 10.h,
                                  left: 10.r,
                                  right: 10.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item[index].descSubcategory,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                      'Kategori : ' + item[index].descCategory),
                                  SizedBox(height: 10.h),
                                  Text(
                                    'Sudah Dipilih di Form Inkaro Program',
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ))
                          : CheckboxListTile(
                              value: item[index].ischecked,
                              title: Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 10.h, top: 10.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item[index].descSubcategory,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text('Kategori : ' +
                                          item[index].descCategory)
                                    ],
                                  )),
                              onChanged: (bool? val) {
                                setState(() {
                                  item[index].ischecked = val!;
                                });
                              },
                            ));
                },
              ));
    });
  }
}
