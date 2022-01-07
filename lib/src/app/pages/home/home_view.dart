import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/pages/entry/newcust_view.dart';
import 'package:sample/src/app/pages/signed/signed_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:sample/src/app/widgets/headerdashboard.dart';
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
            _areaPoint(screenHeight),
            _areaMenu(screenHeight),
            _areaFeature(screenHeight),
            _areaBanner(screenHeight),
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

  SliverToBoxAdapter _areaPoint(double screenHeight) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        // color: Colors.orange,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Points',
                            style: TextStyle(
                              fontFamily: 'Segoe ui',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontFamily: 'Segoe ui',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Image.asset(
                                'assets/images/point.png',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      handleComing(context);
                    },
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reward',
                            style: TextStyle(
                              fontFamily: 'Segoe ui',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Detail',
                                style: TextStyle(
                                  fontFamily: 'Segoe ui',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Image.asset(
                                'assets/images/reward.png',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      handleComing(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _areaBanner(double screenHeight) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Get rewarded with Challenges',
                style: TextStyle(
                  fontSize: 23,
                  fontFamily: 'Segoe ui',
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.all(8),
                height: screenHeight * 0.18,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      'assets/images/espresso.png',
                      width: 50,
                      height: 70,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Win a Coffe Challenge 5 Customers ..',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Ends on 14 Jan 2022',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Accept this challenge',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          handleComing(context);
        },
      ),
    );
  }

  SliverPadding _areaFeature(double screenHeight) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Digital signed',
              style: TextStyle(
                fontSize: 23,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(
                  15,
                ),
                height: screenHeight * 0.18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.black26,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          'assets/images/digital_sign.png',
                          width: 40,
                          height: 40,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set digital signed easily to save your',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            Text(
                              'time when approved new customer',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Center(
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // onTap: () => handleComing(context),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SignedScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
