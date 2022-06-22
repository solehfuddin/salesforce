import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget with PreferredSizeWidget {
  bool isHorizontal = false;

  CustomAppBar({this.isHorizontal});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("islogin", false);
    await preferences.setString("role", null);
    await Future.delayed(const Duration(seconds: 2), () {});
    SystemNavigator.pop();
  }

  handleLogout() {
    AlertDialog alert = AlertDialog(
      title: Text("Logout"),
      content: Container(
        child: Text("Do you want to close app?"),
      ),
      actions: [
        TextButton(
          child: Text('Ok'),
          onPressed: () => signOut(),
        ),
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ],
    );

    showDialog(context: context, builder: (context) => alert);
  }

  handleComing() {
    AlertDialog alert = AlertDialog(
      title: Center(
        child: Text(
          "Coming Soon",
          style: TextStyle(
            fontSize: widget.isHorizontal ? 30.sp : 20.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: Container(
        child: Image.asset(
          'assets/images/coming_soon.png',
          width: widget.isHorizontal ? 110.sp : 80.r,
          height: widget.isHorizontal ? 110.sp : 80.r,
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
              primary: Colors.indigo[600],
              padding: EdgeInsets.symmetric(horizontal: widget.isHorizontal ? 30.r : 20.r, vertical: widget.isHorizontal ? 20.r : 10.r),
            ),
            child: Text(
              'Kembali',
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Segoe ui',
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ),
      ],
    );

    showDialog(context: context, builder: (context) => alert);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 || MediaQuery.of(context).orientation == Orientation.landscape) {
        return AppBar(
          backgroundColor: Colors.green[500],
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.exit_to_app),
            iconSize: 45.r,
            onPressed: () {
              handleLogout();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              iconSize: 45.r,
              onPressed: () {
                handleComing();
              },
            )
          ],
        );
      }

      return AppBar(
        backgroundColor: Colors.green[500],
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          iconSize: 28.r,
          onPressed: () {
            handleLogout();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            iconSize: 28.r,
            onPressed: () {
              handleComing();
            },
          )
        ],
      );
    });
  }
}
