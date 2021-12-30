import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/widgets/passwordtextfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'logintextfield.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController textUsername = TextEditingController();
  TextEditingController textPassword = TextEditingController();
  String username, password;
  bool _isUsername = false;
  bool _isPassword = false;

  check() {
    textUsername.text.isEmpty ? _isUsername = true : _isUsername = false;
    textPassword.text.isEmpty ? _isPassword = true : _isPassword = false;

    print(textUsername.text);
    print(textPassword.text);

    username = textUsername.text;
    password = textPassword.text;
    login(username, password);
  }

  login(String user, String pass) async {
    var url = 'http://timurrayalab.com/salesforce/server/api/auth/login';
    var response =
        await http.post(url, body: {'username': user, 'password': pass});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    var data = json.decode(response.body);
    final bool sts = data['status'];
    final String msg = data['message'];

    if (sts) {
      final String id = data['data']['id'];
      final String name = data['data']['name'];
      final String username = data['data']['username'];
      final String accstatus = data['data']['status'];
      final String role = data['data']['role'];

      savePref(id, name, username, accstatus, role);

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
  }

  savePref(String id, String name, String username, String status,
      String role) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    setState(() {
      pref.setString("id", id);
      pref.setString("name", name);
      pref.setString("username", username);
      pref.setString("status", status);
      pref.setString("role", role);
      pref.setBool("islogin", true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
        ),
        Column(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 7,
                          bottom: 15),
                      child: Text(
                        "SALES FORCE",
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    LoginTextfield(30, 0, "Username", "Username ...",
                        textUsername, _isUsername),
                  ],
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    PasswordTextField(
                        0, 30, "Password ...", textPassword, _isPassword),
                    Padding(
                      padding: EdgeInsets.only(right: 50, top: 30),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 25,
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.only(left: 23),
                // child: roundedRectButton("Login", signInGradients, false),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    primary: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Segoe ui',
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      check();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const List<Color> signInGradients = [
  MyColors.bgColor,
  MyColors.bgColor,
];
