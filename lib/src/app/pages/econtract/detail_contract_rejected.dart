import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/discount.dart';
import 'package:http/http.dart' as http;

class DetailContractRejected extends StatefulWidget {
  Contract item;
  String div;
  String ttd;
  String username;
  bool isNewCust;

  DetailContractRejected(
      {this.item, this.div, this.ttd, this.username, this.isNewCust});

  @override
  State<DetailContractRejected> createState() => _DetailContractRejectedState();
}

class _DetailContractRejectedState extends State<DetailContractRejected> {
  List<Discount> discList = List.empty(growable: true);

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
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleConnectionAdmin(context);
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
    List<Discount> list;
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

  approveCustomerReject(BuildContext context, bool isAr, String idCust,
      String ttd, String username) async {
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
                    'ttd_sales_manager': ttd,
                    'nama_sales_manager': username,
                  }
                : {
                    'id_customer': idCust,
                    'ttd_ar_manager': ttd,
                    'nama_ar_manager': username,
                  },
          )
          .timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'];

      approveContractReject(isAr, idCust, username);
      handleStatus(context, capitalize(msg), sts);
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  approveContractReject(bool isAr, String idCust, String username) async {
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

      handleStatus(context, capitalize(msg), sts);
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  void handleContract() {
    widget.div == "AR"
        ? approveContractReject(true, widget.item.idCustomer, widget.username)
        : approveContractReject(false, widget.item.idCustomer, widget.username);
  }

  void handleCustomer() {
    widget.div == "AR"
        ? approveCustomerReject(
            context, true, widget.item.idCustomer, widget.ttd, widget.username)
        : approveCustomerReject(context, false, widget.item.idCustomer,
            widget.ttd, widget.username);
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
                      onPressed: () => Navigator.pop(context),
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
                        width: 85.h,
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
                    height: 8,
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
                  areaDiskon(widget.item),
                  SizedBox(
                    height: 20.h,
                  ),
                  Center(
                    child: Text(
                      'Apakah anda ingin menyetujui kontrak optik ini?',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ArgonButton(
                        height: 40.h,
                        width: 100.w,
                        borderRadius: 30.0.r,
                        color: Colors.blue[700],
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
                            startLoading();
                            waitingLoad();
                            widget.isNewCust
                                ? handleCustomer()
                                : handleContract();
                            stopLoading();
                          }
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          primary: Colors.red[800],
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.r, vertical: 10.r),
                        ),
                        child: Text(
                          'Tutup',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Segoe ui',
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.h,
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
        discList.length > 0
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
                height: 10.h,
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
                                  width: 120.r,
                                  height: 120.r,
                                ),
                              ),
                              Text(
                                'Item Discount tidak ditemukan',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
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
          vertical: 8.r,
        ),
        itemBuilder: (context, position) {
          return SizedBox(
            height: 40.h,
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
}
