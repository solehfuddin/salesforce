import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/renewcontract/history_contract.dart';
import 'package:sample/src/app/pages/signed/signed_view.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/oldcustomer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

Contract itemContract;
String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

waitingLoad() async {
  await Future.delayed(Duration(seconds: 2));
}

login(String user, String pass, BuildContext context) async {
  var url = 'http://timurrayalab.com/salesforce/server/api/auth/login';
  var response =
      await http.post(url, body: {'username': user, 'password': pass});
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

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

      if (role == 'admin') {
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

handleComing(BuildContext context) {
  AlertDialog alert = AlertDialog(
    title: Center(
      child: Text(
        "Coming Soon",
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'Segoe ui',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    content: Container(
      child: Image.asset(
        'assets/images/coming_soon.png',
        width: 80,
        height: 80,
      ),
    ),
    actions: [
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Segoe ui',
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

handleSigned(BuildContext context) {
  AlertDialog alert = AlertDialog(
    title: Center(
      child: Text(
        "Digital Signed",
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'Segoe ui',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    content: Container(
      padding: EdgeInsets.only(
        top: 20,
      ),
      height: 150,
      child: Column(
        children: [
          Center(
            child: Image.asset(
              'assets/images/digital_sign.png',
              width: 60,
              height: 60,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              "Setup digital signed easily to save your",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Center(
            child: Text(
              "time when approve new customer",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
              primary: Colors.orange[800],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Next time',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Segoe ui',
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
              primary: Colors.indigo[600],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Setup now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Segoe ui',
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SignedScreen()));
            },
          ),
        ],
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

handleStatus(BuildContext context, String msg, bool status) {
  AlertDialog alert = AlertDialog(
    content: Container(
      padding: EdgeInsets.only(
        top: 20,
      ),
      height: 120,
      child: Column(
        children: [
          Center(
            child: Image.asset(
              status
                  ? 'assets/images/success.png'
                  : 'assets/images/failure.png',
              width: 60,
              height: 60,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              msg,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
    actions: [
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Segoe ui',
            ),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(context);
            if (status) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

handleCustomStatus(BuildContext context, String msg, bool status) {
  AlertDialog alert = AlertDialog(
    content: Container(
      padding: EdgeInsets.only(
        top: 20,
      ),
      height: 120,
      child: Column(
        children: [
          Center(
            child: Image.asset(
              status
                  ? 'assets/images/success.png'
                  : 'assets/images/failure.png',
              width: 60,
              height: 60,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              msg,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
    actions: [
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
              fontSize: 14,
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
  );

  showDialog(context: context, builder: (context) => alert);
}

handleStatusChangeContract(OldCustomer item, BuildContext context, String msg, bool status, {dynamic keyword}) {
  AlertDialog alert = AlertDialog(
    content: Container(
      padding: EdgeInsets.only(
        top: 20,
      ),
      height: 120,
      child: Column(
        children: [
          Center(
            child: Image.asset(
              status
                  ? 'assets/images/success.png'
                  : 'assets/images/failure.png',
              width: 60,
              height: 60,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              msg,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
    actions: [
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Segoe ui',
            ),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(context);
            if (status) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HistoryContract(item, keyword: keyword,)));
            }
          },
        ),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

Future<String> getTtdValid(String idUser, BuildContext context) async {
  var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$idUser';
  var response = await http.get(url);
  var data = json.decode(response.body);
  print(data);
  String ttd = data['data'][0]['ttd'];

  return ttd;
}

handleDigitalSigned(
    SignatureController signController, BuildContext context, String id) async {
  if (signController.isNotEmpty) {
    var data = await signController.toPngBytes();
    String signedImg = base64Encode(data);
    print(signedImg);
    print(id);

    var url = 'http://timurrayalab.com/salesforce/server/api/users/update';
    var response = await http.post(
      url,
      body: {
        'id': id,
        'ttd': signedImg,
      },
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    var res = json.decode(response.body);
    final bool sts = res['status'];
    final String msg = res['message'];

    handleStatus(context, capitalize(msg), sts);
  } else {
    Fluttertoast.showToast(
        msg: 'Please signed the form',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16);
  }
}

formWaiting(BuildContext context, List<Customer> customer, int position) {
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
                  customer[position].namaUsaha,
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
                    color: customer[position].status.contains('Pending') ||
                            customer[position].status.contains('PENDING')
                        ? Colors.grey[600]
                        : customer[position].status.contains('Accepted') ||
                                customer[position].status.contains('ACCEPTED')
                            ? Colors.blue[600]
                            : Colors.red[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    customer[position].status,
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
              customer[position].status.contains('Pending') ||
                      customer[position].status.contains('PENDING')
                  ? 'Pengajuan e-kontrak sedang diproses'
                  : customer[position].status.contains('Accepted') ||
                          customer[position].status.contains('ACCEPTED')
                      ? 'Pengajuan e-kontrak diterima'
                      : 'Pengajuan e-kontrak ditolak',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w600,
                color: customer[position].status.contains('Pending') ||
                        customer[position].status.contains('PENDING')
                    ? Colors.grey[600]
                    : customer[position].status.contains('Accepted') ||
                            customer[position].status.contains('ACCEPTED')
                        ? Colors.green[600]
                        : Colors.red[700],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Diajukan tgl : ${convertDateIndo(customer[position].dateAdded)}',
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
                      customer[position].ttdSalesManager == "0"
                          ? 'Menunggu Persetujuan Sales Manager'
                          : customer[position].ttdSalesManager == "1"
                              ? 'Disetujui oleh Sales Manager ${convertDateIndo(customer[position].dateSM)}'
                              : 'Ditolak oleh Sales Manager ${convertDateIndo(customer[position].dateSM)}',
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
                      customer[position].ttdArManager == "0"
                          ? 'Menunggu Persetujuan AR Manager'
                          : customer[position].ttdArManager == "1"
                              ? 'Disetujui oleh AR Manager ${convertDateIndo(customer[position].dateAM)}'
                              : 'Ditolak oleh AR Manager ${convertDateIndo(customer[position].dateAM)}',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ArgonButton(
                  height: 40,
                  width: 120,
                  borderRadius: 30.0,
                  color: Colors.blue[700],
                  child: Text(
                    "Unduh Data",
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
                      donwloadCustomer(
                          int.parse(customer[position].id), stopLoading());
                    }
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    primary: Colors.red[800],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      item[position].approvalSm == "0" || item[position].approvalSm == null 
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
                      item[position].approvalAm == "0" || item[position].approvalSm == null
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
      ? 'http://timurrayalab.com/salesforce/server/api/approval/approveContractSM'
      : 'http://timurrayalab.com/salesforce/server/api/approval/approveContractAM';

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

approveCustomerReject(BuildContext context, bool isAr, String idCust,
    String ttd, String username) async {
  var url = !isAr
      ? 'http://timurrayalab.com/salesforce/server/api/approval/approveSM'
      : 'http://timurrayalab.com/salesforce/server/api/approval/approveAM';

  var response = await http.post(
    url,
    body: !isAr
        ? {
            'id_customer': idCust,
            'ttd_sales_manager': ttd,
            'nama_sales_manager': username,
          }
        : {
            'id_customer': idCust,
            'ttd_ar_manager': ttd,
            'nama_ar_manager': username,
          },
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  var res = json.decode(response.body);
  final bool sts = res['status'];
  final String msg = res['message'];

  approveCustomerContract(isAr, idCust, username);

  handleStatus(context, capitalize(msg), sts);
}

formRejected(BuildContext context, List<Customer> customer, int position,
    {String div, ttd, idCust, username}) {
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
                  customer[position].namaUsaha,
                  style: TextStyle(
                    fontSize: 20,
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
                    color: customer[position].status == "Pending"
                        ? Colors.grey[600]
                        : customer[position].status == "Accepted"
                            ? Colors.blue[600]
                            : Colors.red[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    customer[position].status,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              customer[position].status == "Pending"
                  ? 'Pengajuan e-kontrak sedang diproses'
                  : customer[position].status == "Accepted"
                      ? 'Pengajuan e-kontrak diterima'
                      : 'Pengajuan e-kontrak ditolak',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w600,
                color: customer[position].status == "Pending"
                    ? Colors.grey[600]
                    : customer[position].status == "Accepted"
                        ? Colors.green[600]
                        : Colors.red[700],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Diajukan tgl : ${convertDateIndo(customer[position].dateAdded)}',
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
                      customer[position].ttdSalesManager == "0"
                          ? 'Menunggu Persetujuan Sales Manager'
                          : customer[position].ttdSalesManager == "1"
                              ? 'Disetujui oleh Sales Manager ${convertDateIndo(customer[position].dateSM)}'
                              : 'Ditolak oleh Sales Manager ${convertDateIndo(customer[position].dateSM)}',
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
                      customer[position].ttdArManager == "0"
                          ? 'Menunggu Persetujuan AR Manager'
                          : customer[position].ttdArManager == "1"
                              ? 'Disetujui oleh AR Manager ${convertDateIndo(customer[position].dateAM)}'
                              : 'Ditolak oleh AR Manager ${convertDateIndo(customer[position].dateAM)}',
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
            Center(
              child: Text(
                'Apakah anda ingin menyetujui kontrak optik ini?',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ArgonButton(
                  height: 40,
                  width: 100,
                  borderRadius: 30.0,
                  color: Colors.blue[700],
                  child: Text(
                    "Approve",
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
                      div == "AR"
                          ? approveCustomerReject(
                              context, true, idCust, ttd, username)
                          : approveCustomerReject(
                              context, false, idCust, ttd, username);
                      // stopLoading();
                    }
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    primary: Colors.red[800],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

convertDateIndo(String tgl) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateTime date = dateFormat.parse(tgl);

  return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString()}";
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

String convertToIdr(dynamic number, int decimalDigit) {
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: decimalDigit,
  );
  return currencyFormatter.format(number);
}

int counterTwoDays(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
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

void checkUpdate(BuildContext context) {
  if (Platform.isAndroid) {
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
}

getCustomerContractNew(
    {BuildContext context,
    dynamic idCust,
    String divisi,
    String ttdPertama,
    String username,
    bool isSales,
    bool isContract}) async {
  var url =
      'http://timurrayalab.com/salesforce/server/api/contract?id_customer=$idCust';
  var response = await http.get(url);

  print('Response status: ${response.statusCode}');

  var data = json.decode(response.body);
  final bool sts = data['status'];

  if (sts) {
    var rest = data['data'];
    print(rest);
    itemContract = Contract.fromJson(rest[0]);

    openDialogNew(context, divisi, ttdPertama, username, isSales, isContract);
  } else {
    handleStatus(context, 'Harap ajukan kontrak baru', false);
  }
}

openDialogNew(BuildContext context, String div, String ttdPertama,
    String username, bool isSales, bool isContract) async {
  await formContractNew(
      context, itemContract, div, ttdPertama, username, isSales, isContract);
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
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
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
