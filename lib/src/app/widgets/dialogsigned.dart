import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  Widget childDialogSigned({bool isHorizontal = false}) {
    return AlertDialog(
      title: Center(
        child: Text(
          // "Digital Signed",
          "Tanda Tangan Digital",
          style: TextStyle(
            fontSize: isHorizontal ? 22.sp : 20.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: Container(
        padding: EdgeInsets.only(
          top: isHorizontal ? 0.r : 20.r,
        ),
        height: isHorizontal ? 340.h : 220.h,
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/images/digital_sign.png',
                width: isHorizontal ? 70.r : 60.r,
                height: isHorizontal ? 70.r : 60.r,
              ),
            ),
            SizedBox(
              height: isHorizontal ? 10.h : 20.h,
            ),
            Center(
              child: Text(
                "Lengkapi tanda tanganmu dan mulai ajukan kontrak disini",
                style: TextStyle(
                  fontSize: isHorizontal ? 16.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: isHorizontal ? 10.h : 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(), 
                    backgroundColor: Colors.orange[800],
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.r, vertical: 10.r),
                  ),
                  child: Text(
                    'Next time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isHorizontal ? 18.sp : 14.sp,
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
                    backgroundColor: Colors.indigo[600],
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.r, vertical: 10.r),
                  ),
                  child: Text(
                    'Setup now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isHorizontal ? 18.sp : 14.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Segoe ui',
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SignedScreen(),
                      ),
                    );
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