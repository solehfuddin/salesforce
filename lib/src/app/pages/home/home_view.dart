import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/src/app/controllers/my_controller.dart';
import 'package:sample/src/app/pages/attendance/attendance_prominent.dart';
import 'package:sample/src/app/pages/attendance/attendance_service.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/dbhelper.dart';
import 'package:sample/src/app/utils/mylocation.dart';
import 'package:sample/src/app/widgets/areaheader.dart';
import 'package:sample/src/app/widgets/areabanner.dart';
import 'package:sample/src/app/widgets/areafeature.dart';
import 'package:sample/src/app/widgets/areamenu.dart';
import 'package:sample/src/app/widgets/areamonitoring.dart';
import 'package:sample/src/app/widgets/areapoint.dart';
import 'package:sample/src/app/widgets/areasyncchart.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:sample/src/app/widgets/dialogpassword.dart';
import 'package:sample/src/domain/entities/monitoring.dart';
import 'package:sample/src/domain/entities/notifikasi.dart';
import 'package:sample/src/domain/entities/piereport.dart';
import 'package:sample/src/domain/entities/salesPerform.dart';
import 'package:sample/src/domain/entities/salesSize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/app_config.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MyController myController = Get.find<MyController>();
  DbHelper dbHelper = DbHelper.instance;
  MyLocation _myLocation = MyLocation();
  late SharedPreferences preferences;
  List<Notifikasi> listNotifLocal = List.empty(growable: true);
  List<AppConfig> listAppconfig = List.empty(growable: true);
  
  String? id = '';
  String? role = '';
  String? name = '';
  String? username = '';
  String? divisi = '';
  String? userUpper = '';
  String? ttdSales = '';
  String? changePass = '';
  String? isTrainer = 'NO';
  bool? isProminentAccess = false;
  bool isPermissionCamera = false;
  bool isLocationService = false;
  bool isPermissionService = false;
  bool _isLoading = true;
  bool _hidePerform = false;
  bool _isBadge = false;
  int dailyInt = 0;
  List<Monitoring> listMonitoring = List.empty(growable: true);
  List<SalesPerform> listPerform = List.empty(growable: true);
  List<PieReport> _samplePie = List.empty(growable: true);
  String stDate = "01/04/2022";
  String edDate = "30/04/2022";
  String dateSelected = "01 Apr 2022 - 30 Apr 2022";
  double _totalSales = 0;
  dynamic totalSales;

  getRole() async {
    preferences = await SharedPreferences.getInstance();
    myController.getRole();
    print(myController.sessionId);
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      name = preferences.getString("name");
      username = preferences.getString("username");
      userUpper = username?.toUpperCase();
      divisi = preferences.getString("divisi");
      ttdSales = preferences.getString("ttduser") ?? '';
      isProminentAccess = preferences.getBool("check_prominent") ?? false;
      isTrainer = preferences.getString("isTrainer");

      print("Dashboard : $role");
      print("TTD Sales : $ttdSales");

      getMonitoringSales(int.parse(id!));
      getPerformSales(stDate, edDate);
      checkPassword(int.parse(id!));
      getLocalNotif();

      if (ttdSales == '') {
        handleSigned(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.subscribeToTopic("allsales");
    FirebaseMessaging.instance.unsubscribeFromTopic("alladmin");
    FirebaseMessaging.instance.unsubscribeFromTopic("allar");
    getRole();
    getConfig();

    checkPermission();

    DateTime now = new DateTime.now();

    stDate = "01/${now.month}/${now.year}";
    edDate = "${now.day}/${now.month}/${now.year}";

    String dateSt = "${now.year}-${now.month.toString().padLeft(2, '0')}-01";
    String dateEd =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    dateSelected =
        "${convertDateWithMonth(dateSt)} - ${convertDateWithMonth(dateEd)}";
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

   getConfig() async {
    // const timeout = 30;
    var url = '$API_URL/config/';

    try {
      var response = await http.get(Uri.parse(url));
      //await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout))
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print("appconfig : $rest");

          listAppconfig =
              rest.map<AppConfig>((json) => AppConfig.fromJson(json)).toList();

          if (listAppconfig.length > 1)
          {
            dailyInt = int.parse(listAppconfig[1].status ?? "0");
            print("dailyInt : $dailyInt");
          }
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

  void checkService() async {
    isLocationService = await _myLocation.isServiceEnable();
    setState(() {
      if (isPermissionService && isLocationService) {
        print('Granted');
        // Permission.camera.request();
      } else {
        dialogLocationService(context);
      }
    });
  }

  checkPassword(int input) async {
    const timeout = 15;
    var url = '$API_URL/users?id=$input';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          changePass = data['data']['change_password'];

          if (changePass != '0') {
            dialogChangePassword(context);
          }

          print(ttdSales);
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socker Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('Error : $e');
    }
  }

  dialogChangePassword(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: DialogPassword(
            id,
            name,
          ),
        );
      },
    );
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
            await [Permission.camera, Permission.microphone, Permission.photos]
                .request()
                .then((value) => openAppSettings());
          }
        }
        // checkService();
      },
    );
  }

  getMonitoringSales(int idSales) async {
    _isLoading = true;

    await Future.delayed(Duration(seconds: 1));
    if (listMonitoring.length > 0) listMonitoring.clear();

    var url = '$API_URL/contract/salesMonitoring?id=$idSales';

    var response = await http.get(Uri.parse(url));
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

        if (listMonitoring.length > 3) {
          listMonitoring.removeRange(3, listMonitoring.length);
        }
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
    // setState(() {
    getMonitoringSales(int.parse(id!));
    getPerformSales(stDate, edDate);

    checkPassword(int.parse(id!));
    if (ttdSales == '') {
      handleSigned(context);
    }
    getLocalNotif();
    // });
  }

  Future<bool> _onBackPressed() async {
    handleLogout(context);
    return false;
  }

  getPerformSales(String stDate, String edDate) async {
    _samplePie.clear();
    listPerform.clear();

    const timeout = 15;
    var url = '$API_URL/performance';

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

  void addLocalNotif(Notifikasi item) async {
    int res = await dbHelper.insert(item);
    if (res > 0) {
      getLocalNotif();
    }
  }

  void isReadLocal() async {
    _isBadge = await dbHelper.selectByRead();
  }

  void existLocalNotif(Notifikasi item) async {
    List<Notifikasi> result = await dbHelper.selectById(item);
    if (result.length > 0) {
      print('Data has exist');
    } else {
      addLocalNotif(item);
    }
    result.clear();
  }

  void getLocalNotif() async {
    final Future<Database> dbFuture = dbHelper.createDb();
    dbFuture.then((value) {
      Future<List<Notifikasi>> listNotif = dbHelper.getAllNotifikasi();
      listNotif.then((value) {
        setState(() {
          listNotifLocal = value;

          // for (int i = 0; i < listNotifLocal.length; i++) {
          //   print('Id Notif : ${listNotifLocal[i].idNotif}');
          //   print('Id User : ${listNotifLocal[i].idUser}');
          //   print('Type Template : ${listNotifLocal[i].typeTemplate}');
          //   print('Type Notif : ${listNotifLocal[i].typeNotif}');
          //   print('Judul : ${listNotifLocal[i].judul}');
          //   print('Isi : ${listNotifLocal[i].isi}');
          //   print('Tanggal : ${listNotifLocal[i].tanggal}');
          //   print('Is Read : ${listNotifLocal[i].isRead}');
          // }

          role == "ADMIN"
              ? getNotifikasiRemote(
                  true,
                  idUser: id,
                )
              : getNotifikasiRemote(
                  false,
                  idUser: id,
                );
        });
      });
    });
  }

  getNotifikasiRemote(bool isAdmin, {dynamic idUser}) async {
    const timeout = 15;
    List<Notifikasi> list = List.empty(growable: true);

    var url = isAdmin
        ? '$API_URL/notification/getNotifAdmin/?id=$idUser'
        : '$API_URL/notification/getNotifSales/?id=$idUser';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          // print(rest);
          list = rest
              .map<Notifikasi>((json) => Notifikasi.fromJson(json))
              .toList();

          if (listNotifLocal.length < 1) {
            for (int i = 0; i < list.length; i++) {
              addLocalNotif(list[i]);
            }
          } else {
            for (int i = 0; i < list.length; i++) {
              existLocalNotif(list[i]);
            }
          }

          Future.delayed(Duration(seconds: 3)).then((_) => isReadLocal());
          print("List Size: ${list.length}");
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
    return list;
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
                  isBadge: _isBadge,
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
                        divisi,
                        isConnected: true,
                        isHorizontal: true,
                        dailyInt: dailyInt,
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
                                left: 18.r,
                                right: 18.r,
                                top: 5.r,
                                bottom: 15.r,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter state) {
                                    return Text(
                                      'Penjualan',
                                      style: TextStyle(
                                        fontSize: 21.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                      _hidePerform
                          ? SliverPadding(
                              padding: EdgeInsets.only(
                                left: 18.r,
                                right: 18.r,
                                top: 0.r,
                              ),
                            )
                          : areaInfoDonutUser(
                              sales: listPerform,
                              totalSales: _totalSales,
                              context: context,
                              stDate: stDate,
                              edDate: edDate,
                              isHorizontal: true,
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
                                  ttdSales!,
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
                      areaBanner(
                        screenHeight,
                        context,
                        isHorizontal: true,
                      ),
                    ],
                  ),
                  onRefresh: _refreshData,
                ),
                floatingActionButton: Visibility(
                  visible: isTrainer == "YES" ? true : false,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h, right: 3.h),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'assets/images/training.png',
                        width: 34.w,
                        height: 34.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      mini: false,
                      onPressed: () {
                        Get.toNamed("/trainerScreen");
                      },
                    ),
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endDocked,
              );
            }

            return Scaffold(
              appBar: CustomAppBar(
                isHorizontal: false,
                isBadge: _isBadge,
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
                      divisi,
                      isConnected: true,
                      isHorizontal: false,
                      dailyInt: dailyInt,
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
                              top: 5.r,
                              bottom: 10.r,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: StatefulBuilder(
                                builder:
                                    (BuildContext context, StateSetter state) {
                                  return Text(
                                    'Penjualan',
                                    style: TextStyle(
                                      fontSize: 21.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                    _hidePerform
                        ? SliverPadding(
                            padding: EdgeInsets.only(
                              left: 35.r,
                              right: 35.r,
                              top: 0.r,
                            ),
                          )
                        : areaInfoDonutUser(
                            sales: listPerform,
                            totalSales: _totalSales,
                            context: context,
                            stDate: stDate,
                            edDate: edDate,
                            isHorizontal: false,
                          ),
                    areaHeaderMonitoring(
                      isHorizontal: false,
                    ),
                    _isLoading
                        ? areaLoading(
                            isHorizontal: false,
                          )
                        : listMonitoring.length > 0
                            ? areaMonitoring(
                                listMonitoring,
                                context,
                                ttdSales!,
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
                    areaBanner(
                      screenHeight,
                      context,
                      isHorizontal: false,
                    ),
                  ],
                ),
                onRefresh: _refreshData,
              ),
              floatingActionButton: Visibility(
                  visible: isTrainer == "YES" ? true : false,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h, right: 3.h),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'assets/images/training.png',
                        width: 34.w,
                        height: 34.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      mini: false,
                      onPressed: () {
                        Get.toNamed("/trainerScreen");
                      },
                    ),
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endDocked,
            );
          },
        ),
      ),
    );
  }
}
