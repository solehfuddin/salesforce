import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DialogStatus extends StatefulWidget {
  dynamic msg;
  bool status = false;

  DialogStatus({this.msg, this.status});

  @override
  State<DialogStatus> createState() => _DialogStatusState();
}

class _DialogStatusState extends State<DialogStatus> {
  String id = '';
  String role = '';
  String username = '';
  String divisi = '';

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childDialogStatus(isHorizontal: true);
      }

      return childDialogStatus(isHorizontal: false);
    });
  }

  Widget childDialogStatus({bool isHorizontal}) {
    return AlertDialog(
      content: Container(
        padding: EdgeInsets.only(
          top: 20.r,
        ),
        height: isHorizontal ? 325.h : 205.h,
        child: Column(
          children: [
            Center(
              child: Image.asset(
                widget.status
                    ? 'assets/images/success.png'
                    : 'assets/images/failure.png',
                width: isHorizontal ? 110.r : 70.r,
                height: isHorizontal ? 110.r : 70.r,
              ),
            ),
            SizedBox(
              height: isHorizontal ? 20.h : 20.h,
            ),
            Center(
              child: Text(
                widget.msg,
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: isHorizontal ? 20.h : 20.h,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  primary: Colors.indigo[600],
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.r, vertical: 10.r),
                ),
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 22.sp : 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Segoe ui',
                  ),
                ),
                onPressed: () {
                  if (widget.status) {
                    // Navigator.pop(context);
                    if (role == "ADMIN") {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => AdminScreen()),
                          (route) => false);
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                          (route) => false);
                    }
                  } else {
                    Navigator.of(context, rootNavigator: true).pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget childDialogStatus({bool isHorizontal}) {
  //   return AlertDialog(
  //     content: Container(
  //       padding: EdgeInsets.only(
  //         top: 20.r,
  //       ),
  //       height: isHorizontal ? 325.h : 205.h,
  //       child: Column(
  //         children: [
  //           Center(
  //             child: Image.asset(
  //               widget.status
  //                   ? 'assets/images/success.png'
  //                   : 'assets/images/failure.png',
  //               width: isHorizontal ? 120.r : 70.r,
  //               height: isHorizontal ? 120.r : 70.r,
  //             ),
  //           ),
  //           SizedBox(
  //             height: isHorizontal ? 30.h : 20.h,
  //           ),
  //           Center(
  //             child: Text(
  //               widget.msg,
  //               style: TextStyle(
  //                 fontSize: isHorizontal ? 24.sp : 14.sp,
  //                 fontFamily: 'Montserrat',
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ),
  //           SizedBox(
  //             height: isHorizontal ? 30.h : 20.h,
  //           ),
  //           Center(
  //             child: ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 shape: StadiumBorder(),
  //                 primary: Colors.indigo[600],
  //                 padding:
  //                     EdgeInsets.symmetric(horizontal: 20.r, vertical: 10.r),
  //               ),
  //               child: Text(
  //                 'Ok',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: isHorizontal ? 24.sp : 14.sp,
  //                   fontWeight: FontWeight.bold,
  //                   fontFamily: 'Segoe ui',
  //                 ),
  //               ),
  //               onPressed: () {
  // Navigator.of(widget.context, rootNavigator: true).pop(widget.context);
  // if (widget.status) {
  //   Navigator.pop(context);
  //                 }
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
