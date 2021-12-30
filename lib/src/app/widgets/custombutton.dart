import 'package:flutter/material.dart';

Widget roundedRectButton(
    String title, List<Color> gradientColor, bool isIconVisible) {
  return Builder(builder: (BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 2.8,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              gradient: LinearGradient(
                colors: gradientColor,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Segoe ui',
              ),
            ),
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
          ),
          Visibility(
            visible: isIconVisible,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ImageIcon(
                AssetImage('assets/images/ic_forward.png'),
                size: 30,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  });
}
