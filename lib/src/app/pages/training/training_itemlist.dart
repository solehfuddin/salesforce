import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/training/training_dialogstatus.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/training_resheader.dart';

// ignore: camel_case_types, must_be_immutable
class Training_itemlist extends StatelessWidget {
  TrainingResHeader itemList;
  bool isHorizontal = false;

  Training_itemlist({
    Key? key,
    required this.itemList,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 20.r : 15.r,
        vertical: isHorizontal ? 12.r : 7.r,
      ),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: this.itemList.count,
        itemBuilder: (context, position) {
          return Card(
            elevation: 2,
            borderOnForeground: true,
            color: Colors.white,
            shadowColor: Colors.black45,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10.r,
              ),
            ),
            child: InkWell(
              splashColor: Colors.orange.shade50,
              highlightColor: Colors.orange.shade100,
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: isHorizontal ? 20.r : 10.r,
                ),
                height: 100.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.h),
                              child: Text(
                                itemList.list[position].trainerName ?? '',
                                style: TextStyle(
                                  fontFamily: 'Segoe Ui',
                                  fontSize: isHorizontal ? 20.sp : 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Row(
                                children: [
                                  Image.asset(
                                    itemList.list[position].mechanism ==
                                            "ONLINE GOOGLE MEET"
                                        ? 'assets/images/google_meet.png'
                                        : itemList.list[position].mechanism ==
                                                "ONLINE ZOOM"
                                            ? 'assets/images/zoom_meet.png'
                                            : 'assets/images/training.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: 3.w,
                                  ),
                                  Text(
                                    itemList.list[position].agenda ?? 'PENDING',
                                    style: TextStyle(
                                      fontFamily: 'Segoe Ui',
                                      fontSize: isHorizontal ? 14.sp : 11.sp,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: Visibility(
                            visible:
                                itemList.list[position].trainerPhoto!.isEmpty
                                    ? true
                                    : false,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                height: 40.h,
                                width: 40.w,
                                child: Image.asset(
                                  'assets/images/profile.png',
                                  height: 40.h,
                                  width: 40.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            replacement: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                height: 40.h,
                                width: 40.w,
                                child: Image.memory(
                                  Base64Decoder().convert(
                                    itemList.list[position].trainerPhoto!,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    Container(
                      color: Colors.orange.shade50,
                      height: 25.h,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              left: 8.w,
                            ),
                            child: Row(children: [
                              Padding(
                                padding: EdgeInsets.only(top: 1.h),
                                child: Icon(
                                  Icons.calendar_month_outlined,
                                  size: 15.r,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Text(
                                convertDateWithMonth(
                                    itemList.list[position].scheduleDate ??
                                        '-'),
                                style: TextStyle(
                                  fontFamily: 'Segoe Ui',
                                  fontSize: isHorizontal ? 17.sp : 13.sp,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ]),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              right: 8.w,
                            ),
                            child: Row(children: [
                              Padding(
                                padding: EdgeInsets.only(top: 1.h),
                                child: Icon(
                                  Icons.watch_later_outlined,
                                  size: 15.r,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Text(
                                '${itemList.list[position].scheduleStartTime} - ${itemList.list[position].scheduleEndTime} WIB',
                                style: TextStyle(
                                  fontFamily: 'Segoe Ui',
                                  fontSize: isHorizontal ? 17.sp : 13.sp,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ]),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isHorizontal ? 20.w : 10.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                itemList.list[position].opticName ?? '-',
                                style: TextStyle(
                                  fontFamily: 'Segoe Ui',
                                  fontSize: isHorizontal ? 17.sp : 13.sp,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                itemList.list[position].status ?? 'PENDING',
                                style: TextStyle(
                                  fontFamily: 'Segoe Ui',
                                  fontSize: isHorizontal ? 15.sp : 12.sp,
                                  color: itemList.list[position].status ==
                                          "PENDING"
                                      ? Colors.grey.shade500
                                      : itemList.list[position].status ==
                                              "APPROVE"
                                          ? Colors.blue.shade700
                                          : itemList.list[position].status ==
                                                  "REJECT"
                                              ? Colors.red.shade700
                                              : Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
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
                showModalBottomSheet(
                  context: context,
                  elevation: 2,
                  enableDrag: true,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        15.r,
                      ),
                      topRight: Radius.circular(
                        15.r,
                      ),
                    ),
                  ),
                  builder: (context) {
                    return SingleChildScrollView(
                      child: Training_DialogStatus(
                        item: itemList.list[position],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
