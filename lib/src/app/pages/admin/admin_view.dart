import 'dart:convert';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/areacounter.dart';
import 'package:sample/src/app/widgets/areafeature.dart';
import 'package:sample/src/app/widgets/areamonitoring.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:sample/src/app/widgets/areaheader.dart';
import 'package:sample/src/domain/entities/monitoring.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

String id = '';
String role = '';
String username = '';
String divisi = '';
String userUpper = '';
var ttd;

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int totalWaiting = 0;
  int totalApproved = 0;
  int totalRejected = 0;

  @override
  void initState() {
    super.initState();
    getRole();
    getApprovedData();
    getRejectedData();
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      userUpper = username.toUpperCase();
      divisi = preferences.getString("divisi");
      divisi == "AR" ? getWaitingData(true) : getWaitingData(false);

      checkSigned();
    });
  }

  checkSigned() async {
    String ttd = await getTtdValid(id, context);
    print(ttd);
    if (ttd == null) {
      handleSigned(context);
    }
  }

  Future<List<Monitoring>> getMonitoringData() async {
    List<Monitoring> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/monitoring';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      list = rest.map<Monitoring>((json) => Monitoring.fromJson(json)).toList();
      print("List Size: ${list.length}");
    }

    return list;
  }

  getWaitingData(bool isAr) async {
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/customers/approvalSM?ttd_sales_manager=0'
        : 'http://timurrayalab.com/salesforce/server/api/customers/approvalAM?ttd_ar_manager=0';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      totalWaiting = data['count'];
      print('Waiting : $totalWaiting');

      setState(() {});
    }
  }

  getApprovedData() async {
    var url =
        'http://timurrayalab.com/salesforce/server/api/customers/approved';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      totalApproved = data['count'];
      print('Approve : $totalApproved');

      setState(() {});
    }
  }

  getRejectedData() async {
    var url =
        'http://timurrayalab.com/salesforce/server/api/customers/rejected';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      totalRejected = data['count'];
      print('Rejected : $totalRejected');

      setState(() {});
    }
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
            areaHeader(screenHeight, userUpper, context),
            areaCounter(totalWaiting.toString(), totalApproved.toString(),
                totalRejected.toString(), context),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoring Contract',
                      style: TextStyle(
                        fontSize: 23,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 400,
                      child: FutureBuilder(
                          future: getMonitoringData(),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Center(
                                    child: CircularProgressIndicator());
                              default:
                                return snapshot.data != null
                                    ? listViewWidget(
                                        snapshot.data, snapshot.data.length)
                                    : Column(
                                        children: [
                                          Center(
                                            child: Image.asset(
                                              'assets/images/not_found.png',
                                              width: 300,
                                              height: 300,
                                            ),
                                          ),
                                          Text(
                                            'Data tidak ditemukan',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red[600],
                                              fontFamily: 'Montserrat',
                                            ),
                                          )
                                        ],
                                      );
                            }
                          }),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: ArgonButton(
                        height: 40,
                        width: 130,
                        borderRadius: 30.0,
                        color: Colors.blue[600],
                        child: Text(
                          "More Data",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        loader: Container(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        onTap: (startLoading, stopLoading, btnState) {
                          if (btnState == ButtonState.Idle) {
                            // setState(() {
                            //   startLoading();
                            // });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            areaFeature(screenHeight, context),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget listViewWidget(List<Monitoring> item, int len) {
    return InkWell(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 15,
            ),
            itemBuilder: (context, position) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 7,),
                padding: EdgeInsets.all(
                  15,
                ),
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.black26,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item[position].namaUsaha,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Segoe Ui',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Segoe Ui',
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Contract',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              convertDateIndo(item[position].endDateContract),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Segoe Ui',
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
      ),
      // onTap: viewDetailContract(context, ),
    );
  }
}
