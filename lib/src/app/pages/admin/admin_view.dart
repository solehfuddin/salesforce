import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sample/src/app/controllers/my_controller.dart';
import 'package:sample/src/app/pages/activity/daily_activity.dart';
import 'package:sample/src/app/pages/admin/admin_content.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/dbhelper.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:sample/src/app/widgets/dialogpassword.dart';
import 'package:sample/src/domain/entities/notifikasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  MyController myController = Get.find<MyController>();
  DbHelper dbHelper = DbHelper.instance;
  List<Notifikasi> listNotifLocal = List.empty(growable: true);
  String? id = '';
  String? role = '';
  String? name = '';
  String? username = '';
  String? divisi = '';
  String? ttdPertama = '';
  String? userUpper = '';
  bool _isBadge = false;
  int _selectedIndex = 0;
  dynamic changePass;

  @override
  void initState() {
    super.initState();
    getRole();
    myController.getRole();
    print(myController.sessionId);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _widgetOptionsHor = <Widget>[
    AdminContent(),
    DailyActivity(
      isAdmin: true,
    ),
  ];

  List<Widget> _widgetOptionsVer = <Widget>[
    AdminContent(),
    DailyActivity(
      isAdmin: true,
    ),
  ];

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      name = preferences.getString("name");
      username = preferences.getString("username");
      userUpper = username?.toUpperCase();
      divisi = preferences.getString("divisi");
      ttdPertama = preferences.getString("ttduser");

      getTtd(int.parse(id!));
      getLocalNotif();

      if (role == 'ADMIN' && divisi == 'MARKETING')
      {
        FirebaseMessaging.instance.subscribeToTopic("allmarketing");
        FirebaseMessaging.instance.unsubscribeFromTopic("allsales");
        FirebaseMessaging.instance.unsubscribeFromTopic("alladmin");
        FirebaseMessaging.instance.unsubscribeFromTopic("allar");
        FirebaseMessaging.instance.unsubscribeFromTopic("allgm");
      }
      
      if (role == 'ADMIN' && divisi == 'GM')
      {
        FirebaseMessaging.instance.subscribeToTopic("allgm");
        FirebaseMessaging.instance.unsubscribeFromTopic("allsales");
        FirebaseMessaging.instance.unsubscribeFromTopic("alladmin");
        FirebaseMessaging.instance.unsubscribeFromTopic("allar");
        FirebaseMessaging.instance.unsubscribeFromTopic("allmarketing");
      }
    });
  }

  getTtd(int input) async {
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
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
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
      var response = await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
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

          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              isReadLocal();
            });
          });
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

  Future<bool> _onBackPressed() async {
    if (changePass == '0') {
      handleLogout(context);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
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
                  isBadge: _isBadge,
                ),
                body: _widgetOptionsHor.elementAt(_selectedIndex),
                bottomNavigationBar: Visibility(
                  visible: divisi != "AR" ? true : false,
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard),
                        label: 'Dasbor',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.assignment_outlined),
                        label: 'Aktivitas',
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                  ),
                ),
              );
            }

            return Scaffold(
              appBar: CustomAppBar(
                isHorizontal: false,
                isBadge: _isBadge,
              ),
              body: _widgetOptionsVer.elementAt(_selectedIndex),
              bottomNavigationBar: Visibility(
                visible: divisi != "AR" ? true : false,
                child: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard),
                      label: 'Dasbor',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.assignment_outlined),
                      label: 'Aktivitas',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
              ),
            );
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
