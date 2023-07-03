// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/inkaro/create_inkaro.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/customer_inkaro.dart';
import 'package:sample/src/domain/entities/list_inkaro_detail.dart';
import 'package:sample/src/domain/entities/list_inkaro_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class DetailInkaroScreen extends StatefulWidget {
  final List<ListCustomerInkaro> customerList;
  final int positionCustomer;
  final List<ListInkaroHeader> listInkaroHeader;
  final int positionInkaro;

  @override
  _DetailInkaroScreenState createState() => _DetailInkaroScreenState();

  DetailInkaroScreen(this.customerList, this.positionCustomer,
      this.listInkaroHeader, this.positionInkaro);
}

class _DetailInkaroScreenState extends State<DetailInkaroScreen> {
  final globalKey = GlobalKey();

  String search = '';
  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';

  String namaUsaha = '';
  String namaPJ = '';
  String telpPJ = '';
  String alamatUsaha = '';

  final format = DateFormat("dd MMM yyyy");
  var thisYear, nextYear;

  List<ListInkaroDetail> listInkaroDetailReguler = List.empty(growable: true);
  List<ListInkaroDetail> listInkaroDetailProgram = List.empty(growable: true);
  List<ListInkaroDetail> listInkaroDetailManual = List.empty(growable: true);

  getListInkaro() async {
    const timeout = 15;
    var url =
        '$API_URL/inkaro/getInkaroDetail?id_inkaro_header=${widget.listInkaroHeader[widget.positionInkaro].inkaroContractId}';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];
        if (sts) {
          var rest = data['data'];
          print(rest['program']);
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

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");

      var formatter = new DateFormat('yyyy');
      thisYear = formatter.format(DateTime.now());
      nextYear = int.parse(thisYear) + 1;

      print('This Year : $thisYear');
      print('Next Year : $nextYear');

      print("Dashboard : $role");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
    getListInkaro();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childInkaroHeader(isHorizontal: true);
      }

