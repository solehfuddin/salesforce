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
  TextEditingController textIntervalPembayaran = new TextEditingController();
  TextEditingController textNotesContract = new TextEditingController();
  final formKeyInkaroManual = GlobalKey<FormState>();

  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';
  String tokenAdmin = '';
  String tokenSales = '';
  String searchInkaroProgram = '';
  String searchInkaroManual = '';
  String notesContract = '';
  final format = DateFormat("dd MMM yyyy");
  late DateTime startPeriode;
  late DateTime endPeriode;

  String? namaStaff,
      nikKTP,
      npwp,
      nomorRekening,
      mulaiPeriode,
      selesaiPeriode,
      atasNama,
      telpKonfirmasi,
      _choosenBank,
      _choosenJabatan,
      _choosenSatuanIntervalPembayaran = "",
      _intervalPembayaran = "",
      fullIntervalPembayaran;
  bool _isHorizontal = false;
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
      mulaiPeriode != ''
          ? _emptyMulaiPeriode = false
          : _emptyMulaiPeriode = true;
      selesaiPeriode != ''
          ? _emptySelesaiPeriode = false
          : _emptySelesaiPeriode = true;
    });

    if (_emptyNamaStaff ||
        _emptyNikKTP ||
        _emptyNomorRekening ||
        _emptyMulaiPeriode ||
        _emptySelesaiPeriode ||
        _emptyAtasNama ||
        _emptyTelpKonfirmasi ||
        _emptyIntervalPembayaran ||
        _choosenBank == '' ||
        _choosenBank == null) {
      handleStatus(
        context,
        'Harap lengkapi isian yang telah disediakan.',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    } else {
      updateData(isHorizontal: isHorizontal);
    }
  }

  updateData({bool isHorizontal = false}) async {
    const timeout = 15;
    var url = '$API_URL/inkaro/updateInkaroHeader/';

    try {
      var response = await http.post(Uri.parse(url), body: {
        'id_contract':
            widget.inkaroHeaderList[widget.position].inkaroContractId,
        'cust_ship_num': widget.inkaroHeaderList[widget.position].noAccount,
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
        'notes': notesContract,
        'update_by': id,
      }, headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      // RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      // print(response.body.replaceAll(exp, ''));

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'].toString();

      if (mounted) {
        pushNotif(14, 3,
            idUser: id,
            rcptToken: tokenSales,
            admName: username,
            opticName:
                widget.inkaroHeaderList[widget.position].customerShipName,
            salesName: name);

        pushNotif(
          14,
          1,
          idUser: id,
          rcptToken: tokenSales,
          admName: username,
          opticName: widget.inkaroHeaderList[widget.position].customerShipName,
        );

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
  }

  List<ListMasterBank> _dataBank = List.empty(growable: true);
  List _dataJabatan = [
    {'label': 'Karyawan Optik', 'value_jabatan': 'KARYAWAN OPTIK'},
    {'label': 'Manager Optik', 'value_jabatan': 'MANAGER OPTIK'},
    {'label': 'Owner Optik', 'value_jabatan': 'OWNER OPTIK'},
  ];
  List _dataSatuanIntervalPembayaran = [
    {'label': 'Bulan', 'value_satuan': 'BULAN'},
    {'label': 'Tahun', 'value_satuan': 'TAHUN'},
  ];
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

  getAdmToken(int input) async {
    const timeout = 15;
    var url = '$API_URL/users?id=$input';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          tokenAdmin = data['data']['gentoken'];
          print('Token admin : $tokenAdmin');
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleConnectionAdmin(context);
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  getSalesToken(int input) async {
    const timeout = 15;
    var url = '$API_URL/users?id=$input';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          tokenSales = data['data']['gentoken'];
          print('Token sales : $tokenSales');
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleConnectionAdmin(context);
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

  @override
  void initState() {
    super.initState();
    getRole();
    getOptionBank();

    // set old value to form
    textNamaStaff.text = widget.inkaroHeaderList[widget.position].namaStaff;
    textNikKTP.text = widget.inkaroHeaderList[widget.position].nikKTP;
    textNpwp.text = widget.inkaroHeaderList[widget.position].npwp;
    textMulaiPeriode.text =
        widget.inkaroHeaderList[widget.position].startPeriode;
    textSelesaiPeriode.text =
        widget.inkaroHeaderList[widget.position].endPeriode;
    startPeriode =
        DateTime.parse(widget.inkaroHeaderList[widget.position].startPeriode);
    endPeriode =
        DateTime.parse(widget.inkaroHeaderList[widget.position].endPeriode);
    _choosenBank = widget.inkaroHeaderList[widget.position].bank;
    textAtasNama.text = widget.inkaroHeaderList[widget.position].anRekening;
    textNomorRekening.text =
        widget.inkaroHeaderList[widget.position].nomorRekening;
    textTelpKonfirmasi.text =
        widget.inkaroHeaderList[widget.position].telpKonfirmasi;
    textNotesContract.text = widget.inkaroHeaderList[widget.position].notes;

    // set value param post from initialize value
    namaStaff = widget.inkaroHeaderList[widget.position].namaStaff;
    nikKTP = widget.inkaroHeaderList[widget.position].nikKTP;
    npwp = widget.inkaroHeaderList[widget.position].npwp;
    nomorRekening = widget.inkaroHeaderList[widget.position].nomorRekening;
    mulaiPeriode = widget.inkaroHeaderList[widget.position].startPeriode;
    selesaiPeriode = widget.inkaroHeaderList[widget.position].endPeriode;
    atasNama = widget.inkaroHeaderList[widget.position].anRekening;
    telpKonfirmasi = widget.inkaroHeaderList[widget.position].telpKonfirmasi;
    notesContract = widget.inkaroHeaderList[widget.position].notes;
    _choosenJabatan = widget.inkaroHeaderList[widget.position].jabatan;
    textIntervalPembayaran.text = widget
        .inkaroHeaderList[widget.position].intervalPembayaran
        .split(" ")[0];
    _choosenSatuanIntervalPembayaran = widget
        .inkaroHeaderList[widget.position].intervalPembayaran
        .split(" ")[1];
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");

      getAdmToken(int.parse(id!));
      if (double.tryParse(widget.inkaroHeaderList[widget.position].createBy) ==
          null) {
        print('The input is not a numeric string');
      } else {
        print('Yes, it is a numeric string');
        getSalesToken(
            int.parse(widget.inkaroHeaderList[widget.position].createBy));
      }

      print("Dashboard : $role");
    });
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
          'Ubah Data Inkaro',
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
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '(wajib diisi)',
                        style: TextStyle(
                          fontSize: 12.sp,
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
                        fontSize: 14.sp,
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
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '(wajib diisi)',
                        style: TextStyle(
                          fontSize: 12.sp,
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
                        fontSize: 14.sp,
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
                          fontSize: 12.sp,
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
                        fontSize: 14.sp,
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
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Selesai Periode',
                        style: TextStyle(
                          fontSize: 12.sp,
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
                              initialValue: startPeriode,
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
                              initialValue: endPeriode,
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
                      fontSize: 14.sp,
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
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Atas Nama',
                        style: TextStyle(
                          fontSize: 12.sp,
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
                                fontSize: 14.sp,
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
                                    fontSize: 14.sp,
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
                                fontSize: 14.sp,
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
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Telp/HP Konfirmasi',
                        style: TextStyle(
                          fontSize: 12.sp,
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
                                  fontSize: 14.sp,
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
                                fontSize: 14.sp,
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
                  SizedBox(
                    height: 10.sp,
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
                  Row(
                    children: [
                      Text('Catatan',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
}
