import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/signed/signed_view.dart';
import 'package:sample/src/domain/entities/customer.dart';
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

viewDetailContract(BuildContext context, List<Customer> customer, int position,
    String username, String role) {
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
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalState) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: 35,
                  bottom: 15,
                ),
                child: Center(
                  child: Text(
                    'Perjanjian Kerjasama Pembelian',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Pihak Pertama',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Nama : ',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    username,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Jabatan : ',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    role,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Telp : ',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 29,
                  ),
                  Text(
                    '021-4610154',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Fax : ',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 34,
                  ),
                  Text(
                    '021-4610151-52',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Alamat : ',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    child: Text(
                      'Jl. Rawa Kepiting No. 4 Kawasan Industri Pulogadung, Jakarta Timur',
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Pihak Kedua',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Nama : ',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    customer[position].nama,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Jabatan : ',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    'Owner',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Telp : ',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 29,
                  ),
                  Text(
                    customer[position].noTlp,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Fax : ',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 34,
                  ),
                  Text(
                    customer[position].fax.isEmpty
                        ? '-'
                        : customer[position].fax,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Alamat : ',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    child: Text(
                      customer[position].alamat,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Target Pembelian yang disepakati : ',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     SizedBox(
              //       width: 20,
              //     ),
              //     SizedBox(
              //       width: 180,
              //       child: Text(
              //         'Target Lensa Nikon : ',
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w500),
              //       ),
              //     ),
              //     Expanded(
              //       flex: 1,
              //       child: Text(
              //         convertToIdr(int.parse(tpNikon), 0),
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w600),
              //       ),
              //     ),
              //   ],
              // ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     SizedBox(
              //       width: 20,
              //     ),
              //     SizedBox(
              //       width: 180,
              //       child: Text(
              //         'Target Lensa Leinz : ',
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w500),
              //       ),
              //     ),
              //     Expanded(
              //       flex: 1,
              //       child: Text(
              //         convertToIdr(int.parse(tpLeinz), 0),
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w600),
              //       ),
              //     ),
              //   ],
              // ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     SizedBox(
              //       width: 20,
              //     ),
              //     SizedBox(
              //       width: 180,
              //       child: Text(
              //         'Target Lensa Oriental : ',
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w500),
              //       ),
              //     ),
              //     Expanded(
              //       flex: 1,
              //       child: Text(
              //         convertToIdr(int.parse(tpOriental), 0),
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w600),
              //       ),
              //     ),
              //   ],
              // ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     SizedBox(
              //       width: 20,
              //     ),
              //     SizedBox(
              //       width: 180,
              //       child: Text(
              //         'Target Lensa Moe : ',
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w500),
              //       ),
              //     ),
              //     Expanded(
              //       flex: 1,
              //       child: Text(
              //         convertToIdr(int.parse(tpMoe), 0),
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w600),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(
              //   height: 15,
              // ),
              // Container(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: 20,
              //     vertical: 8,
              //   ),
              //   child: Text(
              //     'Jangka waktu pembayaran : ',
              //     style: TextStyle(
              //       fontSize: 16,
              //       fontFamily: 'Montserrat',
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: 8,
              // ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     SizedBox(
              //       width: 20,
              //     ),
              //     SizedBox(
              //       width: 180,
              //       child: Text(
              //         'Jangka Waktu Nikon : ',
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w500),
              //       ),
              //     ),
              //     Expanded(
              //       flex: 1,
              //       child: Text(
              //         pembNikon,
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w600),
              //       ),
              //     ),
              //   ],
              // ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     SizedBox(
              //       width: 20,
              //     ),
              //     SizedBox(
              //       width: 180,
              //       child: Text(
              //         'Jangka Waktu Leinz : ',
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w500),
              //       ),
              //     ),
              //     Expanded(
              //       flex: 1,
              //       child: Text(
              //         pembLeinz,
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w600),
              //       ),
              //     ),
              //   ],
              // ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     SizedBox(
              //       width: 20,
              //     ),
              //     SizedBox(
              //       width: 180,
              //       child: Text(
              //         'Jangka Waktu Oriental : ',
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w500),
              //       ),
              //     ),
              //     Expanded(
              //       flex: 1,
              //       child: Text(
              //         pembOriental,
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w600),
              //       ),
              //     ),
              //   ],
              // ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     SizedBox(
              //       width: 20,
              //     ),
              //     SizedBox(
              //       width: 180,
              //       child: Text(
              //         'Jangka Waktu Moe : ',
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w500),
              //       ),
              //     ),
              //     Expanded(
              //       flex: 1,
              //       child: Text(
              //         pembMoe,
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w600),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              // Container(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: 20,
              //     vertical: 8,
              //   ),
              //   child: Text(
              //     'Terhitung sejak tanggal : $tglKontrak',
              //     style: TextStyle(
              //         fontSize: 16,
              //         fontFamily: 'Montserrat',
              //         fontWeight: FontWeight.w600),
              //   ),
              // ),
              // SizedBox(
              //   height: 20,
              // ),
            ],
          ),
        );
      });
    },
  );
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
