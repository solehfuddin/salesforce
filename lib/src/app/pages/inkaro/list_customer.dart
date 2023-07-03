import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sample/src/app/pages/inkaro/list_inkaro.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer_inkaro.dart';
import 'package:sample/src/domain/entities/customer_noimage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListCustomerInkaroScreen extends StatefulWidget {
  final int idOuter;
  @override
  _ListCustomerInkaroScreen createState() => _ListCustomerInkaroScreen();

  ListCustomerInkaroScreen(this.idOuter);
}

class _ListCustomerInkaroScreen extends State<ListCustomerInkaroScreen> {
  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';
  String search = '';
  var thisYear, nextYear;
  bool isDataFound = true;
  List<ListCustomerInkaro> ListCustomer = List.empty(growable: true);
  List<ListCustomerInkaro> tmpList = List.empty(growable: true);
  Future<List<ListCustomerInkaro>>? _listFuture;
  final inputSearchController = TextEditingController();

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");

      var formatter = new DateFormat('yyyy');
      thisYear = formatter.format(DateTime.now());
      nextYear = int.parse(thisYear) + 1;

      _listFuture = search.isNotEmpty
          ? getListCustomerInkaroSearch(search)
          : getListCustomerInkaro();

      print('This Year : $thisYear');
      print('Next Year : $nextYear');

      print("Dashboard : $role");
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  Future<List<ListCustomerInkaro>> getListCustomerInkaro() async {
    setState(() {
      isDataFound = true;
    });

    tmpList.clear();
    List<ListCustomerInkaro> list = List.empty(growable: true);
    const timeout = 15;
    var url = '$API_URL/inkaro/getCustomerList';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest
              .map<ListCustomerInkaro>(
                  (json) => ListCustomerInkaro.fromJson(json))
              .toList();
          print("List Size: ${list.length}");

          setState(() {
            // initalizePage(data['total']);
            tmpList = list;
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

    setState(() {
      isDataFound = false;
    });

    return list;
  }

  Future<List<ListCustomerInkaro>> getListCustomerInkaroSearch(
      String input) async {
    setState(() {
      isDataFound = true;
    });

    tmpList.clear();
    List<ListCustomerInkaro> list = List.empty(growable: true);
    const timeout = 15;
    var url = '$API_URL/inkaro/getCustomerList?search=$input';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest
              .map<ListCustomerInkaro>(
                  (json) => ListCustomerInkaro.fromJson(json))
              .toList();
          print("List Size: ${list.length}");

          setState(() {
            // initalizePage(data['total']);
            tmpList = list;
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

    setState(() {
      isDataFound = false;
    });

    return list;
  }

  Future<void> _refreshData() async {
    setState(() {
      _listFuture = inputSearchController.text.isNotEmpty
          ? getListCustomerInkaroSearch(inputSearchController.text)
          : getListCustomerInkaro();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return masterCustomer(isHorizontal: true);
      }

      return masterCustomer(isHorizontal: false);
    });
  }

  Widget masterCustomer({bool isHorizontal = false}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'List Kustomer',
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
            size: isHorizontal ? 20.r : 18.r,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 26.r : 20.r,
              vertical: 10.r,
            ),
            color: Colors.white,
            height: isHorizontal ? 75.h : 80.h,
            child: TextField(
              controller: inputSearchController,
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
                  borderSide: BorderSide(color: Colors.grey, width: 2.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0.r)),
                  borderSide: BorderSide(color: Colors.blue, width: 2.w),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  search = value;
                  _listFuture = search.isNotEmpty
                      ? getListCustomerInkaroSearch(search)
                      : getListCustomerInkaro();
                });
              },
            ),
          ),
          isDataFound
              ? Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.r,
                  ),
                  child: CircularProgressIndicator(),
                )
              : tmpList.length > 0
                  ? Expanded(
                      child: SizedBox(
                        height: 100.h,
                        child: FutureBuilder(
                            future: _listFuture,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<ListCustomerInkaro>>
                                    snapshot) {
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
                                          fontSize:
                                              isHorizontal ? 16.sp : 18.sp,
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
                      ),
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
        ],
      ),
    );
  }

  Widget listViewWidget(List<ListCustomerInkaro> customer, int len,
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
                              color: Colors.blue[600]!,
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
                                    customer[position].namaUsaha,
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
                                            'Penanggungjawab : ',
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
                                            customer[position].namaPj != ''
                                                ? customer[position].namaPj
                                                : '-',
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
                              'Lihat Inkaro',
                              style: TextStyle(
                                fontSize: isHorizontal ? 20.sp : 14.sp,
                                fontFamily: 'Segoe Ui',
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ListInkaroScreen(
                            customer,
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
