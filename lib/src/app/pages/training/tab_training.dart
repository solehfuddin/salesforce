import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/pages/training/training_appointment.dart';
import 'package:sample/src/app/pages/training/training_history.dart';
import 'package:sample/src/app/utils/custom.dart';

class TabTraining extends StatefulWidget {
  const TabTraining({Key? key}) : super(key: key);

  @override
  State<TabTraining> createState() => _TabTrainingState();
}

class _TabTrainingState extends State<TabTraining> with TickerProviderStateMixin {
  late TabController tabController;
  late Color indicatorColor;
  final tabColors = [Colors.blue.shade600, Colors.orange.shade600];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this)..addListener(() {
      setState(() {
        paginateClear();
        indicatorColor = tabColors[tabController.index];
      });
    });
    indicatorColor = tabColors[0];
  }

  Future<bool> _onBackPressed() async {
    Get.back();
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
          backgroundColor: Colors.white,
          title: Text(
            'Training Optik',
            style: TextStyle(
              color: Colors.black54,
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

              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black54,
              size: isHorizontal ? 20.sp : 18.r,
            ),
          ),
          bottom: TabBar(
            controller: tabController,
            labelColor: Colors.black45,
            indicatorColor: indicatorColor,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: Icon(Icons.manage_accounts_outlined),
              ),
              Tab(
                icon: Icon(Icons.history),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            TrainingAppointment(),
            TrainingHistory(),
          ],
        ),
      ),
      onWillPop: _onBackPressed,
    );
  }
}