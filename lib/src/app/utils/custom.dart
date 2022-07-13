import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/renewcontract/history_contract.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/widgets/detail_rejected.dart';
import 'package:sample/src/app/widgets/detail_waiting.dart';
import 'package:sample/src/app/widgets/dialogsigned.dart';
import 'package:sample/src/app/widgets/dialogstatus.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/oldcustomer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

Contract itemContract;
String capitalize(String s) =>
    s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

waitingLoad() async {
  await Future.delayed(Duration(seconds: 2));
}

login(String user, String pass, BuildContext context,
    {bool isHorizontal}) async {
  int timeout = 15;
  var url = '$API_URL/auth/login';

  if (url.contains("dev"))
  {
    print('DEV MODE');
  }
  else
  {
    print('PROD MODE');
  }

  try {
    var response = await http.post(url, body: {
      'username': user,
      'password': pass
    }).timeout(Duration(seconds: timeout));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    try {
      var data = json.decode(response.body);
      final bool sts = data['status'];
      final String msg = data['message'];
      final int code = response.statusCode;

      if (code == 200) {
        if (sts) {
          final String id = data['data']['id'];
          final String name = data['data']['name'];
          final String username = data['data']['username'];
          final String accstatus = data['data']['status'];
          final String role = data['data']['role'];
          final String divisi = data['data']['divisi'];

          savePref(id, name, username, accstatus, role, divisi);

          if (role == "ADMIN") {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AdminScreen()));
          } else {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        } else {
          Fluttertoast.showToast(
              msg: msg,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16);
        }
      } else {
        Fluttertoast.showToast(
            msg: msg,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16);
      }
    } on FormatException catch (e) {
      print('Format Error : $e');
      handleStatus(
        context,
        e.toString(),
        false,
        isHorizontal: isHorizontal,
      );
    }
  } on TimeoutException catch (e) {
    print('Timeout Error : $e');
    handleTimeout(context);
  } on SocketException catch (e) {
    print('Socket Error : $e');
    handleSocket(context);
  } on Error catch (e) {
    print('General Error : $e');
    handleStatus(
      context,
      e.toString(),
      false,
      isHorizontal: isHorizontal,
    );
  }
}

savePref(String id, String name, String username, String status, String role,
    String divisi) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  // setState(() {
  pref.setString("id", id);
  pref.setString("name", name);
  pref.setString("username", username);
  pref.setString("status", status);
  pref.setString("role", role);
  pref.setString("divisi", divisi);
  pref.setBool("islogin", true);
  // });
}

