import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/inkaro_approval/approve_inkaro.dart';
import 'package:sample/src/app/pages/inkaro_approval/pending_inkaro.dart';
import 'package:sample/src/app/pages/inkaro_approval/reject_inkaro.dart';

class CompleteInkaroApproval extends StatefulWidget {
  const CompleteInkaroApproval({ Key? key }) : super(key: key);

  @override
  State<CompleteInkaroApproval> createState() => _CompleteInkaroApprovalState();
}

class _CompleteInkaroApprovalState extends State<CompleteInkaroApproval>  with TickerProviderStateMixin {
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
      if (constraints.maxWidth > 600 || MediaQuery.of(context).orientation == Orientation.landscape){
        return childCompleteRenewal(isHorizontal: true);
      }

      return childCompleteRenewal(isHorizontal: false);
    });
  }

  Widget childCompleteRenewal({bool isHorizontal = false}){
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white70,
          title: Text(
            'List Persetujuan Inkaro',
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
            PendingInkaro(),
            ApproveInkaro(),
            RejectInkaro(),
          ],
        ),
      ),
    );
  }
}