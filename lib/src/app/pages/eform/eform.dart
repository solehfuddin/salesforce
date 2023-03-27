import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/staff/staff_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EformScreen extends StatefulWidget {
  const EformScreen({Key? key}) : super(key: key);

  @override
  State<EformScreen> createState() => _EformScreenState();
}

class _EformScreenState extends State<EformScreen> {
  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  @override
  Widget build(BuildContext context) {
    return childWidget();
  }

  Widget childWidget() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'E-Form',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (role == 'ADMIN') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminScreen()));
            } else if (role == 'SALES') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            } else {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => StaffScreen()));
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: Colors.black54,
          ),
        ),
      ),
      body: WebView(
        initialUrl: "https://timurrayalab.com/e-form",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
