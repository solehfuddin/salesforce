import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/src/app/pages/attendance/attendance_prominent.dart';
import 'package:sample/src/app/pages/attendance/attendance_service.dart';
import 'package:sample/src/app/pages/customer/customer_admin.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/mylocation.dart';
import 'package:sample/src/app/widgets/areacounter.dart';
import 'package:sample/src/app/widgets/areafeature.dart';
import 'package:sample/src/app/widgets/areaheader.dart';
import 'package:sample/src/app/widgets/areamarketing.dart';
import 'package:sample/src/app/widgets/areamenu.dart';
import 'package:sample/src/app/widgets/areamonitoring.dart';
import 'package:sample/src/app/widgets/areanewcustrenewal.dart';
import 'package:sample/src/app/widgets/arearenewal.dart';
import 'package:sample/src/app/widgets/areasyncchart.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/monitoring.dart';
import 'package:sample/src/domain/entities/piereport.dart';
import 'package:sample/src/domain/entities/salesPerform.dart';
import 'package:sample/src/domain/entities/salesSize.dart';
import 'package:sample/src/domain/service/service_marketingexpense.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/service/service_training.dart';

class AdminContent extends StatefulWidget {
  const AdminContent({Key? key}) : super(key: key);

  @override
  State<AdminContent> createState() => _AdminContentState();
}

class _AdminContentState extends State<AdminContent> {
  ServicePosMaterial servicePosMaterial = new ServicePosMaterial();
  ServiceMarketingExpense serviceME = new ServiceMarketingExpense();
  ServiceTraining serviceTraining = new ServiceTraining();
  List<Contract> listContract = List.empty(growable: true);
  List<Contract> listNewContract = List.empty(growable: true);
  List<Monitoring> listMonitoring = List.empty(growable: true);
  List<PieReport> _samplePie = List.empty(growable: true);
  List<SalesPerform> listPerform = List.empty(growable: true);
  MyLocation _myLocation = MyLocation();
  late SharedPreferences preferences;

  String? id = '';
  String? role = '';
  String? name = '';
  String? username = '';
  String? divisi = '';
  String? ttdPertama = '';
  String? userUpper = '';
  double screenHeight = 0;
  bool _isLoading = true;
  bool _isLoadRenewal = true;
  bool _isLoadNewcustRenewal = true;
  bool? isProminentAccess = false;
  bool isPermissionCamera = false;
  bool isLocationService = false;
  bool isPermissionService = false;
  bool _hidePerform = false;
  // bool _isPerform = true;

  String stDate = "01/04/2022";
  String edDate = "30/04/2022";
  String dateSelected = "01 Apr 2022 - 30 Apr 2022";

  double _totalSales = 0;
  dynamic totalSales;
  int totalWaiting = 0;
  int totalApproved = 0;
  int totalRejected = 0;
  int totalNewCustomer = 0;
  int totalOldCustomer = 0;
  int totalPosMaterial = 0;
  int totalMarketingExpense = 0;
  int totalTraining = 0;
  int totalCashbackWaiting = 0;
  int totalCashbackApprove = 0;
  int totalCashbackReject = 0;
  bool showAreaMarketing = false;

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

