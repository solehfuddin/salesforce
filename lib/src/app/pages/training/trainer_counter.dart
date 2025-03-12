import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class TrainerCounter extends StatefulWidget {
  int totalSchedule, totalReschedule, totalHistory;
  TrainerCounter({
    Key? key,
    this.totalSchedule = 0,
    this.totalReschedule = 0,
    this.totalHistory = 0,
  }) : super(key: key);

  @override
  State<TrainerCounter> createState() => _TrainerCounterState();
}

class _TrainerCounterState extends State<TrainerCounter> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(isHorizontal: true);
      }

      return childWidget(isHorizontal: false);
    });
  }

  Widget childWidget({
    bool isHorizontal = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 20.r : 15.r,
      ),
      padding: EdgeInsets.all(
        isHorizontal ? 20.r : 15.r,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade400,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(
                isHorizontal ? 15.r : 10.r,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.totalSchedule.toString(),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isHorizontal ? 38.sp : 28.sp,
                      color: Colors.green.shade200,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 5.h : 2.h,
                  ),
                  Text(
                    'Terjadwal',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isHorizontal ? 14.sp : 11.sp,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: isHorizontal ? 20.w : 15.w,
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(
                isHorizontal ? 15.r : 10.r,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.totalReschedule.toString(),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isHorizontal ? 38.sp : 28.sp,
                      color: Colors.blue.shade200,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 5.h : 2.h,
                  ),
                  Text(
                    'Konfirmasi',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isHorizontal ? 14.sp : 11.sp,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: isHorizontal ? 20.w : 15.w,
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(
                isHorizontal ? 15.r : 10.r,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.totalHistory.toString(),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isHorizontal ? 38.sp : 28.sp,
                      color: Colors.red.shade200,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 5.h : 2.h,
                  ),
                  Text(
                    'Riwayat',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isHorizontal ? 14.sp : 11.sp,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
