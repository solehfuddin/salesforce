import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/renewcontract/approve_renewal.dart';
import 'package:sample/src/app/pages/renewcontract/reject_renewal.dart';
import 'package:sample/src/app/pages/renewcontract/pending_renewal.dart';

class CompleteRenewal extends StatefulWidget {
  @override
  State<CompleteRenewal> createState() => _CompleteRenewalState();
}

class _CompleteRenewalState extends State<CompleteRenewal> with TickerProviderStateMixin {
  TabController tabController;
  final tabColors = [Colors.grey.shade600, Colors.green.shade600, Colors.red.shade700];
  Color indicatorColor;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'List Perubahan Kontrak',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18,
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
            size: 18,
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.black54,
          indicatorColor: indicatorColor,
          indicatorPadding: EdgeInsets.all(3),
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
          PendingRenewal(),
          ApproveRenewal(),
          RejectRenewal(),
        ],
      ),
    );
  }
}