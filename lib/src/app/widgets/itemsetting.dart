import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class ItemSetting extends StatelessWidget {
  IconData? iconData;
  Color? colorIcon, backgroundIcon;
  String? label, contain, changeContain;
  double? marginHor, marginVer;
  bool isOpen;

  ItemSetting({
    Key? key,
    this.iconData,
    this.label,
    this.contain,
    this.changeContain,
    this.marginHor = 0,
    this.marginVer = 0,
    this.isOpen = false,
    this.colorIcon,
    this.backgroundIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: marginHor ?? 0,
        vertical: marginVer ?? 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 33.w,
            height: 33.w,
            decoration: BoxDecoration(
              color: backgroundIcon,
              borderRadius: BorderRadius.circular(
                25.r,
              ),
            ),
            child: Center(
              child: Icon(
                iconData,
                size: 20,
                color: colorIcon,
              ),
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label ?? '',
                  style: TextStyle(
                    fontFamily: 'Segoe Ui',
                    fontSize: 12.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Text(
                  contain ?? '',
                  style: TextStyle(
                    fontFamily: 'Segoe Ui',
                    fontSize: 11.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Visibility(
                  visible: changeContain != '',
                  child: Column(
                    children: [
                      SizedBox(
                        height: 1.h,
                      ),
                      Text(
                        changeContain ?? '',
                        style: TextStyle(
                          fontFamily: 'Segoe Ui',
                          fontSize: 11.sp,
                          color: Colors.orange.shade400,
                          fontWeight: FontWeight.w500,
                        ),
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
          SizedBox(
            width: 10.w,
          ),
          Visibility(
            visible: isOpen,
            child: Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
            replacement: changeContain != ''
                ? Tooltip(
                  message: 'Terdapat perubahan data ${label?.toLowerCase()}',
                  child: Icon(
                      Icons.change_circle,
                      color: Colors.orange.shade300,
                    ),
                )
                : SizedBox(
                    width: 5.w,
                  ),
          ),
        ],
      ),
    );
  }
}
