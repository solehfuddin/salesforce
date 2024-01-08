import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/inkaro_approval/pencairan_inkaro_approve.dart';
import 'package:sample/src/app/pages/inkaro_approval/pencairan_inkaro_pending.dart';
import 'package:sample/src/app/pages/inkaro_approval/pencairan_inkaro_reject.dart';

class PencairanInkaroApproval extends StatefulWidget {
  const PencairanInkaroApproval({Key? key}) : super(key: key);

  @override
  State<PencairanInkaroApproval> createState() =>
      _PencairanInkaroApprovalState();
}

class _PencairanInkaroApprovalState extends State<PencairanInkaroApproval>
    with TickerProviderStateMixin {
  late TabController tabController;
  final tabColors = [
    Colors.grey.shade600,
    Colors.green.shade600,
    Colors.red.shade700
  ];
  late Color indicatorColor;

  @override
  void initState() {
    super.initState();
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
        return childApprovalPencairanInkaro(isHorizontal: true);
      }

      return childApprovalPencairanInkaro(isHorizontal: false);
    });
  }

  Widget childApprovalPencairanInkaro({bool isHorizontal = false}) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white70,
          title: Text(
            'List Pencairan Inkaro',
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
            onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AdminScreen())),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black54,
              size: isHorizontal ? 20.sp : 18.r,
            ),
          ),
          bottom: TabBar(
            controller: tabController,
            labelColor: Colors.black54,
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
            PendingPencairanInkaro(),
            ApprovePencairanInkaro(),
            RejectPencairanInkaro(),
          ],
        ),
      ),
    );
  }
}
