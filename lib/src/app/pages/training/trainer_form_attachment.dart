import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/training_controller.dart';

import '../../widgets/multiImage.dart';

// ignore: must_be_immutable
class TrainerFormAttachment extends StatefulWidget {
  bool isHorizontal;
  TrainerFormAttachment({
    Key? key,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  State<TrainerFormAttachment> createState() => _TrainerFormAttachmentState();
}

class _TrainerFormAttachmentState extends State<TrainerFormAttachment> {
  TrainingController controller = Get.find<TrainingController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: widget.isHorizontal ? 20.r : 12.r,
        right: widget.isHorizontal ? 20.r : 12.r,
        top: widget.isHorizontal ? 20.r : 10.r,
        bottom: widget.isHorizontal ? 20.r : 5.r,
      ),
      child: Card(
        elevation: 2,
        borderOnForeground: true,
        color: Colors.green.shade700,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.r,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                vertical: widget.isHorizontal ? 20.r : 10.r,
              ),
              child: Center(
                child: Text(
                  'Lampiran Training',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isHorizontal ? 26.sp : 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Container(
                color: Colors.white,
                padding: EdgeInsets.all(
                  widget.isHorizontal ? 24.r : 12.r,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambahkan attachment',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize:
                            widget.isHorizontal ? 20.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    MultiImage(
                      dottedColor: Colors.blue.shade800,
                      backgroundColor: Colors.blue.shade100,
                      buttonBackgroundColor: Colors.blue.shade800,
                      labelColor: Colors.blue.shade900,
                      listAttachment: controller.listTrainingAttachment,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}
