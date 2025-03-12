import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/approval/rejected_view.dart';
import 'package:sample/src/app/pages/cashback/cashback_approvalreject.dart';
import 'package:sample/src/app/pages/customer/customer_approvalreject.dart';
import 'package:sample/src/app/utils/custom.dart';

// ignore: must_be_immutable
class TabApprovalRejected extends StatefulWidget {
  int totalDiskon, totalCashback, totalChangeCust;
  TabApprovalRejected({
    Key? key,
    this.totalDiskon = 0,
    this.totalCashback = 0,
    this.totalChangeCust = 0,
  }) : super(key: key);

  @override
  State<TabApprovalRejected> createState() => _TabApprovalRejectedState();
}

class _TabApprovalRejectedState extends State<TabApprovalRejected>
    with TickerProviderStateMixin {
  late TabController tabController;
  final tabColors = [Colors.white, Colors.green.shade300, Colors.deepOrange.shade300];
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
          backgroundColor: Colors.red[300],
          title: Text(
            'Kontrak Ditolak',
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
                text: 'Diskon ${widget.totalDiskon > 0 ? '(${widget.totalDiskon})' : ''}',
              ),
              Tab(
                text: 'Cashback ${widget.totalCashback > 0 ? '(${widget.totalCashback})' : ''}',
              ),
              Tab(
                text: 'Customer ${widget.totalChangeCust > 0 ? '(${widget.totalChangeCust})' : ''}',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            RejectedScreen(
              isHideAppbar: true,
            ),
            CashbackApprovalReject(
              defaultColor: Colors.grey.shade50,
            ),
            CustomerApprovalReject(
              defaultColor: Colors.grey.shade50,
            ),
          ],
        ),
      ),
      onWillPop: _onBackPressed,
    );
  }
}
