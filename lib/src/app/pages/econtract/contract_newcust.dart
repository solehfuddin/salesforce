import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class ContractNewcust extends StatefulWidget {
  int? len = 0;
  ContractNewcust({this.len});

  @override
  State<ContractNewcust> createState() => _ContractNewcustState();
}

class _ContractNewcustState extends State<ContractNewcust> {
  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';
  String ttdPertama = '';
  List<Contract> currList = List.empty(growable: true);
  Future<List<Contract>>? _listFuture;
  int page = 1;
  int pageCount = 5;
  int startAt = 0;
  int endAt = 0;
  int totalPages = 0;

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

      _listFuture = getContractNewcust();
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
        _listFuture = getContractNewcust();
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
        _listFuture = getContractNewcust();
        page = page + 1;
      });
    }
  }

  Future<List<Contract>> getContractNewcust() async {
    const timeout = 15;
    List<Contract> list = List.empty(growable: true);

    if (list.length > 0) {
      list.clear();
    }

    var url = divisi != "AR"
        ? '$API_URL/contract/pendingContractNewCustSM?id_manager=$id&limit=$pageCount&offset=$startAt'
        : '$API_URL/contract/pendingContractNewCustAM?limit=$pageCount&offset=$startAt';

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
          });
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }

    return list;
  }

  Future<void> _refreshData() async {
    setState(() {
      _listFuture = getContractNewcust();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return contractChild(isHorizontal: true);
      }
      return contractChild(isHorizontal: false);
    });
  }

  Widget contractChild({bool isHorizontal = false}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'List Kontrak Kustomer Baru',
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
          onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdminScreen())),
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
          widget.len! > 0
              ? Expanded(
                  child: SizedBox(
                    height: 100.h,
                    child: FutureBuilder(
                        future: _listFuture,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Contract>> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Center(child: CircularProgressIndicator());
                            default:
                              return snapshot.data != null
                                  ? listViewWidget(
                                      snapshot.data!,
                                      snapshot.data!.length,
                                      isHorizontal: isHorizontal,
                                    )
                                  : Column(
                                      children: [
                                        Center(
                                          child: Image.asset(
                                            'assets/images/not_found.png',
                                            width: isHorizontal ? 150.w : 230.w,
                                            height:
                                                isHorizontal ? 150.h : 230.h,
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

  Widget listViewWidget(List<Contract> item, int len,
      {bool isHorizontal = false}) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 10.r : 5.r,
              vertical: isHorizontal ? 20.r : 8.r,
            ),
            itemBuilder: (context, index) {
              return InkWell(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 10.r,
                  ),
                  padding: EdgeInsets.all(isHorizontal ? 20.r : 15.r),
                  height: isHorizontal ? 90.h : 75.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.r),
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
                        width: isHorizontal ? 5.w : 10.w,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          item[index].customerShipName != ''
                              ? item[index].customerShipName.toUpperCase()
                              : '-',
                          style: TextStyle(
                            fontSize: isHorizontal ? 18.sp : 14.sp,
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
                            convertDateWithMonth(item[index].dateAdded),
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Segoe ui',
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            item[index].status,
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: item[index].status == "ACTIVE"
                                  ? Colors.green.shade700
                                  : item[index].status == "INACTIVE"
                                      ? Colors.red.shade800
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  item[index].idCustomer != ''
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailContract(
                              item[index],
                              divisi!,
                              ttdPertama,
                              username!,
                              false,
                              isContract: true,
                              isAdminRenewal: true,
                              isNewCust: true,
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
