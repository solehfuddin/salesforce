import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/pages/intro/intro_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/custom.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future checkIntro() async {
    await SharedPreferences.getInstance().then((value) {
      bool _check = value.getBool('check') ?? false;

      print('Check : $_check');

      if (_check) {
        Get.offNamed('/login');
      } else {
        Get.off(() => IntroPage());
      }
    });
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
