import 'package:flutter/material.dart';
import 'customClip.dart';

class WaveFooter extends StatelessWidget {
  final List<Color> customColor;

  WaveFooter({@required this.customColor});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomClip(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: customColor,
              begin: Alignment.topLeft,
              end: Alignment.center),
        ),
        height: MediaQuery.of(context).size.height / 3,
      ),
    );
  }
}