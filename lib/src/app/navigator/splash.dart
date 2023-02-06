import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/intro/intro_view.dart';
import 'package:sample/src/app/pages/login/login_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future checkIntro() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool _check = (pref.getBool('check') ?? false);

    if (_check) {
      Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IntroPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    checkIntro();
    if (Platform.isAndroid) {
      checkUpdate(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
