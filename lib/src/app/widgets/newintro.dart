import 'dart:async';
import 'dart:io';

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

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
  }

  List<MyIntroData> introScreen = [
    MyIntroData(
      title: "Agenda",
      description: "Membuat rencana kerja Anda menjadi lebih terstruktur",
      imageAsset: "assets/images/agenda.png",
      isHorizontal: false,
    ),
    MyIntroData(
      title: "Reporting",
      description: "Kelola laporan seluruh kegiatan untuk evaluasi kinerja",
      imageAsset: "assets/images/reporting.png",
      isHorizontal: false,
    ),
    MyIntroData(
      title: "Dashboard",
      description: "Pantau kegiatan Anda dan kelola dengan lebih mudah",
      imageAsset: "assets/images/dashboard.png",
      isHorizontal: false,
    ),
  ];

  List<MyIntroData> introScreenHor = [
    MyIntroData(
      title: "Agenda",
      description: "Membuat rencana kerja Anda menjadi lebih terstruktur",
      imageAsset: "assets/images/agenda.png",
      isHorizontal: true,
    ),
    MyIntroData(
      title: "Reporting",
      description: "Kelola laporan seluruh kegiatan untuk evaluasi kinerja",
      imageAsset: "assets/images/reporting.png",
      isHorizontal: true,
    ),
    MyIntroData(
      title: "Dashboard",
      description: "Pantau kegiatan Anda dan kelola dengan lebih mudah",
      imageAsset: "assets/images/dashboard.png",
      isHorizontal: true,
    ),
  ];

  List<Color> colorCustom = [Color(0xff388feb), Color(0xff2a81e4)];

  void platformDevice() {}

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    return Scaffold(
      body: Container(
        child: LayoutBuilder(
          builder: (context, constraint) {
            if (constraint.maxWidth > 600 || MediaQuery.of(context).orientation == Orientation.landscape) {
              return MyIntros(
                slides: introScreenHor,
                onDone: () => changeIntro(),
                onSkip: () => changeIntro(),
                isHorizontal: true,
                footerBgColor: Colors.white,
                activeDotColor: MyColors.textColor,
                textColor: MyColors.textColor,
                footerRadius: 0,
                indicatorType: IndicatorType.DIAMOND,
              );
            }

            return MyIntros(
              slides: introScreen,
              onDone: () => changeIntro(),
              onSkip: () => changeIntro(),
              isHorizontal: false,
              footerBgColor: Colors.white,
              activeDotColor: MyColors.textColor,
              textColor: MyColors.textColor,
              footerRadius: 0,
              indicatorType: IndicatorType.DIAMOND,
            );
          },
        ),
      ),
    );
  }
}
