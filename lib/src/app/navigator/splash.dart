import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/login/login_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/newintro.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future checkIntro() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool _check = (pref.getBool('check') ?? false);
    bool _isLogin = (pref.getBool('islogin') ?? false);

    if (_check) {
      if (_isLogin) {
        String role = pref.getString("role");

        if (role == 'ADMIN') {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdminScreen()));
        } else if (role == 'SALES') {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Login()));
        }
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
      }
    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => NewIntro()));
    }
  }

  
  @override
  void initState() {
    super.initState();
    checkIntro();
    if (Platform.isAndroid){
      // checkUpdate(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
