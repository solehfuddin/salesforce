import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/customer/customer_view.dart';
// import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/staff/staff_view.dart';
// import 'package:sample/src/app/utils/custom.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class DialogStatus extends StatefulWidget {
  dynamic msg;
  bool status;
  bool isLogout, isNewCust, isBack;

  DialogStatus({
    this.msg,
    this.status = false,
    this.isLogout = false,
    this.isNewCust = false,
    this.isBack = false,
  });

  @override
  State<DialogStatus> createState() => _DialogStatusState();
}

class _DialogStatusState extends State<DialogStatus> {
  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';

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
    print('IS LOGOUT : ${widget.isLogout}');
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

  Widget childDialogStatus({bool isHorizontal = false}) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      content: Container(
        padding: EdgeInsets.only(
          top: 20.r,
        ),
        // height: isHorizontal ? 290.h : 225.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Image.asset(
                widget.status
                    ? 'assets/images/success.png'
                    : 'assets/images/failure.png',
                width: isHorizontal ? 70.r : 65.r,
                height: isHorizontal ? 70.r : 65.r,
              ),
            ),
            SizedBox(
              height: isHorizontal ? 20.h : 20.h,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                widget.msg,
                style: TextStyle(
                  fontSize: isHorizontal ? 17.sp : 13.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: isHorizontal ? 20.h : 20.h,
            ),
            widget.isLogout
                ? InkWell(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.indigo[600],
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32.0),
                            bottomRight: Radius.circular(32.0)),
                      ),
                      child: Text(
                        'Kembali',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                // Center(
                //     child: ElevatedButton(
                //       style: ElevatedButton.styleFrom(
                //         shape: StadiumBorder(),
                //         backgroundColor: Colors.indigo[600],
                //         padding: EdgeInsets.symmetric(
                //             horizontal: 20.r, vertical: 10.r),
                //       ),
                //       child: Text(
                //         'Tutup Aplikasi',
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: isHorizontal ? 20.sp : 14.sp,
                //           fontWeight: FontWeight.bold,
                //           fontFamily: 'Segoe ui',
                //         ),
                //       ),
                //       onPressed: () {
                //         signOut(
                //           isChangePassword: true,
                //           context: context,
                //         );
                //       },
                //     ),
                //   )
                :
                // Center(
                //     child: ElevatedButton(
                //       style: ElevatedButton.styleFrom(
                //         shape: StadiumBorder(),
                //         backgroundColor: Colors.indigo[600],
                //         padding: EdgeInsets.symmetric(
                //             horizontal: 20.r, vertical: 10.r),
                //       ),
                //       child: Text(
                //         'Ok',
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: isHorizontal ? 20.sp : 14.sp,
                //           fontWeight: FontWeight.bold,
                //           fontFamily: 'Segoe ui',
                //         ),
                //       ),
                //       onPressed: () {
                //         if (widget.isBack) {
                //           Navigator.of(context, rootNavigator: true)
                //               .pop(context);
                //         } else {
                //           if (widget.status) {
                //             Navigator.pop(context);

                //             if (role == "ADMIN") {
                //               Navigator.of(context).pushAndRemoveUntil(
                //                   MaterialPageRoute(
                //                       builder: (context) => AdminScreen()),
                //                   (route) => false);
                //             } else if (role == "STAFF") {
                //               Navigator.of(context).pushAndRemoveUntil(
                //                   MaterialPageRoute(
                //                       builder: (context) => StaffScreen()),
                //                   (route) => false);
                //             } else {
                //               Navigator.of(context).pushAndRemoveUntil(
                //                   MaterialPageRoute(
                //                       builder: (context) => HomeScreen()),
                //                   (route) => false);
                //             }

                //             if (widget.isNewCust) {
                //               Navigator.of(context).push(
                //                 MaterialPageRoute(
                //                   builder: (context) => CustomerScreen(
                //                     int.parse(id!),
                //                   ),
                //                 ),
                //               );
                //               // Get.toNamed('/customer/$id');
                //             }
                //           } else {
                //             Navigator.of(context, rootNavigator: true)
                //                 .pop(context);
                //           }
                //         }
                //       },
                //     ),
                //   ),
                InkWell(
                    onTap: () {
                      if (widget.isBack) {
                        Navigator.of(context, rootNavigator: true).pop(context);
                      } else {
                        if (widget.status) {
                          Navigator.pop(context);

                          if (role == "ADMIN") {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => AdminScreen()),
                                (route) => false);
                          } else if (role == "STAFF") {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => StaffScreen()),
                                (route) => false);
                          } else {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()),
                                (route) => false);
                          }

                          if (widget.isNewCust) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CustomerScreen(
                                  int.parse(id!),
                                ),
                              ),
                            );
                            // Get.toNamed('/customer/$id');
                          }
                        } else {
                          Navigator.of(context, rootNavigator: true)
                              .pop(context);
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.indigo[600],
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32.0),
                            bottomRight: Radius.circular(32.0)),
                      ),
                      child: Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
