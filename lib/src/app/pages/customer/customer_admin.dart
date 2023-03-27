import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sample/src/app/pages/econtract/econtract_view.dart';
import 'package:sample/src/app/pages/entry/newcust_view.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
// import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/customer_noimage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerAdmin extends StatefulWidget {
  final int idOuter;

  CustomerAdmin(this.idOuter);

  @override
  State<CustomerAdmin> createState() => _CustomerAdminState();
}

class _CustomerAdminState extends State<CustomerAdmin> {
  String? id = '';
  String? role = '';
  String? username = '';
  String search = '';
  bool isDataFound = true;
  var thisYear, nextYear;
  List<CustomerNoImage> customerList = List.empty(growable: true);
  List<CustomerNoImage> currList = List.empty(growable: true);
  List<CustomerNoImage> tmpList = List.empty(growable: true);
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

      var formatter = new DateFormat('yyyy');
      thisYear = formatter.format(DateTime.now());
      nextYear = int.parse(thisYear) + 1;

      _listFuture = search.isNotEmpty
          ? getCustomerBySeach(search)
          : getCustomerByIdOld(widget.idOuter);

      print('This Year : $thisYear');
      print('Next Year : $nextYear');

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
        _listFuture = search.isNotEmpty
            ? getCustomerBySeach(search)
            : getCustomerByIdOld(widget.idOuter);
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
            ? getCustomerBySeach(search)
            : getCustomerByIdOld(widget.idOuter);
        page = page + 1;
      });
    }
  }

  Future<List<CustomerNoImage>> getCustomerByIdOld(int input) async {
    List<CustomerNoImage> list = List.empty(growable: true);
    const timeout = 50;
    tmpList.clear();

    setState(() {
      isDataFound = true;
    });

    try {
      var url = input < 1
          ? '$API_URL/customers&limit=$pageCount&offset=$startAt&id_salesmanager=$id'
          : '$API_URL/customers/getBySales?created_by=$input&limit=$pageCount&offset=$startAt';

      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest.map<CustomerNoImage>((json) => CustomerNoImage.fromJson(json)).toList();
          print("List Size: ${customerList.length}");

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
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }

    setState(() {
      isDataFound = false;
    });

    return list;
  }

  Future<List<CustomerNoImage>> getCustomerBySeach(String input) async {
    List<CustomerNoImage> list = List.empty(growable: true);
    const timeout = 15;
    var url =
        '$API_URL/customers/search?search=$input&limit=$pageCount&offset=$startAt&id_salesmanager=&created_by=$id';
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
          list = rest.map<CustomerNoImage>((json) => CustomerNoImage.fromJson(json)).toList();
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
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }

    setState(() {
      isDataFound = false;
    });

    return list;
  }

  getCustomerContract(List<CustomerNoImage> listCust, int pos, int idCust) async {
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
          await formWaitingAdmin(
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
      _listFuture = search.isNotEmpty
          ? getCustomerBySeach(search)
          : getCustomerByIdOld(widget.idOuter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return masterChild(isHorizontal: true);
      }

      return masterChild(isHorizontal: false);
    });
  }

  Widget masterChild({bool isHorizontal = false}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'List Kustomer Baru',
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
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black54,
            size: isHorizontal ? 20.r : 18.r,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NewcustScreen()));
            },
            icon: Icon(
              Icons.person_add_alt_rounded,
              color: Colors.black54,
              size: isHorizontal ? 20.r : 18.r,
            ),
          ),
        ],
      ),
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
                  borderSide: BorderSide(color: Colors.grey, width: 2.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0.r)),
                  borderSide: BorderSide(color: Colors.blue, width: 2.w),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  search = value;

                  _listFuture = search.isNotEmpty
                      ? getCustomerBySeach(search)
                      : getCustomerByIdOld(widget.idOuter);
                });
              },
            ),
          ),
          tmpList.length > 0
              ? Row(
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
                      backgroundColor: page < totalPages
                          ? Colors.green
                          : Colors.green.shade200,
                      mini: true,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: isHorizontal ? 30.r : 20.r,
                      ),
                      elevation: 0,
                      onPressed: page < totalPages ? loadNextPage : null,
                    ),
                  ],
                )
              : SizedBox(
                  width: 5.w,
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
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasError) {
                                  return Column(
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
                                          fontSize:
                                              isHorizontal ? 16.sp : 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[600],
                                          fontFamily: 'Montserrat',
                                        ),
                                      )
                                    ],
                                  );
                                } else {
                                  return listViewWidget(
                                    snapshot.data!,
                                    snapshot.data!.length,
                                    isHorizontal: isHorizontal,
                                  );
                                }
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
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
              horizontal: isHorizontal ? 23.r : 15.r,
              vertical: isHorizontal ? 12.r : 10.r,
            ),
            itemBuilder: (context, position) {
              return Card(
                elevation: 2,
                child: ClipPath(
                  child: InkWell(
                    child: Container(
                      height: isHorizontal ? 120.h : 90.h,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                              color: customer[position].econtract.contains("1")
                                  ? customer[position]
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
                                          : Colors.red.shade600
                                  : Colors.orange.shade800,
                              width: isHorizontal ? 4.w : 5.w),
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
                              flex: 1,
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
                            customer[position].econtract.contains("1")
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 5.r,
                                      horizontal: 8.r,
                                    ),
                                    decoration: BoxDecoration(
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
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Text(
                                      customer[position].status,
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 16.sp : 11.sp,
                                        fontFamily: 'Segoe ui',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Buat Kontrak',
                                    style: TextStyle(
                                      fontSize: isHorizontal ? 20.sp : 14.sp,
                                      fontFamily: 'Segoe Ui',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      customer[position].econtract == "0"
                          ? Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => EcontractScreen(
                                  customer,
                                  position,
                                  isRevisi: false,
                                  isAdmin: true,
                                ),
                              ),
                            )
                          : getCustomerContract(
                              customer,
                              position,
                              int.parse(customer[position].id),
                            );
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
