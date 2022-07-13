import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/config.dart';
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
import 'package:sample/src/domain/entities/salesPerform.dart';
import 'package:sample/src/domain/entities/salesSize.dart';
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
  bool _isPerform = true;
  int totalWaiting = 0;
  int totalApproved = 0;
  int totalRejected = 0;
  int totalNewCustomer = 0;
  int totalOldCustomer = 0;
  List<Monitoring> listMonitoring = List.empty(growable: true);
  List<Contract> listContract = List.empty(growable: true);
  List<SalesPerform> listPerform = List.empty(growable: true);
  List<BarChartGroupData> rawBarGroups;
  List<BarChartGroupData> showingBarGroups;
  List<Report> _sampleData;
  List<PieReport> _samplePie = List.empty(growable: true);
  double width = 7;
  double _totalSales;
  Color leftBarColor = const Color(0xff845bef);
  List<Color> colorBar = List.empty(growable: true);
  String stDate = "01/04/2022";
  String edDate = "30/04/2022";
  String dateSelected = "01 Apr 2022 - 30 Apr 2022";
  dynamic totalSales;

  @override
  void initState() {
    super.initState();
    if (listContract.length > 0) listContract.clear();

    DateTime now = new DateTime.now();

    stDate = "01/${now.month}/${now.year}";
    edDate = "${now.day}/${now.month}/${now.year}";

    String dateSt = "${now.year}-${now.month.toString().padLeft(2, '0')}-01";
    String dateEd =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    dateSelected =
        "${convertDateWithMonth(dateSt)} - ${convertDateWithMonth(dateEd)}";

    colorBar.add(leftBarColor);

    final barGroup1 = makeGroupData(0, 10);
    final barGroup2 = makeGroupData(1, 12);
    final barGroup3 = makeGroupData(2, 14);
    final barGroup4 = makeGroupData(3, 19);
    final barGroup5 = makeGroupData(4, 15);
    final barGroup6 = makeGroupData(5, 13);
    final barGroup7 = makeGroupData(6, 18);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
    _sampleData = getReportData();
    //_samplePie = getReportPie();
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
      getPerformSales(stDate, edDate);

      getTtd(int.parse(id));
    });
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

        checkSigned();
        getMonitoringData();

        if (sts) {
          ttdPertama = data['data'][0]['ttd'];
          print(ttdPertama);
        }
        _isConnected = true;
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
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
    var url = '$API_URL/customers';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          totalNewCustomer = data['count'];
        }
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

  countOldCustomer() async {
    const timeout = 15;

    var url =
        '$API_URL/customers/oldCustomer';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          totalOldCustomer = data['total_row'];
        }
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

  getWaitingData(bool isAr) async {
    const timeout = 15;
    var url = !isAr
        ? '$API_URL/customers/approvalSM?ttd_sales_manager=0'
        : '$API_URL/customers/approvalAM?ttd_ar_manager=0';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          totalWaiting = data['count'];
          print('Waiting : $totalWaiting');

          setState(() {});
        }
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

  getApprovedData(bool isAr) async {
    const timeout = 15;
    var url = !isAr
        ? '$API_URL/customers/approvedSM'
        : '$API_URL/customers/approvedAM';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          totalApproved = data['count'];
          print('Approve : $totalApproved');

          setState(() {});
        }
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

  getRejectedData(bool isAr) async {
    const timeout = 15;
    var url = !isAr
        ? '$API_URL/customers/rejectedSM'
        : '$API_URL/customers/rejectedAM';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          totalRejected = data['count'];
          print('Rejected : $totalRejected');

          setState(() {});
        }
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

  getMonitoringData() async {
    _isLoading = true;

    await Future.delayed(Duration(seconds: 1));
    if (listMonitoring.length > 0) listMonitoring.clear();
    const timeout = 15;
    var url =
        '$API_URL/contract/monitoring';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          listMonitoring = rest
              .map<Monitoring>((json) => Monitoring.fromJson(json))
              .toList();
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
        ? '$API_URL/contract/pendingContractOldCustSM'
        : '$API_URL/contract/pendingContractOldCustAM';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
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

  List<PieReport> getReportPie() {
    final List<PieReport> dummy = [
      PieReport(
        salesName: "Sales A",
        perc: "30.5%",
        value: 20000,
        color: Color(0xff0293ee),
        size: "94%",
      ),
      PieReport(
        salesName: "Sales B",
        perc: "20.5%",
        value: 11000,
        color: Color(0xfff8b250),
        size: "91%",
      ),
      PieReport(
        salesName: "Sales C",
        perc: "14%",
        value: 4200,
        color: Color(0xff845bef),
        size: "88%",
      ),
      PieReport(
        salesName: "Sales D",
        perc: "35%",
        value: 28000,
        color: Color(0xff13d38e),
        size: "97%",
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
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
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
                      areaHeader(screenHeight, userUpper, context,
                          isHorizontal: true),
                      areaCounter(
                        totalWaiting.toString(),
                        totalApproved.toString(),
                        totalRejected.toString(),
                        totalNewCustomer.toString(),
                        totalOldCustomer.toString(),
                        context,
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
                          ? areaLoadingRenewal(isHorizontal: true,)
                          : areaDonutChartHor(
                              dataPie: _samplePie,
                              startDate: stDate,
                              endDate: edDate,
                              sales: listPerform,
                              totalSales: _totalSales,
                              context: context),
                      areaHeaderRenewal(isHorizontal: true),
                      _isLoadRenewal
                          ? areaLoadingRenewal(isHorizontal: true,)
                          : listContract.length > 0
                              ? areaRenewal(listContract, context, ttdPertama,
                                  username, divisi,
                                  isHorizontal: true)
                              : areaRenewalNotFound(
                                  context,
                                  isHorizontal: true,
                                ),
                      areaButtonRenewal(
                        context,
                        listContract.length > 0 ? true : false,
                        isHorizontal: true,
                      ),
                      areaHeaderMonitoring(isHorizontal: true),
                      _isLoading
                          ? areaLoading(isHorizontal: true,)
                          : listMonitoring.length > 0
                              ? areaMonitoring(
                                  listMonitoring,
                                  context,
                                  ttdPertama,
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
                    ],
                  ),
                  onRefresh: _refreshData,
                ),
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
                    areaHeader(screenHeight, userUpper, context,
                        isHorizontal: false),
                    areaCounter(
                      totalWaiting.toString(),
                      totalApproved.toString(),
                      totalRejected.toString(),
                      totalNewCustomer.toString(),
                      totalOldCustomer.toString(),
                      context,
                      isHorizontal: false,
                    ),
                    // areaChartDonuts(),
                    // areaChart(
                    //     rawBarGroups: rawBarGroups,
                    //     showingBarGroups: showingBarGroups),
                    // areaLineChartSync(reportData: _sampleData),
                    // areaPieChartSync(dataPie: _samplePie),
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
                        ? areaLoadingRenewal(isHorizontal: false,)
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
                    areaHeaderRenewal(isHorizontal: false),
                    _isLoadRenewal
                        ? areaLoadingRenewal(isHorizontal: false,)
                        : listContract.length > 0
                            ? areaRenewal(listContract, context, ttdPertama,
                                username, divisi,
                                isHorizontal: false)
                            : areaRenewalNotFound(
                                context,
                                isHorizontal: false,
                              ),
                    areaButtonRenewal(
                        context, listContract.length > 0 ? true : false,
                        isHorizontal: false),
                    areaHeaderMonitoring(isHorizontal: false),
                    _isLoading
                        ? areaLoading(isHorizontal: false,)
                        : listMonitoring.length > 0
                            ? areaMonitoring(
                                listMonitoring,
                                context,
                                ttdPertama,
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
                  ],
                ),
                onRefresh: _refreshData,
              ),
            );
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
