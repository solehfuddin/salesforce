import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/pages/entry/newcust_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/areabanner.dart';
import 'package:sample/src/app/widgets/areafeature.dart';
import 'package:sample/src/app/widgets/areapoint.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:sample/src/app/widgets/areaheader.dart';
import 'package:shared_preferences/shared_preferences.dart';

String id = '';
String role = '';
String username = '';
String divisi = '';
String userUpper = '';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      userUpper = username.toUpperCase();
      divisi = preferences.getString("divisi");

      print("Dashboard : $role");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  checkSigned() async {
    String ttd = await getTtdValid(id, context);
    print(ttd);
    ttd == null
        ? handleSigned(context)
        : Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => NewcustScreen()));
  }

  checkCustomer() {
    Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => CustomerScreen(int.parse(id))));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(),
        body: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: [
            areaHeader(screenHeight, userUpper, context),
            areaPoint(screenHeight, context),
            _areaMenu(screenHeight),
            areaFeature(screenHeight, context),
            areaBanner(screenHeight, context),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  SliverToBoxAdapter _areaMenu(double screenHeight) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/entry_customer_new.png',
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                        Text(
                          'Customer',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    checkSigned();
                  },
                ),
                GestureDetector(
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/e_contract_new.png',
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                        Text(
                          'E-Contract',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    checkCustomer();
                  },
                ),
                GestureDetector(
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/performance_new.png',
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                        Text(
                          'Performance',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    handleComing(context);
                  },
                ),
                GestureDetector(
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/agenda_menu_new.png',
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                        Text(
                          'Agenda',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    handleComing(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