handleComing(BuildContext context, {bool isHorizontal = false}) {
  AlertDialog alert = AlertDialog(
    title: Center(
      child: Text(
        "Coming Soon",
        style: TextStyle(
          fontSize: isHorizontal ? 30.sp : 20.sp,
          fontFamily: 'Segoe ui',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    content: Container(
      child: Image.asset(
        'assets/images/coming_soon.png',
        width: isHorizontal ? 110.sp : 80.r,
        height: isHorizontal ? 110.sp : 80.r,
      ),
    ),
    actions: [
      Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            primary: Colors.indigo[600],
            padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 30.r : 20.r,
                vertical: isHorizontal ? 20.r : 10.r),
          ),
          child: Text(
            'Ok',
            style: TextStyle(
              color: Colors.white,
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Segoe ui',
            ),
          ),
          onPressed: () {
            // Navigator.of(context).pop();
            Navigator.of(context, rootNavigator: true).pop(context);
          },
        ),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

handleSigned(BuildContext context) {
  showDialog(context: context, builder: (context) => DialogSigned());
}

handleStatus(BuildContext context, String msg, bool status,
    {bool isHorizontal = false}) {
  // AlertDialog dialog = new AlertDialog(
  //   content: Container(
  //     padding: EdgeInsets.only(
  //       top: 20.r,
  //     ),
  //     height: isHorizontal ? 325.h : 205.h,
  //     child: Column(
  //       children: [
  //         Center(
  //           child: Image.asset(
  //             status
  //                 ? 'assets/images/success.png'
  //                 : 'assets/images/failure.png',
  //             width: isHorizontal ? 110.r : 70.r,
  //             height: isHorizontal ? 110.r : 70.r,
  //           ),
  //         ),
  //         SizedBox(
  //           height: isHorizontal ? 20.h : 20.h,
  //         ),
  //         Center(
  //           child: Text(
  //             msg,
  //             style: TextStyle(
  //               fontSize: isHorizontal ? 22.sp : 14.sp,
  //               fontFamily: 'Montserrat',
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         SizedBox(
  //           height: isHorizontal ? 20.h : 20.h,
  //         ),
  //         Center(
  //           child: ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               shape: StadiumBorder(),
  //               primary: Colors.indigo[600],
  //               padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 10.r),
  //             ),
  //             child: Text(
  //               'Ok',
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: isHorizontal ? 22.sp : 14.sp,
  //                 fontWeight: FontWeight.bold,
  //                 fontFamily: 'Segoe ui',
  //               ),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context, rootNavigator: true).pop(context);
  //               if (status) {
  //                 Navigator.pop(context);
  //               }
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   ),
  // );

  // showDialog(context: context, builder: (context) => dialog);

  showDialog(
    context: context,
    builder: (context) => DialogStatus(
      msg: msg,
      status: status,
    ),
  );
}

DateTimeRange _selectedDateRange;
Future<DateTimeRange> showDate(BuildContext context) async {
  final DateTimeRange result = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2022, 1, 1),
    lastDate: DateTime(2030, 12, 31),
    currentDate: DateTime.now(),
    saveText: 'Done',
  );

  if (result != null) {
    print("Start Date : ${result.start.toString()}");
    print("End Date : ${result.end.toString()}");

    print("Convert St Date : ${convertDateOra(result.start.toString())}");
    // setState(() {
    _selectedDateRange = result;
    // });

    return _selectedDateRange;
  }
}

void showDateRange(BuildContext context) async {
  final DateTimeRange result = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2022, 1, 1),
    lastDate: DateTime(2030, 12, 31),
    currentDate: DateTime.now(),
    saveText: 'Done',
    // builder: (BuildContext context, Widget child) {
    //   return Theme(
    //     data: ThemeData.light().copyWith(
    //       colorScheme: ColorScheme.dark(
    //         // primary: Color(0xff64c856),
    //         // onPrimary: Colors.black,
    //         // surface: Color(0xff64c856),
    //         // onSurface: Colors.green,
    //       ),
    //       dialogBackgroundColor: Colors.green,
    //     ),
    //     child: child,
    //   );
    // }
  );

  if (result != null) {
    // Rebuild the UI
    print(result.start.toString());
    // setState(() {
    _selectedDateRange = result;
    // });
  }
}

handleCustomStatus(BuildContext context, String msg, bool status,
    {bool isHorizontal}) {
  AlertDialog alert = AlertDialog(
    content: Container(
      padding: EdgeInsets.only(
        top: 20.r,
      ),
      height: isHorizontal ? 325.h : 205.h,
      child: Column(
        children: [
          Center(
            child: Image.asset(
              status
                  ? 'assets/images/success.png'
                  : 'assets/images/failure.png',
              width: isHorizontal ? 110.r : 70.r,
              height: isHorizontal ? 110.r : 70.r,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Container(
            child: Center(
              child: Text(
                msg,
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                primary: Colors.indigo[600],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Ok',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 22.sp : 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Segoe ui',
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
                if (status) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => AdminScreen()));
                }
              },
            ),
          ),
        ],
      ),
    ),
    // actions: [

    // ],
  );

  showDialog(context: context, builder: (context) => alert);
}

handleStatusChangeContract(
    OldCustomer item, BuildContext context, String msg, bool status,
    {dynamic keyword, bool isHorizontal}) {
  AlertDialog alert = AlertDialog(
    content: Container(
      padding: EdgeInsets.only(
        top: 20.r,
      ),
      height: isHorizontal ? 325.h : 205.h,
      child: Column(
        children: [
          Center(
            child: Image.asset(
              status
                  ? 'assets/images/success.png'
                  : 'assets/images/failure.png',
              width: isHorizontal ? 110.r : 70.r,
              height: isHorizontal ? 110.r : 70.r,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Center(
            child: Text(
              msg,
              style: TextStyle(
                fontSize: isHorizontal ? 22.sp : 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                primary: Colors.indigo[600],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Ok',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 22.sp : 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Segoe ui',
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
                if (status) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HistoryContract(
                            item,
                            keyword: keyword,
                            isAdmin: false,
                          )));
                }
              },
            ),
          ),
        ],
      ),
    ),
    // actions: [

    // ],
  );

  showDialog(context: context, builder: (context) => alert);
}

