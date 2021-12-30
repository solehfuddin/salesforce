import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/login/login_view.dart';
import 'package:sample/src/app/widgets/newintro.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'home.dart';
// import 'navbar.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future checkIntro() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool _check = (pref.getBool('check') ?? false);

    if (_check) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Login()));
    }
    else
    {
      // await pref.setBool('check', true);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NewIntro()));
    }
  }

  @override
  void initState() {
    super.initState();
    checkIntro();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}