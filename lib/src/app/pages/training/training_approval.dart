import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/pages/training/training_approvalapprove.dart';
import 'package:sample/src/app/pages/training/training_approvalpending.dart';
import 'package:sample/src/app/pages/training/training_approvalreject.dart';

import '../../controllers/my_controller.dart';
import '../../utils/custom.dart';
import '../admin/admin_view.dart';

class TrainingAprroval extends StatefulWidget {
  const TrainingAprroval({Key? key}) : super(key: key);

  @override
  State<TrainingAprroval> createState() => _TrainingAprrovalState();
}

class _TrainingAprrovalState extends State<TrainingAprroval> with TickerProviderStateMixin {
  MyController myController = Get.find<MyController>();
  late TabController tabController;
  final tabColors = [Colors.orange, Colors.green, Colors.red];
  late Color indicatorColor;

  @override
  void initState() {
    super.initState();
    myController.getRole();

    tabController = TabController(
      initialIndex: 0,
      length: 3,
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
        MaterialPageRoute(builder: (context) => AdminScreen()));
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
          backgroundColor: Color.fromARGB(255, 158, 92, 6),
          title: Text(
            'List Training',
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

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AdminScreen(),
                ),
              );
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
                text: 'Menunggu',
              ),
              Tab(
                text: 'Disetujui',
              ),
              Tab(
                text: 'Ditolak',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            Training_ApprovalPending(),
            Training_ApprovalApprove(),
            Training_ApprovalReject(),
          ],
        ),
      ),
      onWillPop: _onBackPressed,
    );
  }
}
