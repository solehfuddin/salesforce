import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RejectedScreen extends StatefulWidget {
  const RejectedScreen({Key? key}) : super(key: key);

  @override
  State<RejectedScreen> createState() => _RejectedScreenState();
}

class _RejectedScreenState extends State<RejectedScreen> {
  bool isDataFound = true;
  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';
  String? ttdPertama = '';
  Contract? itemContract;

  List<Customer> tmpList = List.empty(growable: true);
  List<Customer> currList = List.empty(growable: true);
  Future<List<Customer>>? _listFuture;
  int page = 1;
  int pageCount = 5;
  int startAt = 0;
  int endAt = 0;
  int totalPages = 0;

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

      // getTtd(int.parse(id));
      _listFuture =
          divisi == "AR" ? getCustomerData(true) : getCustomerData(false);

      print("Dashboard : $role");
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
        _listFuture =
            divisi == "AR" ? getCustomerData(true) : getCustomerData(false);
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
        _listFuture =
            divisi == "AR" ? getCustomerData(true) : getCustomerData(false);
        page = page + 1;
      });
    }
  }

  Future<List<Customer>> getCustomerData(bool isAr) async {
    setState(() {
      isDataFound = true;
    });

    List<Customer> list = List.empty(growable: true);
    const timeout = 15;

    var url = !isAr
        ? '$API_URL/customers/rejectedSM/$id?limit=$pageCount&offset=$startAt'
        : '$API_URL/customers/rejectedAM?limit=$pageCount&offset=$startAt';

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
          list = rest.map<Customer>((json) => Customer.fromJson(json)).toList();
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

   getCustomerContract(List<Customer> listCust, int pos, int idCust) async {
    var url = '$API_URL/contract?id_customer=$idCust';
    const timeout = 15;

    try {
      var response = await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
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
            idCust: itemContract!.idCustomer,
            div: divisi!,
            username: username,
            ttd: ttdPertama,
            reasonAM: itemContract!.reasonAm,
            reasonSM: itemContract!.reasonSm,
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

  Future<void> _refreshData() async {
    setState(() {
      _listFuture =
          divisi == "AR" ? getCustomerData(true) : getCustomerData(false);
    });
  }

  Future<bool> _onBackPressed() async {
    if (role == 'ADMIN') {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminScreen()));
      return true;
    } else if (role == 'SALES') {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childRejected(isHorizontal: true);
      }

      return childRejected(isHorizontal: false);
    });
  }

  Widget childRejected({bool isHorizontal = false}) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white70,
          title: Text(
            'Reject Customer',
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
              if (role == 'ADMIN') {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AdminScreen()));
              } else if (role == 'SALES') {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              }
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
                    fontSize: isHorizontal ? 28.sp : 18.sp,
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
                                  AsyncSnapshot<List<Customer>> snapshot) {
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
                                        : Column(
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
      ),
    );
  }

  Widget listViewWidget(List<Customer> customer, int len,
      {bool isHorizontal = false}) {
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
                                  ? Colors.grey.shade600
                                  : customer[position]
                                              .status
                                              .contains('Accepted') ||
                                          customer[position]
                                              .status
                                              .contains('ACCEPTED')
                                      ? Colors.blue.shade600
                                      : customer[position].isRevisi == "1"
                                          ? Colors.orange
                                          : Colors.red.shade600,
                              width: isHorizontal ? 4.w : 5.r),
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
                            Expanded(
                              child: Column(
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
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tgl entry : ',
                                        style: TextStyle(
                                            fontSize:
                                                isHorizontal ? 21.sp : 11.sp,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: isHorizontal ? 35.w : 40.w,
                                      ),
                                      Text(
                                        'Pemilik : ',
                                        style: TextStyle(
                                            fontSize:
                                                isHorizontal ? 21.sp : 11.sp,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        convertDateIndo(
                                            customer[position].dateAdded),
                                        style: TextStyle(
                                            fontSize:
                                                isHorizontal ? 23.sp : 13.sp,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        width: isHorizontal ? 28.w : 25.w,
                                      ),
                                      Text(
                                        customer[position].nama,
                                        style: TextStyle(
                                            fontSize:
                                                isHorizontal ? 23.sp : 13.sp,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
