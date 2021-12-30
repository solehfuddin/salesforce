import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/src/app/pages/login/login_view.dart';
import 'package:sample/src/app/utils/colors.dart';
// import 'package:nice_intro/intro_screen.dart';
// import 'package:nice_intro/intro_screens.dart';
// import 'package:sample/style/customClip.dart';
// import 'package:sample/ui/home.dart';
// import 'package:sample/ui/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'introwidget/myintro.dart';
import 'introwidget/myintros.dart';

class NewIntro extends StatefulWidget {
  @override
  _NewIntroState createState() => _NewIntroState();
}

class _NewIntroState extends State<NewIntro> {
  Future changeIntro() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('check', true);

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Login()));
  }

  List<MyIntroData> introScreen = [
    MyIntroData(
      title: "Agenda",
      description: "Membuat rencana kerja Anda menjadi lebih terstruktur",
      imageAsset: "assets/images/agenda.png",
    ),
    MyIntroData(
      title: "Reporting",
      description: "Kelola laporan seluruh kegiatan untuk evaluasi kinerja",
      imageAsset: "assets/images/reporting.png",
    ),
    MyIntroData(
      title: "Dashboard",
      description: "Pantau kegiatan Anda dan kelola dengan lebih mudah",
      imageAsset: "assets/images/dashboard.png",
    ),
  ];

  List<Color> colorCustom = [Color(0xff388feb), Color(0xff2a81e4)];
  // List<Color> colorCustom = [Color(0xffffffff)];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return Scaffold(
      body: Container(
        child: MyIntros(
          slides: introScreen,
          onDone: () => changeIntro(),
          onSkip: () => changeIntro(),
          // footerGradients: colorCustom,
          footerBgColor: Colors.white,
          activeDotColor: MyColors.textColor,
          textColor: MyColors.textColor,
          footerRadius: 0,
          indicatorType: IndicatorType.DIAMOND,
          
        ),
      ),
      // ClipPath(
      //   child: Container(
      //     width: MediaQuery.of(context).size.width,
      //     height: MediaQuery.of(context).size.height / 5,
      //     color: Colors.green,
      //   ),
      //   clipper: CustomClip(),
      // ),
    );
  }
}
