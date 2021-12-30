import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

String role = '';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      role = preferences.getString("role");
      print("Dashboard : $role");
    });
  }

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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );

    showDialog(context: context, builder: (context) => alert);
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100,
                padding: EdgeInsets.symmetric(vertical: 35, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Text(
                  'Digitalisasi data anda dengan sales force',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Segoe ui',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Center(
        //   child: GestureDetector(
        //     onTap: () {
        //       handleLogout();
        //     },
        //     child: Text(
        //       role
        //     ),
        //   ),
        // ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
