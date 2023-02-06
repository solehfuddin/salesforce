import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/itemsp.dart';
import 'package:sample/src/domain/entities/salesact.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class DialogActivity extends StatefulWidget {
  Salesact? item;
  bool isAdmin = false;

  DialogActivity(this.item, this.isAdmin);

  @override
  State<DialogActivity> createState() => _DialogActivityState();
}

class _DialogActivityState extends State<DialogActivity> {
  String salesName = '';
  bool _isLoading = true;
  Future<List<ItemSp>>? _futureSpLensa;
  Future<List<ItemSp>>? _futureSpFrame;
  List<ItemSp> tempSpLensa = List.empty(growable: true);
  List<ItemSp> tempSpFrame = List.empty(growable: true);
  bool isSpLensaFound = true;
  bool isSpFrameFound = true;

  @override
  void initState() {
    super.initState();
    if (widget.item!.mengetahui == "1") {
      getDailyAct(widget.item!.areaManager);
    }

    _futureSpLensa = getSpLensa(widget.item!.actId);
    _futureSpFrame = getSpFrame(widget.item!.actId);
  }

  getDailyAct(String idSalesManager) async {
    const timeout = 15;
    var url = '$API_URL/users?id=$idSalesManager';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];
        var rest = data['data'];
        print(rest);

