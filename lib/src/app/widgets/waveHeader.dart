import 'package:flutter/material.dart';
import 'package:sample/src/app/widgets/waveClip.dart';

class WaveHeader extends StatelessWidget {
  final List<Color> customColor;

  WaveHeader({@required this.customColor});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: customColor,
              begin: Alignment.topLeft,
              end: Alignment.center),
        ),
        height: MediaQuery.of(context).size.height / 2.5,
      ),
    );
  }
}
