import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApprovedScreen extends StatefulWidget {
  @override
  _ApprovedScreenState createState() => _ApprovedScreenState();
}

class _ApprovedScreenState extends State<ApprovedScreen> {
  String id = '';
  String role = '';
  String username = '';
  String divisi = '';
  String ttdPertama;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");

      getTtd(int.parse(id));

      print("Dashboard : $role");
    });
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
      handleConnectionAdmin(context);
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  Future<List<Customer>> getCustomerData(bool isAr) async {
    const timeout = 15;
    List<Customer> list;
    var url = !isAr
        ? '$API_URL/customers/approvedSM'
        : '$API_URL/customers/approvedAM';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest.map<Customer>((json) => Customer.fromJson(json)).toList();
          print("List Size: ${list.length}");
        }

        return list;
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
  }

  Future<void> _refreshData() async {
    setState(() {
      divisi == "AR" ? getCustomerData(true) : getCustomerData(false);
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  getCustomerContract(List<Customer> listCust, int pos, int idCust) async {
    const timeout = 15;
    var url =
        '$API_URL/contract?id_customer=$idCust';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          itemContract = Contract.fromJson(rest[0]);
          await formWaiting(
            context,
            listCust,
            pos,
            reasonAM: itemContract.reasonAm,
            reasonSM: itemContract.reasonSm,
            contract: itemContract,
          );
          setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 || MediaQuery.of(context).orientation == Orientation.landscape){
        return childApproved(isHorizontal: true);
      }

      return childApproved(isHorizontal:  false);
    });
  }

  Widget childApproved({bool isHorizontal}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Approved Customer',
          style: TextStyle(
            color: Colors.black54,
            fontSize: isHorizontal ? 28.sp : 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black54,
            size: isHorizontal ? 28.sp : 18.r,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              height: 100.h,
              child: FutureBuilder(
                  future: divisi == "AR"
                      ? getCustomerData(true)
                      : getCustomerData(false),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        return snapshot.data != null
                            ? listViewWidget(
                                snapshot.data, snapshot.data.length, isHorizontal: isHorizontal,)
                            : Column(
                                children: [
                                  Center(
                                    child: Image.asset(
                                      'assets/images/not_found.png',
                                      width: isHorizontal ? 350.r : 300.r,
                                      height: isHorizontal ? 350.r : 300.r,
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

  Widget listViewWidget(List<Customer> customer, int len, {bool isHorizontal}) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 20.r : 5.r,
              vertical: isHorizontal ? 30.r : 8.r,
            ),
            itemBuilder: (context, position) {
              return Card(
                elevation: 2,
                child: ClipPath(
                  child: InkWell(
                    child: Container(
                      height: isHorizontal ? 160.h : 100.h,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                              color: customer[position]
                                          .status
                                          .contains('Pending') ||
                                      customer[position]
                                          .status
                                          .contains('PENDING')
                                  ? Colors.grey[600]
                                  : customer[position]
                                              .status
                                              .contains('Accepted') ||
                                          customer[position]
                                              .status
                                              .contains('ACCEPTED')
                                      ? Colors.blue[600]
                                      : Colors.red[600],
                              width: isHorizontal ? 4.w : 5.w),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.r,
                          vertical: 8.r,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  customer[position].namaUsaha,
                                  style: TextStyle(
                                    fontSize: isHorizontal ? 25.sp : 16.sp,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tgl entry : ',
                                      style: TextStyle(
                                          fontSize: isHorizontal ? 21.sp : 11.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: isHorizontal ? 35.w : 40.w,
                                    ),
                                    Text(
                                      'Pemilik : ',
                                      style: TextStyle(
                                          fontSize: isHorizontal ? 21.sp : 11.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      convertDateIndo(
                                          customer[position].dateAdded),
                                      style: TextStyle(
                                          fontSize: isHorizontal ? 23.sp : 13.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      width: isHorizontal ? 28.w : 25.w,
                                    ),
                                    Text(
                                      customer[position].nama,
                                      style: TextStyle(
                                          fontSize: isHorizontal ? 23.sp : 13.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 5.r,
                                horizontal: 10.r,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal[400],
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                customer[position].namaSalesman.length > 0
                                    ? capitalize(
                                        customer[position].namaSalesman)
                                    : 'Admin',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 22.sp : 12.sp,
                                  fontFamily: 'Segoe ui',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      getCustomerContract(
                          customer, position, int.parse(customer[position].id));
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
