import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DialogLogin extends StatefulWidget {
  @override
  State<DialogLogin> createState() => _DialogLoginState();
}

class _DialogLoginState extends State<DialogLogin> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600 ||
            MediaQuery.of(context).orientation == Orientation.landscape) {
          return childLoginDialog(
            isHorizontal: true,
          );
        }
        return childLoginDialog(
          isHorizontal: false,
        );
      },
    );
  }

  Widget childLoginDialog({bool isHorizontal = false}) {
    return AlertDialog(
      content: Container(
        height: isHorizontal ? 250.h : 185.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: CircularProgressIndicator(
                color: Colors.green.shade500,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Center(
              child: Text(
                'Mohon menunggu',
                style: TextStyle(
                  fontSize: isHorizontal ? 25.sp : 15.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
