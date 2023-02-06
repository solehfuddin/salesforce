import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/renewcontract/change_contract.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/oldcustomer.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class HistoryContract extends StatefulWidget {
  OldCustomer? item;
  Customer? cust;
  dynamic keyword;
  bool? isAdmin = false;
  bool? isNewCust = false;

  HistoryContract({
    this.item,
    this.cust,
    this.keyword,
    this.isAdmin,
    this.isNewCust,
  });

  @override
  State<HistoryContract> createState() => _HistoryContractState();
}

class _HistoryContractState extends State<HistoryContract> {
  String? id = '';
  String? role = '';
  String? username = '';
  String? search = '';
  String? divisi = '';
  String? ttdPertama = '';
  String? noAccount = '';
  bool isDataFound = true;
  List<Contract> activeContract = List.empty(growable: true);
  Future<List<Contract>>? historyContract;
  List<Contract> tmpList = List.empty(growable: true);

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");
      ttdPertama = preferences.getString("ttduser");

      noAccount = widget.isNewCust!
          ? widget.cust!.noAccount != ''
              ? widget.cust!.noAccount
              : '-'
          : widget.item!.customerShipNumber;

      historyContract = getHistoryContract(widget.isNewCust!
          ? widget.cust!.id
          : widget.item!.customerShipNumber);

