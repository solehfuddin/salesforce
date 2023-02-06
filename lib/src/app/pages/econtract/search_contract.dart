import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/monitoring.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchContract extends StatefulWidget {
  @override
  _SearchContractState createState() => _SearchContractState();
}

class _SearchContractState extends State<SearchContract> {
  String? id = '';
  String? role = '';
  String? username = '';
  String search = '';
  String? divisi = '';
  String? ttdPertama = '';
  late Contract itemContract;
  bool isDataFound = true;

  List<Monitoring> currList = List.empty(growable: true);
  List<Monitoring> tmpList = List.empty(growable: true);
  Future<List<Monitoring>>? _listFuture;
  int page = 1;
  int pageCount = 5;
  int startAt = 0;
  int endAt = 0;
  int totalPages = 0;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");
      ttdPertama = preferences.getString("ttduser");

      _listFuture = search.isNotEmpty
          ? getMonitoringBySearch(search)
          : getMonitoringData();

      print("Search Contract : $role");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  initalizePage(int totalData) {
    endAt = totalData > 5 ? startAt + pageCount : totalData;
    totalPages = (totalData / pageCount).floor();
    if (totalData / pageCount > totalPages) {
      totalPages += 1;
    }
  }

  void loadPreviousPage() {
    if (page > 1) {
      setState(() {
        startAt = startAt - pageCount;
        endAt =
            page == totalPages ? endAt - currList.length : endAt - pageCount;
        _listFuture = search.isNotEmpty
            ? getMonitoringBySearch(search)
            : getMonitoringData();
        page = page - 1;
      });
    }
  }

  void loadNextPage() {
    if (page < totalPages) {
      setState(() {
        startAt = startAt + pageCount;
        endAt = currList.length > endAt + pageCount
            ? endAt + pageCount
            : currList.length;
        _listFuture = search.isNotEmpty
            ? getMonitoringBySearch(search)
            : getMonitoringData();
        page = page + 1;
      });
    }
  }

  Future<List<Monitoring>> getMonitoringData() async {
    setState(() {
      isDataFound = true;
    });

    tmpList.clear();
    List<Monitoring> list = [];
    const timeout = 15;
    var idSm;
    divisi == "AR" ? idSm = '' : idSm = id;
    var url = role == "ADMIN"
        ? '$API_URL/contract/monitoring?limit=$pageCount&offset=$startAt&id_salesmanager=$idSm&created_by='
        : '$API_URL/contract/salesMonitoring?id=$id&limit=$pageCount&offset=$startAt';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest
              .map<Monitoring>((json) => Monitoring.fromJson(json))
              .toList();
          print("List Size: ${list.length}");

          setState(() {
            tmpList = list;
          });
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Exception : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }

    setState(() {
      isDataFound = false;
    });

    return list;
  }

  Future<List<Monitoring>> getMonitoringBySearch(String input) async {
    setState(() {
      isDataFound = true;
    });

    tmpList.clear();
    List<Monitoring> list = [];
    const timeout = 15;
    var url = role == "ADMIN"
        ? divisi == "AR"
            ? '$API_URL/contract/search?search=$input&created_by=&id_salesmanager='
            : '$API_URL/contract/search?search=$input&created_by=&id_salesmanager=$id'
        : '$API_URL/contract/search?search=$input&created_by=$id&id_salesmanager=';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];
        var rest = data['data'];

        if (sts) {
          print(rest);
          list = rest
              .map<Monitoring>((json) => Monitoring.fromJson(json))
              .toList();
          print("List Size: ${list.length}");

          setState(() {
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
      _listFuture = search.isNotEmpty
          ? getMonitoringBySearch(search)
          : getMonitoringData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return contractChild(
          isHorizontal: true,
        );
      }

      return contractChild(
        isHorizontal: false,
      );
    });
  }

  Widget contractChild({bool isHorizontal = false}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'List Monitoring Contract',
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
              horizontal: isHorizontal ? 30.r : 20.r,
              vertical: 10.r,
            ),
            color: Colors.white,
            height: isHorizontal ? 75.h : 80.h,
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
                  search = value;
                  _listFuture = search.isNotEmpty
                      ? getMonitoringBySearch(search)
                      : getMonitoringData();
                });
              },
            ),
          ),
          tmpList.length > 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: Text("prev"),
                      backgroundColor:
                          page > 1 ? Colors.green : Colors.green.shade200,
                      mini: true,
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: isHorizontal ? 30.r : 20.r,
                      ),
                      elevation: 0,
                      onPressed: page > 1 ? loadPreviousPage : null,
                    ),
                    Text(
                      "Hal $page / $totalPages",
                      style: TextStyle(
                        fontFamily: 'Segoe Ui',
                        fontSize: isHorizontal ? 20.sp : 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: Text("next"),
                      backgroundColor: page < totalPages
                          ? Colors.green
                          : Colors.green.shade200,
                      mini: true,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: isHorizontal ? 30.r : 20.r,
                      ),
                      elevation: 0,
                      onPressed: page < totalPages ? loadNextPage : null,
                    ),
                  ],
                )
              : SizedBox(
                  width: 5.w,
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
                              AsyncSnapshot<List<Monitoring>> snapshot) {
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
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
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

  Widget listViewWidget(List<Monitoring> item, int len,
      {bool isHorizontal = false}) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 28.r : 10.r,
              vertical: isHorizontal ? 10.r : 7.r,
            ),
            shrinkWrap: true,
            itemBuilder: (context, position) {
              return InkWell(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 7.r,
                  ),
                  padding: EdgeInsets.all(
                    isHorizontal ? 15.r : 15.r,
                  ),
                  height: isHorizontal ? 120.h : 100.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(
                      color: Colors.black26,
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          item[position].namaUsaha != "null"
                              ? item[position].namaUsaha
                              : item[position].customerShipName,
                          style: TextStyle(
                            fontSize: isHorizontal ? 20.sp : 16.sp,
                            fontFamily: 'Segoe Ui',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 18.sp : 12.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Text(
                                capitalize(item[position].status.toLowerCase()),
                                style: TextStyle(
                                  fontSize: isHorizontal ? 20.sp : 16.sp,
                                  fontFamily: 'Segoe Ui',
                                  fontWeight: FontWeight.w600,
                                  color: item[position].status == "ACTIVE"
                                      ? Colors.orange[800]
                                      : Colors.red[600],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Sisa Kontrak',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 18.sp : 12.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Text(
                                getEndDays(
                                    input: item[position].endDateContract),
                                style: TextStyle(
                                  fontSize: isHorizontal ? 20.sp : 16.sp,
                                  fontFamily: 'Segoe Ui',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  print('ID CUSTOMER : ${item[position].idCustomer}');
                  print('USERAME : $username');
                  print('DIVISI : $divisi');
                  print('TTD : $ttdPertama');

                  bool checkCust = false;

                  if (double.tryParse(item[position].idCustomer) == null) {
                    print('The input is not a numeric string');
                    checkCust = false;
                  } else {
                    print('Yes, it is a numeric string');
                    checkCust = true;
                  }

                  getMonitoringContractNew(
                    context: context,
                    idCust: item[position].idCustomer,
                    username: username,
                    divisi: divisi,
                    ttdPertama: ttdPertama,
                    isSales: true,
                    isContract: false,
                    isHorizontal: isHorizontal,
                    isNewCust: checkCust,
                  );
                },
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}
