import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/settings_training.dart';
import 'package:sample/src/domain/entities/training_resheader.dart';

import '../../utils/custom.dart';
import 'training_dialogstatus.dart';

// ignore: camel_case_types, must_be_immutable
class Training_ItemApproval extends StatefulWidget {
  TrainingResHeader itemList;
  bool isHorizontal = false;
  bool isPending = false;

  Training_ItemApproval({
    Key? key,
    required this.itemList,
    required this.isHorizontal,
    required this.isPending,
  }) : super(key: key);

  @override
  State<Training_ItemApproval> createState() => _Training_ItemApprovalState();
}

// ignore: camel_case_types
class _Training_ItemApprovalState extends State<Training_ItemApproval> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: widget.isHorizontal ? 20.r : 15.r,
        vertical: widget.isHorizontal ? 12.r : 7.r,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.itemList.count,
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
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: widget.isHorizontal ? 20.r : 10.r,
                ),
                height: widget.isPending ? 143.h : 100.h,
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
                                widget.itemList.list[position].trainerName ?? '',
                                style: TextStyle(
                                  fontFamily: 'Segoe Ui',
                                  fontSize: widget.isHorizontal ? 20.sp : 15.sp,
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
                                    widget.itemList.list[position].mechanism ==
                                            "ONLINE GOOGLE MEET"
                                        ? 'assets/images/google_meet.png'
                                        : widget.itemList.list[position]
                                                    .mechanism ==
                                                "ONLINE ZOOM"
                                            ? 'assets/images/zoom_meet.png'
                                            : 'assets/images/training.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: 3.w,
                                  ),
                                  Visibility(
                                    visible:
                                        widget.itemList.list[position].agenda!.length >
                                            0,
                                    child: Text(
                                      widget.itemList.list[position].agenda!.length >
                                              40
                                          ? widget.itemList.list[position].agenda!
                                              .substring(0, 32) + '...'
                                          : widget.itemList.list[position].agenda!,
                                      style: TextStyle(
                                        fontFamily: 'Segoe Ui',
                                        fontSize: widget.isHorizontal ? 14.sp : 11.sp,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    replacement: Text(
                                      'PENDING',
                                      style: TextStyle(
                                        fontFamily: 'Segoe Ui',
                                        fontSize: widget.isHorizontal ? 14.sp : 11.sp,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                            visible: widget
                                    .itemList.list[position].trainerPhoto!.isEmpty
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
                                    widget.itemList.list[position].trainerPhoto!,
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
                                    widget.itemList.list[position].scheduleDate ??
                                        '-'),
                                style: TextStyle(
                                  fontFamily: 'Segoe Ui',
                                  fontSize: widget.isHorizontal ? 17.sp : 13.sp,
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
                                '${widget.itemList.list[position].scheduleStartTime} - ${widget.itemList.list[position].scheduleEndTime} WIB',
                                style: TextStyle(
                                  fontFamily: 'Segoe Ui',
                                  fontSize: widget.isHorizontal ? 17.sp : 13.sp,
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
                          horizontal: widget.isHorizontal ? 20.w : 10.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.itemList.list[position].opticName ?? '-',
                                style: TextStyle(
                                  fontFamily: 'Segoe Ui',
                                  fontSize: widget.isHorizontal ? 17.sp : 13.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: widget.isPending,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5.h,
                          ),
                          handleAction(
                            context: context,
                            isHorizontal: widget.isHorizontal,
                            header: widget.itemList.list[position],
                          ),
                        ],
                      ),
                      replacement: SizedBox(
                        width: 5.w,
                      ),
                    ),
                  ],
                ),
              ),
              onTap : widget.isPending ? null : () {
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
                        item: widget.itemList.list[position],
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
