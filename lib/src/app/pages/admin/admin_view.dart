import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

String role = '';
class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    getRole();
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      role = preferences.getString("role");
    });
  }

  signOut() async {
   SharedPreferences preferences = await SharedPreferences.getInstance();
   await preferences.setBool("islogin", false);
   await preferences.setString("role", null);
   await Future.delayed(const Duration(seconds: 1), (){});
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );

    showDialog(context: context, builder: (context) => alert);
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: GestureDetector(
            onTap: () {
              handleLogout();
            },
            child: Text(
              role
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}