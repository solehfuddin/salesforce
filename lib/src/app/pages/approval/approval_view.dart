import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
// import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/customer_noimage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ApprovedScreen extends StatefulWidget {
  bool isHideAppbar;
  ApprovedScreen({
    Key? key,
    this.isHideAppbar = false,
  }) : super(key: key);

  @override
  State<ApprovedScreen> createState() => _ApprovedScreenState();
}

class _ApprovedScreenState extends State<ApprovedScreen> {
  bool isDataFound = true;
  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';
  String? ttdPertama = '';

  List<CustomerNoImage> tmpList = List.empty(growable: true);
  List<CustomerNoImage> currList = List.empty(growable: true);
  Future<List<CustomerNoImage>>? _listFuture;
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

  Future<List<CustomerNoImage>> getCustomerData(bool isAr) async {
    setState(() {
      isDataFound = true;
    });

    // const timeout = 15;
    List<CustomerNoImage> list = List.empty(growable: true);
    var url = !isAr
        ? '$API_URL/customers/approvedSM/$id?limit=$pageCount&offset=$startAt'
        : '$API_URL/customers/approvedAM?limit=$pageCount&offset=$startAt';

    try {
      var response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest
              .map<CustomerNoImage>((json) => CustomerNoImage.fromJson(json))
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

  getCustomerContract(
      List<CustomerNoImage> listCust, int pos, int idCust) async {
    const timeout = 15;
    var url = '$API_URL/contract?id_customer=$idCust';

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

  Future<void> _refreshData() async {
    setState(() {
      _listFuture =
          divisi == "AR" ? getCustomerData(true) : getCustomerData(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childApproved(isHorizontal: true);
      }

      return childApproved(isHorizontal: false);
    });
  }

  Widget childApproved({bool isHorizontal = false}) {
    return Scaffold(
      appBar: widget.isHideAppbar
          ? null
          : AppBar(
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
          SizedBox(
            height: 8.h,
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
                                AsyncSnapshot<List<CustomerNoImage>> snapshot) {
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
    );
  }

  Widget listViewWidget(List<CustomerNoImage> customer, int len,
      {bool isHorizontal = false}) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 23.r : 5.r,
              vertical: isHorizontal ? 12.r : 10.r,
            ),
            itemBuilder: (context, position) {
              return Card(
                elevation: 2,
                child: ClipPath(
                  child: InkWell(
                    child: Container(
                      height: isHorizontal ? 120.h : 95.h,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color:
                                customer[position].status.contains('Pending') ||
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
                                        : Colors.red.shade600,
                            width: isHorizontal ? 4.w : 5.w,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isHorizontal ? 20.r : 15.r,
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
                                      fontSize: isHorizontal ? 20.sp : 15.sp,
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
                                  SizedBox(
                                    width: isHorizontal ? 250.w : 200.w,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80.w,
                                          child: Text(
                                            'Tgl entry : ',
                                            style: TextStyle(
                                                fontSize: isHorizontal
                                                    ? 16.sp
                                                    : 11.sp,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Pemilik : ',
                                            style: TextStyle(
                                                fontSize: isHorizontal
                                                    ? 16.sp
                                                    : 11.sp,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  SizedBox(
                                    width: 200.w,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80.w,
                                          child: Text(
                                            convertDateIndo(
                                                customer[position].dateAdded),
                                            style: TextStyle(
                                                fontSize: isHorizontal
                                                    ? 17.sp
                                                    : 12.sp,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            customer[position].nama,
                                            style: TextStyle(
                                              fontSize:
                                                  isHorizontal ? 17.sp : 12.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 5.r,
                                horizontal: 8.r,
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
                                  fontSize: isHorizontal ? 16.sp : 11.sp,
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
