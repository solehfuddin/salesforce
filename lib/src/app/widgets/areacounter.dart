import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/approval/approval_view.dart';
import 'package:sample/src/app/pages/approval/rejected_view.dart';
import 'package:sample/src/app/pages/approval/waiting_view.dart';
import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/pages/renewcontract/renewal_contract.dart';
import 'package:sample/src/app/utils/custom.dart';

SliverPadding areaCounter(
    String totalWaiting,
    String totalApproved,
    String totalRejected,
    String totalNewCustomer,
    String totalOldCustomer,
    BuildContext context,
    {bool isHorizontal}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: isHorizontal ? 35.r : 15.r,
      vertical: isHorizontal ? 30.r : 20.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Statistik',
            style: TextStyle(
              fontSize: isHorizontal ? 35.sp : 21.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 13.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(isHorizontal ? 20.r : 10.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isHorizontal ? 20.r : 10.r),
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
                              fontSize: isHorizontal ? 31.sp : 17.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Segoe ui',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 30.h : 15.h,
                        ),
                        Center(
                          child: Text(
                            convertThousand(int.parse(totalNewCustomer), 0),
                            style: TextStyle(
                              fontSize: isHorizontal ? 37.sp : 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 25.h : 10.h,
                        ),
                        Container(
                          height: isHorizontal ? 9.h : 5.h,
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(isHorizontal ? 5.r :2.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CustomerScreen(0))),
                ),
              ),
              SizedBox(
                width: isHorizontal ? 10.w : 20.w,
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(isHorizontal ? 20.r : 10.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isHorizontal ? 20.r : 10.r),
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
                              fontSize: isHorizontal ? 31.sp : 17.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Segoe ui',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 30.h : 15.h,
                        ),
                        Center(
                          child: Text(
                            convertThousand(int.parse(totalOldCustomer), 0),
                            style: TextStyle(
                              fontSize: isHorizontal ? 37.sp : 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 25.h : 10.h,
                        ),
                        Container(
                          height: isHorizontal ? 9.h : 5.h,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange[300],
                            borderRadius: BorderRadius.circular(isHorizontal ? 5.r : 2.r),
                          ),
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
            height: isHorizontal ? 25.h : 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(isHorizontal ? 20.r : 10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isHorizontal ? 20.r : 10.r),
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
                              totalWaiting,
                              style: TextStyle(
                                fontSize: isHorizontal ? 31.sp : 18.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: isHorizontal ? 22.r : 13.r,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHorizontal ? 15.h : 4.h,
                        ),
                        Text(
                          'Menunggu',
                          style: TextStyle(
                            fontSize: isHorizontal ? 29.sp : 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 15.sp : 10.h,
                        ),
                        Container(
                          height: isHorizontal ? 9.h : 5.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(isHorizontal ? 5.r : 2.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => WaitingApprovalScreen(),
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
                    padding: EdgeInsets.all(isHorizontal ? 20.r : 10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isHorizontal ? 20.r : 10.r),
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
                              totalApproved,
                              style: TextStyle(
                                fontSize: isHorizontal ? 31.sp : 18.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: isHorizontal ? 22.r : 13.r,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHorizontal ? 15.h : 4.h,
                        ),
                        Text(
                          'Disetujui',
                          style: TextStyle(
                            fontSize: isHorizontal ? 29.sp : 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 15.sp : 10.h,
                        ),
                        Container(
                          height: isHorizontal ? 9.h : 5.h,
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(isHorizontal ? 5.r : 2.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ApprovedScreen(),
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
                    padding: EdgeInsets.all(isHorizontal ? 20.r : 10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isHorizontal ? 20.r : 10.r),
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
                              totalRejected,
                              style: TextStyle(
                                fontSize: isHorizontal ? 31.sp : 18.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: isHorizontal ? 22.r : 13.r,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHorizontal ? 15.h : 4.h,
                        ),
                        Text(
                          'Ditolak',
                          style: TextStyle(
                            fontSize: isHorizontal ? 29.sp : 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: isHorizontal ? 15.sp : 10.h,
                        ),
                        Container(
                          height: isHorizontal ? 9.h : 5.h,
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(isHorizontal ? 5.r : 2.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
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
