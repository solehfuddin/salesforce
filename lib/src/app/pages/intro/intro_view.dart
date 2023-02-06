import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:sample/src/app/pages/login/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  Future changeIntro() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('check', true);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IntroductionScreen(
        globalBackgroundColor: Colors.white,
        pages: [
          PageViewModel(
            title: "",
            decoration: PageDecoration(
              titlePadding: EdgeInsets.zero,
              contentMargin: EdgeInsets.zero,
            ),
            useScrollView: true,
            bodyWidget: Column(
              children: [
                Image.asset(
                  "assets/images/agenda.png",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 1.7,
                ),
                SizedBox(
                  height: 25.h,
                ),
                Center(
                  child: Text(
                    'Agenda',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Center(
                  child: Text(
                    'Membuat rencana kerja Anda menjadi lebih terstruktur',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          PageViewModel(
            title: "",
            decoration: PageDecoration(
              titlePadding: EdgeInsets.zero,
              contentMargin: EdgeInsets.zero,
            ),
            useScrollView: true,
            bodyWidget: Column(
              children: [
                Image.asset(
                  "assets/images/reporting.png",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 1.7,
                ),
                SizedBox(
                  height: 25.h,
                ),
                Center(
                  child: Text(
                    'Reporting',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Center(
                  child: Text(
                    'Kelola laporan seluruh kegiatan untuk evaluasi kinerja',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          PageViewModel(
            title: "",
            decoration: PageDecoration(
              titlePadding: EdgeInsets.zero,
              contentMargin: EdgeInsets.zero,
            ),
            useScrollView: true,
            bodyWidget: Column(
              children: [
                Image.asset(
                  "assets/images/dashboard.png",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 1.7,
                ),
                SizedBox(
                  height: 25.h,
                ),
                Center(
                  child: Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Center(
                  child: Text(
                    'Pantau kegiatan Anda dan kelola dengan lebih mudah',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
        showSkipButton: true,
        skip: Text(
          "SKIP",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 15.sp,
          ),
        ),
        next: const Icon(
          Icons.arrow_forward,
          color: Colors.black87,
        ),
        done: const Icon(
          Icons.check,
          color: Colors.black87,
        ),
        onDone: () => changeIntro(),
        onSkip: () => changeIntro(),
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Colors.green,
          color: Colors.black26,
          spacing: EdgeInsets.symmetric(horizontal: 3.r),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
        ),
      ),
    );
  }
}