handleConnection(BuildContext context) {
  AlertDialog alert = AlertDialog(
    title: Text("Informasi"),
    content: Container(
      child: Text("Sambungan terputus, ulangi proses!"),
    ),
    actions: [
      TextButton(
        child: Text('Ok'),
        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

handleConnectionAdmin(BuildContext context) {
  AlertDialog alert = AlertDialog(
    title: Text("Informasi"),
    content: Container(
      child: Text("Sambungan terputus, ulangi proses!"),
    ),
    actions: [
      TextButton(
        child: Text('Ok'),
        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AdminScreen()),
            (route) => false),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

Future<String> getTtdValid(String idUser, BuildContext context,
    {String role}) async {
  const timeout = 15;
  var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$idUser';

  try {
    var response = await http.get(url).timeout(Duration(seconds: timeout));

    try {
      var data = json.decode(response.body);
      print(data);
      String ttd = data['data'][0]['ttd'];

      return ttd;
    } on FormatException catch (e) {
      print('Format Error : $e');
    }
  } on TimeoutException catch (e) {
    print('Timeout Error : $e');
    handleTimeout(context);
  } on SocketException catch (e) {
    print('Socket Error : $e');
    // handleSocket(context);
    role.contains('admin')
        ? handleConnectionAdmin(context)
        : handleConnection(context);
  } on Error catch (e) {
    print('General Error : $e');
  }
}

handleDigitalSigned(
    SignatureController signController, BuildContext context, String id,
    {bool isHorizontal}) async {
  const timeout = 15;
  if (signController.isNotEmpty) {
    var data = await signController.toPngBytes();
    String signedImg = base64Encode(data);
    print(signedImg);
    print(id);

    var url = '$API_URL/users/update';

    try {
      var response = await http.post(
        url,
        body: {
          'id': id,
          'ttd': signedImg,
        },
      ).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        handleStatus(
          context,
          capitalize(msg),
          sts,
          isHorizontal: isHorizontal,
        );
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
        );
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(
        context,
        e.toString(),
        false,
        isHorizontal: isHorizontal,
      );
    }
  } else {
    Fluttertoast.showToast(
        // msg: 'Please signed the form',
        msg: 'Mohon tanda tangani form',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.sp);
  }
}

formWaiting(
  BuildContext context,
  List<Customer> customer,
  int position, {
  String reasonSM,
  String reasonAM,
  Contract contract,
}) {
  return showModalBottomSheet(
    elevation: 2,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.r),
        topRight: Radius.circular(15.r),
      ),
    ),
    context: context,
    builder: (context) {
      return DetailWaiting(
        customer: customer,
        position: position,
        reasonSM: reasonSM,
        reasonAM: reasonAM,
        contract: contract,
      );
    },
  );
}

formWaitingContract(BuildContext context, List<Contract> item, int position) {
  return showModalBottomSheet(
    elevation: 2,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
    ),
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item[position].customerShipName,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: item[position].status.contains('Pending') ||
                            item[position].status.contains('PENDING')
                        ? Colors.grey[600]
                        : item[position].status.contains('ACTIVE') ||
                                item[position].status.contains('active')
                            ? Colors.blue[600]
                            : Colors.red[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item[position].status,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              item[position].status.contains('Pending') ||
                      item[position].status.contains('PENDING')
                  ? 'Pengajuan e-kontrak sedang diproses'
                  : item[position].status.contains('ACTIVE') ||
                          item[position].status.contains('active')
                      ? 'Pengajuan e-kontrak diterima'
                      : 'Pengajuan e-kontrak ditolak',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w600,
                color: item[position].status.contains('Pending') ||
                        item[position].status.contains('PENDING')
                    ? Colors.grey[600]
                    : item[position].status.contains('Accepted') ||
                            item[position].status.contains('ACCEPTED')
                        ? Colors.green[600]
                        : Colors.red[700],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Diajukan tgl : ${convertDateIndo(item[position].dateAdded)}',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Divider(
              color: Colors.black54,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Detail Status',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 50,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        'SM',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Sales Manager',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      item[position].approvalSm == "0" ||
                              item[position].approvalSm == null
                          ? 'Menunggu Persetujuan Sales Manager'
                          : item[position].approvalSm == "1"
                              ? 'Disetujui oleh Sales Manager ${convertDateIndo(item[position].dateApprovalSm)}'
                              : 'Ditolak oleh Sales Manager ${convertDateIndo(item[position].dateApprovalSm)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 50,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'AM',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AR Manager',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      item[position].approvalAm == "0" ||
                              item[position].approvalSm == null
                          ? 'Menunggu Persetujuan AR Manager'
                          : item[position].approvalAm == "1"
                              ? 'Disetujui oleh AR Manager ${convertDateIndo(item[position].dateApprovalAm)}'
                              : 'Ditolak oleh AR Manager ${convertDateIndo(item[position].dateApprovalAm)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            item[position].status.contains("PENDING") ||
                    item[position].status.contains("pending")
                ? Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        primary: Colors.red[800],
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Tutup',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ArgonButton(
                        height: 40,
                        width: 120,
                        borderRadius: 30.0,
                        color: Colors.blue[700],
                        child: Text(
                          "Unduh Kontrak",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        loader: Container(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        onTap: (startLoading, stopLoading, btnState) {
                          if (btnState == ButtonState.Idle) {
                            startLoading();
                            waitingLoad();
                            donwloadContract(
                                item[position].idCustomer, stopLoading());
                          }
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          primary: Colors.red[800],
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          'Tutup',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Segoe ui',
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    },
  );
}

donwloadCustomer(int idCust, Function stopLoading()) async {
  var url =
      'https://timurrayalab.com/salesforce/download/customers_pdf/$idCust';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

donwloadContract(dynamic idCust, Function stopLoading()) async {
  var url = 'https://timurrayalab.com/salesforce/download/contract_pdf/$idCust';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

approveCustomerContract(bool isAr, String idCust, String username) async {
  var url = !isAr
      ? '$API_URL/approval/approveContractSM'
      : '$API_URL/approval/approveContractAM';

  var response = await http.post(
    url,
    body: !isAr
        ? {
            'id_customer': idCust,
            'approver_sm': username,
          }
        : {
            'id_customer': idCust,
            'approver_am': username,
          },
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
}

formRejected(
  BuildContext context,
  List<Customer> customer,
  int position, {
  String div,
  ttd,
  idCust,
  username,
  String reasonSM,
  String reasonAM,
  Contract contract,
}) {
  return showModalBottomSheet(
    elevation: 2,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.r),
        topRight: Radius.circular(15.r),
      ),
    ),
    context: context,
    builder: (context) {
      return DetailRejected(
        customer: customer,
        position: position,
        div: div,
        ttd: ttd,
        idCust: idCust,
        username: username,
        reasonSM: reasonSM,
        reasonAM: reasonAM,
        contract: contract,
      );
    },
  );
}

convertDateOra(String tgl) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd hh:mm:ss");
  DateTime date = dateFormat.parse(tgl);

  return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}";
}

convertDateIndo(String tgl) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateTime date = dateFormat.parse(tgl);

  return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString()}";
}

