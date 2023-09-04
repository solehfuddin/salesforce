import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/list_inkaro_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'detail_inkaro_approval.dart';

class RejectInkaro extends StatefulWidget {
  const RejectInkaro({Key? key}) : super(key: key);

  @override
  State<RejectInkaro> createState() => _RejectInkaroState();
}

class _RejectInkaroState extends State<RejectInkaro> {
  String search = '';
  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';
  String? ttdPertama = '';

  List<ListInkaroHeader> tmpList = List.empty(growable: true);
  List<ListInkaroHeader> currList = List.empty(growable: true);
  Future<List<ListInkaroHeader>>? _listFuture;
  int page = 1;
  int pageCount = 5;
  int startAt = 0;
  int endAt = 0;
  int totalPages = 0;
  bool isDataFound = true;

  @override
  initState() {
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

      _listFuture = search.isNotEmpty
          ? getRejectBySearch(
              search,
              divisi == "AR" ? true : false,
              isHorizontal:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? true
                      : false,
            )
          : divisi == "AR"
              ? getRejectData(true)
              : getRejectData(false);
      print("Search Contract : $role");
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
        _listFuture = search.isNotEmpty
            ? getRejectBySearch(
                search,
                divisi == "AR" ? true : false,
                isHorizontal:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? true
                        : false,
              )
            : divisi == "AR"
                ? getRejectData(true)
                : getRejectData(false);
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
            ? getRejectBySearch(
                search,
                divisi == "AR" ? true : false,
                isHorizontal:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? true
                        : false,
              )
            : divisi == "AR"
                ? getRejectData(true)
                : getRejectData(false);
        page = page + 1;
      });
    }
  }

  Future<List<ListInkaroHeader>> getRejectBySearch(String input, bool isAr,
      {bool isHorizontal = false}) async {
    List<ListInkaroHeader> list = List.empty(growable: true);
    const timeout = 15;
    var url = !isAr
        ? '$API_URL/inkaro/getInkaroHeader?approval_sm=REJECT&search=$input&limit=$pageCount&offset=$startAt'
        : '$API_URL/inkaro/getInkaroHeader?approval_am=REJECT&search=$input&limit=$pageCount&offset=$startAt';
    tmpList.clear();

    print('ID SALES : $id');

    setState(() {
      isDataFound = true;
    });

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {"api-key-trl": API_KEY},
      ).timeout(
        Duration(seconds: timeout),
      );

      print('Response status: ${response.statusCode}');

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

  Future<List<ListInkaroHeader>> getRejectData(bool isAr) async {
    List<ListInkaroHeader> list = List.empty(growable: true);
    const timeout = 15;
    var url = !isAr
        ? '$API_URL/inkaro/getInkaroHeader?approval_sm=REJECT&limit=$pageCount&offset=$startAt'
        : '$API_URL/inkaro/getInkaroHeader?approval_am=REJECT&limit=$pageCount&offset=$startAt';
    tmpList.clear();

    setState(() {
      isDataFound = true;
    });

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {"api-key-trl": API_KEY},
      ).timeout(
        Duration(seconds: timeout),
      );
      print('Response status: ${response.statusCode}');

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

  Future<void> _refreshData() async {
    setState(() {
      _listFuture = search.isNotEmpty
          ? getRejectBySearch(
              search,
              divisi == "AR" ? true : false,
              isHorizontal:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? true
                      : false,
            )
          : divisi == "AR"
              ? getRejectData(true)
              : getRejectData(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childRejectedInkaro(isHorizontal: true);
      }
      return childRejectedInkaro(isHorizontal: false);
    });
  }

  Widget childRejectedInkaro({bool isHorizontal = false}) {
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
                  startAt = 0;
                  page = 1;
                  _listFuture = search.isNotEmpty
                      ? getRejectBySearch(
                          search,
                          divisi == "AR" ? true : false,
                          isHorizontal: true,
                        )
                      : divisi == "AR"
                          ? getRejectData(true)
                          : getRejectData(false);
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
                                AsyncSnapshot<List<ListInkaroHeader>>
                                    snapshot) {
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

  Widget listViewWidget(List<ListInkaroHeader> item, int len,
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
              return Padding(
                padding: EdgeInsets.only(
                  bottom: 10.r,
                ),
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.all(isHorizontal ? 15.r : 10.r),
                    height: isHorizontal ? 90.h : 70.h,
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
                          'assets/images/contract-reward.png',
                          filterQuality: FilterQuality.medium,
                          width: isHorizontal ? 45.r : 35.r,
                          height: isHorizontal ? 45.r : 35.r,
                        ),
                        SizedBox(
                          width: isHorizontal ? 8.w : 10.w,
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
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
                              Text(
                                item[position].salesName != ''
                                    ? '(${item[position].salesName})'
                                    : '-',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 20.sp : 14.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Segoe ui',
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              convertDateWithMonth(item[position].createDate),
                              style: TextStyle(
                                fontSize: isHorizontal ? 20.sp : 14.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Segoe ui',
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'REJECTED',
                              style: TextStyle(
                                fontSize: isHorizontal ? 20.sp : 14.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Segoe ui',
                                color: Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    item[position].inkaroContractId != ''
                        ? Navigator.of(context).push(
                            MaterialPageRoute(
                              // builder: (context) => DetailContract(
                              //   item[position],
                              //   divisi!,
                              //   ttdPertama!,
                              //   username!,
                              //   false,
                              //   // isContract: true,
                              //   isContract: false,
                              //   isAdminRenewal: false,
                              //   isNewCust: false,
                              // ),
                              builder: (context) => DetailInkaroApproval(
                                item[position],
                                isPending: false,
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
                ),
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}