    getRole();
    checkPermission();
  }

  getRole() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      name = preferences.getString("name");
      username = preferences.getString("username");
      userUpper = username?.toUpperCase();
      divisi = preferences.getString("divisi");
      ttdPertama = preferences.getString("ttduser") ?? '';
      isProminentAccess = preferences.getBool("check_prominent") ?? false;

      divisi == "AR" ? getCounterData(true) : getCounterData(false);
      divisi == "AR" ? getRenewalData(true) : getRenewalData(false);
      divisi == "AR"
          ? getNewcustRenewalData(true)
          : getNewcustRenewalData(false);

      getPerformSales(stDate, edDate);

      getMonitoringData();

      print("Dashboard : $role");
      print("TTD Sales : $ttdPertama");
      print("Id user : $id");

      if (role == 'ADMIN' && divisi == 'SALES') {
        servicePosMaterial
            .getPosMaterialDashboard(
              mounted,
              context,
              idManager: int.parse(id!),
              isBrandManager: false,
              status: 0,
            )
            .then((value) => totalPosMaterial = value.total!);

        serviceME
            .getMEDashboard(mounted, context,
                idManager: int.parse(id!), status: 0)
            .then((value) {
          totalMarketingExpense = value.total!;
          print("Total Me : $totalMarketingExpense");
        });

        serviceTraining.getHeader(
          mounted,
          context,
          idManager: int.parse(id!),
          status: 0,
        ).then((value) {
          totalTraining = value.total!;
          print("Total Training : $totalTraining");
        });
      }

      if (role == 'ADMIN' && divisi == 'MARKETING') {
        servicePosMaterial
            .getPosMaterialDashboard(
              mounted,
              context,
              idManager: 0,
              isBrandManager: true,
              status: 0,
            )
            .then((value) => totalPosMaterial = value.total!);
          
        serviceTraining.getHeaderManager(mounted, context, status: 0).then((value) {
          totalTraining = value.total!;
          print("Total Training : $totalTraining");
        });
      }

      if (role == 'ADMIN' && divisi == 'GM') {
        servicePosMaterial
            .getPosMaterialDashboard(
              mounted,
              context,
              idManager: 0,
              isBrandManager: false,
              status: 0,
            )
            .then((value) => totalPosMaterial = value.total!);

        serviceME
            .getMEDashboard(mounted, context,
                idGeneral: int.parse(id!), status: 0)
            .then((value) {
          totalMarketingExpense = value.total!;
          print("Total Me : $totalMarketingExpense");
        });
      }

      switch (divisi) {
        case 'AR':
        case 'PGA':
        case 'IT':
        case 'SAM':
          showAreaMarketing = false;
          break;
        default:
          showAreaMarketing = true;
          break;
      }
    });
  }

  void checkPermission() async {
    isPermissionService = await _myLocation.isPermissionEnable();
    setState(() {
      if (!isProminentAccess!) {
        dialogProminentService(context);
      } else {
        checkService();
      }
    });
  }

  void checkService() async {
    isLocationService = await _myLocation.isServiceEnable();
    setState(() {
      if (isPermissionService && isLocationService) {
        print('Granted');
      } else {
        dialogLocationService(context);
      }
    });
  }

  dialogLocationService(BuildContext context) {
    return showModalBottomSheet(
      elevation: 2,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (context) {
        return AttendanceService();
      },
    );
  }

  dialogProminentService(BuildContext context) {
    return showModalBottomSheet(
      elevation: 2,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (context) {
        return AttendanceProminent();
      },
    ).whenComplete(
      () async {
        preferences.setBool("check_prominent", true);

        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;

          if (androidInfo.version.sdkInt < 33) {
            await [
              Permission.camera,
              Permission.microphone,
              Permission.storage,
              Permission.notification,
            ].request();
          } else {
            await [
              Permission.camera,
              Permission.microphone,
              Permission.photos,
            ].request().then((value) => openAppSettings());
          }
        }
        // checkService();
      },
    );
  }

  getCounterData(bool isAr) async {
    const timeout = 15;
    var url = divisi == "AR"
        ? '$API_URL/counter/counter/'
        : '$API_URL/counter/counter/$id';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];
        dynamic counter = data['data'];

        if (sts) {
          print(counter);

          totalNewCustomer = counter['newCust'];
          totalOldCustomer = counter['oldCust'];
          totalWaiting = isAr ? counter['awaitAR'] : counter['awaitSM'];
          totalApproved = isAr ? counter['approvedAR'] : counter['approvedSM'];
          totalRejected = isAr ? counter['rejectedAR'] : counter['rejectedSM'];

          totalCashbackWaiting = divisi == 'GM'
              ? counter['awaitCashbackGM']
              : counter['awaitCashbackSM'];
          totalCashbackApprove = divisi == 'GM'
              ? counter['approvedCashbackGM']
              : counter['approvedCashbackSM'];
          totalCashbackReject = divisi == 'GM'
              ? counter['rejectedCashbackGM']
              : counter['rejectedCashbackSM'];

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

  getRenewalData(bool isAr) async {
    _isLoadRenewal = true;

    const timeout = 15;
    var url = !isAr
        ? '$API_URL/contract/pendingContractOldCustSM?id_manager=$id'
        : '$API_URL/contract/pendingContractOldCustAM?id_customer';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
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

          if (listContract.length > 3) {
            listContract.removeRange(3, listContract.length);
          }
        }

        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isLoadRenewal = false;
            });
          }
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

  getNewcustRenewalData(bool isAr) async {
    if (listNewContract.length > 0) listNewContract.clear();
    _isLoadNewcustRenewal = true;

    const timeout = 15;
    var url = !isAr
        ? '$API_URL/contract/pendingContractNewCustSM?id_manager=$id'
        : '$API_URL/contract/pendingContractNewCustAM';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print("Renewal Kontrak: $rest");

          listNewContract =
              rest.map<Contract>((json) => Contract.fromJson(json)).toList();
          print("List Renewal Kontrak: ${listNewContract.length}");

          if (listNewContract.length > 3) {
            listNewContract.removeRange(3, listNewContract.length);
          }
        }

        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isLoadNewcustRenewal = false;
            });
          }
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

  getMonitoringData() async {
    _isLoading = true;

    await Future.delayed(Duration(seconds: 1));
    if (listMonitoring.length > 0) listMonitoring.clear();
    const timeout = 15;
    var idSm;
    divisi == "AR" ? idSm = '' : idSm = id;
    var url = '$API_URL/contract/monitoring?id_salesmanager=$idSm';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
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

          if (listMonitoring.length > 3) {
            listMonitoring.removeRange(3, listMonitoring.length);
          }
        }

        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
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
    // _isPerform = true;

    const timeout = 15;
    var url = '$API_URL/performance?from=$stDate&to=$edDate';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
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
              data['total_penjualan'].replaceAll(RegExp(','), ''))!;
          print('Total Sales Convert : $_totalSales');

          _samplePie = generateReport(_totalSales);
          _hidePerform = false;
        } else {
          _hidePerform = true;
        }

        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              // _isPerform = false;
            });
          }
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
      Colors.green[500]!,
      Colors.deepOrange[400]!,
      Colors.grey[500]!,
      Colors.blue[500]!,
      Colors.red[500]!,
      Colors.purple[400]!,
      Colors.teal[500]!,
    ];

    List<SalesPerform> newListPerform = List.empty(growable: true);
    List<SalesSize> salesSize = List.empty(growable: true);
    newListPerform.addAll(listPerform);

    newListPerform.sort((a, b) {
      double aVal = double.tryParse(a.penjualan)!;
      double bVal = double.tryParse(b.penjualan)!;
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
      double value = double.tryParse(listPerform[i].penjualan)!;
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

  Future<void> _refreshData() async {
    setState(() {
      if (listMonitoring.length > 0) listMonitoring.clear();
      if (listContract.length > 0) listContract.clear();
      divisi == "AR" ? getCounterData(true) : getCounterData(false);
      divisi == "AR" ? getRenewalData(true) : getRenewalData(false);
      divisi == "AR"
          ? getNewcustRenewalData(true)
          : getNewcustRenewalData(false);
      getMonitoringData();

      if (role == 'ADMIN' && divisi == 'SALES') {
        servicePosMaterial
            .getPosMaterialDashboard(
              mounted,
              context,
              idManager: int.parse(id!),
              isBrandManager: false,
              status: 0,
            )
            .then((value) => totalPosMaterial = value.total!);

        serviceME
            .getMEDashboard(mounted, context,
                idManager: int.parse(id!), status: 0)
            .then((value) {
          totalMarketingExpense = value.total!;
          print("Total Me : $totalMarketingExpense");
        });

        serviceTraining.getHeader(mounted, context, idManager: int.parse(id!), status: 0).then((value) {
          totalTraining = value.total!;
          print("Total Training : $totalTraining");
        });
      }

      if (role == 'ADMIN' && divisi == 'MARKETING') {
        servicePosMaterial
            .getPosMaterialDashboard(
              mounted,
              context,
              idManager: 0,
              isBrandManager: true,
              status: 0,
            )
            .then((value) => totalPosMaterial = value.total!);

        serviceTraining.getHeaderManager(mounted, context, status: 0).then((value) {
          totalTraining = value.total!;
          print("Total Training : $totalTraining");
        });
      }

      if (role == 'ADMIN' && divisi == 'GM') {
        servicePosMaterial
            .getPosMaterialDashboard(
              mounted,
              context,
              idManager: 0,
              isBrandManager: false,
              status: 0,
            )
            .then((value) => totalPosMaterial = value.total!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600 ||
            MediaQuery.of(context).orientation == Orientation.landscape) {
          return Scaffold(
            floatingActionButton: Visibility(
              visible: divisi == "AR" ? false : true,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                child: Image.asset(
                  'assets/images/entry_customer_new.png',
                  width: 34.w,
                  height: 34.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                mini: false,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CustomerAdmin(int.parse(id!))));
                },
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            body: _areaHorizontalHome(),
          );
        }

        return Scaffold(
          floatingActionButton: Visibility(
            visible: divisi == "AR" ? false : true,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Image.asset(
                'assets/images/entry_customer_new.png',
                width: 28.w,
                height: 28.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              mini: true,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CustomerAdmin(int.parse(id!))));
              },
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniEndFloat,
          body: _areaVerticalHome(),
        );
      },
    );
  }

  Widget _areaHorizontalHome() {
    screenHeight = MediaQuery.of(context).size.height;
    return RefreshIndicator(
      child: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          areaHeader(screenHeight, userUpper, context, isHorizontal: true),
          areaCounter(
            // (totalWaiting + totalCashbackWaiting).toString(),
            totalWaiting.toString(),
            // (totalApproved + totalCashbackApprove).toString(),
            totalApproved.toString(),
            // (totalRejected + totalCashbackReject).toString(),
            totalRejected.toString(),
            totalNewCustomer.toString(),
            totalOldCustomer.toString(),
            id,
            context,
            divisi: divisi ?? '',
            isHorizontal: true,
            totalWaitingCashback: totalCashbackWaiting,
            totalApprovedCashback: totalCashbackApprove,
            totalRejectedCashback: totalCashbackReject,
          ),
          areaMarketing(
            true,
            context,
            totalPosMaterial,
            totalMarketingExpense,
            totalTraining,
            showAreaMarketing,
            divisi ?? '',
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: 20.r,
              right: 20.r,
              top: 0.r,
            ),
            sliver: SliverToBoxAdapter(
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Fitur',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          areaMenu(
            screenHeight,
            context,
            id,
            role,
            divisi,
            isConnected: true,
            isHorizontal: true,
          ),
          _hidePerform
              ? SliverPadding(
                  padding: EdgeInsets.only(
                    left: 35.r,
                    right: 35.r,
                    top: 0.r,
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.only(
                    left: 20.r,
                    right: 20.r,
                    top: 10.r,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    // showDate(context).then((value) {
                                    //   state(() {
                                    //     if (value != null) {
                                    //       String dateSt =
                                    //           value.start.toString();
                                    //       String dateEd = value.end.toString();

                                    //       dateSelected =
                                    //           "${convertDateWithMonth(dateSt)} - ${convertDateWithMonth(dateEd)}";
                                    //       print(
                                    //           "Date Selected Start : ${convertDateOra(dateSt)}");
                                    //       print(
                                    //           "Date Selected End : ${convertDateOra(dateEd)}");
                                    //       print(
                                    //           "Date Selected UI : $dateSelected");

                                    //       stDate = convertDateOra(dateSt);
                                    //       edDate = convertDateOra(dateEd);

                                    //       getPerformSales(stDate, edDate);

                                    //       setState(() {});
                                    //     } else {
                                    //       print('Cancel');
                                    //     }
                                    //   });
                                    // });
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
          // _hidePerform
          //     ? SliverPadding(
          //         padding: EdgeInsets.only(
          //           left: 35.r,
          //           right: 35.r,
          //           top: 0.r,
          //         ),
          //       )
          //     : _isPerform
          //         ? areaLoadingRenewal(
          //             isHorizontal: true,
          //           )
          //         : areaDonutChartHor(
          //             dataPie: _samplePie,
          //             startDate: stDate,
          //             endDate: edDate,
          //             sales: listPerform,
          //             totalSales: _totalSales,
          //             context: context),
          areaHeaderRenewal(isHorizontal: true),
          _isLoadRenewal
              ? areaLoadingRenewal(
                  isHorizontal: true,
                )
              : listContract.length > 0
                  ? areaRenewal(
                      listContract, context, ttdPertama!, username!, divisi!,
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
          areaHeaderNewcustRenewal(isHorizontal: true),
          _isLoadNewcustRenewal
              ? areaLoadingNewcustRenewal(
                  isHorizontal: true,
                )
              : listNewContract.length > 0
                  ? areaNewcustRenewal(
                      listNewContract, context, ttdPertama!, username!, divisi!,
                      isHorizontal: true)
                  : areaNewcustRenewalNotFound(
                      context,
                      isHorizontal: true,
                      item: listNewContract,
                    ),
          areaButtonNewcustRenewal(
            context,
            listNewContract.length > 0 ? true : false,
            isHorizontal: true,
            item: listNewContract,
          ),
          areaHeaderMonitoring(isHorizontal: true),
          _isLoading
              ? areaLoading(
                  isHorizontal: true,
                )
              : listMonitoring.length > 0
                  ? areaMonitoring(
                      listMonitoring,
                      context,
                      ttdPertama!,
                      username!,
                      divisi!,
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
    );
  }

  Widget _areaVerticalHome() {
    screenHeight = MediaQuery.of(context).size.height;
    return RefreshIndicator(
      child: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          areaHeader(screenHeight, userUpper, context, isHorizontal: false),
          areaCounter(
            // (totalWaiting + totalCashbackWaiting).toString(),
            totalWaiting.toString(),
            // (totalApproved + totalCashbackApprove).toString(),
            totalApproved.toString(),
            // (totalRejected + totalCashbackReject).toString(),
            totalRejected.toString(),
            totalNewCustomer.toString(),
            totalOldCustomer.toString(),
            id,
            context,
            divisi: divisi ?? '',
            isHorizontal: false,
            totalWaitingCashback: totalCashbackWaiting,
            totalApprovedCashback: totalCashbackApprove,
            totalRejectedCashback: totalCashbackReject,
          ),
          areaMarketing(
            true,
            context,
            totalPosMaterial,
            totalMarketingExpense,
            totalTraining,
            showAreaMarketing,
            divisi ?? '',
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: 20.r,
              right: 20.r,
              top: 10.r,
            ),
            sliver: SliverToBoxAdapter(
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Feature',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          areaMenu(
            screenHeight,
            context,
            id,
            role,
            divisi,
            isConnected: true,
            isHorizontal: false,
          ),
          _hidePerform
              ? SliverPadding(
                  padding: EdgeInsets.only(
                    left: 35.r,
                    right: 35.r,
                    top: 0.r,
                  ),
                )
              : SliverPadding(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    // showDate(context).then((value) {
                                    //   state(() {
                                    //     if (value != null) {
                                    //       String dateSt =
                                    //           value.start.toString();
                                    //       String dateEd = value.end.toString();

                                    //       dateSelected =
                                    //           "${convertDateWithMonth(dateSt)} - ${convertDateWithMonth(dateEd)}";
                                    //       print(
                                    //           "Date Selected Start : ${convertDateOra(dateSt)}");
                                    //       print(
                                    //           "Date Selected End : ${convertDateOra(dateEd)}");
                                    //       print(
                                    //           "Date Selected UI : $dateSelected");

                                    //       stDate = convertDateOra(dateSt);
                                    //       edDate = convertDateOra(dateEd);

                                    //       getPerformSales(stDate, edDate);

                                    //       setState(() {});
                                    //     } else {
                                    //       print('Cancel');
                                    //     }
                                    //   });
                                    // });
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
          // _hidePerform
          //     ? SliverPadding(
          //         padding: EdgeInsets.only(
          //           left: 35.r,
          //           right: 35.r,
          //           top: 0.r,
          //         ),
          //       )
          //     : _isPerform
          //         ? areaLoadingRenewal(
          //             isHorizontal: false,
          //           )
          //         : areaDonutChart(
          //             dataPie: _samplePie, startDate: stDate, endDate: edDate),
          _hidePerform
              ? SliverPadding(
                  padding: EdgeInsets.only(
                    left: 35.r,
                    right: 35.r,
                    top: 0.r,
                  ),
                )
              : areaInfoDonut(
                  sales: listPerform,
                  totalSales: _totalSales,
                  context: context,
                  stDate: stDate,
                  edDate: edDate,
                ),
          areaHeaderRenewal(isHorizontal: false),
          _isLoadRenewal
              ? areaLoadingRenewal(
                  isHorizontal: false,
                )
              : listContract.length > 0
                  ? areaRenewal(
                      listContract, context, ttdPertama!, username!, divisi!,
                      isHorizontal: false)
                  : areaRenewalNotFound(
                      context,
                      isHorizontal: false,
                    ),
          areaButtonRenewal(context, listContract.length > 0 ? true : false,
              isHorizontal: false),
          areaHeaderNewcustRenewal(isHorizontal: false),
          _isLoadNewcustRenewal
              ? areaLoadingNewcustRenewal(
                  isHorizontal: false,
                )
              : listNewContract.length > 0
                  ? areaNewcustRenewal(
                      listNewContract,
                      context,
                      ttdPertama!,
                      username!,
                      divisi!,
                      isHorizontal: false,
                    )
                  : areaNewcustRenewalNotFound(
                      context,
                      isHorizontal: false,
                      item: listNewContract,
                    ),
          areaButtonNewcustRenewal(
            context,
            listNewContract.length > 0 ? true : false,
            isHorizontal: false,
            item: listNewContract,
          ),
          areaHeaderMonitoring(isHorizontal: false),
          _isLoading
              ? areaLoading(
                  isHorizontal: false,
                )
              : listMonitoring.length > 0
                  ? areaMonitoring(
                      listMonitoring,
                      context,
                      ttdPertama!,
                      username!,
                      divisi!,
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
    );
  }
}
