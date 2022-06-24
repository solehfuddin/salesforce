import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:sample/src/app/pages/signed/signed_view.dart';

class DialogSigned extends StatefulWidget {
  @override
  State<DialogSigned> createState() => _DialogSignedState();
}

class _DialogSignedState extends State<DialogSigned> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childDialogSigned(isHorizontal: true);
      }

      return childDialogSigned(isHorizontal: false);
    });
  }

  Widget childDialogSigned({bool isHorizontal}) {
    return AlertDialog(
      title: Center(
        child: Text(
          // "Digital Signed",
          "Tanda Tangan Digital",
          style: TextStyle(
            fontSize: isHorizontal ? 35.sp : 20.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: Container(
        padding: EdgeInsets.only(
          top: 20,
        ),
        height: isHorizontal ? 350.h : 220.h,
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/images/digital_sign.png',
                width: isHorizontal ? 120.r : 60.r,
                height: isHorizontal ? 120.r : 60.r,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "Lengkapi tanda tanganmu dan mulai ajukan kontrak disini",
                style: TextStyle(
                  fontSize: isHorizontal ? 24.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: isHorizontal ? 30.h : 20.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    primary: Colors.orange[800],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Next time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Segoe ui',
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    primary: Colors.indigo[600],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Setup now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Segoe ui',
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SignedScreen()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