convertDateSql(String tgl) {
  var split = tgl.split(" ");
  var month = convertMonth(split[1]);

  return "${split[2]}-$month-${split[0]}";
}

convertMonth(String input) {
  switch (input) {
    case 'Jan':
      return '01';
      break;
    case 'Feb':
      return '02';
      break;
    case 'Mar':
      return '03';
      break;
    case 'Apr':
      return '04';
      break;
    case 'May':
      return '05';
      break;
    case 'Jun':
      return '06';
      break;
    case 'Jul':
      return '07';
      break;
    case 'Aug':
      return '08';
      break;
    case 'Sep':
      return '09';
      break;
    case 'Oct':
      return '10';
      break;
    case 'Nov':
      return '11';
      break;
    default:
      return '12';
      break;
  }
}

convertDateWithMonth(String tgl) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateTime date = dateFormat.parse(tgl);

  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Des'
  ];

  return "${date.day.toString().padLeft(2, '0')} ${months.elementAt(date.month - 1)} ${date.year.toString()}";
}

convertDateWithMonthHour(String tgl) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  DateTime date = dateFormat.parse(tgl);

  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Des'
  ];

  return "${date.day.toString().padLeft(2, '0')} ${months.elementAt(date.month - 1)} ${date.year.toString()} Pukul ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
}

String convertToIdr(dynamic number, int decimalDigit) {
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: decimalDigit,
  );
  return currencyFormatter.format(number);
}

