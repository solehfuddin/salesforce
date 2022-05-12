import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sample/src/app/pages/econtract/econtract_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerScreen extends StatefulWidget {
  final int idOuter;
  @override
  _CustomerScreenState createState() => _CustomerScreenState();

  CustomerScreen(this.idOuter);
}

class _CustomerScreenState extends State<CustomerScreen> {
  String id = '';
  String role = '';
  String username = '';
  String search = '';
  var thisYear, nextYear;
  int _count = 10;
  List<Customer> customerList = List.empty(growable: true);

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");

      var formatter = new DateFormat('yyyy');
      thisYear = formatter.format(DateTime.now());
      nextYear = int.parse(thisYear) + 1;

      print('This Year : $thisYear');
      print('Next Year : $nextYear');

      print("Dashboard : $role");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  Future<List<Customer>> getCustomerByIdOld(int input) async {
    List<Customer> list;
    const timeout = 50;

    try {
      var url = input < 1
        ? 'http://timurrayalab.com/salesforce/server/api/customers'
        : 'http://timurrayalab.com/salesforce/server/api/customers/getBySales?created_by=$input';

      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        list = rest.map<Customer>((json) => Customer.fromJson(json)).toList();
        print("List Size: ${customerList.length}");
      }

      return list;
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

  // getCustomerById(int input) async {
  //   var url = input < 1
  //       ? 'http://timurrayalab.com/salesforce/server/api/customers'
  //       : 'http://timurrayalab.com/salesforce/server/api/customers/getBySales?created_by=$input';
  //   var response = await http.get(url);

  //   print('Response status: ${response.statusCode}');

  //   var data = json.decode(response.body);
  //   final bool sts = data['status'];

  //   if (sts) {
  //     var rest = data['data'];
  //     print(rest);
  //     customerList =
  //         rest.map<Customer>((json) => Customer.fromJson(json)).toList();
  //     print("List Size: ${customerList.length}");
  //   }
  // }

  // Future<List<Customer>> getCustomerByIdLimit(int count) async {
  //   return Future.delayed(Duration(seconds: 3), () => getData(customerList));
  // }

  // List<Customer> getData(List<Customer> item) {
  //   List<Customer> local = List.empty(growable: true);

  //   for (int i = 0; i < item.length; i++) {
  //     if (i < _count) {
  //       local.add(item[i]);
  //     }
  //   }

  //   print('Lokal size : ${local.length}');
  //   return local.toList();
  // }

  Future<List<Customer>> getCustomerBySeach(String input) async {
    List<Customer> list;
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/customers/search?search=$input';

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
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      // _count = 10;
      search.isNotEmpty
          ? getCustomerBySeach(search)
          : getCustomerByIdOld(widget.idOuter);
      // : getCustomerByIdLimit(_count);
    });
  }

  getCustomerContract(List<Customer> listCust, int pos, int idCust) async {
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract?id_customer=$idCust';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'List Customer Baru',
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
          onPressed: () => Navigator.of(context).pop(),
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
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.r,
              vertical: 10.r,
            ),
            color: Colors.white,
            height: 80.h,
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
                });
              },
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 100.h,
              child: FutureBuilder(
                  future: search.isNotEmpty
                      ? getCustomerBySeach(search)
                      // : getCustomerByIdLimit(_count),
                      : getCustomerByIdOld(widget.idOuter),
                  // future: _refreshData(),
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
                    //final data = snapshot.data;
                    // final controller = ScrollController();
                    // controller.addListener(() {
                    //   final position = controller.offset /
                    //       controller.position.maxScrollExtent;
                    //   if (position >= 0.8) {
                    //     if (snapshot.data.length == _count &&
                    //         _count < customerList.length) {
                    //       setState(() {
                    //         _count += 5;
                    //       });
                    //     }
                    //   }
                    // });
                    // if (data == null) {
                    //   return Center(child: CircularProgressIndicator());
                    // } else {
                    //   if (customerList.length < 1) {
                    //     return Column(
                    //       children: [
                    //         Center(
                    //           child: Image.asset(
                    //             'assets/images/not_found.png',
                    //             width: 300.w,
                    //             height: 300.h,
                    //           ),
                    //         ),
                    //         Text(
                    //           'Data tidak ditemukan',
                    //           style: TextStyle(
                    //             fontSize: 18.sp,
                    //             fontWeight: FontWeight.w600,
                    //             color: Colors.red[600],
                    //             fontFamily: 'Montserrat',
                    //           ),
                    //         )
                    //       ],
                    //     );
                    //   } else {
                    //     // return listViewWidget(
                    //     //     snapshot.data, snapshot.data.length, controller);
                    //     return listViewWidget(
                    //         snapshot.data, snapshot.data.length);
                    //   }
                    // }
                  }),
            ),
          ),
        ],
      ),
    );
  }

   Widget listViewWidget(
      List<Customer> customer, int len) {
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
                              color: customer[position].econtract.contains("1")
                                  ? customer[position]
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
                                          : Colors.red[600]
                                  : Colors.orange[800],
                              width: 5.w),
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
                            customer[position].econtract.contains("1")
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 5.r,
                                      horizontal: 10.r,
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
                                        fontSize: 12.sp,
                                        fontFamily: 'Segoe ui',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Buat Kontrak',
                                    style: TextStyle(
                                      fontSize: 16.sp,
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
                                  builder: (context) =>
                                      EcontractScreen(customer, position)))
                          : getCustomerContract(customer, position,
                              int.parse(customer[position].id));
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

  // Widget listViewWidget(
  //     List<Customer> customer, int len, ScrollController controller) {
  //   return RefreshIndicator(
  //     child: Container(
  //       child: ListView.builder(
  //           controller: controller,
  //           itemCount: len,
  //           padding: EdgeInsets.symmetric(
  //             horizontal: 5.r,
  //             vertical: 8.r,
  //           ),
  //           itemBuilder: (context, position) {
  //             return Card(
  //               elevation: 2,
  //               child: ClipPath(
  //                 child: InkWell(
  //                   child: Container(
  //                     height: 100.h,
  //                     decoration: BoxDecoration(
  //                       border: Border(
  //                         left: BorderSide(
  //                             color: customer[position].econtract.contains("1")
  //                                 ? customer[position]
  //                                             .status
  //                                             .contains('Pending') ||
  //                                         customer[position]
  //                                             .status
  //                                             .contains('PENDING')
  //                                     ? Colors.grey[600]
  //                                     : customer[position]
  //                                                 .status
  //                                                 .contains('Accepted') ||
  //                                             customer[position]
  //                                                 .status
  //                                                 .contains('ACCEPTED')
  //                                         ? Colors.blue[600]
  //                                         : Colors.red[600]
  //                                 : Colors.orange[800],
  //                             width: 5.w),
  //                       ),
  //                     ),
  //                     child: Container(
  //                       padding: EdgeInsets.symmetric(
  //                         horizontal: 15.r,
  //                         vertical: 8.r,
  //                       ),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Text(
  //                                 customer[position].namaUsaha,
  //                                 style: TextStyle(
  //                                   fontSize: 16.sp,
  //                                   fontFamily: 'Segoe ui',
  //                                   fontWeight: FontWeight.w600,
  //                                 ),
  //                               ),
  //                               SizedBox(
  //                                 height: 15.h,
  //                               ),
  //                               Row(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Text(
  //                                     'Tgl entry : ',
  //                                     style: TextStyle(
  //                                         fontSize: 11.sp,
  //                                         fontFamily: 'Montserrat',
  //                                         fontWeight: FontWeight.w500),
  //                                   ),
  //                                   SizedBox(
  //                                     width: 40.w,
  //                                   ),
  //                                   Text(
  //                                     'Pemilik : ',
  //                                     style: TextStyle(
  //                                         fontSize: 11.sp,
  //                                         fontFamily: 'Montserrat',
  //                                         fontWeight: FontWeight.w500),
  //                                   ),
  //                                 ],
  //                               ),
  //                               SizedBox(
  //                                 height: 5.h,
  //                               ),
  //                               Row(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Text(
  //                                     convertDateIndo(
  //                                         customer[position].dateAdded),
  //                                     style: TextStyle(
  //                                         fontSize: 13.sp,
  //                                         fontFamily: 'Montserrat',
  //                                         fontWeight: FontWeight.w600),
  //                                   ),
  //                                   SizedBox(
  //                                     width: 25.w,
  //                                   ),
  //                                   Text(
  //                                     customer[position].nama,
  //                                     style: TextStyle(
  //                                         fontSize: 13.sp,
  //                                         fontFamily: 'Montserrat',
  //                                         fontWeight: FontWeight.w600),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ],
  //                           ),
  //                           customer[position].econtract.contains("1")
  //                               ? Container(
  //                                   padding: EdgeInsets.symmetric(
  //                                     vertical: 5.r,
  //                                     horizontal: 10.r,
  //                                   ),
  //                                   decoration: BoxDecoration(
  //                                     color: customer[position]
  //                                                 .status
  //                                                 .contains('Pending') ||
  //                                             customer[position]
  //                                                 .status
  //                                                 .contains('PENDING')
  //                                         ? Colors.grey[600]
  //                                         : customer[position]
  //                                                     .status
  //                                                     .contains('Accepted') ||
  //                                                 customer[position]
  //                                                     .status
  //                                                     .contains('ACCEPTED')
  //                                             ? Colors.blue[600]
  //                                             : Colors.red[600],
  //                                     borderRadius: BorderRadius.circular(10.r),
  //                                   ),
  //                                   child: Text(
  //                                     customer[position].status,
  //                                     style: TextStyle(
  //                                       fontSize: 12.sp,
  //                                       fontFamily: 'Segoe ui',
  //                                       fontWeight: FontWeight.w600,
  //                                       color: Colors.white,
  //                                     ),
  //                                   ),
  //                                 )
  //                               : Text(
  //                                   'Buat Kontrak',
  //                                   style: TextStyle(
  //                                     fontSize: 16.sp,
  //                                     fontFamily: 'Segoe Ui',
  //                                     fontWeight: FontWeight.w600,
  //                                     color: Colors.orange[800],
  //                                   ),
  //                                 ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   onTap: () {
  //                     customer[position].econtract == "0"
  //                         ? Navigator.of(context).pushReplacement(
  //                             MaterialPageRoute(
  //                                 builder: (context) =>
  //                                     EcontractScreen(customer, position)))
  //                         : getCustomerContract(customer, position,
  //                             int.parse(customer[position].id));
  //                   },
  //                 ),
  //                 clipper: ShapeBorderClipper(
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(3.r),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           }),
  //     ),
  //     onRefresh: _refreshData,
  //   );
  // }
}
