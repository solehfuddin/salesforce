import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/settings_cashback.dart';

// ignore: must_be_immutable
class CashbackWidgetType extends StatefulWidget {
  final Function(String? varName, dynamic input) updateParent;
  bool isHorizontal = false;
  bool isSelected = false;
  String cardIcon, cardTitle;
  CashbackWidgetType({
    Key? key,
    required this.updateParent,
    required this.isHorizontal,
    required this.isSelected,
    required this.cardIcon,
    required this.cardTitle,
  }) : super(key: key);

  @override
  State<CashbackWidgetType> createState() => _CashbackWidgetTypeState();
}

class _CashbackWidgetTypeState extends State<CashbackWidgetType> {
  late CashbackType cashbackType;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        width: 87.w,
        height: 87.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(
              10.r,
            ),
          ),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Visibility(
          visible: widget.isSelected,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isHorizontal ? 15.r : 10.r,
              vertical: widget.isHorizontal ? 15.r : 10.r,
            ),
            decoration: BoxDecoration(
              color: MyColors.purpleColor,
              borderRadius: BorderRadius.all(
                Radius.circular(
                  10.r,
                ),
              ),
              border: Border.all(
                color: MyColors.purpleColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 30.r,
                ),
                Center(
                  child: Text(
                    widget.cardTitle,
                    style: TextStyle(
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w600,
                      fontSize: widget.isHorizontal ? 14.sp : 12.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          replacement: InkWell(
            onTap: () {
              widget.updateParent('selectedCashbackType', widget.cardTitle);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isHorizontal ? 15.r : 10.r,
                vertical: widget.isHorizontal ? 15.r : 10.r,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 30.w,
                    height: 30.w,
                    padding: EdgeInsets.all(
                      5.r,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Center(
                      child: Image.asset(
                        widget.cardIcon,
                        width: 22.w,
                        height: 22.h,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          widget.cardTitle,
                          style: TextStyle(
                            fontFamily: 'Segoe Ui',
                            fontWeight: FontWeight.w600,
                            fontSize: widget.isHorizontal ? 14.sp : 12.sp,
                            color: Colors.black87,
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
      ),
    );
  }
}
