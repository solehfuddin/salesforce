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
    BuildContext context) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
      vertical: 20.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Statistik',
            style: TextStyle(
              fontSize: 21.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 13.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
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
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Segoe ui',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Center(
                          child: Text(
                            convertThousand(int.parse(totalNewCustomer), 0),
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(2.r),
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
                width: 20.w,
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
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
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Segoe ui',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Center(
                          child: Text(
                            convertThousand(int.parse(totalOldCustomer), 0),
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange[300],
                            borderRadius: BorderRadius.circular(2.r),
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
            height: 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
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
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 13.r,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          'Menunggu',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(2.r),
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
                width: 20.w,
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
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
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 13.r,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          'Disetujui',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(2.r),
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
                width: 20.w,
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
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
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 13.r,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          'Ditolak',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(2.r),
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
