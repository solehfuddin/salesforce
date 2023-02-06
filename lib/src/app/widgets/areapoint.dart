import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';

SliverToBoxAdapter areaPoint(
  double screenHeight,
  BuildContext context, {
  bool isHorizontal = false,
}) {
  return SliverToBoxAdapter(
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 18.r : 18.r,
        vertical: isHorizontal ? 5.r : 0.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(isHorizontal ? 15.r : 10.r),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          BorderRadius.circular(isHorizontal ? 20.r : 10.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Poin',
                          style: TextStyle(
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 16.sp : 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.01,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 18.sp : 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Image.asset(
                              'assets/images/point.png',
                              width: isHorizontal ? 24.r : 20.r,
                              height: isHorizontal ? 24.r : 20.r,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    handleComing(context, isHorizontal: isHorizontal);
                  },
                ),
              ),
              SizedBox(
                width: isHorizontal ? 15.w : 20.w,
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(isHorizontal ? 15.r : 10.r),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          BorderRadius.circular(isHorizontal ? 20.r : 10.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Penghargaan',
                          style: TextStyle(
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 16.sp : 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.01,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lebih lanjut',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 18.sp : 15.5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Image.asset(
                              'assets/images/reward.png',
                              width: isHorizontal ? 24.r : 20.r,
                              height: isHorizontal ? 24.r : 20.r,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    handleComing(context, isHorizontal: isHorizontal);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
