import 'package:flutter/material.dart';
import 'package:sample/src/app/navigator/splash.dart';

void main() {
  runApp(new Test());
}

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}