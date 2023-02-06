import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApproveRenewal extends StatefulWidget {
  const ApproveRenewal({Key? key}) : super(key: key);

  @override
  State<ApproveRenewal> createState() => _ApproveRenewalState();
}

class _ApproveRenewalState extends State<ApproveRenewal> {
  String? search = '';
  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';
  String? ttdPertama = '';

  List<Contract> tmpList = List.empty(growable: true);
  List<Contract> currList = List.empty(growable: true);
  Future<List<Contract>>? _listFuture;
  int page = 1;
  int pageCount = 5;
  int startAt = 0;
  int endAt = 0;
  int totalPages = 0;
  bool isDataFound = true;

  @override
  void initState() {
    super.initState();
    getRole();
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");
      ttdPertama = preferences.getString("ttduser") ?? '';

      _listFuture = search!.isNotEmpty
          ? getApprovalBySearch(
              search!,
              divisi == "AR" ? true : false,
              isHorizontal:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? true
                      : false,
            )
          : divisi == "AR"
              ? getApprovalData(true)
              : getApprovalData(false);
      print("Search Contract : $role");
      print("Divisi : $divisi");
    });
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
        _listFuture = search!.isNotEmpty
            ? getApprovalBySearch(
                search!,
                divisi == "AR" ? true : false,
                isHorizontal:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? true
                        : false,
              )
            : divisi == "AR"
                ? getApprovalData(true)
                : getApprovalData(false);
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
        _listFuture = search!.isNotEmpty
            ? getApprovalBySearch(
                search!,
                divisi == "AR" ? true : false,
                isHorizontal:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? true
                        : false,
              )
            : divisi == "AR"
                ? getApprovalData(true)
                : getApprovalData(false);
        page = page + 1;
      });
    }
  }

  Future<List<Contract>> getApprovalData(bool isAr) async {
    const timeout = 15;
    List<Contract> list = List.empty(growable: true);
    var url = !isAr
        ? '$API_URL/contract/acceptedContractOldCustSM?id_manager=$id&limit=$pageCount&offset=$startAt'
        : '$API_URL/contract/acceptedContractOldCustAM?id_customer=&limit=$pageCount&offset=$startAt';
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
          list = rest.map<Contract>((json) => Contract.fromJson(json)).toList();
          print("List Size: ${list.length}");

          setState(() {
            initalizePage(data['total']);
            tmpList = list;
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
      isDataFound = false;
    });

    return list;
  }

  Future<List<Contract>> getApprovalBySearch(String input, bool isAr,
      {bool isHorizontal = false}) async {
    const timeout = 15;
    List<Contract> list = List.empty(growable: true);
    var url = '$API_URL/contract/findOldCustContract';
    tmpList.clear();

    setState(() {
      isDataFound = true;
    });

    try {
      var response = await http
          .post(
            Uri.parse(url),
            body: !isAr
                ? {
                    'search': input,
                    'approval_sm': '1',
                    'id_salesmanager': '$id',
                    'limit': '$pageCount',
                    'offset': '$startAt',
                  }
                : {
                    'search': input,
                    'approval_sm': '1',
                    'approval_am': '1',
                    'limit': '$pageCount',
                    'offset': '$startAt',
                  },
          )
          .timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest.map<Contract>((json) => Contract.fromJson(json)).toList();
          print("List Size: ${list.length}");

          setState(() {
            initalizePage(data['total']);
            tmpList = list;
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
      print('Timeout Error :$e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
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
      _listFuture = search!.isNotEmpty
          ? getApprovalBySearch(
              search!,
              divisi == "AR" ? true : false,
              isHorizontal:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? true
                      : false,
            )
          : divisi == "AR"
              ? getApprovalData(true)
              : getApprovalData(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childApproveRenewal(isHorizontal: true);
      }

      return childApproveRenewal(isHorizontal: false);
    });
  }

  Widget childApproveRenewal({bool isHorizontal = false}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  _listFuture = search!.isNotEmpty
                      ? getApprovalBySearch(
                          search!,
                          divisi == "AR" ? true : false,
                          isHorizontal: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? true
                              : false,
                        )
                      : divisi == "AR"
                          ? getApprovalData(true)
                          : getApprovalData(false);
                });
              },
            ),
          ),
          Row(
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
                backgroundColor:
                    page < totalPages ? Colors.green : Colors.green.shade200,
                mini: true,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: isHorizontal ? 30.r : 20.r,
                ),
                elevation: 0,
                onPressed: page < totalPages ? loadNextPage : null,
              ),
            ],
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
                                AsyncSnapshot<List<Contract>> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Center(
                                      child: CircularProgressIndicator());
                                default:
                                  return snapshot.data != null
                                      ? listViewWidget(
                                          snapshot.data!,
                                          snapshot.data!.length,
                                          isHorizontal: isHorizontal,
                                        )
                                      : Expanded(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Center(
                                                  child: Image.asset(
                                                    'assets/images/not_found.png',
                                                    width: isHorizontal
                                                        ? 150.w
                                                        : 230.w,
                                                    height: isHorizontal
                                                        ? 150.h
                                                        : 230.h,
                                                  ),
                                                ),
                                                Text(
                                                  'Data tidak ditemukan',
                                                  style: TextStyle(
                                                    fontSize: isHorizontal
                                                        ? 16.sp
                                                        : 18.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.red[600],
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                              }
                            }),
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Column(
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
                    ),
        ],
      ),
    );
  }

  Widget listViewWidget(List<Contract> item, int len,
      {bool isHorizontal = false}) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 25.r : 20.r,
              vertical: isHorizontal ? 15.r : 10.r,
            ),
            shrinkWrap: true,
            itemBuilder: (context, position) {
              return InkWell(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 10.r,
                  ),
                  padding: EdgeInsets.all(isHorizontal ? 15.r : 10.r),
                  height: isHorizontal ? 90.h : 75.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(isHorizontal ? 20.r : 15.r),
                    ),
                    border: Border.all(
                      color: Colors.black26,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/e_contract_new.png',
                        filterQuality: FilterQuality.medium,
                        width: isHorizontal ? 45.r : 35.r,
                        height: isHorizontal ? 45.r : 35.r,
                      ),
                      SizedBox(
                        width: isHorizontal ? 8.w : 10.w,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          item[position].customerShipName != ''
                              ? item[position].customerShipName
                              : '-',
                          style: TextStyle(
                            fontSize: isHorizontal ? 20.sp : 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            convertDateWithMonth(item[position].dateAdded),
                            style: TextStyle(
                              fontSize: isHorizontal ? 20.sp : 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Segoe ui',
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: isHorizontal ? 20.sp : 14.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  item[position].idCustomer != ''
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailContract(
                              item[position],
                              divisi!,
                              ttdPertama!,
                              username!,
                              true,
                              isContract: true,
                              isAdminRenewal: false,
                              isNewCust: false,
                            ),
                          ),
                        )
                      : handleStatus(
                          context,
                          'Id customer tidak ditemukan',
                          false,
                          isHorizontal: isHorizontal,
                          isLogout: false,
                        );
                },
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}
