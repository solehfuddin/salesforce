import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sample/src/app/utils/config.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/dialoglogin.dart';
import 'package:sample/src/domain/entities/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  List<AppConfig> listAppconfig = List.empty(growable: true);
  String messageTitle = "Empty";
  String notificationAlert = "alert";
  String? token = '123445';

  TextEditingController textUsername = TextEditingController();
  TextEditingController textPassword = TextEditingController();
  String username = '';
  String password = '';
  bool _isUsername = false;
  bool _isPassword = false;
  bool _isHidePass = true;

  void _tooglePassVisibility() {
    setState(() {
      _isHidePass = !_isHidePass;
    });
  }

  generateTokenFCM() async {
    // token = await FirebaseMessaging.instance.getToken();
    // print('Akses token : $token');
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken().then((value) {
      if (value != null) {
        token = value;
        print('Akses token : $token');
      } else {
        print('Google play service not support');
      }
    });
  }

  getConfig() async {
    // const timeout = 30;
    var url = '$API_URL/config/';

    try {
      var response = await http.get(Uri.parse(url));
      //await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout))
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);

          listAppconfig =
              rest.map<AppConfig>((json) => AppConfig.fromJson(json)).toList();

          loginStatus(context);
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  getTokenInfo(int id) async {
    const timeout = 15;
    var url = '$API_URL/users?id=$id';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          DateTime todayDate = DateTime.now();
          DateTime tokenDate = DateTime.parse(data['data']['gentoken_updated']);

          if (getTotalDay(tokenDate, todayDate) > 30) {
            print('Refresh Token FCM Please...');

            updateToken(
              id.toString(),
              token!,
              context,
            );
          }
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  check({bool isHorizontal = false}) {
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
      token: token,
    );
  }

  Future loginStatus(BuildContext dialogContext) async {
    await Future.delayed(Duration.zero);
    // if (mounted)
    // {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return DialogLogin();
      },
    );
    // }

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? role = pref.getString("role");
    String? id = pref.getString("id");
    print('Akses role : $role');

    if (id != null) {
      getTokenInfo(int.parse(id));
    }

    if (listAppconfig[0].status == "0") {
      if (role != null) {
        if (role == 'ADMIN') {
          Get.offAllNamed('/admin');
        } else if (role == 'SALES') {
          Get.offAllNamed('/home');
        } else if (role == 'STAFF' || role == "USER") {
          Get.offAllNamed('/staff');
        } else {
          if (dialogContext.mounted) {
            await Future.delayed(
              Duration(seconds: 1),
            ).then((value) => Navigator.pop(dialogContext));
          }

          print('Belum Login');
        }
      } else {
        if (dialogContext.mounted) {
          await Future.delayed(
            Duration(seconds: 1),
          ).then((value) => Navigator.pop(dialogContext));
        }

        print('Belum pernah login');
      }
    } else {
      Get.offAllNamed('/maintenance');
    }
  }

  @override
  void initState() {
    super.initState();
    getConfig();
    generateTokenFCM();

    /* if (Platform.isAndroid)
    {
      DeviceInfoPlugin().androidInfo.then((value) {
        if (value.version.sdkInt! > 27)
        {
          generateTokenFCM();
        }
        else
        {
          print('Disable firebase function');
        }
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    bool _isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 600 ||
            MediaQuery.of(context).orientation == Orientation.landscape) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0XFF3BC937),
                      Color(0XFF00962A),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/leinzlogo.png',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.45,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.14,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.r,
                                  vertical: 10.r,
                                ),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.r),
                                    ),
                                    hintText: 'Username',
                                    fillColor: Colors.white,
                                    filled: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 10,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 20.sp,
                                    ),
                                    errorStyle: TextStyle(
                                      fontSize: 20.sp,
                                      fontFamily: 'Segoe Ui',
                                      color: Colors.white,
                                    ),
                                    errorText: _isUsername
                                        ? 'Username harus diisi'
                                        : null,
                                  ),
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontFamily: 'Segoe Ui',
                                  ),
                                  controller: textUsername,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.r,
                                  vertical: 10.r,
                                ),
                                child: TextFormField(
                                  obscureText: _isHidePass,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.r),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 10,
                                    ),
                                    hintText: 'Password',
                                    hintStyle: TextStyle(
                                      fontSize: 20.sp,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        _tooglePassVisibility();
                                      },
                                      child: Icon(
                                        _isHidePass
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: _isHidePass
                                            ? Colors.grey
                                            : Colors.blue,
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                      fontSize: 20.sp,
                                      fontFamily: 'Segoe Ui',
                                      color: Colors.white,
                                    ),
                                    errorText: _isPassword
                                        ? 'Password harus diisi'
                                        : null,
                                  ),
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontFamily: 'Segoe Ui',
                                  ),
                                  controller: textPassword,
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Container(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding: EdgeInsets.only(right: 20.r),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade100,
                                    ),
                                    onPressed: () {
                                      check(
                                        isHorizontal: true,
                                      );
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Segoe Ui',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18.sp,
                                      ),
                                    ),
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
              ),
              !_isKeyboard
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 15.r,
                        ),
                        child: Text(
                          'versi 1.5.2',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Segoe ui',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: 5.r,
                    ),
            ],
          );
        }

        return Stack(
          children: [
            Container(
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0XFF3BC937),
                    Color(0XFF00962A),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.18,
                  ),
                  Center(
                    child: Image.asset(
                      'assets/images/leinzlogo.png',
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.3,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.r,
                      vertical: 10.r,
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        hintText: 'Username',
                        hintStyle: TextStyle(
                          fontSize: 15.sp,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        errorStyle: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Segoe Ui',
                          color: Colors.white,
                        ),
                        errorText: _isUsername ? 'Username harus diisi' : null,
                      ),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: 'Segoe Ui',
                      ),
                      controller: textUsername,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.r,
                      vertical: 10.r,
                    ),
                    child: TextFormField(
                      obscureText: _isHidePass,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          fontSize: 15.sp,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _tooglePassVisibility();
                          },
                          child: Icon(
                            _isHidePass
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: _isHidePass ? Colors.grey : Colors.blue,
                          ),
                        ),
                        errorStyle: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Segoe Ui',
                          color: Colors.white,
                        ),
                        errorText: _isPassword ? 'Password harus diisi' : null,
                      ),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: 'Segoe Ui',
                      ),
                      controller: textPassword,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: EdgeInsets.only(right: 20.r),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                        ),
                        onPressed: () {
                          check(
                            isHorizontal: true,
                          );
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Segoe Ui',
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            !_isKeyboard
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.r),
                      child: Text(
                        'versi 1.5.2',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : SizedBox(
                    width: 5.r,
                  ),
          ],
        );
      }),
    );
  }
}
