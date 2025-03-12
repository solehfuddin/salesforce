import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/approval/approval_view.dart';
import 'package:sample/src/app/pages/approval/rejected_view.dart';
// import 'package:sample/src/app/pages/approval/approval_view.dart';
// import 'package:sample/src/app/pages/approval/rejected_view.dart';
import 'package:sample/src/app/pages/approval/tab_approval_approve.dart';
import 'package:sample/src/app/pages/approval/tab_approval_rejected.dart';
import 'package:sample/src/app/pages/approval/tab_approval_waiting.dart';
import 'package:sample/src/app/pages/approval/tab_ar_approve.dart';
import 'package:sample/src/app/pages/approval/tab_ar_rejected.dart';
import 'package:sample/src/app/pages/approval/tab_ar_waiting.dart';
import 'package:sample/src/app/pages/approval/waiting_view.dart';
import 'package:sample/src/app/pages/customer/customer_view.dart';
// import 'package:sample/src/app/pages/approval/waiting_view.dart';
// import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/pages/renewcontract/renewal_contract.dart';
import 'package:sample/src/app/utils/custom.dart';

SliverPadding areaCounter(
  String totalWaiting,
  String totalApproved,
  String totalRejected,
  String totalNewCustomer,
  String totalOldCustomer,
  dynamic idAdmin,
  BuildContext context, {
  bool isHorizontal = false,
  String divisi = '',
  int totalWaitingCashback = 0,
  int totalApprovedCashback = 0,
  int totalRejectedCashback = 0,
  int totalWaitingChangeCust = 0,
  int totalApprovedChangeCust = 0,
  int totalRejectedChangeCust = 0,
}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: isHorizontal ? 18.r : 18.r,
      vertical: isHorizontal ? 20.r : 13.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Statistik',
            style: TextStyle(
              fontSize: isHorizontal ? 21.sp : 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 15.h : 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(isHorizontal ? 10.r : 10.r),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(isHorizontal ? 10.r : 8.r),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Kustomer Baru',
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Segoe ui',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 8.r : 8.r,
                        ),
                        Center(
                          child: Text(
                            convertThousand(int.parse(totalNewCustomer), 0),
                            style: TextStyle(
                              fontSize: isHorizontal ? 25.sp : 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 8.r : 8.r,
                        ),
                        Container(
                          height: isHorizontal ? 6.h : 5.h,
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius:
                                BorderRadius.circular(isHorizontal ? 5.r : 2.r),
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 3.h : 3.h,
                        ),
                      ],
                    ),
                  ),
                  // onTap: () => Get.toNamed('/customer/$idAdmin'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CustomerScreen(
                        int.parse(idAdmin),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: isHorizontal ? 10.w : 20.w,
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(isHorizontal ? 10.r : 10.r),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(isHorizontal ? 10.r : 8.r),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Kustomer Lama',
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Segoe ui',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 8.h : 8.r,
                        ),
                        Center(
                          child: Text(
                            convertThousand(int.parse(totalOldCustomer), 0),
                            style: TextStyle(
                              fontSize: isHorizontal ? 25.sp : 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 8.h : 8.r,
                        ),
                        Container(
                          height: isHorizontal ? 6.h : 5.h,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange[300],
                            borderRadius:
                                BorderRadius.circular(isHorizontal ? 5.r : 2.r),
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 3.h : 3.h,
                        ),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RenewalContract(
                        keyword: '',
                        isAdmin: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 12.h : 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(isHorizontal ? 13.r : 10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(isHorizontal ? 10.r : 8.r),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              divisi == "SALES"
                                  ? '${totalWaitingCashback + int.parse(totalWaiting) + totalWaitingChangeCust}'
                                  : '${int.parse(totalWaiting) + totalWaitingChangeCust}',
                              style: TextStyle(
                                fontSize: isHorizontal ? 20.sp : 18.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: isHorizontal ? 18.r : 13.r,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHorizontal ? 10.h : 4.h,
                        ),
                        Text(
                          'Menunggu',
                          style: TextStyle(
                            fontSize: isHorizontal ? 18.sp : 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 13.sp : 10.h,
                        ),
                        Container(
                          height: isHorizontal ? 7.h : 5.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius:
                                BorderRadius.circular(isHorizontal ? 5.r : 2.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.of(context).pushReplacement(
                    divisi == "GM" || divisi == "SALES"
                        ? MaterialPageRoute(
                            builder: (context) => TabApprovalWaiting(
                              totalDiskon: int.parse(totalWaiting),
                              totalCashback: totalWaitingCashback,
                              totalChangeCust: totalWaitingChangeCust,
                            ),
                          )
                        : divisi == "AR"
                            ? MaterialPageRoute(
                                builder: (context) => TabArWaiting(
                                  totalDiskon: int.parse(totalWaiting),
                                  totalChangeCust: totalWaitingChangeCust,
                                ),
                              )
                            : MaterialPageRoute(
                                builder: (context) => WaitingApprovalScreen(),
                              ),
                  ),
                ),
              ),
              SizedBox(
                width: isHorizontal ? 10.w : 15.w,
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(isHorizontal ? 13.r : 10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(isHorizontal ? 10.r : 8.r),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              divisi == "SALES" 
                                ? '${totalApprovedCashback + int.parse(totalApproved) + totalApprovedChangeCust}'
                                : '${int.parse(totalApproved) + totalApprovedChangeCust}',
                              style: TextStyle(
                                fontSize: isHorizontal ? 20.sp : 18.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: isHorizontal ? 18.r : 13.r,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHorizontal ? 10.h : 4.h,
                        ),
                        Text(
                          'Disetujui',
                          style: TextStyle(
                            fontSize: isHorizontal ? 18.sp : 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 13.sp : 10.h,
                        ),
                        Container(
                          height: isHorizontal ? 7.h : 5.h,
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius:
                                BorderRadius.circular(isHorizontal ? 5.r : 2.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    divisi == "GM" || divisi == "SALES"
                        ? MaterialPageRoute(
                            builder: (context) => TabApprovalApprove(
                              totalDiskon: int.parse(totalApproved),
                              totalCashback: totalApprovedCashback,
                              totalChangeCust: totalApprovedChangeCust,
                            ),
                          )
                        : divisi == "AR"
                            ? MaterialPageRoute(
                                builder: (context) => TabArApprove(
                                  totalDiskon: int.parse(totalApproved),
                                  totalChangeCust: totalApprovedChangeCust,
                                ),
                              )
                            : MaterialPageRoute(
                                builder: (context) => ApprovedScreen(),
                              ),
                  ),
                ),
              ),
              SizedBox(
                width: isHorizontal ? 10.w : 15.w,
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(isHorizontal ? 13.r : 10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(isHorizontal ? 10.r : 8.r),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              divisi == "SALES" 
                                ? '${totalRejectedCashback + int.parse(totalRejected) + totalRejectedChangeCust}'
                                : '${int.parse(totalRejected) + totalRejectedChangeCust}',
                              style: TextStyle(
                                fontSize: isHorizontal ? 20.sp : 18.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: isHorizontal ? 18.r : 13.r,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHorizontal ? 10.h : 4.h,
                        ),
                        Text(
                          'Ditolak',
                          style: TextStyle(
                            fontSize: isHorizontal ? 18.sp : 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 13.sp : 10.h,
                        ),
                        Container(
                          height: isHorizontal ? 7.h : 5.h,
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius:
                                BorderRadius.circular(isHorizontal ? 5.r : 2.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.of(context).pushReplacement(
                    divisi == "GM" || divisi == "SALES"
                        ? MaterialPageRoute(
                            builder: (context) => TabApprovalRejected(
                              totalDiskon: int.parse(totalRejected),
                              totalCashback: totalRejectedCashback,
                              totalChangeCust: totalRejectedChangeCust,
                            ),
                          )
                        : divisi == "AR"
                            ? MaterialPageRoute(
                                builder: (context) => TabArRejected(
                                  totalDiskon: int.parse(totalRejected),
                                  totalChangeCust: totalRejectedChangeCust,
                                ),
                              )
                            : MaterialPageRoute(
                                builder: (context) => RejectedScreen(),
                              ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
