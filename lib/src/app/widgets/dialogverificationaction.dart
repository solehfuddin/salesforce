import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/inkaro/edit_header_inkaro.dart';
import 'package:sample/src/app/pages/signed/signed_view.dart';
import 'package:sample/src/domain/entities/list_inkaro_header.dart';

class DialogVerificationAction extends StatefulWidget {
  final List<ListInkaroHeader> inkaroHeaderList;
  final int position;

  @override
  State<DialogVerificationAction> createState() =>
      _DialogVerificationActionState();

  DialogVerificationAction(this.inkaroHeaderList, this.position);
}

class _DialogVerificationActionState extends State<DialogVerificationAction> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childDialogVerificationAction(isHorizontal: true);
      }

      return childDialogVerificationAction(isHorizontal: false);
    });
  }

  Widget childDialogVerificationAction({bool isHorizontal = false}) {
    return AlertDialog(
      title: Center(
        child: Text(
          "Apakah Anda Yakin Ingin Mengubah Data Kontrak Inkaro ?",
          style: TextStyle(
            fontSize: isHorizontal ? 20.sp : 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: Container(
        padding: EdgeInsets.only(
          top: isHorizontal ? 0.r : 20.r,
        ),
        height: isHorizontal ? 300.h : 180.h,
        child: Column(
          children: [
            // Center(
            //   child: Image.asset(
            //     'assets/images/digital_sign.png',
            //     width: isHorizontal ? 70.r : 60.r,
            //     height: isHorizontal ? 70.r : 60.r,
            //   ),
            // ),
            Center(
              child: Text(
                'Jika Data Kontrak Mengalami Perubahan, maka status kontrak inkaro akan kembali menjadi "PENDING" dan perlu melalui proses approval Sales Manager',
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
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      primary: Colors.indigo[600],
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.r, vertical: 10.r),
                    ),
                    child: Text(
                      'Iya',
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
                          builder: (context) => EditInkaroHeaderScreen(
                              widget.inkaroHeaderList, widget.position),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: isHorizontal ? 10.h : 20.h,
                ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      primary: Colors.orange[800],
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.r, vertical: 10.r),
                    ),
                    child: Text(
                      'Batal',
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
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
