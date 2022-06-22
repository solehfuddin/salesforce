import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/signed/signed_view.dart';

SliverPadding areaFeature(double screenHeight, BuildContext context,
    {bool isHorizontal}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: isHorizontal ? 35.r : 15.r,
      vertical: isHorizontal ? 15.r : 10.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tanda tangan digital',
            style: TextStyle(
              fontSize: isHorizontal ? 35.sp : 21.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 13.h,
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(
                isHorizontal ? 20.r : 15.r,
              ),
              height: isHorizontal ? screenHeight * 0.24 : screenHeight * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isHorizontal ? 20.r : 5.r),
                border: Border.all(
                  color: Colors.black26,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        'assets/images/digital_sign.png',
                        width: isHorizontal ? 55.w : 40.w,
                        height: isHorizontal ? 55.h : 40.h,
                      ),
                      SizedBox(
                        width: isHorizontal ? 0.w : 8.w,
                      ),
                      isHorizontal
                          ? Expanded(
                            flex: 1,
                            child: Text(
                              // 'Set digital signed easily to save your time when approved new customer',
                              'Tanda tangan digital untuk memudahkan proses pengajuan kustomer baru',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                          )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  // 'Set digital signed easily to save your',
                                  'Tanda tangan digital untuk memudahkan',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: 'Segoe ui',
                                  ),
                                ),
                                Text(
                                  // 'time when approved new customer',
                                  'proses pengajuan kustomer baru',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: 'Segoe ui',
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  Container(
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Center(
                    child: Text(
                      // 'View Details',
                      'Selengkapnya',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: isHorizontal ? 24.sp : 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Segoe ui',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => SignedScreen())),
          ),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    ),
  );
}
