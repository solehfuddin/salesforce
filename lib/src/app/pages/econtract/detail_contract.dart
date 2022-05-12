import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/discount.dart';
import 'package:http/http.dart' as http;

class DetailContract extends StatefulWidget {
  Contract item;
  String div;
  String ttd;
  String username;
  bool isMonitoring;
  bool isContract = false;
  bool isAdminRenewal = false;
  bool isHasDisc = false;

  DetailContract(
      this.item, this.div, this.ttd, this.username, this.isMonitoring,
      {this.isContract, this.isAdminRenewal, this.isHasDisc});

  @override
  _DetailContractState createState() => _DetailContractState();
}

class _DetailContractState extends State<DetailContract> {
  bool _isLoading = true;
  List<Discount> discList = List.empty(growable: true);
  TextEditingController textReason = new TextEditingController();
  String reasonVal;
  bool _isReason = false;

  getDisc(dynamic idContract) async {
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/discount/getByIdContract?id_contract=$idContract';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        discList =
            rest.map<Discount>((json) => Discount.fromJson(json)).toList();
        print("List Size: ${discList.length}");

        discList.length > 0
            ? widget.isHasDisc = true
            : widget.isHasDisc = false;
      }

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
      });
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  @override
  initState() {
    super.initState();
    getDisc(widget.item.idContract);
  }

  Future<List<Discount>> getDiscountData(dynamic idContract) async {
    const timeout = 15;
    List<Discount> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/discount/getByIdContract?id_contract=$idContract';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        list = rest.map<Discount>((json) => Discount.fromJson(json)).toList();
        print("List Size: ${list.length}");
      }

      return list;
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  approveContract(bool isAr, String idCust, String username) async {
    const timeout = 15;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/approval/approveContractSM'
        : 'http://timurrayalab.com/salesforce/server/api/approval/approveContractAM';

    try {
      var response = await http
          .post(
            url,
            body: !isAr
                ? {
                    'id_customer': idCust,
                    'approver_sm': username,
                  }
                : {
                    'id_customer': idCust,
                    'approver_am': username,
                  },
          )
          .timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'];

      widget.isAdminRenewal
          ? handleCustomStatus(context, capitalize(msg), sts)
          : handleStatus(context, capitalize(msg), sts);
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  approveCustomer(bool isAr, String idCust, String ttd, String username) async {
    const timeout = 15;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/approval/approveSM'
        : 'http://timurrayalab.com/salesforce/server/api/approval/approveAM';

    try {
      var response = await http
          .post(
            url,
            body: !isAr
                ? {
                    'id_customer': idCust,
                    'nama_sales_manager': username,
                  }
                : {
                    'id_customer': idCust,
                    'nama_ar_manager': username,
                  },
          )
          .timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      approveContract(isAr, idCust, username);
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  rejectContract(
      bool isAr, String idCust, String username, String reason) async {
    const timeout = 15;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/approval/rejectContractSM'
        : 'http://timurrayalab.com/salesforce/server/api/approval/rejectContractAM';

    try {
      var response = await http
          .post(
            url,
            body: !isAr
                ? {
                    'id_customer': idCust,
                    'approver_sm': username,
                    'reason_sm': reason,
                  }
                : {
                    'id_customer': idCust,
                    'approver_am': username,
                    'reason_am': reason,
                  },
          )
          .timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      print('Username : $username');

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'];

      widget.isAdminRenewal
          ? handleCustomStatus(context, capitalize(msg), sts)
          : handleStatus(context, capitalize(msg), sts);
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  rejectCustomer(bool isAr, String idCust, String ttd, String username,
      String reason) async {
    const timeout = 15;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/approval/rejectSM'
        : 'http://timurrayalab.com/salesforce/server/api/approval/rejectAM';

    try {
      var response = await http
          .post(
            url,
            body: !isAr
                ? {
                    'id_customer': idCust,
                    'nama_sales_manager': username,
                  }
                : {
                    'id_customer': idCust,
                    'nama_ar_manager': username,
                  },
          )
          .timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      rejectContract(isAr, idCust, username, reason);
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  approveOldCustomer() {
    widget.div == "AR"
        ? approveContract(true, widget.item.idCustomer, widget.username)
        : approveContract(false, widget.item.idCustomer, widget.username);
  }

  approveNewCustomer() {
    widget.div == "AR"
        ? approveCustomer(
            true, widget.item.idCustomer, widget.ttd, widget.username)
        : approveCustomer(
            false, widget.item.idCustomer, widget.ttd, widget.username);
  }

  rejectOldCustomer() {
    widget.div == "AR"
        ? rejectContract(true, widget.item.idCustomer, widget.username,
            textReason.text.trim())
        : rejectContract(false, widget.item.idCustomer, widget.username,
            textReason.text.trim());
  }

  rejectNewCustomer() {
    widget.div == "AR"
        ? rejectCustomer(true, widget.item.idCustomer, widget.ttd,
            widget.username, textReason.text.trim())
        : rejectCustomer(false, widget.item.idCustomer, widget.ttd,
            widget.username, textReason.text.trim());
  }

  checkEntry() {
    textReason.text.isEmpty ? _isReason = true : _isReason = false;

    if (!_isReason) {
      widget.isContract ? rejectOldCustomer() : rejectNewCustomer();
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      handleStatus(context, 'Harap lengkapi data terlebih dahulu', false);
    }
  }

  handleRejection(BuildContext context, Function stop) {
    AlertDialog alert = AlertDialog(
      title: Center(
        child: Text(
          "Mengapa kontrak tidak disetujui ?",
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: Form(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: !_isReason ? 'Data wajib diisi' : null,
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 6,
            maxLength: 100,
            controller: textReason,
          ),
        ],
      )),
      actions: [
        TextButton(
          child: Text('Ok'),
          onPressed: () {
            stop();
            checkEntry();
          },
        ),
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            stop();
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    );

    showDialog(context: context, builder: (context) => alert);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity.w,
              height: 230.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 30.r),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.isAdminRenewal
                            ? Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => AdminScreen()))
                            : Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 15.r,
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(CircleBorder()),
                        padding: MaterialStateProperty.all(EdgeInsets.all(8.r)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.r,
                      vertical: 15.r,
                    ),
                    child: Center(
                      child: Text(
                        'Perjanjian Kerjasama Pembelian',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/sepakat.jpg'),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 5.r,
                      horizontal: 10.r,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[600],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'KONTRAK ${widget.item.typeContract}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Berlaku tanggal',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Hingga tanggal',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        convertDateWithMonth(widget.item.startContract),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: 85.w,
                      ),
                      Text(
                        convertDateWithMonth(widget.item.endContract),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Container(
                    height: 1.3.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Text(
                    'Pihak Pertama',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 5.w,
                        ),
                        VerticalDivider(
                          color: Colors.orange[500],
                          thickness: 3.5,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Nama',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90.w,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Jabatan',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.item.namaPertama,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90.w,
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.item.jabatanPertama,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'No Telp',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90.w,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'No Fax',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '021-4610154',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90.w,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '021-4610151-52',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                'Alamat : ',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              Text(
                                'Jl. Rawa Kepiting No. 4 Kawasan Industri Pulogadung, Jakarta Timur',
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  Text(
                    'Pihak Kedua',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 5.w,
                        ),
                        VerticalDivider(
                          color: Colors.green[600],
                          thickness: 3.5,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Nama',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90.w,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Jabatan',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.item.namaKedua,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90.w,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Owner',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'No Telp',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90.w,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'No Fax',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.item.telpKedua,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90.w,
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.item.faxKedua == null
                                          ? '-'
                                          : widget.item.faxKedua,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                'Alamat : ',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              Text(
                                widget.item.alamatKedua,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Container(
                    height: 1.3.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    'Target Pembelian yang disepakati',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Lensa Nikon',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120.w,
                      ),
                      Expanded(
                        child: Text(
                          'Lensa Leinz',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          convertToIdr(int.parse(widget.item.tpNikon), 0),
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 120.w,
                      ),
                      Expanded(
                        child: Text(
                          convertToIdr(int.parse(widget.item.tpLeinz), 0),
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Lensa Oriental',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120.w,
                      ),
                      Expanded(
                        child: Text(
                          'Lensa Moe',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          convertToIdr(int.parse(widget.item.tpOriental), 0),
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 120.w,
                      ),
                      Expanded(
                        child: Text(
                          convertToIdr(int.parse(widget.item.tpMoe), 0),
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  Text(
                    'Jangka waktu pembayaran',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Lensa Nikon',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120.w,
                      ),
                      Expanded(
                        child: Text(
                          'Lensa Leinz',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.pembNikon,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 120.w,
                      ),
                      Expanded(
                        child: Text(
                          widget.item.pembLeinz,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Lensa Oriental',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120.w,
                      ),
                      Expanded(
                        child: Text(
                          'Lensa Moe',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.pembOriental,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 120.w,
                      ),
                      Expanded(
                        child: Text(
                          widget.item.pembMoe,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Container(
                    height: 1.3.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  widget.item.typeContract.contains('FRAME')
                      ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                'KETERANGAN',
                                style: TextStyle(
                                  fontFamily: 'Segoe Ui',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5.r,
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                'Diskon khusus pada kontrak frame disesuakan dengan surat pesanan (SP) .',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        )
                      : areaDiskon(widget.item),
                  SizedBox(
                    height: 30.h,
                  ),
                  widget.isMonitoring
                      ? Center(
                          child: ArgonButton(
                            height: 40.h,
                            width: 150.w,
                            borderRadius: 30.0.r,
                            color: Colors.blue[700],
                            child: Text(
                              "Unduh Kontrak",
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
                                  donwloadContract(
                                      int.parse(widget.item.idCustomer),
                                      stopLoading());
                                });
                              }
                            },
                          ),
                        )
                      : SizedBox(
                          height: 5.h,
                        ),
                  widget.isMonitoring
                      ? SizedBox(
                          height: 5.h,
                        )
                      : handleAction(),
                  SizedBox(
                    height: 10.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget areaDiskon(Contract item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 0.r,
                vertical: 5.r,
              ),
              child: Text(
                'Kontrak Diskon',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 3.h,
        ),
        _isLoading
            ? Center(
                child: Text(
                  'Processing ...',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              )
            : widget.isHasDisc == null
                ? SizedBox(
                    height: 3.h,
                  )
                : widget.isHasDisc
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 170.w,
                            child: Text(
                              'Deskripsi produk',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 90.w,
                            child: Text(
                              'Diskon',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        height: 3.h,
                      ),
        Container(
          width: double.maxFinite.w,
          height: 170.h,
          child: FutureBuilder(
              future: getDiscountData(item.idContract),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return snapshot.data != null
                        ? listDiscWidget(snapshot.data, snapshot.data.length)
                        : Column(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/not_found.png',
                                  width: 145.w,
                                  height: 145.h,
                                ),
                              ),
                              Text(
                                'Item Discount tidak ditemukan',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                            ],
                          );
                }
              }),
        ),
      ],
    );
  }

  Widget listDiscWidget(List<Discount> item, int len) {
    return ListView.builder(
        itemCount: len,
        padding: EdgeInsets.symmetric(
          horizontal: 0.r,
          vertical: 5.r,
        ),
        itemBuilder: (context, position) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 200.w,
                  child: Text(
                    item[position].prodDesc != null
                        ? item[position].prodDesc
                        : '-',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80.w,
                  child: Text(
                    item[position].discount != null
                        ? '${item[position].discount} %'
                        : '-',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget handleAction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.r,
            vertical: 5.r,
          ),
          alignment: Alignment.centerRight,
          child: ArgonButton(
            height: 40.h,
            width: 100.w,
            borderRadius: 30.0.r,
            color: Colors.red[700],
            child: Text(
              "Reject",
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
                  handleRejection(context, stopLoading);
                  // widget.isContract ? rejectOldCustomer() : rejectNewCustomer();
                });
              }
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.r,
            vertical: 5.r,
          ),
          alignment: Alignment.centerRight,
          child: ArgonButton(
            height: 40.h,
            width: 100.w,
            borderRadius: 30.0.r,
            color: Colors.blue[600],
            child: Text(
              "Approve",
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
                  widget.isContract
                      ? approveOldCustomer()
                      : approveNewCustomer();
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
