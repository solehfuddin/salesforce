import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;

class SignedScreen extends StatefulWidget {
  @override
  _SignedScreenState createState() => _SignedScreenState();
}

class _SignedScreenState extends State<SignedScreen> {
  String id = '';
  String role = '';
  String username = '';
  String tmpTtd;

  final SignatureController _signController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");

      print("Dashboard : $role");
      checkSigned(id);
    });
  }

  checkSigned(String idUser) async {
    await getTtdValid(idUser, context).then((data) {
      setState(() {
        tmpTtd = data;
        print(tmpTtd);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _signController.addListener(() => print('Value changed'));
    getRole();
  }

  Widget showImage() {
    if (tmpTtd != null) {
      return Column(
        children: [
          Text(
            'Last your signed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black54,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.memory(
              base64Decode(tmpTtd),
            ),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  uploadImg() async {
    if (_signController.isNotEmpty) {
      var data = await _signController.toPngBytes();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Digital Signature',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18,
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
              size: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/signedable.png',
                  width: 220,
                  height: 193,
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    'ELECTRONIC SIGNATURE INSTANTLY',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    'By signing this document with an electronic signature, I agree that such signature will be as valid as handwritten signatures to the extent allowed by local law',
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Signature(
                  controller: _signController,
                  height: 150,
                  backgroundColor: Colors.blueGrey.shade50,
                ),
                SizedBox(
                  height: 20,
                ),
                showImage(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        primary: Colors.orange[800],
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onPressed: () {
                        _signController.clear();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        primary: Colors.blue[700],
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onPressed: () {
                        uploadImg();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
