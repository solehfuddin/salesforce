import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/signed/signed_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';

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
            Navigator.of(context).pop();
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

convertDateIndo(String tgl) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateTime date = dateFormat.parse(tgl);

  return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString()}";
}

String convertToIdr(dynamic number, int decimalDigit) {
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: decimalDigit,
  );
  return currencyFormatter.format(number);
}