import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/pages/econtract/search_contract.dart';
import 'package:sample/src/app/pages/entry/newcust_view.dart';
import 'package:sample/src/app/pages/renewcontract/renewal_contract.dart';
import 'package:sample/src/app/utils/custom.dart';

checkSigned(String id, String role, BuildContext context,
    {bool isConnected}) async {
  if (isConnected) {
    String ttd = await getTtdValid(id, context, role: role);
    print(ttd);
    ttd == null
        ? handleSigned(context)
        : Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => NewcustScreen()));
  }
}

checkCustomer(String id, BuildContext context) {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CustomerScreen(int.parse(id))));
}

SliverToBoxAdapter areaMenu(
    double screenHeight, BuildContext context, String idSales, String role,
    {bool isConnected, bool isHorizontal}) {
  return SliverToBoxAdapter(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: isHorizontal ? 25.r : 15.r, horizontal: isHorizontal ? 25.r : 10.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: isHorizontal ? 15.h :10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/entry_customer_new.png',
                        width: isHorizontal ? 75.r : 50.r,
                        height: isHorizontal ? 75.r : 50.r,
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      Text(
                        'Kustomer',
                        style: TextStyle(
                            fontSize: isHorizontal ? 24.sp : 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  checkSigned(idSales, role, context, isConnected: isConnected);
                },
              ),
              GestureDetector(
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/e_contract_new.png',
                        width: isHorizontal ? 75.r : 50.r,
                        height: isHorizontal ? 75.r : 50.r,
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      Text(
                        'E-Kontrak',
                        style: TextStyle(
                            fontSize: isHorizontal ? 24.sp : 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  checkCustomer(idSales, context);
                },
              ),
              GestureDetector(
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/mon_contract.png',
                        width: isHorizontal ? 75.r : 50.r,
                        height: isHorizontal ? 75.r : 50.r,
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      Text(
                        'Monitoring',
                        style: TextStyle(
                            fontSize: isHorizontal ? 24.sp : 14.sp,
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
                      builder: (context) => SearchContract(),
                    ),
                  );
                },
              ),
              GestureDetector(
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/renew_contract.png',
                        width: isHorizontal ? 75.r : 50.r,
                        height: isHorizontal ? 75.r : 50.r,
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      Text(
                        'Ubah Kontrak',
                        style: TextStyle(
                            fontSize: isHorizontal ? 24.sp : 14.sp,
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
        ],
      ),
    ),
  );
}
