import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';

SliverToBoxAdapter areaBanner(
  double screenHeight,
  BuildContext context, {
  bool isHorizontal = false,
}) {
  return SliverToBoxAdapter(
    child: GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isHorizontal ? 18.r : 18.r,
          vertical: isHorizontal ? 10.r : 15.r,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              // 'Get rewarded with Challenges',
              'Dapatkan hadiah menarik',
              style: TextStyle(
                fontSize: isHorizontal ? 20.sp : 18.sp,
                fontFamily: 'Segoe ui',
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: isHorizontal ? 20.h : 13.h,
            ),
            Container(
              padding: EdgeInsets.all(8.r),
              height: isHorizontal ? screenHeight * 0.31 : screenHeight * 0.18,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black12,
                ),
                borderRadius: BorderRadius.circular(isHorizontal ? 15.r : 5.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'assets/images/espresso.png',
                      width: isHorizontal ? 45.r : 35.r,
                      height: isHorizontal ? 65.r : 55.r,
                    ),
                  ),
                  SizedBox(
                    width: isHorizontal ? 5.w : 10.w,
                  ),
                  isHorizontal
                      ? Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gratis kopi, misi 5 kustomer baru harus terselesaikan dengan baik',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Segoe ui',
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                'Berakhir pada 28 Feb 2022',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
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
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gratis kopi, misi 5 kustomer baru ..',
                              style: TextStyle(
                                fontSize: 14.sp,
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
        // if (mounted)
        handleComing(context, isHorizontal: isHorizontal);
      },
    ),
  );
}
