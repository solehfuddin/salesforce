import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/renewcontract/history_contract.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/oldcustomer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class RenewalContract extends StatefulWidget {
  dynamic keyword;
  bool? isAdmin = false;

  RenewalContract({this.keyword, this.isAdmin});

  @override
  State<RenewalContract> createState() => _RenewalContractState();
}

class _RenewalContractState extends State<RenewalContract> {
  String? id = '';
  String? role = '';
  String? username = '';
  String? search = '';
  String? divisi = '';
  String? ttdPertama = '';
  bool isDataFound = true;

  // int _count = 10;
  Future<List<OldCustomer>>? oldCustomerList;
  List<OldCustomer> tmpList = List.empty(growable: true);
  TextEditingController txtSearch = TextEditingController();

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");
      ttdPertama = preferences.getString("ttduser");

      print("Search Contract : $role");

      txtSearch.text = widget.keyword;
      search = widget.keyword;
      print("Keyword : ${widget.keyword}");

      oldCustomerList = search!.isNotEmpty
          ? getOldCustomerBySearch(search!)
          : getAllOldCustomer();
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  Future<List<OldCustomer>> getAllOldCustomer() async {
    const timeout = 15;
    var url = '$API_URL/customers/oldCustomer?limit=20&offset=0';
    List<OldCustomer> list = List.empty(growable: true);
    tmpList.clear();
    setState(() {
      isDataFound = true;
    });

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
          // oldCustomerList = rest
          //     .map<OldCustomer>((json) => OldCustomer.fromJson(json))
          //     .toList();

          list = rest
              .map<OldCustomer>((json) => OldCustomer.fromJson(json))
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
      widget.isAdmin!
          ? handleConnectionAdmin(context)
          : handleConnection(context);
    } on Error catch (e) {
      print('General Error : $e');
    }

    setState(() {
      isDataFound = false;
    });

    return list;
  }

  Future<List<OldCustomer>> getOldCustomerBySearch(String input) async {
    const timeout = 15;
    tmpList.clear();
    setState(() {
      isDataFound = true;
    });

    List<OldCustomer> list = List.empty(growable: true);
    var url =
        '$API_URL/customers/searchOldCust?limit=100&offset=0&search=$input';

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
              .map<OldCustomer>((json) => OldCustomer.fromJson(json))
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
      widget.isAdmin!
          ? handleConnectionAdmin(context)
          : handleConnection(context);
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
      // _count = 10;
      oldCustomerList = search!.isNotEmpty
          ? getOldCustomerBySearch(search!)
          // : getOldCustomerByIdLimit(_count);
          : getAllOldCustomer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childRenewalContract(isHorizontal: true);
      }

      return childRenewalContract(isHorizontal: false);
    });
  }

  Widget childRenewalContract({bool isHorizontal = false}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'List Customer Lama',
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
              size: isHorizontal ? 20.sp : 18.r,
              color: Colors.black54,
            )),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 25.r : 20.r,
              vertical: isHorizontal ? 15.r : 10.r,
            ),
            color: Colors.white,
            height: isHorizontal ? 75.h : 80.h,
            child: TextField(
              textInputAction: TextInputAction.search,
              autocorrect: true,
              controller: txtSearch,
              decoration: InputDecoration(
                hintText: 'Pencarian data..',
                prefixIcon: Icon(Icons.search),
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white70,
                contentPadding: EdgeInsets.symmetric(vertical: 3.r),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0.r),
                  ),
                  borderSide: BorderSide(color: Colors.grey, width: 2.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.r),
                  ),
                  borderSide: BorderSide(color: Colors.blue, width: 2.r),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  txtSearch.text = value;
                  search = txtSearch.text;
                  // isDataFound = true;
                  oldCustomerList = search!.isNotEmpty
                      ? getOldCustomerBySearch(search!)
                      : getAllOldCustomer();
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
                          future: oldCustomerList,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<OldCustomer>> snapshot) {
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

  Widget listViewWidget(List<OldCustomer> item, int len,
      {bool isHorizontal = false}) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 25.h : 10.h,
            ),
            shrinkWrap: true,
            itemBuilder: (context, position) {
              return InkWell(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: isHorizontal ? 12.r : 7.r,
                  ),
                  padding: EdgeInsets.all(isHorizontal ? 20.r : 15.r),
                  height: isHorizontal ? 140.h : 125.h,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(isHorizontal ? 30.r : 15.r),
                    border: Border.all(
                      color: Colors.black26,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              item[position].customerShipName,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isHorizontal ? 16.sp : 14.sp,
                                fontFamily: 'Segoe Ui',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            item[position].customerShipNumber,
                            style: TextStyle(
                              fontSize: isHorizontal ? 16.sp : 14.sp,
                              fontFamily: 'Segoe Ui',
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: isHorizontal ? 3.h : 0.h,
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 2.r,
                              horizontal: 5.r,
                            ),
                            decoration: BoxDecoration(
                              color: item[position].status == "A"
                                  ? Colors.orange[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            child: Text(
                              item[position].status == 'A'
                                  ? 'AKTIF'
                                  : 'TIDAK AKTIF',
                              style: TextStyle(
                                fontSize: isHorizontal ? 14.sp : 12.sp,
                                fontFamily: 'Segoe ui',
                                fontWeight: FontWeight.bold,
                                color: item[position].status == "A"
                                    ? Colors.orange[800]
                                    : Colors.red[800],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 2.r,
                              horizontal: 10.r,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.pin_drop_sharp,
                                      color: Colors.blue[800],
                                      size: isHorizontal ? 16.sp : 14.r,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.r,
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: item[position].city,
                                    style: TextStyle(
                                      fontSize: isHorizontal ? 14.sp : 12.sp,
                                      fontFamily: 'Segoe ui',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.attach_file,
                                    color: Colors.grey[600],
                                    size: isHorizontal ? 24.sp : 19.r,
                                  ),
                                ),
                                TextSpan(
                                  text: item[position].totalContract,
                                  style: TextStyle(
                                    fontSize: isHorizontal ? 20.sp : 15.sp,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  item[position].contactPerson,
                                  style: TextStyle(
                                    fontSize: isHorizontal ? 14.sp : 13.sp,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  width: 7.w,
                                ),
                                Image.asset(
                                  'assets/images/avatar_user.png',
                                  width: isHorizontal ? 18.w : 28.w,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryContract(
                        item: item[position],
                        keyword: txtSearch.text,
                        isAdmin: widget.isAdmin,
                        isNewCust: false,
                      ),
                    ),
                  ).then((_) {
                    setState(() {
                      _refreshData();
                    });
                  });
                },
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}
