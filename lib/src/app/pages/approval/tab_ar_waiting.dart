import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/approval/waiting_view.dart';
import 'package:sample/src/app/pages/customer/customer_approvalpending.dart';

import '../../utils/custom.dart';
import '../admin/admin_view.dart';

// ignore: must_be_immutable
class TabArWaiting extends StatefulWidget {
  int totalDiskon, totalChangeCust;
  TabArWaiting({
    Key? key,
    this.totalDiskon = 0,
    this.totalChangeCust = 0,
  }) : super(key: key);

  @override
  State<TabArWaiting> createState() => _TabArWaitingState();
}

class _TabArWaitingState extends State<TabArWaiting>
    with TickerProviderStateMixin {
  late TabController tabController;
  final tabColors = [
    Colors.white,
    Colors.deepOrange.shade200
  ];
  late Color indicatorColor;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: widget.totalDiskon > widget.totalChangeCust ? 0 : 1,
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
          backgroundColor: Colors.grey[500],
          title: Text(
            'Kontrak Menunggu',
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
                text:
                    'Diskon ${widget.totalDiskon > 0 ? '(${widget.totalDiskon})' : ''}',
              ),
              Tab(
                text:
                    'Customer ${widget.totalChangeCust > 0 ? '(${widget.totalChangeCust})' : ''}',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            WaitingApprovalScreen(
              isHideAppbar: true,
            ),
            CustomerApprovalPending(
              defaultColor: Colors.grey.shade50,
            ),
          ],
        ),
      ),
      onWillPop: _onBackPressed,
    );
  }
}
