import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/activity/daily_activity.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class DialogBack extends StatefulWidget {
  dynamic msg, accessFrom;
  bool? status = false;
  bool? isLogout = false;
  bool? isAdmin = false;

  DialogBack({
    this.msg,
    this.status,
    this.isLogout,
    this.accessFrom,
    this.isAdmin,
  });

  @override
  State<DialogBack> createState() => _DialogBackState();
}

class _DialogBackState extends State<DialogBack> {
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
        return childDialogBack(isHorizontal: true);
      }

      return childDialogBack(isHorizontal: false);
    });
  }
  
  Widget childDialogBack({bool isHorizontal = false}) {
    return AlertDialog(
      content: Container(
        padding: EdgeInsets.only(
          top: 20.r,
        ),
        height: isHorizontal ? 290.h : 225.h,
        child: Column(
          children: [
            Center(
              child: Image.asset(
                widget.status!
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
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: isHorizontal ? 20.h : 20.h,
            ),
            widget.isLogout!
                ? Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(), 
                        backgroundColor: Colors.indigo[600],
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.r, vertical: 10.r),
                      ),
                      child: Text(
                        'Tutup Aplikasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isHorizontal ? 22.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onPressed: () {
                        signOut(
                          isChangePassword: true,
                          context: context,
                        );
                      },
                    ),
                  )
                : Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(), 
                        backgroundColor: Colors.indigo[600],
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.r, vertical: 10.r),
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
                        if (widget.status!) {
                          if (widget.accessFrom == "Aktivitas") {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => DailyActivity(
                                    isAdmin: widget.isAdmin!,
                                  ),
                                ),
                                (route) => false);
                          }
                        } else {
                          Navigator.of(context, rootNavigator: true)
                              .pop(context);
                        }
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}