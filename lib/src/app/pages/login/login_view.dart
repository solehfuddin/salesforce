import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/backgroundlogin.dart';
import 'package:sample/src/app/widgets/loginform.dart';
import 'package:sample/src/app/widgets/logintextfield.dart';
import 'package:sample/src/app/widgets/passwordtextfield.dart';
import 'package:sample/src/app/widgets/waveFooter.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static const List<Color> customColor = [
    Color(0xff64c856),
    Color(0xff7dd571),
  ];

  TextEditingController textUsername = TextEditingController();
  TextEditingController textPassword = TextEditingController();
  String username, password;
  bool _isUsername = false;
  bool _isPassword = false;

  check({bool isHorizontal}) {
    textUsername.text.isEmpty ? _isUsername = true : _isUsername = false;
    textPassword.text.isEmpty ? _isPassword = true : _isPassword = false;

    print(textUsername.text);
    print(textPassword.text);

    username = textUsername.text;
    password = textPassword.text;
    login(
      username,
      password,
      context,
      isHorizontal: isHorizontal,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 600 ||
            MediaQuery.of(context).orientation == Orientation.landscape) {
          return Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        Center(
                          child: Image.asset(
                            'assets/images/newlogin.png',
                            width: MediaQuery.of(context).size.width / 2.47,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.r,
                            vertical: 10.r,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "e-SALES",
                                style: TextStyle(
                                  fontSize: 36.sp,
                                  color: MyColors.bgColor,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(
                                'v 1.1.0',
                                style: TextStyle(
                                  fontSize: 27.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Segoe ui',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.17,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.r),
                          child: LoginTextfield(
                            15,
                            0,
                            "USERNAME",
                            "USERNAME",
                            textUsername,
                            _isUsername,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.r),
                          child: PasswordTextField(
                              0, 15, "PASSWORD", textPassword, _isPassword),
                        ),
                        SizedBox(
                          height: 18.h,
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: EdgeInsets.only(right: 15.w),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  check(
                                    isHorizontal: true,
                                  );
                                });
                              },
                              icon: Icon(
                                Icons.login,
                                size: 40.r,
                              ),
                              label: Text(''),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.deepOrange[600],
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 12.h),
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35.r),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    WaveFooter(
                      customColor: customColor,
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Stack(
          children: <Widget>[
            BackgroundLogin(),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: LoginForm(),
            ),
          ],
        );
      }),
    );
  }
}
