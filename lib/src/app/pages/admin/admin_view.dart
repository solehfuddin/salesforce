import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

String role = '';
String username = '';

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
      username = preferences.getString("username");
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("islogin", false);
    await preferences.setString("role", null);
    await Future.delayed(const Duration(seconds: 1), () {});
    SystemNavigator.pop();
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
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(),
        body: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: [
            _areaHeader(screenHeight),
            _areaCounter(),
            _areaFeature(screenHeight),
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

  SliverPadding _areaCounter() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black26,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'New Customer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: Text(
                              '50',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => handleComing(),
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
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black26,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Total Customer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: Text(
                              '18.750',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => handleComing(),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black26,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '3',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Segoe ui',
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_outlined,
                                size: 13,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Waiting',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => handleComing(),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black26,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '10',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Segoe ui',
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_outlined,
                                size: 13,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Approved',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => handleComing(),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black26,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Segoe ui',
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_outlined,
                                size: 13,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Rejected',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.red[700],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => handleComing(),
                  ),
                ),
              ],
            ),
          ],
        ),
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
                          'assets/images/e_contract_new.png',
                          width: 30,
                          height: 30,
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
              onTap: () => handleComing(),
            ),
          ],
        ),
      ),
    );
  }
}