String convertThousand(dynamic number, int decimalDigit) {
  NumberFormat currencyFormatter = NumberFormat.currency(
    decimalDigits: decimalDigit,
    locale: 'id',
    symbol: '',
  );
  return currencyFormatter.format(number);
}

int counterTwoDays(DateTime from, DateTime to) {
  Duration diff = to.difference(from);
  return diff.inDays;
}

String getEndDays({String input}) {
  DateTime now = DateTime.now();
  DateTime compare = DateTime.parse(input);

  return '${counterTwoDays(now, compare)} Hari';
}

void showError(BuildContext context, dynamic exception) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(exception),
    duration: Duration(seconds: 2),
  ));
}

Future<void> checkUpdate(BuildContext context) async {
  AppUpdateInfo _updateInfo;

  InAppUpdate.checkForUpdate().then((info) {
    _updateInfo = info;
    if (_updateInfo.updateAvailable) {
      print('Info : $_updateInfo');
      print('Update please');

      InAppUpdate.performImmediateUpdate().catchError((e) =>
          Fluttertoast.showToast(
              msg: e.toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16));

      // InAppUpdate.startFlexibleUpdate()
      //     .then((value) => print('Update please'))
      //     .catchError((e) => Fluttertoast.showToast(
      //         msg: e.toString(),
      //         toastLength: Toast.LENGTH_SHORT,
      //         gravity: ToastGravity.BOTTOM,
      //         timeInSecForIosWeb: 1,
      //         backgroundColor: Colors.red,
      //         textColor: Colors.white,
      //         fontSize: 16));
      SystemNavigator.pop();
    }
  }).catchError((e) {
    Fluttertoast.showToast(
        msg: 'Pastikan aplikasimu sudah versi terbaru',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16);

    print(e.toString());
  });
}

getCustomerContractNew({
  BuildContext context,
  dynamic idCust,
  String divisi,
  String ttdPertama,
  String username,
  bool isSales,
  bool isContract,
  bool isHorizontal,
}) async {
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

        openDialogNew(
          context,
          divisi,
          ttdPertama,
          username,
          isSales,
          isContract,
        );
      } else {
        handleStatus(
          context,
          'Harap ajukan kontrak baru',
          false,
          isHorizontal: isHorizontal,
        );
      }
    } on FormatException catch (e) {
      print('Format Error : $e');
      handleStatus(
        context,
        e.toString(),
        false,
        isHorizontal: isHorizontal,
      );
    }
  } on TimeoutException catch (e) {
    print('Timeout Error : $e');
    handleTimeout(context);
  } on SocketException catch (e) {
    print('Socket Error : $e');
    handleSocket(context);
  } on Error catch (e) {
    print('General Error : $e');
    handleStatus(
      context,
      e.toString(),
      false,
      isHorizontal: isHorizontal,
    );
  }
}

openDialogNew(BuildContext context, String div, String ttdPertama,
    String username, bool isSales, bool isContract) async {
  await formContractNew(
    context,
    itemContract,
    div,
    ttdPertama,
    username,
    isSales,
    isContract,
  );
}

formContractNew(BuildContext context, Contract item, String div,
    String ttdPertama, String username, bool isSales, bool isContract) {
  return showModalBottomSheet(
      elevation: 2,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.r),
          topRight: Radius.circular(15.r),
        ),
      ),
      builder: (context) {
        return DetailContract(
          item,
          div,
          ttdPertama,
          username,
          isSales,
          isContract: isContract,
          isAdminRenewal: false,
        );
      });
}

signOut() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setBool("islogin", false);
  await preferences.setString("role", null);
  await Future.delayed(const Duration(seconds: 2), () {});
  SystemNavigator.pop();
}

handleLogout(BuildContext context) {
  AlertDialog alert = AlertDialog(
    title: Text("Informasi"),
    content: Container(
      child: Text("Apakah anda yakin menutup aplikasi ini?"),
    ),
    actions: [
      TextButton(
        child: Text('Iya'),
        onPressed: () => signOut(),
      ),
      TextButton(
        child: Text('Tidak'),
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

void handleTimeout(BuildContext context) {
  handleStatus(context, 'Internet tidak stabil atau lambat', false);
}

void handleSocket(BuildContext context) {
  handleStatus(context, 'Aktifkan paket data atau wifi', false);
}
