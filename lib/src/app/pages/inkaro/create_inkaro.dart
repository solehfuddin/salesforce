import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:date_field/date_field.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
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
import 'package:sample/src/domain/entities/list_inkaro_detail.dart';
import 'package:sample/src/domain/entities/list_inkaro_header.dart';
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
  TextEditingController textIntervalPembayaran = new TextEditingController();
  TextEditingController textNotesContract = new TextEditingController();
  final formKeyInkaroManual = GlobalKey<FormState>();

  late String tokenSm, idSm;
  String? id = '';
  String? role = '';
  String? username = '';
  String searchInkaroProgram = '';
  String searchInkaroManual = '';
  final format = DateFormat("dd MMM yyyy");
  bool _isHorizontal = false;
  bool _isLoadingInkaroManualSelected = false,
      isSwitchedCopyTemplateContract = false,
      isSwitchedHouseBrandProgram = false,
      isSwitchedHouseBrandManual = false;

  bool checkAllInkaroReguler = false,
      checkAllInkaroProgram = false,
      checkAllInkaroManual = false,
      checkSetAllValueManual = false;

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
      _choosenFilterSubcatManual,
      _choosenCopyContract,
      _choosenJabatan,
      _choosenSatuanIntervalPembayaran = "BULAN",
      _intervalPembayaran = "",
      fullIntervalPembayaran;
  String notesContract = '', allValueManual = '';
  bool _emptyNamaStaff = false,
      _emptyNikKTP = false,
      // _emptyNpwp = false,
      _emptyNomorRekening = false,
      _emptyMulaiPeriode = false,
      _emptySelesaiPeriode = false,
      _emptyAtasNama = false,
      _emptyTelpKonfirmasi = false,
      _emptyNotesContract = false,
      _emptyIntervalPembayaran = false;

  checkEntry({bool isHorizontal = false}) {
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
      textIntervalPembayaran.text.isEmpty
          ? _emptyAtasNama = true
          : _emptyAtasNama = false;
      (mulaiPeriode != '' && mulaiPeriode != null)
          ? _emptyMulaiPeriode = false
          : _emptyMulaiPeriode = true;
      (selesaiPeriode != '' && selesaiPeriode != null)
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
        _emptyIntervalPembayaran ||
        _choosenBank == '' ||
        _choosenBank == null ||
        _choosenJabatan == '' ||
        _choosenJabatan == null) {
      handleStatus(
        context,
        'Harap lengkapi isian yang telah disediakan.',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    } else {
      if (isSwitchedCopyTemplateContract &&
          _choosenCopyContract != null &&
          _choosenCopyContract != '') {
        simpanData(isHorizontal: isHorizontal);
      } else {
        if (!isSwitchedCopyTemplateContract) {
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
          } else {
            if (validationInkaroManual) {
              handleStatus(
                context,
                'Harap Lengkapi Nilai Inkaro untuk Tipe Inkaro Manual.',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );
            } else {
              simpanData(isHorizontal: isHorizontal);
            }
          }
        } else {
          handleStatus(
            context,
            'Pilih Kontrak Yang Ingin Disalin Terlebih Dahulu.',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }
      }
    }
  }

  getTokenSM(int smID) async {
    const timeout = 15;
    var url = '$API_URL/users?id=$smID';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          idSm = data['data']['id'];
          tokenSm = data['data']['gentoken'];
          print('Id SM : $idSm');
          print('Token SM : $tokenSm');
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
  }

  onButtonPressed() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
      () => checkEntry(
        isHorizontal: _isHorizontal,
      ),
    );

    return () {};
  }

  simpanData({bool isHorizontal = false}) async {
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

    // Check Data Copy Contract
    String copyContract = '';
    if (isSwitchedCopyTemplateContract) {
      copyContract = _choosenCopyContract!;
    } else {
      copyContract = '';
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
        'jabatan': _choosenJabatan,
        'bank': _choosenBank,
        'nomor_rekening': nomorRekening,
        'an_rekening': atasNama,
        'telp_konfirmasi': telpKonfirmasi,
        'interval_pembayaran': _intervalPembayaran.toString() +
            " " +
            _choosenSatuanIntervalPembayaran.toString(),
        'created_by': id,
        'detail_inkaro': json.encode(finalListInkaro),
        'notes': notesContract,
        'copyContract': copyContract
      }, headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'].toString();

      // debugPrint(response.body, wrapWidth: 10240);

      if (mounted) {
        handleStatus(
          context,
          msg,
          sts,
          isHorizontal: isHorizontal,
          isLogout: false,
        );

        pushNotif(
          13,
          3,
          idUser: idSm,
          rcptToken: tokenSm,
          salesName: username,
          opticName: widget.customerList[widget.position].namaUsaha,
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
  }

  getKategoriInkaro() async {
    const timeout = 15;
    var url = '$API_URL/inkaro/category_inkaro?typeGet=all';

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
              // Set Value Inkaro New Selected to Same Value [feat.setAllValue]
              if (checkSetAllValueManual) {
                listInkaroManual[i].inkaroValue =
                    allValueManual.replaceAll('.', '');
              }
              inkaroManualSelected.add(listInkaroManual[i]);
            });
          } else {
            // Get Index List inkaroManualSelected with Value SubCategory is Checked [feat.setAllValue]
            final indexTempSelected = inkaroManualSelected.indexWhere(
                (element) =>
                    element.idSubcategory == listInkaroManual[i].idSubcategory);
            setState(() {
              // Set Value Inkaro Before Selected to Same Value [feat.setAllValue]
              if (checkSetAllValueManual) {
                inkaroManualSelected[indexTempSelected].inkaroValue =
                    allValueManual.replaceAll('.', '');
              }
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
    String houseBrand = isSwitchedHouseBrandProgram ? 'on' : 'off';
    var url =
        '$API_URL/inkaro/item_inkaro?search=$input&category_id=$_choosenFilterSubcatProg&house_brand=$houseBrand';
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
            list = rest
                .map<InkaroProgram>((json) => InkaroProgram.fromJson(json))
                .toList();
            listInkaroProgram = rest
                .map<InkaroProgram>((json) => InkaroProgram.fromJson(json))
                .toList();
          });

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
    String houseBrand = isSwitchedHouseBrandManual ? 'on' : 'off';
    var url =
        '$API_URL/inkaro/item_inkaro?search=$input&category_id=$_choosenFilterSubcatManual&house_brand=$houseBrand';
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
            list = rest
                .map<InkaroManual>((json) => InkaroManual.fromJson(json))
                .toList();
            listInkaroManual = rest
                .map<InkaroManual>((json) => InkaroManual.fromJson(json))
                .toList();
          });

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
  List<ListInkaroHeader> _dataCopyContract = List.empty(growable: true);
  List _dataJabatan = [
    {'label': 'Karyawan Optik', 'value_jabatan': 'KARYAWAN OPTIK'},
    {'label': 'Manager Optik', 'value_jabatan': 'MANAGER OPTIK'},
    {'label': 'Owner Optik', 'value_jabatan': 'OWNER OPTIK'},
  ];
  List _dataSatuanIntervalPembayaran = [
    {'label': 'Bulan', 'value_satuan': 'BULAN'},
    {'label': 'Tahun', 'value_satuan': 'TAHUN'},
  ];
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

  Future<List<ListInkaroHeader>> getOptionCopyContract() async {
    const timeout = 15;
    var url = '$API_URL/inkaro/getInkaroHeader';
    List<ListInkaroHeader> list = List.empty(growable: true);
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
              .map<ListInkaroHeader>((json) => ListInkaroHeader.fromJson(json))
              .toList();
          setState(() {
            _dataCopyContract = list;
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

  List<ListInkaroDetail> listInkaroDetailReguler = List.empty(growable: true);
  List<ListInkaroDetail> listInkaroDetailProgram = List.empty(growable: true);
  List<ListInkaroDetail> listInkaroDetailManual = List.empty(growable: true);

  getListInkaro() async {
    const timeout = 15;
    var url =
        '$API_URL/inkaro/getInkaroDetail?id_inkaro_header=$_choosenCopyContract';

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
            listInkaroDetailReguler = rest['reguler']
                .map<ListInkaroDetail>(
                    (json) => ListInkaroDetail.fromJson(json))
                .toList();
            listInkaroDetailProgram = rest['program']
                .map<ListInkaroDetail>(
                    (json) => ListInkaroDetail.fromJson(json))
                .toList();
            listInkaroDetailManual = rest['manual']
                .map<ListInkaroDetail>(
                    (json) => ListInkaroDetail.fromJson(json))
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
    getOptionCopyContract();
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
      getTtdSales(int.parse(id!));
    });
  }

  getTtdSales(int input) async {
    var url = '$API_URL/users?id=$input';

    var response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');

    try {
      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        int areaId =
            data['data']['area'] != null ? int.parse(data['data']['area']) : 29;
        getTokenSM(areaId);
      }
    } on FormatException catch (e) {
      print('Format Error : $e');
    }
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
    _isHorizontal = isHorizontal;
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
                        'Pilih Jabatan',
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
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.r, vertical: 7.r),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5.r)),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      value: _choosenJabatan,
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Segoe Ui',
                        fontSize: isHorizontal ? 18.sp : 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      items: _dataJabatan
                          .map((val) => DropdownMenuItem(
                                value: val["value_jabatan"],
                                child: Text(val["label"]),
                              ))
                          .toList(),
                      hint: Text(
                        "Pilih Jabatan",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: isHorizontal ? 18.sp : 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe Ui'),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _choosenJabatan = value.toString();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 22.sp : 12.h,
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
                        'Nomor Rekening / e-Wallet',
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
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
                      ]),
                  SizedBox(
                    height: isHorizontal ? 22.sp : 12.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Atas Nama',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                              errorText: _emptyAtasNama ? 'Wajib diisi' : null,
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
                    ],
                  ),
                  SizedBox(
                    height: isHorizontal ? 22.sp : 12.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Interval Pembayaran',
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 15.0, right: 10.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              errorText: _emptyIntervalPembayaran
                                  ? 'Wajib diisi'
                                  : null,
                            ),
                            maxLength: 50,
                            controller: textIntervalPembayaran,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Segoe Ui',
                            ),
                            onChanged: (String? value) {
                              setState(() {
                                _intervalPembayaran = value!;
                                if (value == '') {
                                  _emptyIntervalPembayaran = true;
                                } else {
                                  _emptyIntervalPembayaran = false;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 5.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.r, vertical: 7.r),
                          decoration: BoxDecoration(
                              color: Colors.white70,
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(5.r)),
                          child: DropdownButton(
                            underline: SizedBox(),
                            isExpanded: true,
                            value: _choosenSatuanIntervalPembayaran,
                            style: TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Segoe Ui',
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            items: _dataSatuanIntervalPembayaran
                                .map((val) => DropdownMenuItem(
                                      value: val["value_satuan"],
                                      child: Text(val["label"]),
                                    ))
                                .toList(),
                            hint: Text(
                              "Pilih Interval Pembayaran",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: isHorizontal ? 18.sp : 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Segoe Ui'),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _choosenSatuanIntervalPembayaran =
                                    value.toString();
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: isHorizontal ? 22.sp : 12.h,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 10.sp),
              child: Row(
                children: [
                  Switch(
                    value: isSwitchedCopyTemplateContract,
                    onChanged: (value) {
                      setState(() {
                        isSwitchedCopyTemplateContract = value;
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                  Text(
                    "Salin Data Kontrak dari Kontrak Lain",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      fontFamily: 'Montserrat',
                    ),
                  )
                ],
              ),
            ),
            isSwitchedCopyTemplateContract
                ? Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pilih Kontrak yang ingin disalin",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(
                          height: 10.sp,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.r, vertical: 7.r),
                          decoration: BoxDecoration(
                              color: Colors.white70,
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(5.r)),
                          child: DropdownButton(
                            underline: SizedBox(),
                            isExpanded: true,
                            value: _choosenCopyContract,
                            style: TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Segoe Ui',
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            items: _dataCopyContract.map((e) {
                              return DropdownMenuItem(
                                value: e.inkaroContractId,
                                child: Text(e.customerShipName,
                                    style: TextStyle(color: Colors.black54)),
                              );
                            }).toList(),
                            hint: Text(
                              "Pilih Kontrak",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: isHorizontal ? 18.sp : 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Segoe Ui'),
                            ),
                            onChanged: (String? value) async {
                              setState(() {
                                _choosenCopyContract = value!;
                              });
                              await getListInkaro();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10.sp,
                        ),
                        _choosenCopyContract != null
                            ? buildPreviewDetailContractToCopy(
                                listInkaroDetailReguler,
                                listInkaroDetailProgram,
                                listInkaroDetailManual)
                            : Padding(
                                padding: EdgeInsets.all(15.sp),
                                child: Text(
                                    "Silahkan Pilih Kontrak Yang Ingin Disalin"))
                      ],
                    ),
                  )
                : StatefulBuilder(builder: (context, setState) {
                    return buildSelectedInkaroReguler(inkaroRegSelected,
                        isHorizontal: isHorizontal);
                  }),
            isSwitchedCopyTemplateContract
                ? SizedBox()
                : StatefulBuilder(builder: (context, setState) {
                    return buildSelectedInkaroProgram(inkaroProgSelected,
                        isHorizontal: isHorizontal);
                  }),
            isSwitchedCopyTemplateContract
                ? SizedBox()
                : StatefulBuilder(builder: (context, setState) {
                    return buildSelectedInkaroManual(inkaroManualSelected,
                        isHorizontal: isHorizontal);
                  }),
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
                  EasyButton(
                    idleStateWidget: Text(
                      "Simpan",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontWeight: FontWeight.w700),
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
                    buttonColor: Colors.blue.shade700,
                    elevation: 2.0,
                    contentGap: 6.0,
                    onPressed: onButtonPressed,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildPreviewDetailContractToCopy(
      List<ListInkaroDetail> listPreviewInkaroReguler,
      List<ListInkaroDetail> listPreviewInkaroProgram,
      List<ListInkaroDetail> listPreviewInkaroManual) {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        children: [
          Card(
              margin: EdgeInsets.all(10.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  // implement shadow effect
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black38, // shadow color
                        blurRadius: 5, // shadow radius
                        offset: Offset(3, 3), // shadow offset
                        spreadRadius:
                            0.1, // The amount the box should be inflated prior to applying the blur
                        blurStyle: BlurStyle.normal // set blur style
                        ),
                  ],
                ),
                child: ExpansionTile(
                  title: Text(
                    'INKARO REGULER',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                  children: <Widget>[
                    Card(
                      color: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.sp, vertical: 10.sp),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'BRAND',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Percent',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Inkaro',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.sp,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              listPreviewInkaroReguler.length > 0
                                  ? SingleChildScrollView(
                                      physics: ScrollPhysics(),
                                      child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              listPreviewInkaroReguler.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                                padding: EdgeInsets.only(
                                                  top: 1.sp,
                                                  bottom: 1.sp,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        listPreviewInkaroReguler[
                                                                index]
                                                            .descKategori,
                                                        style: TextStyle(
                                                          fontSize: 11.sp,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        listPreviewInkaroReguler[
                                                                index]
                                                            .inkaroPercent,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 11.sp,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        convertToIdr(
                                                            int.parse(
                                                                listPreviewInkaroReguler[
                                                                        index]
                                                                    .inkaroValue),
                                                            0),
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          fontSize: 11.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                          }),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: 30.r,
                                          bottom: 30.r,
                                          left: 10.r,
                                          right: 10.r),
                                      child: Center(
                                          child:
                                              Text('Inkaro Reguler Tidak Ada',
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontFamily: 'Montserrat',
                                                  ))))
                            ],
                          )),
                    ),
                  ],
                ),
              )),
          Card(
            margin: EdgeInsets.all(10.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade300,
                // implement shadow effect
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black38, // shadow color
                      blurRadius: 5, // shadow radius
                      offset: Offset(3, 3), // shadow offset
                      spreadRadius:
                          0.1, // The amount the box should be inflated prior to applying the blur
                      blurStyle: BlurStyle.normal // set blur style
                      ),
                ],
              ),
              child: ExpansionTile(
                title: Text(
                  'INKARO PROGRAM',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp),
                ),
                // subtitle: Text('Trailing expansion arrow icon'),
                children: <Widget>[
                  Card(
                    color: Colors.white,
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.sp, vertical: 10.sp),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'BRAND',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.sp),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Percent',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.sp),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Inkaro',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.sp),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            listPreviewInkaroProgram.length > 0
                                ? SingleChildScrollView(
                                    physics: ScrollPhysics(),
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:
                                            listPreviewInkaroProgram.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                              padding: EdgeInsets.only(
                                                top: 1.sp,
                                                bottom: 1.sp,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      listPreviewInkaroProgram[
                                                              index]
                                                          .descSubcategory,
                                                      style: TextStyle(
                                                          fontSize: 11.sp),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      listPreviewInkaroProgram[
                                                              index]
                                                          .inkaroPercent,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 11.sp),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      convertToIdr(
                                                          int.parse(
                                                              listPreviewInkaroProgram[
                                                                      index]
                                                                  .inkaroValue),
                                                          0),
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          fontSize: 11.sp),
                                                    ),
                                                  ),
                                                ],
                                              ));
                                        }))
                                : Padding(
                                    padding: EdgeInsets.only(
                                        top: 30.r,
                                        bottom: 30.r,
                                        left: 10.r,
                                        right: 10.r),
                                    child: Center(
                                        child: Text('Inkaro Program Tidak Ada',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontFamily: 'Montserrat',
                                            ))))
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
          Card(
              margin: EdgeInsets.all(10.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  // implement shadow effect
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black38, // shadow color
                        blurRadius: 5, // shadow radius
                        offset: Offset(3, 3), // shadow offset
                        spreadRadius:
                            0.1, // The amount the box should be inflated prior to applying the blur
                        blurStyle: BlurStyle.normal // set blur style
                        ),
                  ],
                ),
                child: ExpansionTile(
                  title: Text(
                    'INKARO MANUAL',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp),
                  ),
                  // subtitle: Text('Trailing expansion arrow icon'),
                  children: <Widget>[
                    Card(
                      color: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.sp, vertical: 10.sp),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'BRAND',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.sp),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Inkaro',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.sp),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              listPreviewInkaroManual.length > 0
                                  ? SingleChildScrollView(
                                      physics: ScrollPhysics(),
                                      child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              listPreviewInkaroManual.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                                padding: EdgeInsets.only(
                                                  top: 1.sp,
                                                  bottom: 1.sp,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        listPreviewInkaroManual[
                                                                index]
                                                            .descSubcategory,
                                                        style: TextStyle(
                                                            fontSize: 11.sp),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        convertToIdr(
                                                            int.parse(
                                                                listPreviewInkaroManual[
                                                                        index]
                                                                    .inkaroValue),
                                                            0),
                                                        style: TextStyle(
                                                            fontSize: 11.sp),
                                                        textAlign:
                                                            TextAlign.end,
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                          }))
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: 30.r,
                                          bottom: 30.r,
                                          left: 10.r,
                                          right: 10.r),
                                      child: Center(
                                          child: Text('Inkaro Manual Tidak Ada',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontFamily: 'Montserrat',
                                              ))))
                            ],
                          )),
                    ),
                  ],
                ),
              )),
        ],
      );
    });
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
                          checkAllInkaroReguler = false;
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
                    ),
                  )
          ],
        ));
  }

  Widget dialogInkaroReguler(List<InkaroReguler> item) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(
          'Pilih Inkaro Reguler',
          textAlign: TextAlign.center,
        ),
        actions: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    getSelectedInkaroReguler();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  )),
              margin: EdgeInsets.only(bottom: 10.h),
              child: CheckboxListTile(
                value: checkAllInkaroReguler,
                title: Padding(
                  padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pilih Semua",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
                onChanged: (bool? val) {
                  setState(() {
                    checkAllInkaroReguler = val!;
                    for (var loopUpdateCheckedReguler = 0;
                        loopUpdateCheckedReguler < itemInkaroReguler.length;
                        loopUpdateCheckedReguler++) {
                      itemInkaroReguler[loopUpdateCheckedReguler].ischecked =
                          val;
                    }
                  });
                },
              ),
            ),
            Container(
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
          ],
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
                          checkAllInkaroProgram = false;
                          _choosenFilterSubcatProg = null;
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                checkAllInkaroProgram = false;
                                searchInkaroProgram = '';
                                return dialogInkaroProgram();
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

  Widget dialogInkaroProgram() {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: Text(
          'Pilih Inkaro Program',
          textAlign: TextAlign.center,
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(left: 7.0, right: 7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                    onPressed: () {
                      getSelectedInkaroProgram();
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Padding(
            //   padding: EdgeInsets.only(bottom: 10.sp),
            //   child: TextField(
            //     textInputAction: TextInputAction.search,
            //     autocorrect: true,
            //     decoration: InputDecoration(
            //       hintText: 'Pencarian data ...',
            //       prefixIcon: Icon(Icons.search),
            //       hintStyle: TextStyle(color: Colors.grey),
            //       filled: true,
            //       fillColor: Colors.white70,
            //       contentPadding: EdgeInsets.symmetric(vertical: 15.sp),
            //       enabledBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.all(Radius.circular(7.0.sp)),
            //         borderSide: BorderSide(color: Colors.grey, width: 2.r),
            //       ),
            //       focusedBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.all(Radius.circular(7.0.sp)),
            //         borderSide: BorderSide(color: Colors.blue, width: 2.r),
            //       ),
            //     ),
            //     onSubmitted: (value) {
            //       setState(() {
            //         searchInkaroProgram = value;
            //       });
            //     },
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Switch(
                  value: isSwitchedHouseBrandProgram,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedHouseBrandProgram = value;
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
                Text(
                  "House Brand",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    fontFamily: 'Montserrat',
                  ),
                )
              ],
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
                          padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
                          child: Text(e.descKategori,
                              style: TextStyle(color: Colors.black54))),
                    );
                  }).toList(),
                  hint: Padding(
                      padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
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
                      searchInkaroProgram.isNotEmpty
                          ? getSearchInkaroProgram(searchInkaroProgram)
                          : getSearchInkaroProgram('');
                      checkAllInkaroProgram = false;
                    });
                  },
                ),
              ),
            ),
            FutureBuilder(
                future: searchInkaroProgram.isNotEmpty
                    ? getSearchInkaroProgram(searchInkaroProgram)
                    : getSearchInkaroProgram(''),
                builder: (BuildContext context,
                    AsyncSnapshot<List<InkaroProgram>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      return snapshot.hasData
                          ? widgetListInkaroProgram()
                          : Center(
                              child: Text('Data tidak ditemukan'),
                            );
                  }
                })
          ],
        ),
      );
    });
  }

  Widget widgetListInkaroProgram() {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        children: [
          listInkaroProgram.length > 0
              ? Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )),
                  margin: EdgeInsets.only(bottom: 10.h),
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: checkAllInkaroProgram,
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pilih Semua",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),
                    onChanged: (bool? val) {
                      setState(() {
                        checkAllInkaroProgram = val!;
                        for (var loopUpdateCheckedProgram = 0;
                            loopUpdateCheckedProgram < listInkaroProgram.length;
                            loopUpdateCheckedProgram++) {
                          if (!indexInkaroManualSelected.contains(
                              listInkaroProgram[loopUpdateCheckedProgram]
                                  .idSubcategory)) {
                            listInkaroProgram[loopUpdateCheckedProgram]
                                .ischecked = val;
                          }
                        }
                      });
                    },
                  ),
                )
              : SizedBox(),
          listInkaroProgram.length > 0
              ? Container(
                  // width: double.minPositive.w,
                  width: MediaQuery.of(context).size.width / 1,
                  height: 300.h,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: listInkaroProgram.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              )),
                          margin: EdgeInsets.only(bottom: 10.h),
                          child: indexInkaroManualSelected.contains(
                                  listInkaroProgram[index].idSubcategory)
                              ? Padding(
                                  padding: EdgeInsets.all(10.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listInkaroProgram[index]
                                            .descSubcategory,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12.sp),
                                      ),
                                      Text(
                                          'Kategori : ' +
                                              listInkaroProgram[index]
                                                  .descCategory,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                          )),
                                      SizedBox(height: 10.h),
                                      Text(
                                        'Sudah Dipilih di Form Inkaro Manual',
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  ))
                              : CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  value: listInkaroProgram[index].ischecked,
                                  title: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 10.h, top: 10.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listInkaroProgram[index]
                                              .descSubcategory,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.sp,
                                        ),
                                        Text(
                                          "Inkaro : " +
                                              convertToIdr(
                                                  int.parse(
                                                      listInkaroProgram[index]
                                                          .inkaroValue),
                                                  0),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 12.sp,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  onChanged: (bool? val) {
                                    setState(() {
                                      listInkaroProgram[index].ischecked = val!;
                                    });
                                  },
                                ));
                    },
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(top: 20.sp),
                  child: Text("Data Kosong"),
                ),
        ],
      );
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
                          checkSetAllValueManual = false;
                          checkAllInkaroManual = false;
                          _choosenFilterSubcatManual = null;
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                checkAllInkaroProgram = false;
                                searchInkaroManual = '';
                                return dialogInkaroManual();
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
                ? _isLoadingInkaroManualSelected
                    ? CircularProgressIndicator()
                    : Form(
                        key: formKeyInkaroManual,
                        child: Container(
                            padding: EdgeInsets.only(top: 10.w),
                            height: isHorizontal ? 160.h : 150.h,
                            child: ListView.builder(
                              itemCount: itemSelected.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 10.r, right: 3.r),
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
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  Text('Kategori : ' +
                                                      itemSelected[index]
                                                          .descCategory),
                                                  Text('Inkaro Program : ' +
                                                      convertToIdr(
                                                          int.parse(itemSelected[
                                                                  index]
                                                              .inkaroProgram),
                                                          0))
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
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal:
                                                    isHorizontal ? 10.r : 10.r,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              hintStyle: TextStyle(
                                                fontFamily: 'Segoe Ui',
                                                fontSize: isHorizontal
                                                    ? 18.sp
                                                    : 16.sp,
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
                    )),
            SizedBox(
              height: 10.sp,
            ),
            Row(
              children: [
                Text('Catatan Kontrak',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start),
              ],
            ),
            SizedBox(
              height: 10.sp,
            ),
            TextFormField(
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 4,
              maxLength: 250,
              controller: textNotesContract,
              style: TextStyle(
                fontSize: isHorizontal ? 18.sp : 14.sp,
                fontFamily: 'Segoe Ui',
              ),
              onChanged: (String? value) {
                setState(() {
                  notesContract = value!;
                  if (value == '') {
                    _emptyNotesContract = true;
                  } else {
                    _emptyNotesContract = false;
                  }
                });
              },
            ),
          ],
        ));
  }

  Widget dialogInkaroManual() {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: Text(
          'Pilih Inkaro Manual',
          textAlign: TextAlign.center,
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(left: 7.0, right: 7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: checkSetAllValueManual,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Set Semua Inkaro yang Dipilih Menjadi : ",
                        style: TextStyle(color: Colors.black, fontSize: 12.sp),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(
                        height: 5.sp,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.sp),
                        child: TextFormField(
                          enabled: checkSetAllValueManual,
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 5.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            hintStyle: TextStyle(
                              fontFamily: 'Segoe Ui',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          initialValue: ThousandsSeparatorInputFormatter()
                              .formatEditUpdate(TextEditingValue.empty,
                                  TextEditingValue(text: "0"))
                              .text,
                          onChanged: (value) {
                            allValueManual = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  onChanged: (bool? val) {
                    setState(() {
                      checkAllInkaroManual = false;
                      checkSetAllValueManual = val!;
                    });
                  },
                ),
                ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoadingInkaroManualSelected = true;
                      });
                      await getSelectedInkaroManual();
                      Timer(Duration(milliseconds: 500), () {
                        setState(() {
                          _isLoadingInkaroManualSelected = false;
                          Navigator.pop(context);
                        });
                      });
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Padding(
            //   padding: EdgeInsets.only(bottom: 10.sp),
            //   child: TextField(
            //     textInputAction: TextInputAction.search,
            //     autocorrect: true,
            //     decoration: InputDecoration(
            //       hintText: 'Pencarian data ...',
            //       prefixIcon: Icon(Icons.search),
            //       hintStyle: TextStyle(color: Colors.grey),
            //       filled: true,
            //       fillColor: Colors.white70,
            //       contentPadding: EdgeInsets.symmetric(vertical: 15.sp),
            //       enabledBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.all(Radius.circular(7.0.sp)),
            //         borderSide: BorderSide(color: Colors.grey, width: 2.r),
            //       ),
            //       focusedBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.all(Radius.circular(7.0.sp)),
            //         borderSide: BorderSide(color: Colors.blue, width: 2.r),
            //       ),
            //     ),
            //     onSubmitted: (value) {
            //       setState(() {
            //         searchInkaroManual = value;
            //       });
            //     },
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Switch(
                  value: isSwitchedHouseBrandManual,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedHouseBrandManual = value;
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
                Text(
                  "House Brand",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    fontFamily: 'Montserrat',
                  ),
                )
              ],
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
                          padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
                          child: Text(e.descKategori,
                              style: TextStyle(color: Colors.black54))),
                    );
                  }).toList(),
                  hint: Padding(
                      padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
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
                      searchInkaroManual.isNotEmpty
                          ? getSearchInkaroManual(searchInkaroManual)
                          : getSearchInkaroManual('');
                      checkAllInkaroManual = false;
                    });
                  },
                ),
              ),
            ),
            FutureBuilder(
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
                          ? widgetListInkaroManual()
                          : Center(
                              child: Text('Data tidak ditemukan'),
                            );
                  }
                })
          ],
        ),
      );
    });
  }

  Widget widgetListInkaroManual() {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        children: [
          listInkaroManual.length > 0
              ? Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )),
                  margin: EdgeInsets.only(bottom: 10.h),
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: checkAllInkaroManual,
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pilih Semua",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),
                    onChanged: (bool? val) {
                      setState(() {
                        checkAllInkaroManual = val!;
                        for (var loopUpdateCheckedManual = 0;
                            loopUpdateCheckedManual < listInkaroManual.length;
                            loopUpdateCheckedManual++) {
                          if (!indexInkaroProgSelected.contains(
                              listInkaroManual[loopUpdateCheckedManual]
                                  .idSubcategory)) {
                            listInkaroManual[loopUpdateCheckedManual]
                                .ischecked = val;
                          }
                        }
                      });
                    },
                  ),
                )
              : SizedBox(),
          listInkaroManual.length > 0
              ? Container(
                  // width: double.minPositive.w,
                  width: MediaQuery.of(context).size.width / 1,
                  height: 300.h,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: listInkaroManual.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              )),
                          margin: EdgeInsets.only(bottom: 10.h),
                          child: indexInkaroProgSelected.contains(
                                  listInkaroManual[index].idSubcategory)
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 10.h,
                                      top: 10.h,
                                      left: 10.r,
                                      right: 10.r),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listInkaroManual[index].descSubcategory,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12.sp),
                                      ),
                                      Text(
                                          'Kategori : ' +
                                              listInkaroManual[index]
                                                  .descCategory,
                                          style: TextStyle(fontSize: 12.sp)),
                                      SizedBox(height: 10.h),
                                      Text(
                                          'Sudah Dipilih di Form Inkaro Program',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12.sp))
                                    ],
                                  ))
                              : CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  value: listInkaroManual[index].ischecked,
                                  title: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 10.h, top: 10.h),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            listInkaroManual[index]
                                                .descSubcategory,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12.sp),
                                          ),
                                          Text(
                                              'Kategori : ' +
                                                  listInkaroManual[index]
                                                      .descCategory,
                                              style:
                                                  TextStyle(fontSize: 12.sp)),
                                          Text(
                                            'Inkaro : ' +
                                                convertToIdr(
                                                    int.parse(
                                                        listInkaroManual[index]
                                                            .inkaroProgram),
                                                    0),
                                            style: TextStyle(fontSize: 12.sp),
                                          )
                                        ],
                                      )),
                                  onChanged: (bool? val) {
                                    setState(() {
                                      checkAllInkaroManual = false;
                                      listInkaroManual[index].ischecked = val!;
                                    });
                                  },
                                ));
                    },
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(top: 20.sp),
                  child: Text("Data Kosong"),
                ),
        ],
      );
    });
  }
}
