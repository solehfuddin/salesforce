import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/activity/daily_activity.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/pages/econtract/search_contract.dart';
import 'package:sample/src/app/pages/entry/newcust_view.dart';
import 'package:sample/src/app/pages/renewcontract/renewal_contract.dart';

checkSigned(String? id, String? role, BuildContext context,
    {bool isConnected = true}) async {
  if (isConnected) {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? ttd = pref.getString("ttduser") ?? '';
    print("User ttd : $ttd");

    ttd == ''
        ? handleSigned(context)
        : Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => NewcustScreen()));
  } else {
    handleConnection(context);
  }
}

checkCustomer(String id, BuildContext context) {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CustomerScreen(int.parse(id))));
}

SliverToBoxAdapter areaMenu(
  double screenHeight,
  BuildContext context,
  String? idSales,
  String? role, {
  bool isConnected = false,
  bool isHorizontal = false,
}) {
  return SliverToBoxAdapter(
    child: Container(
      padding: EdgeInsets.symmetric(
        vertical: isHorizontal ? 10.r : 10.r,
        horizontal: isHorizontal ? 5.r : 15.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: isHorizontal ? 10.h : 7.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/entry_customer_new.png',
                          width: isHorizontal ? 60.r : 45.r,
                          height: isHorizontal ? 60.r : 45.r,
                        ),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                        Text(
                          'Kustomer',
                          style: TextStyle(
                              fontSize: isHorizontal ? 17.sp : 13.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  checkSigned(idSales, role, context, isConnected: isConnected);
                },
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/e_contract_new.png',
                          width: isHorizontal ? 55.r : 45.r,
                          height: isHorizontal ? 55.r : 45.r,
                        ),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                        Text(
                          'E-Kontrak',
                          style: TextStyle(
                              fontSize: isHorizontal ? 17.sp : 13.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  checkCustomer(idSales!, context);
                },
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/mon_contract.png',
                          width: isHorizontal ? 55.r : 45.r,
                          height: isHorizontal ? 55.r : 45.r,
                        ),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                        Text(
                          'Monitoring',
                          style: TextStyle(
                              fontSize: isHorizontal ? 17.sp : 13.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchContract(),
                    ),
                  );
                },
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/renew_contract.png',
                        width: isHorizontal ? 55.r : 45.r,
                        height: isHorizontal ? 55.r : 45.r,
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      Text(
                        'Ubah Kontrak',
                        style: TextStyle(
                            fontSize: isHorizontal ? 17.sp : 13.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RenewalContract(
                        keyword: '',
                        isAdmin: false,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 15.h : 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/agenda_menu_new.png',
                          width: isHorizontal ? 55.r : 45.r,
                          height: isHorizontal ? 55.r : 45.r,
                        ),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                        Text(
                          'Aktivitas',
                          style: TextStyle(
                              fontSize: isHorizontal ? 17.sp : 13.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DailyActivity(
                        isAdmin: false,
                      ),
                    ),
                  );
                },
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  child: Center(
                    child: Column(
                      children: [
                        // Image.asset(
                        //   'assets/images/e_contract_new.png',
                        //   width: isHorizontal ? 50.r : 40.r,
                        //   height: isHorizontal ? 50.r : 40.r,
                        // ),
                        // SizedBox(
                        //   height: screenHeight * 0.015,
                        // ),
                        // Text(
                        //   'E-Kontrak',
                        //   style: TextStyle(
                        //       fontSize: isHorizontal ? 17.sp : 13.sp,
                        //       fontWeight: FontWeight.w600,
                        //       fontFamily: 'Segoe ui',
                        //       color: Colors.black54),
                        //   textAlign: TextAlign.center,
                        // ),
                        SizedBox(
                          width: isHorizontal ? 90.r : 65.r,
                        ),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  // checkCustomer(idSales!, context);
                },
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  child: Center(
                    child: Column(
                      children: [
                        // Image.asset(
                        //   'assets/images/mon_contract.png',
                        //   width: isHorizontal ? 50.r : 40.r,
                        //   height: isHorizontal ? 50.r : 40.r,
                        // ),
                        // SizedBox(
                        //   height: screenHeight * 0.015,
                        // ),
                        // Text(
                        //   'Monitoring',
                        //   style: TextStyle(
                        //       fontSize: isHorizontal ? 17.sp : 13.sp,
                        //       fontWeight: FontWeight.w600,
                        //       fontFamily: 'Segoe ui',
                        //       color: Colors.black54),
                        //   textAlign: TextAlign.center,
                        // ),
                        SizedBox(
                          width: isHorizontal ? 90.r : 65.r,
                        ),
                        SizedBox(
                          height: screenHeight * 0.015,
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => SearchContract(),
                  //   ),
                  // );
                },
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  child: Column(
                    children: [
                      // Image.asset(
                      //   'assets/images/renew_contract.png',
                      //   width: isHorizontal ? 50.r : 40.r,
                      //   height: isHorizontal ? 50.r : 40.r,
                      // ),
                      // SizedBox(
                      //   height: screenHeight * 0.015,
                      // ),
                      // Text(
                      //   'Ubah Kontrak',
                      //   style: TextStyle(
                      //       fontSize: isHorizontal ? 17.sp : 13.sp,
                      //       fontWeight: FontWeight.w600,
                      //       fontFamily: 'Segoe ui',
                      //       color: Colors.black54),
                      //   textAlign: TextAlign.center,
                      // ),
                      SizedBox(
                        width: isHorizontal ? 90.r : 65.r,
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => RenewalContract(
                  //       keyword: '',
                  //       isAdmin: false,
                  //     ),
                  //   ),
                  // );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
