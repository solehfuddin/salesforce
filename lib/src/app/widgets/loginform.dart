import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/passwordtextfield.dart';

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
    login(username, password, context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 6),
        ),
        Column(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    LoginTextfield(15, 0, "USERNAME", "USERNAME", textUsername,
                        _isUsername),
                  ],
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    PasswordTextField(
                        0, 15, "PASSWORD", textPassword, _isPassword),
                    Padding(
                      padding: EdgeInsets.only(right: 50.w, top: 30.h),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: 40.w,
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
            SizedBox(
              height: 30.h,
            ),
            Container(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.only(right: 35.w),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      check();
                    });
                  },
                  icon: Icon(
                    Icons.login,
                    size: 33.r,
                  ),
                  label: Text(''),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrange[600],
                      padding:
                          EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      )),
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, bottom: 2),
              child: Text(
                "e-SALES",
                style: TextStyle(
                  fontSize: 23.sp,
                  color: MyColors.bgColor,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 50, bottom: 35),
              child: Text(
                'v 1.1.0',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Segoe ui',
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
