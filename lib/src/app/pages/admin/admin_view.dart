import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/areacounter.dart';
import 'package:sample/src/app/widgets/areafeature.dart';
import 'package:sample/src/app/widgets/areamonitoring.dart';
import 'package:sample/src/app/widgets/arearenewal.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:sample/src/app/widgets/areaheader.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/monitoring.dart';
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
  int totalWaiting = 0;
  int totalApproved = 0;
  int totalRejected = 0;
  int totalNewCustomer = 0;
  int totalOldCustomer = 0;
  List<Monitoring> listMonitoring = List.empty(growable: true);
  List<Contract> listContract = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    if (listContract.length > 0) listContract.clear();

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

      checkSigned();
      countNewCustomer();
      countOldCustomer();

      getTtd(int.parse(id));
      getMonitoringData();
    });
  }

  getTtd(int input) async {
    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      ttdPertama = data['data'][0]['ttd'];
      print(ttdPertama);
    }
  }

  checkSigned() async {
    String ttd = await getTtdValid(id, context);
    print(ttd);
    if (ttd == null) {
      handleSigned(context);
    }
  }

  countNewCustomer() async {
    var url = 'http://timurrayalab.com/salesforce/server/api/customers';
    var response = await http.get(url);

    print('Response status : ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      totalNewCustomer = data['count'];
    }
  }

  countOldCustomer() async {
    var url =
        'http://timurrayalab.com/salesforce/server/api/customers/oldCustomer';
    var response = await http.get(url);

    print('Response status : ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      totalOldCustomer = data['total_row'];
    }
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

  getApprovedData(bool isAr) async {
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/customers/approvedSM'
        : 'http://timurrayalab.com/salesforce/server/api/customers/approvedAM';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      setState(() {
        totalApproved = data['count'];
        print('Approve : $totalApproved');
      });
    }
  }

  getRejectedData(bool isAr) async {
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/customers/rejectedSM'
        : 'http://timurrayalab.com/salesforce/server/api/customers/rejectedAM';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      setState(() {
        totalRejected = data['count'];
        print('Rejected : $totalRejected');
      });
    }
  }

  getMonitoringData() async {
    _isLoading = true;

    await Future.delayed(Duration(seconds: 1));
    if (listMonitoring.length > 0) listMonitoring.clear();

    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/monitoring';
    var response = await http.get(url);

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
  }

  getRenewalData(bool isAr) async {
    _isLoadRenewal = true;

    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/contract/pendingContractOldCustSM'
        : 'http://timurrayalab.com/salesforce/server/api/contract/pendingContractOldCustAM';
    var response = await http.get(url);

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
  }

  Future<void> _refreshData() async {
    setState(() {
      if (listMonitoring.length > 0) listMonitoring.clear();
      if (listContract.length > 0) listContract.clear();

      divisi == "AR" ? getWaitingData(true) : getWaitingData(false);
      divisi == "AR" ? getApprovedData(true) : getApprovedData(false);
      divisi == "AR" ? getRejectedData(true) : getRejectedData(false);
      divisi == "AR" ? getRenewalData(true) : getRenewalData(false);
      getMonitoringData();
      getTtd(int.parse(id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
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
                          listMonitoring, context, ttdPertama, username, divisi)
                      : areaMonitoringNotFound(context),
              areaButtonMonitoring(
                  context, listMonitoring.length > 0 ? true : false),
              areaFeature(screenHeight, context),
            ],
          ),
          onRefresh: _refreshData,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
