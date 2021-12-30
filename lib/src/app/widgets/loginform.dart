import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/widgets/passwordtextfield.dart';

import 'custombutton.dart';
import 'logintextfield.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

enum LoginStatus {notSignIn, signIn}

class _LoginFormState extends State<LoginForm> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  TextEditingController textUsername = TextEditingController();
  TextEditingController textPassword = TextEditingController();
  final _key = new GlobalKey<FormState>();
  bool _isUsername = false;
  bool _isPassword = false;

  check(){
    // final form = _key.currentState;
    // if (form.validate())
    // {
      // form.save();
      textUsername.text.isEmpty ? _isUsername = true : _isUsername = false; 
      textPassword.text.isEmpty ? _isPassword = true : _isPassword = false;
      print(textUsername.text);
      print(textPassword.text);
    // }
    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
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
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 7, bottom: 15),
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
                    LoginTextfield(30, 0, "Username", "Username ...", textUsername, _isUsername),
                  ],
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    PasswordTextField(0, 30, "Password ...", textPassword, _isPassword),
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
                  child: Text('Login', style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Segoe ui',
                  ),),
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
