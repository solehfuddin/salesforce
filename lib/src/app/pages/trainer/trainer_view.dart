import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/controllers/training_controller.dart';
// import 'package:sample/src/app/pages/profile/profile_schedule.dart';
import 'package:sample/src/app/pages/trainer/trainer_terkonfirmasi.dart';
import 'package:sample/src/app/pages/trainer/trainer_riwayat.dart';
import 'package:sample/src/app/pages/trainer/trainer_terjadwal.dart';
import 'package:sample/src/domain/service/service_training.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/trainer.dart';
import '../../../domain/entities/training_resheader.dart';
import '../../controllers/my_controller.dart';
import '../../utils/dbhelper.dart';
import '../profile/profile_screen.dart';
// import '../profile/profile_screen.dart';

class TrainerScreen extends StatefulWidget {
  const TrainerScreen({Key? key}) : super(key: key);

  @override
  State<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends State<TrainerScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  final tabColors = [Colors.orange, Colors.green, Colors.red];
  late Color indicatorColor;

  ServiceTraining serviceTraining = new ServiceTraining();
  MyController myController = Get.find<MyController>();
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();
  TrainingController trainingController = Get.find<TrainingController>();

  DbHelper dbHelper = DbHelper.instance;
  Future<TrainingResHeader>? listRes;
  List<Trainer> _list = List.empty(growable: true);
  String? id = '';
  String? role = '';
  String? name = '';
  String? username = '';
  String? divisi = '';
  String? ttdPertama = '';
  String? userUpper = '';
  dynamic changePass;

  DateTime now = DateTime.now();
  late DateTime selDateTime;
  int totalItem = 0;
  int totalPage = 0;
  int offset = 0;
  int limit = 5;
  var selectedDate = '';

  @override
  void initState() {
    super.initState();
    getRole();
    myController.getRole();
    print(myController.sessionId);

    selDateTime = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    selectedDate = formattedDate;

    tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    )..addListener(() {
        setState(() {
          indicatorColor = tabColors[tabController.index];
        });
      });
    indicatorColor = tabColors[0];
  }

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

      getTrainer(name: name);
    });
  }

  void getTrainer({String? name = ""}) {
    meController
        .getAllTrainer(
          mounted,
          context,
          key: name ?? "",
        )
        .then(
          (value) => setState(
            () {
              _list.addAll(value);

              if (_list.length > 0) {
                trainingController.trainer.value = _list[0];
              }
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Training Schedule',
          style: TextStyle(
            color: Colors.black54,
            fontSize: meController.isHorizontal.value ? 20.sp : 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black54,
            size: meController.isHorizontal.value ? 20.r : 18.r,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: 3.r,
            ),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.black54,
                size: meController.isHorizontal.value ? 20.r : 18.r,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.black45,
          indicatorColor: indicatorColor,
          indicatorPadding: EdgeInsets.all(3.r),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          tabs: [
            Tab(
              text: 'Terjadwal',
            ),
            Tab(
              text: 'Terkonfirmasi',
            ),
            Tab(
              text: 'Riwayat',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          TrainerTerjadwal(),
          TrainerTerkonfirmasi(),
          TrainerRiwayat(),
        ],
      ),
    );
  }

  Widget getImgProfile(String? image) {
    if (image == null || image.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          height: 60.h,
          width: 60.w,
          child: Image.asset(
            'assets/images/profile.png',
            height: 60.h,
            width: 60.w,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          height: 60.h,
          width: 60.w,
          // child: Text('test'),
          child: Image.memory(
            Base64Decoder().convert(
              image,
            ),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }
}
