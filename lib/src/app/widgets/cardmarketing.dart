import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/settings_posmaterial.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CardMarketing extends StatefulWidget {
  bool isHorizontal = false;
  String cardIcon;
  String cardTitle, cardSubtitle;
  dynamic navigateTo;
  int totalPos = 0;
  int totalCashback = 0;
  int totalExpense = 0;

  CardMarketing({
    Key? key,
    required this.isHorizontal,
    required this.cardIcon,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.navigateTo,
    this.totalPos = 0,
    this.totalCashback = 0,
    this.totalExpense = 0,
  }) : super(key: key);

  @override
  State<CardMarketing> createState() => _CardMarketingState();
}

class _CardMarketingState extends State<CardMarketing> {
  late MarketingFeature enumMarketing;

  bool showBadge = false;
  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';

  @override
  void initState() {
    super.initState();
    enumMarketing = getMarketingFeature(widget.cardTitle);
    getRole();
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        width: 140.w,
        height: 140.h,
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
        child: InkWell(
          onTap: () {
            if (widget.navigateTo != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => widget.navigateTo,
                ),
              );
            }
            else
            {
              handleComing(context, isHorizontal: widget.isHorizontal);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isHorizontal ? 15.r : 10.r,
              vertical: widget.isHorizontal ? 15.r : 10.r,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      padding: EdgeInsets.all(
                        5.r,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                        child: Image.asset(
                          widget.cardIcon,
                          width: 25.w,
                          height: 25.h,
                        ),
                      ),
                    ),
                    enumMarketing == MarketingFeature.POS_MATERIAL
                        ? Visibility(
                            visible: widget.totalPos > 0 ? true : false,
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: Icon(
                                Icons.notifications_on,
                                color: Colors.red.shade500,
                              ),
                            ),
                            replacement: SizedBox(
                              width: 5.w,
                            ),
                          )
                        : enumMarketing == MarketingFeature.CASHBACK
                            ? Visibility(
                                visible:
                                    widget.totalCashback > 0 ? true : false,
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Icon(
                                    Icons.notifications_on,
                                    color: Colors.red.shade500,
                                  ),
                                ),
                                replacement: SizedBox(
                                  width: 5.w,
                                ),
                              )
                            : Visibility(
                                visible: widget.totalExpense > 0 ? true : false,
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Icon(
                                    Icons.notifications_on,
                                    color: Colors.red.shade500,
                                  ),
                                ),
                                replacement: SizedBox(
                                  width: 5.w,
                                ),
                              ),
                  ],
                ),
                SizedBox(
                  height: 15.h,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cardTitle,
                      style: TextStyle(
                        fontFamily: 'Segoe Ui',
                        fontWeight: FontWeight.w600,
                        fontSize: widget.isHorizontal ? 20.sp : 15.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(
                      height: widget.isHorizontal ? 10.h : 5.h,
                    ),
                    Text(
                      widget.cardSubtitle,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontSize: widget.isHorizontal ? 14.sp : 11.sp,
                        color: Colors.grey.shade500,
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
