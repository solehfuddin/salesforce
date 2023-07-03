import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/inkaro/create_inkaro.dart';
import 'package:sample/src/app/pages/inkaro/detail_inkaro.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/customer_inkaro.dart';
import 'package:sample/src/domain/entities/list_inkaro_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class ListInkaroScreen extends StatefulWidget {
  final List<ListCustomerInkaro> customerList;
  final int position;

  @override
  _ListInkaroScreenState createState() => _ListInkaroScreenState();

  ListInkaroScreen(this.customerList, this.position);
}

class _ListInkaroScreenState extends State<ListInkaroScreen> {
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

  bool _isEmpty = false;
  final format = DateFormat("dd MMM yyyy");
  var thisYear, nextYear;

  List<ListInkaroHeader> listInkaroHeader = List.empty(growable: true);
  List<ListInkaroHeader> tmpList = List.empty(growable: true);
  Future<List<ListInkaroHeader>>? _listFuture;

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

      _listFuture =
          getHeaderInkaro(widget.customerList[widget.position].noAccount);
    });
  }

  Future<List<ListInkaroHeader>> getHeaderInkaro(String noAccount) async {
    const timeout = 15;
    var url = '$API_URL/inkaro/getInkaroHeader?no_account=$noAccount';

    tmpList.clear();
    List<ListInkaroHeader> list = List.empty(growable: true);

    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      if (response.statusCode == 400) {
        _isEmpty = true;
      }

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest
              .map<ListInkaroHeader>((json) => ListInkaroHeader.fromJson(json))
              .toList();
          print("List Size: ${list.length}");
          setState(() {
            // initalizePage(data['total']);
            tmpList = list;
          });
          _isEmpty = false;
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
    print(tmpList);
  }

  Future<void> _refreshData() async {
    setState(() {
      _listFuture =
          getHeaderInkaro(widget.customerList[widget.position].noAccount);
    });
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
            'Manage Inkaro',
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 25.r : 20.r,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            left: isHorizontal ? 10.r : 5.r,
                          ),
                          width: isHorizontal
                              ? MediaQuery.of(context).size.width / 5.5
                              : MediaQuery.of(context).size.width / 5.2,
                          child: Text(
                            'Nama : ',
                            style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            namaUsaha =
                                widget.customerList[widget.position].namaUsaha,
                            style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: isHorizontal ? 18.h : 8.h,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            left: isHorizontal ? 10.r : 5.r,
                          ),
                          width: isHorizontal
                              ? MediaQuery.of(context).size.width / 5.5
                              : MediaQuery.of(context).size.width / 5.2,
                          child: Text(
                            'Pemilik : ',
                            style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            namaPJ =
                                widget.customerList[widget.position].namaPj,
                            style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: isHorizontal ? 18.h : 8.h,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            left: isHorizontal ? 10.r : 5.r,
                          ),
                          width: isHorizontal
                              ? MediaQuery.of(context).size.width / 5.5
                              : MediaQuery.of(context).size.width / 5.2,
                          child: Text(
                            'Telp : ',
                            style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            telpPJ =
                                widget.customerList[widget.position].tlpUsaha,
                            style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: isHorizontal ? 18.h : 8.h,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            left: isHorizontal ? 10.r : 5.r,
                          ),
                          width: isHorizontal
                              ? MediaQuery.of(context).size.width / 5.5
                              : MediaQuery.of(context).size.width / 5.2,
                          child: Text(
                            'Alamat : ',
                            style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            alamatUsaha = widget
                                .customerList[widget.position].alamatUsaha,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: isHorizontal ? 18.h : 8.h,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: isHorizontal ? 18.r : 8.r,
                              ),
                              child: Text(
                                'Inkaro Optik : ',
                                style: TextStyle(
                                    fontSize: isHorizontal ? 19.sp : 15.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isHorizontal ? 15.r : 0.r,
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
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CreateInkaroScreen(
                                              widget.customerList,
                                              widget.position,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: tmpList.length > 0
                  ? Expanded(
                      child: FutureBuilder(
                          future: _listFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<ListInkaroHeader>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasError) {
                                return Column(
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        'assets/images/not_found.png',
                                        width: isHorizontal ? 150.w : 230.w,
                                        height: isHorizontal ? 150.h : 230.h,
                                      ),
                                    ),
                                    Text(
                                      'Data tidak ditemukan',
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 16.sp : 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red[600],
                                        fontFamily: 'Montserrat',
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                return listViewWidget(
                                  snapshot.data!,
                                  snapshot.data!.length,
                                  isHorizontal: isHorizontal,
                                );
                              }
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          }),
                    )
                  : Column(
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/not_found.png',
                            width: isHorizontal ? 150.w : 230.w,
                            height: isHorizontal ? 150.h : 230.h,
                          ),
                        ),
                        Text(
                          'Data tidak ditemukan',
                          style: TextStyle(
                            fontSize: isHorizontal ? 16.sp : 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[600],
                            fontFamily: 'Montserrat',
                          ),
                        )
                      ],
                    ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
              child: Text('Scroll untuk melihat Inkaro Lainnya'),
            )
          ],
        ));
  }

  Widget listViewWidget(List<ListInkaroHeader> inkaroHeader, int len,
      {bool isHorizontal = false}) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 23.r : 15.r,
              vertical: isHorizontal ? 12.r : 10.r,
            ),
            itemBuilder: (context, position) {
              return Card(
                elevation: 2,
                child: ClipPath(
                  child: InkWell(
                    child: Container(
                      height: isHorizontal ? 120.h : 90.h,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                              color:
                                  inkaroHeader[position].approvalSM == 'REJECT'
                                      ? Colors.red[600]!
                                      : inkaroHeader[position].approvalSM ==
                                              'PENDING'
                                          ? Colors.orange[600]!
                                          : inkaroHeader[position].status ==
                                                  'ACTIVE'
                                              ? Colors.green[600]!
                                              : Colors.grey[400]!,
                              width: isHorizontal ? 4.w : 5.w),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isHorizontal ? 20.r : 15.r,
                          vertical: 8.r,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    inkaroHeader[position].namaStaff,
                                    style: TextStyle(
                                      fontSize: isHorizontal ? 20.sp : 15.sp,
                                      fontFamily: 'Segoe ui',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  SizedBox(
                                    width: isHorizontal ? 250.w : 200.w,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Mulai Periode : ',
                                            style: TextStyle(
                                                fontSize: isHorizontal
                                                    ? 16.sp
                                                    : 11.sp,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  SizedBox(
                                    width: 200.w,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            inkaroHeader[position].startPeriode,
                                            style: TextStyle(
                                              fontSize:
                                                  isHorizontal ? 17.sp : 12.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              inkaroHeader[position].approvalSM == 'REJECT' ||
                                      inkaroHeader[position].approvalSM ==
                                          'PENDING'
                                  ? inkaroHeader[position].approvalSM
                                  : inkaroHeader[position].status,
                              style: TextStyle(
                                fontSize: isHorizontal ? 20.sp : 14.sp,
                                fontFamily: 'Segoe Ui',
                                fontWeight: FontWeight.w600,
                                color: inkaroHeader[position].approvalSM ==
                                        'REJECT'
                                    ? Colors.red[600]!
                                    : inkaroHeader[position].approvalSM ==
                                            'PENDING'
                                        ? Colors.orange[600]!
                                        : inkaroHeader[position].status ==
                                                'ACTIVE'
                                            ? Colors.green[600]!
                                            : Colors.grey[400]!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailInkaroScreen(
                            widget.customerList,
                            widget.position,
                            inkaroHeader,
                            position,
                          ),
                        ),
                      );
                    },
                  ),
                  clipper: ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}