      print("Search Contract : $role");
      print("Keyword : ${widget.keyword}");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
    getContractActive();
  }

  getContractActive() async {
    const timeout = 15;
    var url = widget.isNewCust!
        ? '$API_URL/contract/getActiveContractById?id=${widget.cust!.id}' //recheck please
        : '$API_URL/contract/getActiveContractById?id=${widget.item!.customerShipNumber}';

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
          activeContract =
              rest.map<Contract>((json) => Contract.fromJson(json)).toList();
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
  }

  Future<List<Contract>> getHistoryContract(String input) async {
    setState(() {
      isDataFound = false;
    });

    tmpList.clear();
    const timeout = 15;
    List<Contract> list = List.empty(growable: true);
    var url = '$API_URL/contract?id_customer=$input';

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
      historyContract = getHistoryContract(widget.isNewCust!
          ? widget.cust!.id
          : widget.item!.customerShipNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childHistoryContract(isHorizontal: true);
      }

      return childHistoryContract(isHorizontal: false);
    });
  }

  Widget childHistoryContract({bool isHorizontal = false}) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity.w,
                        height: isHorizontal ? 240.h : 270.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: isHorizontal
                                      ? MediaQuery.of(context).size.height / 2.9
                                      : MediaQuery.of(context).size.width /
                                          2.1),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: isHorizontal ? 25.r : 15.r,
                                ),
                                style: ButtonStyle(
                                  shape:
                                      MaterialStateProperty.all(CircleBorder()),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(8.r)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity.w,
                              height: isHorizontal ? 35.h : 25.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                      isHorizontal ? 60.r : 30.r),
                                  topRight: Radius.circular(
                                      isHorizontal ? 60.r : 30.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/history_contract.png'),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                      Container(
                        height: isHorizontal ? 260.r : 220.h,
                        padding: EdgeInsets.symmetric(
                            horizontal: isHorizontal ? 30.r : 20.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isHorizontal
                                ? Center(
                                    child: Text(
                                      widget.isNewCust!
                                          ? widget.cust!.namaUsaha
                                          : widget.item!.customerShipName,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22.sp,
                                        fontFamily: 'Montserrat',
                                      ),
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : Text(
                                    widget.isNewCust!
                                        ? widget.cust!.namaUsaha
                                        : widget.item!.customerShipName,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                      fontFamily: 'Montserrat',
                                    ),
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            SizedBox(
                              height: isHorizontal ? 20.h : 10.h,
                            ),
                            Center(
                              child: Container(
                                width: isHorizontal
                                    ? MediaQuery.of(context).size.width / 0.8
                                    : double.infinity.w,
                                height: isHorizontal ? 190.h : 180.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.r),
                                  border: Border.all(
                                    color: Colors.black12,
                                    width: 1.8.r,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.r,
                                            ),
                                            child: Text(
                                              'Penanggung Jawab',
                                              style: TextStyle(
                                                fontFamily: 'Segoe ui',
                                                fontSize: isHorizontal
                                                    ? 18.sp
                                                    : 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black54,
                                              ),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.r,
                                            ),
                                            child: Text(
                                              widget.isNewCust!
                                                  ? widget.cust!.namaPj
                                                  : widget.item!.contactPerson
                                                      .trim(),
                                              style: TextStyle(
                                                fontFamily: 'Segoe ui',
                                                fontSize: isHorizontal
                                                    ? 18.sp
                                                    : 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 1.8.h,
                                      decoration: BoxDecoration(
                                        color: Colors.black12,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.r,
                                            ),
                                            child: Text(
                                              'Nomor Akun',
                                              style: TextStyle(
                                                fontFamily: 'Segoe ui',
                                                fontSize: isHorizontal
                                                    ? 18.sp
                                                    : 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black54,
                                              ),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.r,
                                            ),
                                            child: Text(
                                              noAccount!,
                                              style: TextStyle(
                                                fontFamily: 'Segoe ui',
                                                fontSize: isHorizontal
                                                    ? 18.sp
                                                    : 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 1.8.h,
                                      decoration: BoxDecoration(
                                        color: Colors.black12,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.r,
                                            ),
                                            child: Text(
                                              'Nomor Kontak',
                                              style: TextStyle(
                                                fontFamily: 'Segoe ui',
                                                fontSize: isHorizontal
                                                    ? 18.sp
                                                    : 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black54,
                                              ),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.r,
                                              vertical: 3.r,
                                            ),
                                            child: Text(
                                              widget.isNewCust!
                                                  ? widget.cust!.noTlp
                                                  : widget.item!.phone,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isHorizontal ? 28.r : 20.r,
                          vertical: isHorizontal ? 0.r : 10.r,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            divisi != "SALES"
                                ? SizedBox(
                                    width: 5.w,
                                  )
                                : Container(
                                    alignment: Alignment.centerRight,
                                    child: ArgonButton(
                                      height: isHorizontal ? 45.h : 30.h,
                                      width: isHorizontal ? 90.w : 100.w,
                                      borderRadius:
                                          isHorizontal ? 60.r : 30.0.r,
                                      color: Colors.blue[600],
                                      child: Text(
                                        "Ubah kontrak",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                isHorizontal ? 16.sp : 12.sp,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      loader: Container(
                                        padding: EdgeInsets.all(8.r),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onTap: (startLoading, stopLoading,
                                          btnState) {
                                        if (btnState == ButtonState.Idle) {
                                          startLoading();
                                          waitingLoad();
                                          widget.isNewCust!
                                              ? Navigator.of(context)
                                                  .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChangeContract(
                                                      activeContract,
                                                      customer: widget.cust!,
                                                      isNewCust: true,
                                                      keyword: widget.keyword,
                                                    ),
                                                  ),
                                                )
                                              : Navigator.of(context)
                                                  .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChangeContract(
                                                      activeContract,
                                                      oldCustomer: widget.item!,
                                                      keyword: widget.keyword,
                                                      isNewCust: false,
                                                    ),
                                                  ),
                                                );
                                          stopLoading();
                                        }
                                      },
                                    ),
                                  ),
                            SizedBox(
                              height: isHorizontal ? 30.h : 15.h,
                            ),
                            isHorizontal
                                ? Text('Riwayat Kontrak',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 22.sp,
                                      fontFamily: 'Montserrat',
                                    ))
                                : Text(
                                    'Riwayat Kontrak',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                            SizedBox(
                              height: isHorizontal ? 15.h : 10.h,
                            ),
                            isDataFound
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.r,
                                    ),
                                    child: CircularProgressIndicator(),
                                  )
                                : tmpList.length > 0
                                    ? FutureBuilder(
                                        future: historyContract,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<Contract>>
                                                snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            if (snapshot.hasError) {
                                              return Column(
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
                                                      fontSize:
                                                          isHorizontal
                                                              ? 16.sp
                                                              : 18.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.red[600],
                                                      fontFamily:
                                                          'Montserrat',
                                                    ),
                                                  )
                                                ],
                                              );
                                            } else {
                                              return listViewWidget(
                                                snapshot.data!,
                                                snapshot.data!.length,
                                                isHorizontal:
                                                    isHorizontal,
                                                isNewCust:
                                                    widget.isNewCust!,
                                              );
                                            }
                                          } else {
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        })
                                    : Column(
                                        children: [
                                          Center(
                                            child: Image.asset(
                                              'assets/images/not_found.png',
                                              width:
                                                  isHorizontal ? 150.w : 230.w,
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
                                      ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listViewWidget(
    List<Contract> item,
    int len, {
    bool isHorizontal = false,
    bool isNewCust = false,
  }) {
    return RefreshIndicator(
      child: ListView.builder(
        padding: isHorizontal
            ? EdgeInsets.symmetric(
                horizontal: 3.r,
                vertical: 10.r,
              )
            : EdgeInsets.zero,
        itemCount: len,
        shrinkWrap: true,
        itemBuilder: (context, position) {
          return InkWell(
            child: Container(
              margin: EdgeInsets.only(
                bottom: isHorizontal ? 15.r : 8.r,
              ),
              padding: EdgeInsets.all(isHorizontal ? 17.r : 15.r),
              height: isHorizontal ? 95.h : 75.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(isHorizontal ? 25.r : 15.r),
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
                    width: isHorizontal ? 50.r : 35.r,
                    height: isHorizontal ? 50.r : 35.r,
                  ),
                  SizedBox(
                    width: isHorizontal ? 5.w : 10.w,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Kontrak tahun ${item[position].startContract.substring(0, 4)}',
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Segoe ui',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        convertDateWithMonth(item[position].startContract),
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Segoe ui',
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        item[position].status,
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Segoe ui',
                          color: item[position].status == "ACTIVE"
                              ? Colors.green.shade700
                              : item[position].status == "INACTIVE" ||
                                      item[position].status == "REJECTED"
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
              item[position].status.contains('ACTIVE')
                  ? getCustomerContractNew(
                      context: context,
                      idCust: item[position].idCustomer,
                      divisi: divisi,
                      username: username,
                      ttdPertama: ttdPertama,
                      isSales: true,
                      isContract: false,
                      isHorizontal: isHorizontal,
                      isNewCust: isNewCust,
                    )
                  : formWaitingContract(
                      context,
                      item,
                      position,
                      item[position].reasonSm,
                      item[position].reasonAm,
                      isNewCust: widget.isNewCust!,
                      customer: widget.cust,
                    );
            },
          );
        },
      ),
      onRefresh: _refreshData,
    );
  }
}
