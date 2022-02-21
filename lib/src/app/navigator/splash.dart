import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/login/login_view.dart';
import 'package:sample/src/app/widgets/newintro.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppUpdateInfo _updateInfo;

  Future checkIntro() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool _check = (pref.getBool('check') ?? false);
    bool _isLogin = (pref.getBool('islogin') ?? false);

    if (_check) {
      if (_isLogin) {
        String role = pref.getString("role");

        if (role == 'admin') {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdminScreen()));
        } else if (role == 'sales') {
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
      // await pref.setBool('check', true);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => NewIntro()));
    }
  }

  void _showError(dynamic exception) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(exception),
      duration: Duration(seconds: 2),
    ));
  }

  void checkUpdate() {
    if (Platform.isAndroid) {
      InAppUpdate.checkForUpdate().then((info) {
        setState(() {
          _updateInfo = info;

          if (_updateInfo.updateAvailable == true) {
            InAppUpdate.performImmediateUpdate()
                .catchError((e) => _showError(e.toString()));
          }
        });
      }).catchError((e) => _showError(e.toString()));
    }
  }

  @override
  void initState() {
    super.initState();
    checkIntro();
    checkUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
