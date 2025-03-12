import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/profile/profile_schedule_offline.dart';
import 'package:sample/src/app/pages/profile/profile_schedule_online.dart';
import 'package:sample/src/app/pages/trainer/trainer_view.dart';

import '../../utils/custom.dart';

// ignore: must_be_immutable
class ProfileSchedule extends StatefulWidget {
  bool isHorizontal;

  ProfileSchedule({
    Key? key,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  State<ProfileSchedule> createState() => _ProfileScheduleState();
}

class _ProfileScheduleState extends State<ProfileSchedule>
    with TickerProviderStateMixin {
  late TabController tabController;
  final tabColors = [Colors.red, Colors.blue];
  late Color indicatorColor;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    )..addListener(() {
        setState(() {
          paginateClear();
          indicatorColor = tabColors[tabController.index];
        });
      });
    indicatorColor = tabColors[0];
  }

  Future<bool> _onBackPressed() async {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => TrainerScreen()));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(isHorizontal: true);
      }

      return childWidget(isHorizontal: false);
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.teal.shade900,
          title: Text(
            'Trainer Schedule',
            style: TextStyle(
              color: Colors.white,
              fontSize: isHorizontal ? 20.sp : 18.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              paginateClear();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: isHorizontal ? 20.sp : 18.r,
            ),
          ),
          bottom: TabBar(
            controller: tabController,
            labelColor: Colors.white,
            indicatorColor: indicatorColor,
            indicatorPadding: EdgeInsets.all(3.r),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            tabs: [
              Tab(
                text: 'Schedule Offline',
              ),
              Tab(
                text: 'Schedule Online',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            ProfileScheduleOffline(),
            ProfileScheduleOnline(),
          ],
        ),
      ),
      onWillPop: _onBackPressed,
    );
  }
}
