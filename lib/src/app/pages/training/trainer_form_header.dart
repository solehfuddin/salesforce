import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/training/trainer_form_detail.dart';
import 'package:sample/src/app/pages/training/trainer_form_optik.dart';
import 'package:sample/src/app/pages/training/trainer_form_scheduler.dart';

// ignore: must_be_immutable
class TrainerFormHeader extends StatefulWidget {
  bool isHorizontal;

  TrainerFormHeader({
    Key? key,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  State<TrainerFormHeader> createState() => _TrainerFormHeaderState();
}

class _TrainerFormHeaderState extends State<TrainerFormHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: widget.isHorizontal ? 20.r : 12.r,
        right: widget.isHorizontal ? 20.r : 12.r,
        top: widget.isHorizontal ? 20.r : 5.r,
        bottom: widget.isHorizontal ? 20.r : 10.r,
      ),
      child: Card(
        elevation: 2,
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
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    10.r,
                  ),
                  topRight: Radius.circular(
                    10.r,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: widget.isHorizontal ? 20.r : 10.r,
              ),
              child: Center(
                child: Text(
                  'Form Training',
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
                  TrainerFormScheduler(
                    isHorizontal: widget.isHorizontal,
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 20.h : 15.h,
                  ),
                  TrainerFormOptik(
                    isHorizontal: widget.isHorizontal,
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 10.h,
                  ),
                  TrainerFormDetail(
                    isHorizontal: widget.isHorizontal,
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
