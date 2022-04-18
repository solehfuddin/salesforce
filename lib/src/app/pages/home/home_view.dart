import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/areabanner.dart';
import 'package:sample/src/app/widgets/areafeature.dart';
import 'package:sample/src/app/widgets/areamenu.dart';
import 'package:sample/src/app/widgets/areamonitoring.dart';
import 'package:sample/src/app/widgets/areapoint.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:sample/src/app/widgets/areaheader.dart';
import 'package:sample/src/domain/entities/monitoring.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String id = '';
  String role = '';
  String username = '';
  String divisi = '';
  String userUpper = '';
  String ttdSales;
  bool _isLoading = true;
  List<Monitoring> listMonitoring = List.empty(growable: true);

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      userUpper = username.toUpperCase();
      divisi = preferences.getString("divisi");

      getMonitoringSales(int.tryParse(id));
      print("Dashboard : $role");
      getTtd(int.parse(id));
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  getTtd(int input) async {
    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      ttdSales = data['data'][0]['ttd'];
      print(ttdSales);
    }
  }

  getMonitoringSales(int idSales) async {
    _isLoading = true;
    
    await Future.delayed(Duration(seconds: 1));
    if (listMonitoring.length > 0) listMonitoring.clear();

    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/salesMonitoring?id=$idSales';
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

  Future<void> _refreshData() async {
    setState(() {
      getMonitoringSales(int.tryParse(id));
      getTtd(int.parse(id));
    });
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
          appBar: CustomAppBar(),
          body: RefreshIndicator(
            child: CustomScrollView(
              physics: ClampingScrollPhysics(),
              slivers: [
                areaHeader(screenHeight, userUpper, context),
                areaPoint(screenHeight, context),
                areaMenu(screenHeight, context, id),
                areaHeaderMonitoring(),
                _isLoading
                    ? areaLoading()
                    : listMonitoring.length > 0
                        ? areaMonitoring(
                            listMonitoring, context, ttdSales, username, divisi)
                        : areaMonitoringNotFound(context),
                areaButtonMonitoring(
                    context, listMonitoring.length > 0 ? true : false),
                areaFeature(screenHeight, context),
                areaBanner(screenHeight, context),
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
