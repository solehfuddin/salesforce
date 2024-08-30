import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/pages/notification/notif_view.dart';
import 'package:sample/src/app/widgets/mybadge.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  bool isHorizontal;
  bool isBadge;

  CustomAppBar({this.isHorizontal = false, this.isBadge = false});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("islogin", false);
    await preferences.setString("role", '');
    await Future.delayed(const Duration(seconds: 2), () {});
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return AppBar(
          backgroundColor: Colors.green[500],
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.exit_to_app),
            iconSize: 28.r,
            onPressed: () {
              handleLogout(context);
            },
          ),
          actions: [
            widget.isBadge
                ? MyBadge(
                    top: 21.r,
                    right: 18.r,
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications,
                        size: 28.r,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NotifScreen(),
                          ),
                        );
                      },
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.notifications),
                    iconSize: 28.r,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NotifScreen(),
                        ),
                      );
                    },
                  ),
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
            handleLogout(context);
          },
        ),
        actions: [
          widget.isBadge
              ? MyBadge(
                  top: 21.r,
                  right: 19.r,
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications,
                      size: 28.r,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => NotifScreen(),
                        ),
                      );
                    },
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.notifications),
                  iconSize: 28.r,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => NotifScreen(),
                      ),
                    );
                  },
                ),
        ],
      );
    });
  }
}
