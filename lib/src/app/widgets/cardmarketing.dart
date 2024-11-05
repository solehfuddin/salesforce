import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/settings_posmaterial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/service/service_marketingexpense.dart';

// ignore: must_be_immutable
class CardMarketing extends StatefulWidget {
  bool isHorizontal = false;
  String cardIcon;
  String cardTitle, cardSubtitle;
  dynamic navigateTo;
  int totalPos = 0;
  int totalTraining = 0;
  int totalExpense = 0;

  CardMarketing({
    Key? key,
    required this.isHorizontal,
    required this.cardIcon,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.navigateTo,
    this.totalPos = 0,
    this.totalTraining = 0,
    this.totalExpense = 0,
  }) : super(key: key);

  @override
  State<CardMarketing> createState() => _CardMarketingState();
}

class _CardMarketingState extends State<CardMarketing> {
  ServiceMarketingExpense serviceME = new ServiceMarketingExpense();
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
    print("Total Me widget : ${widget.totalExpense}");

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
        width: 145.w,
        height: 145.h,
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
              horizontal: widget.isHorizontal ? 13.r : 10.r,
              vertical: widget.isHorizontal ? 13.r : 10.r,
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
                      width: 35.w,
                      height: 35.w,
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
                          width: 24.w,
                          height: 24.h,
                        ),
                      ),
                    ),
                    enumMarketing == MarketingFeature.POS_MATERIAL
                        ? Visibility(
                            visible: widget.totalPos > 0 ? true : false,
                            child: SizedBox(
                              height: 15,
                              width: 15,
                              child: Icon(
                                Icons.notifications_on,
                                color: Colors.red.shade500,
                              ),
                            ),
                            replacement: SizedBox(
                              width: 5.w,
                            ),
                          )
                        : enumMarketing == MarketingFeature.TRAINING
                            ? Visibility(
                                visible:
                                    widget.totalTraining > 0 ? true : false,
                                child: SizedBox(
                                  height: 15,
                                  width: 15,
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
                                  height: 15,
                                  width: 15,
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
                        fontSize: widget.isHorizontal ? 13.sp : 11.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(
                      height: widget.isHorizontal ? 5.h : 5.h,
                    ),
                    Text(
                      widget.cardSubtitle,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontSize: widget.isHorizontal ? 12.sp : 11.sp,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.justify,
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
