import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/approval/waiting_view.dart';
import 'package:sample/src/app/pages/cashback/cashback_approvalpending.dart';
import 'package:sample/src/app/pages/customer/customer_approvalpending.dart';
import 'package:sample/src/app/utils/custom.dart';

// ignore: must_be_immutable
class TabApprovalWaiting extends StatefulWidget {
  int totalDiskon, totalCashback, totalChangeCust;

  TabApprovalWaiting({
    Key? key,
    this.totalDiskon = 0,
    this.totalCashback = 0,
    this.totalChangeCust = 0,
  }) : super(key: key);

  @override
  State<TabApprovalWaiting> createState() => _TabApprovalWaitingState();
}

class _TabApprovalWaitingState extends State<TabApprovalWaiting>
    with TickerProviderStateMixin {
  late TabController tabController;
  final tabColors = [
    Colors.white,
    Colors.green.shade200,
    Colors.deepOrange.shade200
  ];
  late Color indicatorColor;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: widget.totalDiskon > widget.totalCashback &&
              widget.totalDiskon > widget.totalChangeCust
          ? 0
          : widget.totalCashback > widget.totalDiskon &&
                  widget.totalCashback > widget.totalChangeCust
              ? 1
              : 2,
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
                    'Cashback ${widget.totalCashback > 0 ? '(${widget.totalCashback})' : ''}',
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
            CashbackApprovalPending(
              defaultColor: Colors.grey.shade50,
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
