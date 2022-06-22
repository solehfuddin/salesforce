import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApproveRenewal extends StatefulWidget {
  @override
  State<ApproveRenewal> createState() => _ApproveRenewalState();
}

class _ApproveRenewalState extends State<ApproveRenewal> {
  String search = '';
  String id = '';
  String role = '';
  String username = '';
  String divisi = '';
  String ttdPertama;

  Future<void> _refreshData() async {
    setState(() {
      divisi == "AR" ? getApprovalData(true) : getApprovalData(false);
    });
  }

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

      getTtd(int.parse(id));
      print("Search Contract : $role");
      print("Divisi : $divisi");
    });
  }

  getTtd(int input) async {
    const timeout = 15;
    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          ttdPertama = data['data'][0]['ttd'];
          print(ttdPertama);
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(context, e.toString(), false);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  Future<List<Contract>> getApprovalData(bool isAr) async {
    const timeout = 15;
    List<Contract> list;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/contract/acceptedContractOldCustSM'
        : 'http://timurrayalab.com/salesforce/server/api/contract/acceptedContractOldCustAM';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest.map<Contract>((json) => Contract.fromJson(json)).toList();
          print("List Size: ${list.length}");
        }

        return list;
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(context, e.toString(), false);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  Future<List<Contract>> getApprovalBySearch(String input, bool isAr) async {
    const timeout = 15;
    List<Contract> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/findOldCustContract';

    try {
      var response = await http
          .post(
            url,
            body: !isAr
                ? {
                    'search': input,
                    'approval_sm': '1',
                  }
                : {
                    'search': input,
                    'approval_am': '1',
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
        }

        return list;
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(context, e.toString(), false);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error :$e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
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

  Widget childApproveRenewal({bool isHorizontal}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 30.r : 20.r,
              vertical: isHorizontal ? 20.r : 10.r,
            ),
            color: Colors.white,
            height: isHorizontal ? 110.h : 80.h,
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
                      ? getApprovalBySearch(
                          search, divisi == "AR" ? true : false)
                      : divisi == "AR"
                          ? getApprovalData(true)
                          : getApprovalData(false),
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
                                      width: isHorizontal ? 275.r : 300.r,
                                      height: isHorizontal ? 275.r : 300.r,
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

  Widget listViewWidget(List<Contract> item, int len, {bool isHorizontal}) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 30.r : 5.r,
              vertical: isHorizontal ? 20.r : 15.r,
            ),
            shrinkWrap: true,
            itemBuilder: (context, position) {
              return InkWell(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 10.r,
                  ),
                  padding: EdgeInsets.all(isHorizontal ? 20.r : 15.r),
                  height: isHorizontal ? 110.h : 80.h,
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
                        width: isHorizontal ? 60.r : 35.r,
                        height: isHorizontal ? 60.r : 35.r,
                      ),
                      SizedBox(
                        width: isHorizontal ? 5.w : 10.w,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          item[position].customerShipName != null
                              ? item[position].customerShipName
                              : '-',
                          style: TextStyle(
                            fontSize: isHorizontal ? 22.sp : 14.sp,
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
                              fontSize: isHorizontal ? 22.sp : 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Segoe ui',
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: isHorizontal ? 22.sp : 14.sp,
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
                  item[position].idCustomer != null
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailContract(
                              item[position],
                              divisi,
                              ttdPertama,
                              username,
                              true,
                              isContract: true,
                              isAdminRenewal: false,
                            ),
                          ),
                        )
                      : handleStatus(
                          context, 'Id customer tidak ditemukan', false);
                },
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}
