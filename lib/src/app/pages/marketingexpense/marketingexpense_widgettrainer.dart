import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/trainer.dart';

// ignore: camel_case_types, must_be_immutable
class Marketingexpense_widgettrainer extends StatefulWidget {
  Trainer trainer;
  bool isSelected = false;
  Marketingexpense_widgettrainer({
    Key? key,
    required this.isSelected,
    required this.trainer,
  }) : super(key: key);

  @override
  State<Marketingexpense_widgettrainer> createState() =>
      _Marketingexpense_widgethourState();
}

// ignore: camel_case_types
class _Marketingexpense_widgethourState
    extends State<Marketingexpense_widgettrainer> {
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        width: 95.w,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Colors.green.shade400
              : widget.trainer.isOnlne == "NO"
                  ? Colors.grey.shade200
                  : Colors.blueGrey.shade100,
          borderRadius: BorderRadius.all(
            Radius.circular(
              10.r,
            ),
          ),
          border: Border.all(
            color: widget.isSelected
                ? Colors.green.shade400
                : widget.trainer.isOnlne == "NO"
                    ? Colors.grey.shade200
                    : Colors.blueGrey.shade100,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (widget.trainer.isOnlne == "YES") {
              meController.selectedTrainer.value = widget.trainer.name ?? '';
              print(meController.selectedTrainer.value);

              // Get.toNamed('/marketingexpenseformtrainer/${widget.trainer}');
            } else {
              if (widget.trainer.offlineReason == "SAKIT") {
                Get.snackbar(
                  'Informasi',
                  'Trainer sedang ${widget.trainer.offlineReason?.toLowerCase()}',
                  backgroundColor: Colors.red.shade400,
                  colorText: Colors.white,
                  animationDuration: Duration(seconds: 1),
                  duration: Duration(seconds: 2),
                  messageText: Text(
                    'Trainer sedang ${widget.trainer.offlineReason?.toLowerCase()}',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'Montserrat'),
                  ),
                );
              }
              else
              {
                Get.snackbar(
                  'Informasi',
                  'Trainer sedang ${widget.trainer.offlineReason?.toLowerCase()} hingga ${convertDateWithMonth(widget.trainer.offlineUntil ?? '')}',
                  backgroundColor: Colors.red.shade400,
                  colorText: Colors.white,
                  animationDuration: Duration(seconds: 1),
                  duration: Duration(seconds: 2),
                  messageText: Text(
                    'Trainer sedang ${widget.trainer.offlineReason?.toLowerCase()} hingga ${convertDateWithMonth(widget.trainer.offlineUntil ?? '')}',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'Montserrat'),
                  ),
                );
              }
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 8.r,
              horizontal: 5.r,
            ),
            child: Column(
              children: [
                Visibility(
                  visible: widget.trainer.imgprofile!.isEmpty ? true : false,
                  child: CircleAvatar(
                    radius: 18.r,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/profile.png',
                        height: 36.h,
                        width: 36.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  replacement: CircleAvatar(
                    radius: 18.r,
                    backgroundImage: MemoryImage(
                      Base64Decoder().convert(widget.trainer.imgprofile!),
                    ),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 3.h,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 1.w,
                          ),
                          Icon(
                            Icons.circle_rounded,
                            color: widget.trainer.isOnlne == "YES" ? Colors.green : Colors.red,
                            size: 10.r,
                          ),
                          SizedBox(
                            width: 3.w,
                          ),
                          Text(
                            widget.trainer.isOnlne == "YES" ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontFamily: 'Segoe Ui',
                            ),
                          ),
                          SizedBox(
                            width: 1.w,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Center(
                      child: Text(
                        widget.trainer.name ?? '',
                        style: TextStyle(
                          color:
                              widget.isSelected ? Colors.white : Colors.black54,
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
