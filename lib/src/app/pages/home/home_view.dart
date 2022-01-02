import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/entry/newcust_view.dart';
// import 'package:flutter/services.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

String role = '';
String username = '';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      role = preferences.getString("role");
      username = preferences.getString("username");

      print("Dashboard : $role");
    });
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
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );

    showDialog(context: context, builder: (context) => alert);
  }

  handleEntryCust() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewcustScreen()));
  }

  @override
  void initState() {
    super.initState();
    getRole();
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
            _areaHeader(screenHeight),
            _areaPoint(screenHeight),
            _areaMenu(screenHeight),
            _areaBanner(screenHeight),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  SliverToBoxAdapter _areaHeader(double screenHeight) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.green[500],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hi, $username',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    handleComing();
                  },
                  icon: Icon(Icons.account_circle),
                  label: Text('Profile'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey[600],
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      )),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            Column(
              children: [
                Text(
                  'Digitalisasi data customer, monitoring e-kontrak dan kinerja menjadi lebih mudah dan efisien',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _areaMenu(double screenHeight) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        // color: Colors.orange,
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
                    handleEntryCust();
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
                    handleComing();
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
                    handleComing();
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
                    handleComing();
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
                      handleComing();
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
                      handleComing();
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
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Get rewarded with Challenges',
                style: TextStyle(
                  fontSize: 20,
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
          handleComing();
        },
      ),
    );
  }
}
