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
  String id = '';
  String role = '';
  String username = '';
  String search = '';
  String divisi = '';
  String ttdPertama;
  Contract itemContract;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");

      getTtd(int.parse(id));
      print("Search Contract : $role");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  getTtd(int input) async {
    const timeout = 15;
    var url = '$API_URL/users?id=$input';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          ttdPertama = data['data']['ttd'];
          print(ttdPertama);
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

  Future<List<Monitoring>> getMonitoringData() async {
    List<Monitoring> list;
    const timeout = 15;

    var url =
        '$API_URL/contract/monitoring';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
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
        }

        return list;
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
  }

  Future<List<Monitoring>> getMonitoringBySearch(String input) async {
    List<Monitoring> list;
    const timeout = 15;
    var url =
        '$API_URL/contract/search?search=$input';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
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
        }

        return list;
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

  Future<void> _refreshData() async {
    setState(() {
      search.isNotEmpty ? getMonitoringBySearch(search) : getMonitoringData();
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

  Widget contractChild({bool isHorizontal}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'List Monitoring Contract',
          style: TextStyle(
            color: Colors.black54,
            fontSize: isHorizontal ? 30.sp : 18.sp,
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
            size: isHorizontal ? 28.r : 18.r,
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
            height: isHorizontal ? 100.h : 80.h,
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
                });
              },
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 100.h,
              child: FutureBuilder(
                  future: search.isNotEmpty
                      ? getMonitoringBySearch(search)
                      : getMonitoringData(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        return snapshot.data != null
                            ? listViewWidget(
                                snapshot.data,
                                snapshot.data.length,
                                isHorizontal: isHorizontal,
                              )
                            : Column(
                                children: [
                                  Center(
                                    child: Image.asset(
                                      'assets/images/not_found.png',
                                      width: isHorizontal ? 340.r : 300.r,
                                      height: isHorizontal ? 340.r : 300.r,
                                    ),
                                  ),
                                  Text(
                                    'Data tidak ditemukan',
                                    style: TextStyle(
                                      fontSize: isHorizontal ? 28.sp : 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[600],
                                      fontFamily: 'Montserrat',
                                    ),
                                  )
                                ],
                              );
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget listViewWidget(List<Monitoring> item, int len, {bool isHorizontal}) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 25.r : 10.r,
              vertical: isHorizontal ? 30.r : 15.r,
            ),
            shrinkWrap: true,
            itemBuilder: (context, position) {
              return InkWell(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 7.r,
                  ),
                  padding: EdgeInsets.all(
                    isHorizontal ? 25.r : 15.r,
                  ),
                  height: isHorizontal ? 170.h : 110.h,
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
                      Text(
                        item[position].namaUsaha != null
                            ? item[position].namaUsaha
                            : item[position].customerShipName,
                        style: TextStyle(
                          fontSize: isHorizontal ? 28.sp : 18.sp,
                          fontFamily: 'Segoe Ui',
                          fontWeight: FontWeight.w600,
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
                                  fontSize: isHorizontal ? 22.sp : 12.sp,
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
                                  fontSize: isHorizontal ? 26.sp : 16.sp,
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
                                  fontSize: isHorizontal ? 22.sp : 12.sp,
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
                                  fontSize: isHorizontal ? 26.sp : 16.sp,
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
                  item[position].idCustomer != null
                      ? getCustomerContractNew(
                          context: context,
                          idCust: item[position].idCustomer,
                          username: username,
                          divisi: divisi,
                          ttdPertama: ttdPertama,
                          isSales: true,
                          isContract: false,
                          isHorizontal: isHorizontal,
                        )
                      : handleStatus(
                          context,
                          'Id customer tidak ditemukan',
                          false,
                          isHorizontal: isHorizontal,
                        );
                },
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}
