import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget with PreferredSizeWidget {
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
          // onPressed: () => Navigator.of(context).pop(),
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
            fontSize: 20,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: Container(
        child: Image.asset(
          'assets/images/coming_soon.png',
          width: 80,
          height: 80,
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
              primary: Colors.indigo[600],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Kembali',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Segoe ui',
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              // Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );

    showDialog(context: context, builder: (context) => alert);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green[500],
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(Icons.exit_to_app),
        iconSize: 28,
        onPressed: () {
          handleLogout();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          iconSize: 28,
          onPressed: () {
            handleComing();
          },
        )
      ],
    );
  }
}
