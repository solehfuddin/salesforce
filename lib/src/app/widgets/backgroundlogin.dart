import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/src/app/widgets/waveFooter.dart';
import 'package:sample/src/app/widgets/waveHeader.dart';

class BackgroundLogin extends StatefulWidget {
  @override
  _BackgroundLogin createState() => _BackgroundLogin();
}

class _BackgroundLogin extends State<BackgroundLogin> {
  static const List<Color> customColor = [
    Color(0xff64c856),
    Color(0xff7dd571),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              WaveHeader(
                customColor: customColor,
              ),
              Image.asset(
                'assets/images/newlogin.png',
                width: MediaQuery.of(context).size.width / 1.54,
                fit: BoxFit.cover,
              ),
            ],
          ),
          Expanded(
            child: Container(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                WaveFooter(
                  customColor: customColor,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
