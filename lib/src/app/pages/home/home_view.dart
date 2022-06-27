import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/areabanner.dart';
import 'package:sample/src/app/widgets/areafeature.dart';
import 'package:sample/src/app/widgets/areamenu.dart';
import 'package:sample/src/app/widgets/areamonitoring.dart';
import 'package:sample/src/app/widgets/areapoint.dart';
import 'package:sample/src/app/widgets/arearenewal.dart';
import 'package:sample/src/app/widgets/areasyncchart.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:sample/src/app/widgets/areaheader.dart';
import 'package:sample/src/domain/entities/monitoring.dart';
import 'package:sample/src/domain/entities/piereport.dart';
import 'package:sample/src/domain/entities/salesPerform.dart';
import 'package:sample/src/domain/entities/salesSize.dart';
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
  bool _isConnected = false;
  bool _isPerform = true;
  List<Monitoring> listMonitoring = List.empty(growable: true);
  List<SalesPerform> listPerform = List.empty(growable: true);
  List<PieReport> _samplePie = List.empty(growable: true);
  String stDate = "01/04/2022";
  String edDate = "30/04/2022";
  String dateSelected = "01 Apr 2022 - 30 Apr 2022";
  double _totalSales;
  dynamic totalSales;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      userUpper = username.toUpperCase();
      divisi = preferences.getString("divisi");

      getPerformSales(stDate, edDate);

      print("Dashboard : $role");
      getTtd(int.parse(id));
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();

    DateTime now = new DateTime.now();

    stDate = "01/${now.month}/${now.year}";
    edDate = "${now.day}/${now.month}/${now.year}";

    String dateSt = "${now.year}-${now.month.toString().padLeft(2, '0')}-01";
    String dateEd =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    dateSelected =
        "${convertDateWithMonth(dateSt)} - ${convertDateWithMonth(dateEd)}";
  }

  getTtd(int input) async {
    const timeout = 15;
    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          ttdSales = data['data'][0]['ttd'];
          print(ttdSales);
        }

        getMonitoringSales(input);
        _isConnected = true;
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
      _isConnected = false;
    } on SocketException catch (e) {
      print('Socker Error : $e');
      handleSocket(context);
      _isConnected = false;
    } on Error catch (e) {
      print('Error : $e');
      _isConnected = false;
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

    try {
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
    } on FormatException catch (e) {
      print('Format Error : $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      getTtd(int.parse(id));
    });
  }

  Future<bool> _onBackPressed() async {
    handleLogout(context);
    return false;
  }

  getPerformSales(String stDate, String edDate) async {
    _samplePie.clear();
    listPerform.clear();
    _isPerform = true;

    const timeout = 15;
    var url =
        'https://timurrayalab.com/salesforce/server/api/performance?from=$stDate&to=$edDate';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          listPerform = rest
              .map<SalesPerform>((json) => SalesPerform.fromJson(json))
              .toList();
          print("List Size: ${listPerform.length}");

          print('Total Sales : ${data['total_penjualan']}');

          _totalSales = double.tryParse(
              data['total_penjualan'].replaceAll(RegExp(','), ''));
          print('Total Sales Convert : $_totalSales');

          _samplePie = generateReport(_totalSales);
        }

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isPerform = false;
          });
        });
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  List<PieReport> generateReport(double totalSales) {
    List<PieReport> dummy = List.empty(growable: true);

    List<Color> colorList = [
      Colors.green[500],
      Colors.deepOrange[400],
      Colors.grey[500],
      Colors.blue[500],
      Colors.red[500],
      Colors.purple[400],
      Colors.teal[500],
    ];

    List<SalesPerform> newListPerform = List.empty(growable: true);
    List<SalesSize> salesSize = List.empty(growable: true);
    newListPerform.addAll(listPerform);

    newListPerform.sort((a, b) {
      double aVal = double.tryParse(a.penjualan);
      double bVal = double.tryParse(b.penjualan);
      return bVal.compareTo(aVal);
    });

    dynamic initialSize = 93;
    for (int j = 0; j < newListPerform.length; j++) {
      initialSize -= 3;
      salesSize.add(SalesSize(
        salesRepId: newListPerform[j].salesRepId,
        size: '$initialSize%',
        salesPerson: newListPerform[j].salesPerson,
        penjualan: newListPerform[j].penjualan,
      ));
      print('Percentnya : ${newListPerform[j].penjualan}');
      print('Sizenya : $initialSize');
    }

    for (int i = 0; i < listPerform.length; i++) {
      double value = double.tryParse(listPerform[i].penjualan);
      double perc = (value / totalSales * 100);
      dynamic size;

      for (int j = 0; j < salesSize.length; j++) {
        if (salesSize[j].salesRepId == listPerform[i].salesRepId) {
          size = salesSize[j].size;
          print('Size new : $size');
        }
      }

      dummy.add(PieReport(
        salesName: listPerform[i].salesPerson,
        value: value,
        perc: "${perc.toStringAsFixed(2)} %",
        color: colorList[i],
        size: size,
      ));

      print("Hitung persen ${[i]}: $perc");
    }

    return dummy;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: _onBackPressed,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600 ||
                MediaQuery.of(context).orientation == Orientation.landscape) {
              return Scaffold(
                appBar: CustomAppBar(
                  isHorizontal: true,
                ),
                body: RefreshIndicator(
                    child: CustomScrollView(
                      physics: ClampingScrollPhysics(),
                      slivers: [
                        areaHeader(
                          screenHeight,
                          userUpper,
                          context,
                          isHorizontal: true,
                        ),
                        areaPoint(
                          screenHeight * 1.8,
                          context,
                          isHorizontal: true,
                        ),
                        areaMenu(
                          screenHeight,
                          context,
                          id,
                          role,
                          isConnected: _isConnected,
                          isHorizontal: true,
                        ),
                        SliverPadding(
                          padding: EdgeInsets.only(
                            left: 35.r,
                            right: 35.r,
                            top: 15.r,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter state) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Penjualan',
                                          style: TextStyle(
                                            fontSize: 35.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.blue,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 3,
                                              horizontal: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.black54,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(dateSelected),
                                                Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.black54,
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            showDate(context).then((value) {
                                              state(() {
                                                if (value != null) {
                                                  String dateSt =
                                                      value.start.toString();
                                                  String dateEd =
                                                      value.end.toString();

                                                  dateSelected =
                                                      "${convertDateWithMonth(dateSt)} - ${convertDateWithMonth(dateEd)}";
                                                  print(
                                                      "Date Selected Start : ${convertDateOra(dateSt)}");
                                                  print(
                                                      "Date Selected End : ${convertDateOra(dateEd)}");
                                                  print(
                                                      "Date Selected UI : $dateSelected");

                                                  stDate =
                                                      convertDateOra(dateSt);
                                                  edDate =
                                                      convertDateOra(dateEd);

                                                  getPerformSales(
                                                      stDate, edDate);

                                                  setState(() {});
                                                } else {
                                                  print('Cancel');
                                                }
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        _isPerform
                            ? areaLoadingRenewal(
                                isHorizontal: true,
                              )
                            : areaDonutChartHor(
                                dataPie: _samplePie,
                                startDate: stDate,
                                endDate: edDate,
                                sales: listPerform,
                                totalSales: _totalSales,
                                context: context),
                        areaHeaderMonitoring(isHorizontal: true),
                        _isLoading
                            ? areaLoading(isHorizontal: true,)
                            : listMonitoring.length > 0
                                ? areaMonitoring(
                                    listMonitoring,
                                    context,
                                    ttdSales,
                                    username,
                                    divisi,
                                    isHorizontal: true,
                                  )
                                : areaMonitoringNotFound(
                                    context,
                                    isHorizontal: true,
                                  ),
                        areaButtonMonitoring(
                          context,
                          listMonitoring.length > 0 ? true : false,
                          isHorizontal: true,
                        ),
                        areaFeature(
                          screenHeight,
                          context,
                          isHorizontal: true,
                        ),
                        areaBanner(
                          screenHeight,
                          context,
                          isHorizontal: true,
                        ),
                      ],
                    ),
                    onRefresh: _refreshData),
              );
            }

            return Scaffold(
              appBar: CustomAppBar(
                isHorizontal: false,
              ),
              body: RefreshIndicator(
                child: CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  slivers: [
                    areaHeader(
                      screenHeight,
                      userUpper,
                      context,
                      isHorizontal: false,
                    ),
                    areaPoint(
                      screenHeight,
                      context,
                      isHorizontal: false,
                    ),
                    areaMenu(
                      screenHeight,
                      context,
                      id,
                      role,
                      isConnected: _isConnected,
                      isHorizontal: false,
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: 15.r,
                        right: 15.r,
                        top: 15.r,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: StatefulBuilder(
                          builder: (BuildContext context, StateSetter state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Penjualan',
                                      style: TextStyle(
                                        fontSize: 21.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.blue,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(dateSelected),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        showDate(context).then((value) {
                                          state(() {
                                            if (value != null) {
                                              String dateSt =
                                                  value.start.toString();
                                              String dateEd =
                                                  value.end.toString();

                                              dateSelected =
                                                  "${convertDateWithMonth(dateSt)} - ${convertDateWithMonth(dateEd)}";
                                              print(
                                                  "Date Selected Start : ${convertDateOra(dateSt)}");
                                              print(
                                                  "Date Selected End : ${convertDateOra(dateEd)}");
                                              print(
                                                  "Date Selected UI : $dateSelected");

                                              stDate = convertDateOra(dateSt);
                                              edDate = convertDateOra(dateEd);

                                              getPerformSales(stDate, edDate);

                                              setState(() {});
                                            } else {
                                              print('Cancel');
                                            }
                                          });
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    _isPerform
                        ? areaLoadingRenewal(
                            isHorizontal: false,
                          )
                        : areaDonutChart(
                            dataPie: _samplePie,
                            startDate: stDate,
                            endDate: edDate),
                    areaInfoDonut(
                      sales: listPerform,
                      totalSales: _totalSales,
                      context: context,
                      stDate: stDate,
                      edDate: edDate,
                    ),
                    areaHeaderMonitoring(
                      isHorizontal: false,
                    ),
                    _isLoading
                        ? areaLoading(isHorizontal: false,)
                        : listMonitoring.length > 0
                            ? areaMonitoring(
                                listMonitoring,
                                context,
                                ttdSales,
                                username,
                                divisi,
                                isHorizontal: false,
                              )
                            : areaMonitoringNotFound(
                                context,
                                isHorizontal: false,
                              ),
                    areaButtonMonitoring(
                      context,
                      listMonitoring.length > 0 ? true : false,
                      isHorizontal: false,
                    ),
                    areaFeature(
                      screenHeight,
                      context,
                      isHorizontal: false,
                    ),
                    areaBanner(
                      screenHeight,
                      context,
                      isHorizontal: false,
                    ),
                  ],
                ),
                onRefresh: _refreshData,
              ),
            );
          },
        ),
      ),
    );
  }
}