        if (sts) {
          salesName = rest['name'];
          print("Manager name : $salesName");

          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _isLoading = false;
            });
          });
        } else {
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _isLoading = false;
            });
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
  }

  Future<List<ItemSp>> getSpLensa(dynamic idActivity) async {
    const timeout = 15;
    List<ItemSp> list = List.empty(growable: true);
    var url = '$API_URL/sales_activity/getSp';
    setState(() {
      isSpLensaFound = true;
    });

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id_activity': idActivity,
          'jenis_sp': 'L',
        },
      ).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest.map<ItemSp>((json) => ItemSp.fromJson(json)).toList();
          print("List Size: ${list.length}");

          setState(() {
            tempSpLensa.addAll(list);
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

    setState(() {
      isSpLensaFound = false;
    });

    return list;
  }

  Future<List<ItemSp>> getSpFrame(dynamic idActivity,
      {bool isHorizontal = false}) async {
    const timeout = 15;
    List<ItemSp> list = List.empty(growable: true);
    var url = '$API_URL/sales_activity/getSp';
    setState(() {
      isSpFrameFound = true;
    });

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id_activity': idActivity,
          'jenis_sp': 'F',
        },
      ).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest.map<ItemSp>((json) => ItemSp.fromJson(json)).toList();
          print("List Size: ${list.length}");

          setState(() {
            tempSpFrame.addAll(list);
          });
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
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
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }

    setState(() {
      isSpFrameFound = false;
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childDetail(isHorizontal: true);
      }

      return childDetail(isHorizontal: false);
    });
  }

  childDetail({bool isHorizontal = false}) {
    List<String> lain = widget.item!.lainnya.split(';');

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isHorizontal ? 20.r : 15.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: isHorizontal ? 30.h : 20.h,
                  ),
                  widget.isAdmin
                      ? SizedBox(
                          width: 5.w,
                        )
                      : widget.item!.mengetahui == "1"
                          ? _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.green.shade500,
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.r,
                                        vertical: 3.r,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        'Dikonfirmasi oleh ${capitalize(salesName)}',
                                        style: TextStyle(
                                          fontSize:
                                              isHorizontal ? 16.sp : 12.sp,
                                          fontFamily: 'Montserrat',
                                          color: Colors.green.shade600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.r,
                                    vertical: 3.r,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    'Menunggu dikonfirmasi',
                                    style: TextStyle(
                                      fontSize: isHorizontal ? 16.sp : 12.sp,
                                      fontFamily: 'Montserrat',
                                      color: Colors.red.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  widget.isAdmin
                      ? SizedBox(
                          width: 5.w,
                        )
                      : SizedBox(
                          height: isHorizontal ? 15.h : 15.h,
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.item!.optik,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 16.sp,
                          fontFamily: 'Segoe Ui',
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      widget.isAdmin
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.r,
                                vertical: 3.r,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade500,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                widget.item!.salesName,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isHorizontal ? 16.sp : 12.sp,
                                  fontFamily: 'Segoe Ui',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 10.w,
                            ),
                    ],
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Container(
                    height: isHorizontal ? 70.h : 40.h,
                    child: Column(
                      children: [
                        areaLainnya(
                          isHorizontal: isHorizontal,
                          data: lain,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15.r,
              ),
              child: areaSpLensa(
                widget.item!,
                isHorizontal: isHorizontal,
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15.r,
              ),
              child: areaSpFrame(
                widget.item!,
                isHorizontal: isHorizontal,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15.r,
              ),
              child: widget.item!.feedback != ''
                  ? areaFeedback(
                      isHorizontal: isHorizontal,
                    )
                  : SizedBox(
                      height: 5.h,
                    ),
            ),
            SizedBox(
              height: 35.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget areaLainnya({
    bool isHorizontal = false,
    List<String>? data,
  }) {
    return Expanded(
      child: ListView.builder(
          itemCount: data!.length,
          padding: EdgeInsets.symmetric(
            vertical: isHorizontal ? 10.r : 3.r,
          ),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, position) {
            return Container(
              margin: EdgeInsets.only(
                right: 15.r,
              ),
              padding: EdgeInsets.only(
                right: 10.w,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: 10.w,
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: isHorizontal ? 5.r : 2.r),
                    child: Icon(
                      Icons.check,
                      color: Colors.blue.shade800,
                      size: isHorizontal ? 22.r : 18.r,
                    ),
                  ),
                  SizedBox(
                    width: isHorizontal ? 5.w : 10.w,
                  ),
                  Text(
                    data[position].toString(),
                    style: TextStyle(
                      fontSize: isHorizontal ? 16.sp : 12.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget areaFeedback({bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15.h,
        ),
        Text(
          "Feedback : ",
          style: TextStyle(
            fontSize: isHorizontal ? 18.sp : 16.sp,
            fontFamily: 'Segoe ui',
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Text(
          capitalize(widget.item!.feedback),
          style: TextStyle(
            fontSize: isHorizontal ? 16.sp : 12.sp,
            fontFamily: 'Montserrat',
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.justify,
        )
      ],
    );
  }

  Widget areaSpLensa(Salesact item, {bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 0.r,
                vertical: isHorizontal ? 10.r : 5.r,
              ),
              child: Text(
                'Sp Lensa',
                style: TextStyle(
                  fontSize: isHorizontal ? 26.sp : 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 0.r,
                vertical: isHorizontal ? 10.r : 5.r,
              ),
              child: Text(
                convertToIdr(int.parse(widget.item!.spLensaStock), 0),
                style: TextStyle(
                  fontSize: isHorizontal ? 25.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  color: Colors.black,
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
                'Item',
                style: TextStyle(
                  fontSize: isHorizontal ? 24.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Qty',
                style: TextStyle(
                  fontSize: isHorizontal ? 24.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 7.h,
        ),
        isSpLensaFound
            ? Center(child: CircularProgressIndicator())
            : tempSpLensa.length > 0
                ? Container(
                    width: double.maxFinite.w,
                    height: isHorizontal ? 330.h : 140.h,
                    child: FutureBuilder(
                        future: _futureSpLensa,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<ItemSp>> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Center(child: CircularProgressIndicator());
                            default:
                              return snapshot.data != null
                                  ? listDiscWidget(
                                      snapshot.data!,
                                      snapshot.data!.length,
                                      isHorizontal: isHorizontal,
                                    )
                                  : Column(
                                      children: [
                                        Center(
                                          child: Image.asset(
                                            'assets/images/not_found.png',
                                            width: isHorizontal ? 90.w : 105.w,
                                            height: isHorizontal ? 90.w : 105.h,
                                          ),
                                        ),
                                        Text(
                                          'SP Lensa tidak ditemukan',
                                          style: TextStyle(
                                            fontSize:
                                                isHorizontal ? 22.sp : 14.sp,
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
                  )
                : Column(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/not_found.png',
                          width: isHorizontal ? 90.w : 105.w,
                          height: isHorizontal ? 90.w : 105.h,
                        ),
                      ),
                      Text(
                        'SP Lensa tidak ditemukan',
                        style: TextStyle(
                          fontSize: isHorizontal ? 22.sp : 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[600],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                    ],
                  ),
      ],
    );
  }

  Widget areaSpFrame(Salesact item, {bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 0.r,
                vertical: isHorizontal ? 10.r : 5.r,
              ),
              child: Text(
                'Sp Frame',
                style: TextStyle(
                  fontSize: isHorizontal ? 26.sp : 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 0.r,
                vertical: isHorizontal ? 10.r : 5.r,
              ),
              child: Text(
                convertToIdr(int.parse(widget.item!.spFrame), 0),
                style: TextStyle(
                  fontSize: isHorizontal ? 25.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  color: Colors.black,
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
                'Item',
                style: TextStyle(
                  fontSize: isHorizontal ? 24.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Qty',
                style: TextStyle(
                  fontSize: isHorizontal ? 24.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 7.h,
        ),
        isSpFrameFound
            ? Center(child: CircularProgressIndicator())
            : tempSpFrame.length > 0
                ? Container(
                    width: double.maxFinite.w,
                    height: isHorizontal ? 330.h : 140.h,
                    child: FutureBuilder(
                        future: _futureSpFrame,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<ItemSp>> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Center(child: CircularProgressIndicator());
                            default:
                              return snapshot.data != null
                                  ? listFrameWidget(
                                      snapshot.data!,
                                      snapshot.data!.length,
                                      isHorizontal: isHorizontal,
                                    )
                                  : Column(
                                      children: [
                                        Center(
                                          child: Image.asset(
                                            'assets/images/not_found.png',
                                            width: isHorizontal ? 90.w : 105.w,
                                            height: isHorizontal ? 90.w : 105.h,
                                          ),
                                        ),
                                        Text(
                                          'SP Frame tidak ditemukan',
                                          style: TextStyle(
                                            fontSize:
                                                isHorizontal ? 22.sp : 14.sp,
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
                  )
                : Column(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/not_found.png',
                          width: isHorizontal ? 90.w : 105.w,
                          height: isHorizontal ? 90.w : 105.h,
                        ),
                      ),
                      Text(
                        'SP Frame tidak ditemukan',
                        style: TextStyle(
                          fontSize: isHorizontal ? 22.sp : 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[600],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                    ],
                  ),
      ],
    );
  }

  Widget listDiscWidget(List<ItemSp> item, int len,
      {bool isHorizontal = false}) {
    return ListView.builder(
        itemCount: len,
        padding: EdgeInsets.symmetric(
          horizontal: 0.r,
          vertical: 5.r,
        ),
        itemBuilder: (context, position) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.green.shade50,
            ),
            margin: EdgeInsets.only(
              bottom: 8.h,
            ),
            padding: EdgeInsets.symmetric(
              vertical: isHorizontal ? 8.r : 4.r,
              horizontal: 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    item[position].prodName != ''
                        ? item[position].prodName.toUpperCase()
                        : '-',
                    style: TextStyle(
                      fontSize: isHorizontal ? 22.sp : 12.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    item[position].qty != '0' ? '${item[position].qty}' : '-',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget listFrameWidget(List<ItemSp> item, int len,
      {bool isHorizontal = false}) {
    return ListView.builder(
        itemCount: len,
        padding: EdgeInsets.symmetric(
          horizontal: 0.r,
          vertical: 5.r,
        ),
        itemBuilder: (context, position) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
            ),
            margin: EdgeInsets.only(
              bottom: 8.r,
            ),
            padding: EdgeInsets.symmetric(
              vertical: isHorizontal ? 8.r : 4.r,
              horizontal: 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    item[position].prodName != ''
                        ? item[position].prodName
                        : '-',
                    style: TextStyle(
                      fontSize: isHorizontal ? 22.sp : 12.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    item[position].qty != '0' ? '${item[position].qty}' : '-',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
