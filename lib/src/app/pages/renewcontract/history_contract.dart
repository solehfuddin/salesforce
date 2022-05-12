import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/renewcontract/change_contract.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/oldcustomer.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryContract extends StatefulWidget {
  OldCustomer item;
  dynamic keyword;
  bool isAdmin = false;

  HistoryContract(this.item, {this.keyword, this.isAdmin});

  @override
  State<HistoryContract> createState() => _HistoryContractState();
}

class _HistoryContractState extends State<HistoryContract> {
  String id = '';
  String role = '';
  String username = '';
  String search = '';
  String divisi = '';
  String ttdPertama;
  bool _isConnected = false;
  List<Contract> activeContract = List.empty(growable: true);

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");

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

  getTtd(int input) async {
    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      ttdPertama = data['data'][0]['ttd'];
      print(ttdPertama);
    }
  }

  getContractActive() async {
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/getActiveContractById?id=${widget.item.customerShipNumber}';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      getTtd(int.parse(id));

      if (sts) {
        var rest = data['data'];
        print(rest);
        activeContract =
            rest.map<Contract>((json) => Contract.fromJson(json)).toList();
      }
      _isConnected = true;
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
      _isConnected = false;
    } on SocketException catch (e) {
      print('Socket Error : $e');
      widget.isAdmin
          ? handleConnectionAdmin(context)
          : handleConnection(context);
      _isConnected = false;
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
      _isConnected = false;
    }
  }

  Future<List<Contract>> getHistoryContract(String input) async {
    const timeout = 15;
    List<Contract> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract?id_customer=$input';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        list = rest.map<Contract>((json) => Contract.fromJson(json)).toList();
        print("List Size: ${list.length}");
      }

      return list;
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      getHistoryContract(widget.item.customerShipNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        height: 280.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 190.r),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 15.r,
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
                              height: 25.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30.r),
                                  topRight: Radius.circular(30.r),
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
                        height: 230.h,
                        padding: EdgeInsets.symmetric(horizontal: 20.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.customerShipName,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 18.sp,
                                fontFamily: 'Montserrat',
                              ),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Container(
                              width: double.infinity.w,
                              height: 180.h,
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
                                              fontSize: 15.sp,
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
                                            widget.item.contactPerson.trim(),
                                            style: TextStyle(
                                              fontFamily: 'Segoe ui',
                                              fontSize: 15.sp,
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
                                              fontSize: 15.sp,
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
                                            widget.item.customerShipNumber,
                                            style: TextStyle(
                                              fontFamily: 'Segoe ui',
                                              fontSize: 15.sp,
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
                                            'Status Akun',
                                            style: TextStyle(
                                              fontFamily: 'Segoe ui',
                                              fontSize: 15.sp,
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
                                          margin: EdgeInsets.only(left: 7.r),
                                          decoration: BoxDecoration(
                                            color: widget.item.status == "A"
                                                ? Colors.orange[100]
                                                : Colors.red[100],
                                            borderRadius:
                                                BorderRadius.circular(3.r),
                                          ),
                                          child: Text(
                                            widget.item.status == 'A'
                                                ? 'AKTIF'
                                                : 'TIDAK AKTIF',
                                            style: TextStyle(
                                              fontFamily: 'Segoe ui',
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                              color: widget.item.status == 'A'
                                                  ? Colors.orange[800]
                                                  : Colors.red[800],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.r,
                          vertical: 10.r,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.isAdmin
                                ? SizedBox(
                                    width: 5.w,
                                  )
                                : Container(
                                    alignment: Alignment.centerRight,
                                    child: ArgonButton(
                                      height: 30.h,
                                      width: 100.w,
                                      borderRadius: 30.0.r,
                                      color: Colors.blue[600],
                                      child: Text(
                                        "Ubah kontrak",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
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
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChangeContract(
                                                        widget.item,
                                                        activeContract,
                                                        keyword: widget.keyword,
                                                      )));
                                          stopLoading();
                                        }
                                      },
                                    ),
                                  ),
                            SizedBox(
                              height: 15.h,
                            ),
                            Text(
                              'Riwayat Kontrak',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            FutureBuilder(
                                future: getHistoryContract(
                                    widget.item.customerShipNumber),
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Center(
                                          child: CircularProgressIndicator());
                                    default:
                                      return snapshot.data != null
                                          ? listViewWidget(snapshot.data,
                                              snapshot.data.length)
                                          : Column(
                                              children: [
                                                Center(
                                                  child: Image.asset(
                                                    'assets/images/not_found.png',
                                                    width: 150.w,
                                                    height: 150.h,
                                                  ),
                                                ),
                                                Text(
                                                  'Data tidak ditemukan',
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.red[600],
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                ),
                                              ],
                                            );
                                  }
                                }),
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

  Widget listViewWidget(List<Contract> item, int len) {
    return RefreshIndicator(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: len,
        shrinkWrap: true,
        itemBuilder: (context, position) {
          return InkWell(
            child: Container(
              margin: EdgeInsets.only(
                bottom: 5.r,
              ),
              padding: EdgeInsets.all(15.r),
              height: 75.h,
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
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Kontrak tahun ${item[position].startContract.substring(0, 4)}',
                      style: TextStyle(
                        fontSize: 14.sp,
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
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Segoe ui',
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        item[position].status,
                        style: TextStyle(
                          fontSize: 14.sp,
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
              item[position].status.contains('PENDING') ||
                      item[position].status.contains('pending') ||
                      item[position].status.contains('REJECTED') ||
                      item[position].status.contains('rejected')
                  ? formWaitingContract(context, item, position)
                  : item[position].idCustomer != null
                      ? getCustomerContractNew(
                          context: context,
                          idCust: item[position].idCustomer,
                          divisi: divisi,
                          username: username,
                          ttdPertama: ttdPertama,
                          isSales: true,
                          isContract: false,
                        )
                      : handleStatus(
                          context, 'Id customer tidak ditemukan', false);
            },
          );
        },
      ),
      onRefresh: _refreshData,
    );
  }
}
