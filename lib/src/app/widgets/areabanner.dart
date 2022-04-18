import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';

SliverToBoxAdapter areaBanner(double screenHeight, BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15.r, vertical: 10.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                // 'Get rewarded with Challenges',
                'Dapatkan hadiah menarik',
                style: TextStyle(
                  fontSize: 23.sp,
                  fontFamily: 'Segoe ui',
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Container(
                padding: EdgeInsets.all(8.r),
                height: screenHeight * 0.18,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      'assets/images/espresso.png',
                      width: 50.r,
                      height: 70.r,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gratis kopi, misi 5 kustomer baru ..',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          'Berakhir pada 28 Feb 2022',
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          'Ikuti misi',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          handleComing(context);
        },
      ),
    );
  }