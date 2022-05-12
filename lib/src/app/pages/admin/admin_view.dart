import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/areachart.dart';
import 'package:sample/src/app/widgets/areacounter.dart';
import 'package:sample/src/app/widgets/areafeature.dart';
import 'package:sample/src/app/widgets/areamonitoring.dart';
import 'package:sample/src/app/widgets/arearenewal.dart';
import 'package:sample/src/app/widgets/areasyncchart.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:sample/src/app/widgets/areaheader.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/monitoring.dart';
import 'package:sample/src/domain/entities/piereport.dart';
import 'package:sample/src/domain/entities/report.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String id = '';
  String role = '';
  String username = '';
  String divisi = '';
  String ttdPertama;
  String userUpper = '';
  bool _isLoading = true;
  bool _isLoadRenewal = true;
  bool _isConnected = false;
  int totalWaiting = 0;
  int totalApproved = 0;
  int totalRejected = 0;
  int totalNewCustomer = 0;
  int totalOldCustomer = 0;
  List<Monitoring> listMonitoring = List.empty(growable: true);
  List<Contract> listContract = List.empty(growable: true);
  List<BarChartGroupData> rawBarGroups;
  List<BarChartGroupData> showingBarGroups;
  List<Report> _sampleData;
  List<PieReport> _samplePie;
  double width = 7;
  Color leftBarColor = const Color(0xff845bef);
  List<Color> colorBar = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    if (listContract.length > 0) listContract.clear();

    colorBar.add(leftBarColor);

    final barGroup1 = makeGroupData(0, 10);
    final barGroup2 = makeGroupData(1, 12);
    final barGroup3 = makeGroupData(2, 14);
    final barGroup4 = makeGroupData(3, 19);
    final barGroup5 = makeGroupData(4, 15);
    final barGroup6 = makeGroupData(5, 13);
    final barGroup7 = makeGroupData(6, 18);
    // final barGroup8 = makeGroupData(7, 15);
    // final barGroup9 = makeGroupData(8, 14);
    // final barGroup10 = makeGroupData(9, 12);
    // final barGroup11 = makeGroupData(10, 15);
    // final barGroup12 = makeGroupData(11, 10);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
      // barGroup8,
      // barGroup9,
      // barGroup10,
      // barGroup11,
      // barGroup12
    ];

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
    _sampleData = getReportData();
    _samplePie = getReportPie();
    getRole();
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
      divisi == "AR" ? getApprovedData(true) : getApprovedData(false);
      divisi == "AR" ? getRejectedData(true) : getRejectedData(false);
      divisi == "AR" ? getRenewalData(true) : getRenewalData(false);

      countNewCustomer();
      countOldCustomer();

      getTtd(int.parse(id));
    });
  }

  getTtd(int input) async {
    const timeout = 15;
    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      checkSigned();
      // countNewCustomer();
      // countOldCustomer();
      getMonitoringData();

      if (sts) {
        ttdPertama = data['data'][0]['ttd'];
        print(ttdPertama);
      }

      // divisi == "AR" ? getWaitingData(true) : getWaitingData(false);
      // divisi == "AR" ? getApprovedData(true) : getApprovedData(false);
      // divisi == "AR" ? getRejectedData(true) : getRejectedData(false);
      // divisi == "AR" ? getRenewalData(true) : getRenewalData(false);

      _isConnected = true;
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
      _isConnected = false;
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
      _isConnected = false;
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
      _isConnected = false;
    }
  }

  checkSigned() async {
    if (_isConnected) {
      String ttd = await getTtdValid(id, context, role: role);
      print(ttd);
      if (ttd == null) {
        handleSigned(context);
      }
    }
  }

  countNewCustomer() async {
    const timeout = 15;
    var url = 'http://timurrayalab.com/salesforce/server/api/customers';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status : ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        totalNewCustomer = data['count'];
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  countOldCustomer() async {
    const timeout = 15;

    var url =
        'http://timurrayalab.com/salesforce/server/api/customers/oldCustomer';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status : ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        totalOldCustomer = data['total_row'];
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  getWaitingData(bool isAr) async {
    const timeout = 15;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/customers/approvalSM?ttd_sales_manager=0'
        : 'http://timurrayalab.com/salesforce/server/api/customers/approvalAM?ttd_ar_manager=0';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        totalWaiting = data['count'];
        print('Waiting : $totalWaiting');

        setState(() {});
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  getApprovedData(bool isAr) async {
    const timeout = 15;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/customers/approvedSM'
        : 'http://timurrayalab.com/salesforce/server/api/customers/approvedAM';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        totalApproved = data['count'];
        print('Approve : $totalApproved');

        setState(() {});
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  getRejectedData(bool isAr) async {
    const timeout = 15;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/customers/rejectedSM'
        : 'http://timurrayalab.com/salesforce/server/api/customers/rejectedAM';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        totalRejected = data['count'];
        print('Rejected : $totalRejected');

        setState(() {});
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  getMonitoringData() async {
    _isLoading = true;

    await Future.delayed(Duration(seconds: 1));
    if (listMonitoring.length > 0) listMonitoring.clear();
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/monitoring';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        listMonitoring =
            rest.map<Monitoring>((json) => Monitoring.fromJson(json)).toList();
        print("List Size: ${listMonitoring.length}");
      }

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
      });
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  getRenewalData(bool isAr) async {
    _isLoadRenewal = true;

    const timeout = 15;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/contract/pendingContractOldCustSM'
        : 'http://timurrayalab.com/salesforce/server/api/contract/pendingContractOldCustAM';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        listContract =
            rest.map<Contract>((json) => Contract.fromJson(json)).toList();
        print("List Size: ${listContract.length}");
      }

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _isLoadRenewal = false;
        });
      });
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      if (listMonitoring.length > 0) listMonitoring.clear();
      if (listContract.length > 0) listContract.clear();
      divisi == "AR" ? getWaitingData(true) : getWaitingData(false);
      divisi == "AR" ? getApprovedData(true) : getApprovedData(false);
      divisi == "AR" ? getRejectedData(true) : getRejectedData(false);
      divisi == "AR" ? getRenewalData(true) : getRenewalData(false);

      countNewCustomer();
      countOldCustomer();

      getTtd(int.parse(id));
    });
  }

  BarChartGroupData makeGroupData(int x, double y1) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1,
        colors: colorBar,
        width: width,
      ),
    ]);
  }

  List<Report> getReportData() {
    final List<Report> sample = [
      Report(
          category: "Januari", sales1: 50, sales2: 30, sales3: 40, sales4: 20),
      Report(
          category: "Februari", sales1: 35, sales2: 25, sales3: 35, sales4: 30),
      Report(category: "Maret", sales1: 20, sales2: 40, sales3: 45, sales4: 35),
      Report(category: "April", sales1: 50, sales2: 35, sales3: 25, sales4: 40)
    ];
    return sample;
  }

  List<PieReport> getReportPie() {
    final List<PieReport> dummy = [
      PieReport(
        salesName: "Sales A",
        perc: "30.5%",
        value: 20000,
        color: Color(0xff0293ee),
      ),
      PieReport(
        salesName: "Sales B",
        perc: "20.5%",
        value: 11000,
        color: Color(0xfff8b250),
      ),
      PieReport(
        salesName: "Sales C",
        perc: "9%",
        value: 4200,
        color: Color(0xff845bef),
      ),
      PieReport(
        salesName: "Sales D",
        perc: "40%",
        value: 28000,
        color: Color(0xff13d38e),
      ),
    ];
    return dummy;
  }

  Future<bool> _onBackPressed() async {
    handleLogout(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(),
          body: RefreshIndicator(
            child: CustomScrollView(
              physics: ClampingScrollPhysics(),
              slivers: [
                areaHeader(screenHeight, userUpper, context),
                areaCounter(
                  totalWaiting.toString(),
                  totalApproved.toString(),
                  totalRejected.toString(),
                  totalNewCustomer.toString(),
                  totalOldCustomer.toString(),
                  context,
                ),
                areaChartDonuts(),
                areaChart(
                    rawBarGroups: rawBarGroups,
                    showingBarGroups: showingBarGroups),
                areaLineChartSync(reportData: _sampleData),
                areaPieChartSync(dataPie: _samplePie),
                areaHeaderRenewal(),
                _isLoadRenewal
                    ? areaLoadingRenewal()
                    : listContract.length > 0
                        ? areaRenewal(
                            listContract, context, ttdPertama, username, divisi)
                        : areaRenewalNotFound(context),
                areaButtonRenewal(
                    context, listContract.length > 0 ? true : false),
                areaHeaderMonitoring(),
                _isLoading
                    ? areaLoading()
                    : listMonitoring.length > 0
                        ? areaMonitoring(
                            listMonitoring,
                            context,
                            ttdPertama,
                            username,
                            divisi,
                          )
                        : areaMonitoringNotFound(context),
                areaButtonMonitoring(
                    context, listMonitoring.length > 0 ? true : false),
                areaFeature(screenHeight, context),
              ],
            ),
            onRefresh: _refreshData,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