      return childInkaroHeader(isHorizontal: false);
    });
  }

  Widget childInkaroHeader({bool isHorizontal = false}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Detail Inkaro',
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
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Card(
                margin: EdgeInsets.all(10.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(15),
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
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: isHorizontal ? 18.h : 8.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                namaUsaha = widget
                                    .customerList[widget.positionCustomer]
                                    .namaUsaha,
                                style: TextStyle(
                                    fontSize: isHorizontal ? 18.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                "Periode : " +
                                    DateFormat("dd MMM yyyy").format(
                                        DateTime.parse(widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .startPeriode)) +
                                    ' sampai ' +
                                    DateFormat("dd MMM yyyy").format(
                                        DateTime.parse(widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .endPeriode)),
                                style: TextStyle(
                                  // fontSize: isHorizontal ? 18.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  // fontWeight: FontWeight.w600
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 18.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black12, width: 2)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 20, right: 20, top: 10, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .namaStaff,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "NPWP",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                                    .listInkaroHeader[
                                                        widget.positionInkaro]
                                                    .npwp ==
                                                null
                                            ? widget
                                                .listInkaroHeader[
                                                    widget.positionInkaro]
                                                .npwp
                                            : '-',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.h,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "NIK",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .nikKTP,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Rekening/e-wallet Tujuan',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Bank / e-Wallet",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .namaBank,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.h,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Nomor Rekening",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .nikKTP,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Atas Nama",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .anRekening,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.h,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Telp Konfirmasi",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .telpKonfirmasi,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(children: [
                          Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  handleVerificationAction(
                                      context,
                                      widget.listInkaroHeader,
                                      widget.positionInkaro);
                                },
                                style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 10.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    primary: Colors.blue[700]),
                                child: Text(
                                  "Ubah Data",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              )),
                        ])
                      ],
                    ),
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
                        'INKARO REGULER',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Card(
                                  color: Colors.white,
                                  child: Padding(
                                      padding: EdgeInsets.all(15.0),
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
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                          listInkaroDetailReguler.length > 0
                                              ? Container(
                                                  padding: EdgeInsets.only(
                                                      top: 10.w),
                                                  height: (30.00 *
                                                      listInkaroDetailReguler
                                                          .length),
                                                  child: ListView.builder(
                                                      itemCount:
                                                          listInkaroDetailReguler
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        10.r,
                                                                    right: 3.r),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 4,
                                                                  child: Text(
                                                                    listInkaroDetailReguler[
                                                                            index]
                                                                        .descKategori,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    listInkaroDetailReguler[
                                                                            index]
                                                                        .inkaroPercent,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    convertToIdr(
                                                                        int.parse(
                                                                            listInkaroDetailReguler[index].inkaroValue),
                                                                        0),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
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
                                                      child: Text(
                                                          'Inkaro Reguler Tidak Ada',
                                                          style: TextStyle(
                                                            fontSize:
                                                                isHorizontal
                                                                    ? 24.sp
                                                                    : 14.sp,
                                                            fontFamily:
                                                                'Montserrat',
                                                          ))))
                                        ],
                                      )),
                                ),
                              ),
                            ),
                          ],
                        )

                        // ListTile(title: Text('This is tile number 1')),
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
                        ),
                      ),
                      // subtitle: Text('Trailing expansion arrow icon'),
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Card(
                                  color: Colors.white,
                                  child: Padding(
                                      padding: EdgeInsets.all(15.0),
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
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                          listInkaroDetailProgram.length > 0
                                              ? Container(
                                                  padding: EdgeInsets.only(
                                                      top: 10.w),
                                                  height: (45.00 *
                                                      listInkaroDetailProgram
                                                          .length),
                                                  child: ListView.builder(
                                                      itemCount:
                                                          listInkaroDetailProgram
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        10.r,
                                                                    right: 3.r),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 4,
                                                                  child: Text(
                                                                    listInkaroDetailProgram[
                                                                            index]
                                                                        .descSubcategory,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    listInkaroDetailProgram[
                                                                            index]
                                                                        .inkaroPercent,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    convertToIdr(
                                                                        int.parse(
                                                                            listInkaroDetailProgram[index].inkaroValue),
                                                                        0),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
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
                                                      child: Text(
                                                          'Inkaro Program Tidak Ada',
                                                          style: TextStyle(
                                                            fontSize:
                                                                isHorizontal
                                                                    ? 24.sp
                                                                    : 14.sp,
                                                            fontFamily:
                                                                'Montserrat',
                                                          ))))
                                        ],
                                      )),
                                ),
                              ),
                            ),
                          ],
                        )
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
                        'INKARO MANUAL',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // subtitle: Text('Trailing expansion arrow icon'),
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Card(
                                  color: Colors.white,
                                  child: Padding(
                                      padding: EdgeInsets.all(15.0),
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
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Inkaro',
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                          listInkaroDetailManual.length > 0
                                              ? Container(
                                                  padding: EdgeInsets.only(
                                                      top: 10.w),
                                                  height: (50.00 *
                                                      listInkaroDetailManual
                                                          .length),
                                                  child: ListView.builder(
                                                      itemCount:
                                                          listInkaroDetailManual
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        10.r,
                                                                    right: 3.r),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 4,
                                                                  child: Text(
                                                                    listInkaroDetailManual[
                                                                            index]
                                                                        .descSubcategory,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    convertToIdr(
                                                                        int.parse(
                                                                            listInkaroDetailManual[index].inkaroValue),
                                                                        0),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
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
                                                      child: Text(
                                                          'Inkaro Manual Tidak Ada',
                                                          style: TextStyle(
                                                            fontSize:
                                                                isHorizontal
                                                                    ? 24.sp
                                                                    : 14.sp,
                                                            fontFamily:
                                                                'Montserrat',
                                                          ))))
                                        ],
                                      )),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
