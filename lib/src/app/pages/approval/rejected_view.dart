import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RejectedScreen extends StatefulWidget {
  @override
  _RejectedScreenState createState() => _RejectedScreenState();
}

class _RejectedScreenState extends State<RejectedScreen> {
  String id = '';
  String role = '';
  String username = '';
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

      print("Dashboard : $role");
    });
  }

  Future<List<Customer>> getCustomerData(bool isAr) async {
    List<Customer> list;
    const timeout = 15;

    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/customers/rejectedSM'
        : 'http://timurrayalab.com/salesforce/server/api/customers/rejectedAM';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        list = rest.map<Customer>((json) => Customer.fromJson(json)).toList();
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

  getCustomerContract(List<Customer> listCust, int pos, int idCust) async {
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract?id_customer=$idCust';
    const timeout = 15;

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        itemContract = Contract.fromJson(rest[0]);
        await formRejected(
          context,
          listCust,
          pos,
          idCust: itemContract.idCustomer,
          div: divisi,
          username: username,
          ttd: ttdPertama,
          reasonAM: itemContract.reasonAm,
          reasonSM: itemContract.reasonSm,
          contract: itemContract,
        );
        setState(() {});
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

  getTtd(int input) async {
    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';
    const timeout = 15;

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        ttdPertama = data['data'][0]['ttd'];
        print(ttdPertama);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleConnectionAdmin(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
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

  Future<bool> _onBackPressed() async {
    if (role == 'admin') {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminScreen()));
      return true;
    } else if (role == 'sales') {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white70,
          title: Text(
            'Reject Customer',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0.0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              if (role == 'admin') {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AdminScreen()));
              } else if (role == 'sales') {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              }
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black54,
              size: 18.r,
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
                                  snapshot.data, snapshot.data.length)
                              : Column(
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        'assets/images/not_found.png',
                                        width: 300.r,
                                        height: 300.r,
                                      ),
                                    ),
                                    Text(
                                      'Data tidak ditemukan',
                                      style: TextStyle(
                                        fontSize: 18.sp,
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
      ),
    );
  }

  Widget listViewWidget(List<Customer> customer, int len) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: 5.r,
              vertical: 8.r,
            ),
            itemBuilder: (context, position) {
              return Card(
                elevation: 2,
                child: ClipPath(
                  child: InkWell(
                    child: Container(
                      height: 100.h,
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
                              width: 5.r),
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
                                    fontSize: 16.sp,
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
                                          fontSize: 11.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 40.w,
                                    ),
                                    Text(
                                      'Pemilik : ',
                                      style: TextStyle(
                                          fontSize: 11.sp,
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
                                          fontSize: 13.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      width: 25.w,
                                    ),
                                    Text(
                                      customer[position].nama,
                                      style: TextStyle(
                                          fontSize: 13.sp,
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
                                  fontSize: 12.sp,
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
