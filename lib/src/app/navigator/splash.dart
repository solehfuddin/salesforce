import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
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
  AppUpdateInfo _updateInfo;

  Future checkIntro() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool _check = (pref.getBool('check') ?? false);
    bool _isLogin = (pref.getBool('islogin') ?? false);

    if (_check) {
      if (_isLogin)
      {
        String role = pref.getString("role");

        if (role == 'admin') {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdminScreen()));
        } 
        else if(role == 'sales') {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        }
        else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Login()));
        }
      }      
      else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Login()));
      }
    }
    else
    {
      // await pref.setBool('check', true);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NewIntro()));
    }
  }

  void checkUpdate() {
    if(_updateInfo.updateAvailability == UpdateAvailability.updateAvailable)
    {
      // ignore: invalid_return_type_for_catch_error
      InAppUpdate.performImmediateUpdate().catchError((e) => handleStatus(context, e.toString(), false));
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
    return Container(
      
    );
  }
}