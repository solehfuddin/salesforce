import 'dart:convert';

import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/pages/trainer/trainer_reschedule.dart';
import 'package:sample/src/domain/entities/training_header.dart';
import '../utils/custom.dart';

// ignore: must_be_immutable
class DialogReschedule extends StatefulWidget {
  TrainingHeader? item;
  DialogReschedule({Key? key, this.item}) : super(key: key);

  @override
  State<DialogReschedule> createState() => _DialogRescheduleState();
}

class _DialogRescheduleState extends State<DialogReschedule> {
  onButtonPressed() async {
    Get.to(TrainerReschedule());

    return () {};
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(isHor: true);
      }

      return childWidget(isHor: false);
    });
  }

  Widget childWidget({bool isHor = false}) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isHor ? 10.r : 12.r,
            horizontal: isHor ? 15.r : 8.r,
          ),
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
                          widget.item?.trainerName ?? '',
                          style: TextStyle(
                            fontFamily: 'Segoe Ui',
                            fontSize: isHor ? 20.sp : 15.sp,
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
                            Text(
                              widget.item!.agenda!.length > 30
                                  ? widget.item!.agenda!.substring(0, 27) +
                                      '...'
                                  : widget.item!.agenda!,
                              style: TextStyle(
                                fontFamily: 'Segoe Ui',
                                fontSize: isHor ? 14.sp : 11.sp,
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
                          widget.item!.trainerPhoto!.isEmpty ? true : false,
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
                              widget.item!.trainerPhoto!,
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
                              widget.item?.scheduleDate ?? '-'),
                          style: TextStyle(
                            fontFamily: 'Segoe Ui',
                            fontSize: isHor ? 15.sp : 12.sp,
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
                          '${widget.item?.scheduleStartTime} - ${widget.item?.scheduleEndTime} WIB',
                          style: TextStyle(
                            fontFamily: 'Segoe Ui',
                            fontSize: isHor ? 15.sp : 12.sp,
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
                padding: EdgeInsets.symmetric(horizontal: isHor ? 20.w : 10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan Trainer : ${widget.item?.rescheduleNotes ?? ''}',
                      style: TextStyle(
                        fontFamily: 'Segoe Ui',
                        fontSize: isHor ? 14.sp : 11.sp,
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: EasyButton(
                        idleStateWidget: Text(
                          "Selengkapnya",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700),
                        ),
                        loadingStateWidget: CircularProgressIndicator(
                          strokeWidth: 3.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        useEqualLoadingStateWidgetDimension: true,
                        useWidthAnimation: true,
                        height: 30.h,
                        width: 90.w,
                        borderRadius: 15.r,
                        buttonColor: Colors.blue.shade600,
                        elevation: 2.0,
                        onPressed: onButtonPressed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
