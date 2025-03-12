import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../domain/entities/trainer.dart';
import '../../controllers/training_controller.dart';

// ignore: must_be_immutable
class TrainerList extends StatefulWidget {
  List<Trainer>? list = List.empty(growable: true);
  bool isHorizontal;
  TrainerList({
    Key? key,
    this.list,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  State<TrainerList> createState() => _TrainerListState();
}

class _TrainerListState extends State<TrainerList> {
  TrainingController controller = Get.find<TrainingController>();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      padding: widget.isHorizontal
          ? EdgeInsets.symmetric(
              horizontal: 3.r,
              vertical: 10.r,
            )
          : EdgeInsets.symmetric(
              horizontal: 20.r,
            ),
      itemCount: widget.list?.length ?? 0,
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 8.h,
        );
      },
      shrinkWrap: true,
      itemBuilder: (context, position) {
        return Material(
          color: Colors.white,
          child: InkWell(
            splashColor: Colors.green.shade200,
            highlightColor: Colors.green.shade200,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.all(widget.isHorizontal ? 17.r : 10.r),
              height: widget.isHorizontal ? 95.h : 85.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.isHorizontal ? 20.r : 10.r),
                ),
                border: Border.all(
                  color: Colors.black12,
                ),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Visibility(
                        visible: widget.list![position].imgprofile!.isEmpty
                            ? true
                            : false,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            height: 45.h,
                            width: 45.w,
                            child: Image.asset(
                              'assets/images/profile.png',
                              height: 45.h,
                              width: 45.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        replacement: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            height: 45.h,
                            width: 45.w,
                            child: Image.memory(
                              Base64Decoder().convert(
                                widget.list![position].imgprofile!,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2.r,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              top: 1.r,
                            ),
                            child: Icon(
                              Icons.circle_rounded,
                              color: widget.list![position].isOnlne == "YES"
                                  ? Colors.green
                                  : Colors.grey,
                              size: 10.r,
                            ),
                          ),
                          SizedBox(
                            width: 3.w,
                          ),
                          Text(
                            widget.list![position].isOnlne == "YES"
                                ? "Ready"
                                : "Offline",
                            style: TextStyle(
                              fontSize: widget.isHorizontal ? 14.sp : 11.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Segoe ui',
                              color: widget.list![position].isOnlne == "YES"
                                  ? Colors.green.shade500
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        widget.list?[position].name ?? 'Tidak dikenali',
                        style: TextStyle(
                          fontSize: widget.isHorizontal ? 16.sp : 13.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Segoe ui',
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.list?[position].trainerRole ?? '-',
                        style: TextStyle(
                          fontSize: widget.isHorizontal ? 12.sp : 11.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          color: Colors.black38,
                        ),
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.r,
                              vertical: 5.r,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              'Appointment',
                              style: TextStyle(
                                fontSize: widget.isHorizontal ? 14.sp : 10.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            type: MaterialType.card,
                            color: Colors.grey.shade200,
                            child: InkWell(
                              onTap: () {},
                              splashColor: Colors.green.shade200,
                              highlightColor: Colors.green.shade200,
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 5.r,
                                  vertical: 5.r,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: Icon(
                                  Icons.assignment,
                                  size: 12.r,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            type: MaterialType.card,
                            color: Colors.grey.shade200,
                            child: InkWell(
                              onTap: () {
                                if (widget.list![position].isOnlne == "YES")
                                {
                                  controller.trainer.value = widget.list![position];
                                  Get.toNamed("/trainerProfile");
                                }
                                else 
                                {
                                  Get.snackbar(
                                      'Informasi',
                                      'Trainer tidak dapat dipilih karena sedang berhalangan (${widget.list![position].offlineReason})',
                                      backgroundColor: Colors.amber.shade500,
                                      animationDuration: Duration(seconds: 1),
                                      duration: Duration(seconds: 2),
                                    );
                                }
                              },
                              splashColor: Colors.green.shade200,
                              highlightColor: Colors.green.shade200,
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 5.r,
                                  vertical: 5.r,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: Icon(
                                  Icons.account_circle,
                                  size: 12.r,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () {
              if (widget.list![position].isOnlne == "YES")
              {
                controller.trainer.value = widget.list![position];
                Get.toNamed("/trainerProfile");
              }
              else 
              {
                 Get.snackbar(
                    'Informasi',
                    'Trainer tidak dapat dipilih karena sedang berhalangan (${widget.list![position].offlineReason})',
                    backgroundColor: Colors.amber.shade500,
                    animationDuration: Duration(seconds: 1),
                    duration: Duration(seconds: 2),
                  );
              }
            },
          ),
        );
      },
    );
  }
}
