import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/src/app/pages/activity/daily_activity.dart';
import 'package:sample/src/app/pages/attendance/attendance.dart';
// import 'package:sample/src/app/pages/cashback/cashback_screen.dart';
import 'package:sample/src/app/pages/eform/eform.dart';
import 'package:sample/src/app/pages/inkaro/list_customer.dart';
import 'package:sample/src/app/pages/inkaro_approval/complete_inkaro_approval.dart';
import 'package:sample/src/app/pages/inkaro_approval/pencairan_inkaro_approval.dart';
// import 'package:sample/src/app/pages/news/product_corner.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_screen.dart';
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
  String? role,
  String? divisi, {
  bool isConnected = false,
  bool isHorizontal = false,
}) {
  return SliverToBoxAdapter(
    child: Container(
      padding: EdgeInsets.symmetric(
        vertical: isHorizontal ? 10.r : 10.r,
        horizontal: isHorizontal ? 5.r : 15.r,
      ),
      child: role == "STAFF"
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: isHorizontal ? 10.h : 7.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/check_in_attendance.png',
                                  width: isHorizontal ? 55.r : 45.r,
                                  height: isHorizontal ? 55.r : 45.r,
                                ),
                                SizedBox(
                                  height: screenHeight * 0.015,
                                ),
                                Text(
                                  'Masuk',
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
                        onTap: () async {
                          await Permission.camera.request();
                          if (await Permission.camera.isGranted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AttendanceScreen(
                                  isCekin: true,
                                ),
                              ),
                            );
                          } else {
                            print('Access camera tidak diizinkan');
                          }
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/check_out_attendance.png',
                                  width: isHorizontal ? 55.r : 45.r,
                                  height: isHorizontal ? 55.r : 45.r,
                                ),
                                SizedBox(
                                  height: screenHeight * 0.015,
                                ),
                                Text(
                                  'Pulang',
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
                        onTap: () async {
                          await Permission.camera.request();
                          if (await Permission.camera.isGranted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AttendanceScreen(
                                  isCekin: false,
                                ),
                              ),
                            );
                          } else {
                            print('Access camera tidak diizinkan');
                          }
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/e-form.png',
                                  width: isHorizontal ? 55.r : 45.r,
                                  height: isHorizontal ? 55.r : 45.r,
                                ),
                                SizedBox(
                                  height: screenHeight * 0.015,
                                ),
                                Text(
                                  'E-form',
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
                              builder: (context) => EformScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Center(
                            child: Column(
                              children: [
                                // Image.asset(
                                //   'assets/images/product_corner.png',
                                //   width: isHorizontal ? 55.r : 45.r,
                                //   height: isHorizontal ? 55.r : 45.r,
                                // ),
                                // SizedBox(
                                //   height: screenHeight * 0.015,
                                // ),
                                // Text(
                                //   'Product Corner',
                                //   style: TextStyle(
                                //     fontSize: isHorizontal ? 17.sp : 13.sp,
                                //     fontWeight: FontWeight.w600,
                                //     fontFamily: 'Segoe ui',
                                //     color: Colors.black54,
                                //     overflow: TextOverflow.ellipsis,
                                //   ),
                                //   textAlign: TextAlign.center,
                                //   maxLines: 1,
                                // ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => ProductCornerScreen(),
                          //   ),
                          // );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )
          : role == "ADMIN" && divisi == "SALES"
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: isHorizontal ? 0.h : 0.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/check_in_attendance.png',
                                      width: isHorizontal ? 55.r : 45.r,
                                      height: isHorizontal ? 55.r : 45.r,
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.015,
                                    ),
                                    Text(
                                      'Masuk',
                                      style: TextStyle(
                                          fontSize:
                                              isHorizontal ? 17.sp : 13.sp,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Segoe ui',
                                          color: Colors.black54),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () async {
                              await Permission.camera.request();
                              if (await Permission.camera.isGranted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AttendanceScreen(
                                      isCekin: true,
                                    ),
                                  ),
                                );
                              } else {
                                print('Access camera tidak diizinkan');
                              }
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/check_out_attendance.png',
                                      width: isHorizontal ? 55.r : 45.r,
                                      height: isHorizontal ? 55.r : 45.r,
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.015,
                                    ),
                                    Text(
                                      'Pulang',
                                      style: TextStyle(
                                          fontSize:
                                              isHorizontal ? 17.sp : 13.sp,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Segoe ui',
                                          color: Colors.black54),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () async {
                              await Permission.camera.request();
                              if (await Permission.camera.isGranted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AttendanceScreen(
                                      isCekin: false,
                                    ),
                                  ),
                                );
                              } else {
                                print('Access camera tidak diizinkan');
                              }
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/e-form.png',
                                      width: isHorizontal ? 55.r : 45.r,
                                      height: isHorizontal ? 55.r : 45.r,
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.015,
                                    ),
                                    Text(
                                      'E-form',
                                      style: TextStyle(
                                          fontSize:
                                              isHorizontal ? 17.sp : 13.sp,
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
                                  builder: (context) => EformScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/inkaro.png',
                                      width: isHorizontal ? 55.r : 45.r,
                                      height: isHorizontal ? 55.r : 45.r,
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.015,
                                    ),
                                    Text(
                                      'Inkaro',
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 17.sp : 13.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Segoe ui',
                                        color: Colors.black54,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.sp),
                                    topRight: Radius.circular(15.sp),
                                  ),
                                ),
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      top: 25.00.sp,
                                      bottom: 25.00.sp,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 10.0.sp, right: 5.0.sp),
                                            child: TextButton.icon(
                                              style: TextButton.styleFrom(
                                                textStyle: TextStyle(
                                                    color: Colors.white),
                                                backgroundColor: Colors.green,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.sp),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0.sp),
                                                ),
                                              ),
                                              onPressed: () => {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CompleteInkaroApproval(),
                                                  ),
                                                )
                                              },
                                              icon: Icon(
                                                Icons.text_snippet,
                                                color: Colors.white,
                                                size: 20.0.sp,
                                              ),
                                              label: Text(
                                                'Kontrak Inkaro',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.0.sp,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 5.0.sp, right: 10.0.sp),
                                            child: TextButton.icon(
                                              style: TextButton.styleFrom(
                                                textStyle: TextStyle(
                                                    color: Colors.white),
                                                backgroundColor: Colors.green,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.sp),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0.sp),
                                                ),
                                              ),
                                              onPressed: () => {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PencairanInkaroApproval(),
                                                  ),
                                                )
                                              },
                                              icon: Icon(
                                                Icons.card_giftcard_sharp,
                                                color: Colors.white,
                                                size: 20.0.sp,
                                              ),
                                              label: Text(
                                                'Pencairan Inkaro',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.0.sp,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: isHorizontal ? 20.h : 15.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Column(
                                  children: [
                                    // Image.asset(
                                    //   'assets/images/product_corner.png',
                                    //   width: isHorizontal ? 55.r : 45.r,
                                    //   height: isHorizontal ? 55.r : 45.r,
                                    // ),
                                    // SizedBox(
                                    //   height: screenHeight * 0.015,
                                    // ),
                                    // Text(
                                    //   'Product Corner',
                                    //   style: TextStyle(
                                    //     fontSize: isHorizontal ? 17.sp : 13.sp,
                                    //     fontWeight: FontWeight.w600,
                                    //     fontFamily: 'Segoe ui',
                                    //     color: Colors.black54,
                                    //     overflow: TextOverflow.ellipsis,
                                    //   ),
                                    //   textAlign: TextAlign.center,
                                    //   maxLines: 1,
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) => ProductCornerScreen(),
                              //   ),
                              // );
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Column(
                                  children: [
                                    // Image.asset(
                                    //   'assets/images/check_in_attendance.png',
                                    //   width: isHorizontal ? 55.r : 45.r,
                                    //   height: isHorizontal ? 55.r : 45.r,
                                    // ),
                                    // SizedBox(
                                    //   height: screenHeight * 0.015,
                                    // ),
                                    // Text(
                                    //   'Masuk',
                                    //   style: TextStyle(
                                    //       fontSize:
                                    //           isHorizontal ? 17.sp : 13.sp,
                                    //       fontWeight: FontWeight.w600,
                                    //       fontFamily: 'Segoe ui',
                                    //       color: Colors.black54),
                                    //   textAlign: TextAlign.center,
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () async {
                              // await Permission.camera.request();
                              // if (await Permission.camera.isGranted) {
                              //   Navigator.of(context).push(
                              //     MaterialPageRoute(
                              //       builder: (context) => AttendanceScreen(
                              //         isCekin: true,
                              //       ),
                              //     ),
                              //   );
                              // } else {
                              //   print('Access camera tidak diizinkan');
                              // }
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Column(
                                  children: [
                                    // Image.asset(
                                    //   'assets/images/check_out_attendance.png',
                                    //   width: isHorizontal ? 55.r : 45.r,
                                    //   height: isHorizontal ? 55.r : 45.r,
                                    // ),
                                    // SizedBox(
                                    //   height: screenHeight * 0.015,
                                    // ),
                                    // Text(
                                    //   'Pulang',
                                    //   style: TextStyle(
                                    //       fontSize:
                                    //           isHorizontal ? 17.sp : 13.sp,
                                    //       fontWeight: FontWeight.w600,
                                    //       fontFamily: 'Segoe ui',
                                    //       color: Colors.black54),
                                    //   textAlign: TextAlign.center,
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () async {
                              // await Permission.camera.request();
                              // if (await Permission.camera.isGranted) {
                              //   Navigator.of(context).push(
                              //     MaterialPageRoute(
                              //       builder: (context) => AttendanceScreen(
                              //         isCekin: false,
                              //       ),
                              //     ),
                              //   );
                              // } else {
                              //   print('Access camera tidak diizinkan');
                              // }
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Column(
                                  children: [
                                    // Image.asset(
                                    //   'assets/images/more.png',
                                    //   width: isHorizontal ? 55.r : 45.r,
                                    //   height: isHorizontal ? 55.r : 45.r,
                                    // ),
                                    // SizedBox(
                                    //   height: screenHeight * 0.015,
                                    // ),
                                    // Text(
                                    //   'Menu Lain',
                                    //   style: TextStyle(
                                    //       fontSize:
                                    //           isHorizontal ? 17.sp : 13.sp,
                                    //       fontWeight: FontWeight.w600,
                                    //       fontFamily: 'Segoe ui',
                                    //       color: Colors.black54),
                                    //   textAlign: TextAlign.center,
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) => EformScreen(),
                              //   ),
                              // );
                              // showModalBottomSheet(
                              //   context: context,
                              //   builder: (context) {
                              //     return Wrap(
                              //       // crossAxisAlignment: CrossAxisAlignment.start,
                              //       // mainAxisSize: MainAxisSize.min,
                              //       children: [
                              //         Padding(
                              //           padding: const EdgeInsets.symmetric(
                              //             vertical: 15,
                              //             horizontal: 15,
                              //           ),
                              //           child: Text(
                              //             'Pilih Menu',
                              //             style: TextStyle(
                              //               fontSize:
                              //                   isHorizontal ? 17.sp : 13.sp,
                              //               fontWeight: FontWeight.w600,
                              //               fontFamily: 'Segoe ui',
                              //               color: Colors.black54,
                              //             ),
                              //           ),
                              //         ),
                              //         Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.spaceAround,
                              //           children: [
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   child: Center(
                              //                     child: Column(
                              //                       children: [
                              //                         Image.asset(
                              //                           'assets/images/entry_customer_new.png',
                              //                           width: isHorizontal
                              //                               ? 60.r
                              //                               : 45.r,
                              //                           height: isHorizontal
                              //                               ? 60.r
                              //                               : 45.r,
                              //                         ),
                              //                         SizedBox(
                              //                           height: screenHeight *
                              //                               0.015,
                              //                         ),
                              //                         Text(
                              //                           'Kustomer',
                              //                           style: TextStyle(
                              //                               fontSize:
                              //                                   isHorizontal
                              //                                       ? 17.sp
                              //                                       : 13.sp,
                              //                               fontWeight:
                              //                                   FontWeight.w600,
                              //                               fontFamily:
                              //                                   'Segoe ui',
                              //                               color:
                              //                                   Colors.black54),
                              //                           textAlign:
                              //                               TextAlign.center,
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 onTap: () {
                              //                   checkSigned(
                              //                       idSales, role, context,
                              //                       isConnected: isConnected);
                              //                 },
                              //               ),
                              //             ),
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   child: Center(
                              //                     child: Column(
                              //                       children: [
                              //                         Image.asset(
                              //                           'assets/images/e_contract_new.png',
                              //                           width: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                           height: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                         ),
                              //                         SizedBox(
                              //                           height: screenHeight *
                              //                               0.015,
                              //                         ),
                              //                         Text(
                              //                           'E-Kontrak',
                              //                           style: TextStyle(
                              //                               fontSize:
                              //                                   isHorizontal
                              //                                       ? 17.sp
                              //                                       : 13.sp,
                              //                               fontWeight:
                              //                                   FontWeight.w600,
                              //                               fontFamily:
                              //                                   'Segoe ui',
                              //                               color:
                              //                                   Colors.black54),
                              //                           textAlign:
                              //                               TextAlign.center,
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 onTap: () {
                              //                   checkCustomer(
                              //                       idSales!, context);
                              //                 },
                              //               ),
                              //             ),
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   child: Center(
                              //                     child: Column(
                              //                       children: [
                              //                         Image.asset(
                              //                           'assets/images/mon_contract.png',
                              //                           width: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                           height: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                         ),
                              //                         SizedBox(
                              //                           height: screenHeight *
                              //                               0.015,
                              //                         ),
                              //                         Text(
                              //                           'Monitoring',
                              //                           style: TextStyle(
                              //                               fontSize:
                              //                                   isHorizontal
                              //                                       ? 17.sp
                              //                                       : 13.sp,
                              //                               fontWeight:
                              //                                   FontWeight.w600,
                              //                               fontFamily:
                              //                                   'Segoe ui',
                              //                               color:
                              //                                   Colors.black54),
                              //                           textAlign:
                              //                               TextAlign.center,
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 onTap: () {
                              //                   Navigator.of(context).push(
                              //                     MaterialPageRoute(
                              //                       builder: (context) =>
                              //                           SearchContract(),
                              //                     ),
                              //                   );
                              //                 },
                              //               ),
                              //             ),
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   child: Center(
                              //                     child: Column(
                              //                       children: [
                              //                         Image.asset(
                              //                           'assets/images/renew_contract.png',
                              //                           width: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                           height: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                         ),
                              //                         SizedBox(
                              //                           height: screenHeight *
                              //                               0.015,
                              //                         ),
                              //                         Text(
                              //                           'Ubah Kontrak',
                              //                           style: TextStyle(
                              //                             fontSize: isHorizontal
                              //                                 ? 17.sp
                              //                                 : 13.sp,
                              //                             fontWeight:
                              //                                 FontWeight.w600,
                              //                             fontFamily:
                              //                                 'Segoe ui',
                              //                             color: Colors.black54,
                              //                           ),
                              //                           textAlign:
                              //                               TextAlign.center,
                              //                           maxLines: 1,
                              //                           overflow: TextOverflow
                              //                               .ellipsis,
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 onTap: () {
                              //                   Navigator.of(context).push(
                              //                     MaterialPageRoute(
                              //                       builder: (context) =>
                              //                           RenewalContract(
                              //                         keyword: '',
                              //                         isAdmin: false,
                              //                       ),
                              //                     ),
                              //                   );
                              //                 },
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //         Padding(
                              //           padding: const EdgeInsets.symmetric(
                              //             vertical: 5,
                              //           ),
                              //           child: Text(
                              //             'Pilih Menu',
                              //             style: TextStyle(
                              //               fontSize:
                              //                   isHorizontal ? 10.sp : 5.sp,
                              //               fontWeight: FontWeight.w600,
                              //               fontFamily: 'Segoe ui',
                              //               color: Colors.white,
                              //             ),
                              //           ),
                              //         ),
                              //         Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.spaceAround,
                              //           children: [
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   child: Center(
                              //                     child: Column(
                              //                       children: [
                              //                         Image.asset(
                              //                           'assets/images/agenda_menu_new.png',
                              //                           width: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                           height: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                         ),
                              //                         SizedBox(
                              //                           height: screenHeight *
                              //                               0.015,
                              //                         ),
                              //                         Text(
                              //                           'Aktivitas',
                              //                           style: TextStyle(
                              //                               fontSize:
                              //                                   isHorizontal
                              //                                       ? 17.sp
                              //                                       : 13.sp,
                              //                               fontWeight:
                              //                                   FontWeight.w600,
                              //                               fontFamily:
                              //                                   'Segoe ui',
                              //                               color:
                              //                                   Colors.black54),
                              //                           textAlign:
                              //                               TextAlign.center,
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 onTap: () {
                              //                   Navigator.of(context).push(
                              //                     MaterialPageRoute(
                              //                       builder: (context) =>
                              //                           DailyActivity(
                              //                         isAdmin: false,
                              //                       ),
                              //                     ),
                              //                   );
                              //                 },
                              //               ),
                              //             ),
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   child: Center(
                              //                     child: Column(
                              //                       children: [
                              //                         Image.asset(
                              //                           'assets/images/check_in_attendance.png',
                              //                           width: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                           height: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                         ),
                              //                         SizedBox(
                              //                           height: screenHeight *
                              //                               0.015,
                              //                         ),
                              //                         Text(
                              //                           'Masuk',
                              //                           style: TextStyle(
                              //                               fontSize:
                              //                                   isHorizontal
                              //                                       ? 17.sp
                              //                                       : 13.sp,
                              //                               fontWeight:
                              //                                   FontWeight.w600,
                              //                               fontFamily:
                              //                                   'Segoe ui',
                              //                               color:
                              //                                   Colors.black54),
                              //                           textAlign:
                              //                               TextAlign.center,
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 onTap: () async {
                              //                   await Permission.camera
                              //                       .request();
                              //                   if (await Permission
                              //                       .camera.isGranted) {
                              //                     Navigator.of(context).push(
                              //                       MaterialPageRoute(
                              //                         builder: (context) =>
                              //                             AttendanceScreen(
                              //                           isCekin: true,
                              //                         ),
                              //                       ),
                              //                     );
                              //                   } else {
                              //                     print(
                              //                         'Access camera tidak diizinkan');
                              //                   }
                              //                 },
                              //               ),
                              //             ),
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   child: Center(
                              //                     child: Column(
                              //                       children: [
                              //                         Image.asset(
                              //                           'assets/images/check_out_attendance.png',
                              //                           width: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                           height: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                         ),
                              //                         SizedBox(
                              //                           height: screenHeight *
                              //                               0.015,
                              //                         ),
                              //                         Text(
                              //                           'Pulang',
                              //                           style: TextStyle(
                              //                               fontSize:
                              //                                   isHorizontal
                              //                                       ? 17.sp
                              //                                       : 13.sp,
                              //                               fontWeight:
                              //                                   FontWeight.w600,
                              //                               fontFamily:
                              //                                   'Segoe ui',
                              //                               color:
                              //                                   Colors.black54),
                              //                           textAlign:
                              //                               TextAlign.center,
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 onTap: () async {
                              //                   await Permission.camera
                              //                       .request();
                              //                   if (await Permission
                              //                       .camera.isGranted) {
                              //                     Navigator.of(context).push(
                              //                       MaterialPageRoute(
                              //                         builder: (context) =>
                              //                             AttendanceScreen(
                              //                           isCekin: false,
                              //                         ),
                              //                       ),
                              //                     );
                              //                   } else {
                              //                     print(
                              //                         'Access camera tidak diizinkan');
                              //                   }
                              //                 },
                              //               ),
                              //             ),
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   child: Center(
                              //                     child: Column(
                              //                       children: [
                              //                         Image.asset(
                              //                           'assets/images/e-form.png',
                              //                           width: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                           height: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                         ),
                              //                         SizedBox(
                              //                           height: screenHeight *
                              //                               0.015,
                              //                         ),
                              //                         Text(
                              //                           'E-form',
                              //                           style: TextStyle(
                              //                             fontSize: isHorizontal
                              //                                 ? 17.sp
                              //                                 : 13.sp,
                              //                             fontWeight:
                              //                                 FontWeight.w600,
                              //                             fontFamily:
                              //                                 'Segoe ui',
                              //                             color: Colors.black54,
                              //                             overflow: TextOverflow
                              //                                 .ellipsis,
                              //                           ),
                              //                           textAlign:
                              //                               TextAlign.center,
                              //                           maxLines: 1,
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 onTap: () {
                              //                   Navigator.of(context).push(
                              //                     MaterialPageRoute(
                              //                       builder: (context) =>
                              //                           EformScreen(),
                              //                     ),
                              //                   );
                              //                 },
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //         Padding(
                              //           padding: const EdgeInsets.symmetric(
                              //             vertical: 5,
                              //           ),
                              //           child: Text(
                              //             'Pilih Menu',
                              //             style: TextStyle(
                              //               fontSize:
                              //                   isHorizontal ? 10.sp : 5.sp,
                              //               fontWeight: FontWeight.w600,
                              //               fontFamily: 'Segoe ui',
                              //               color: Colors.white,
                              //             ),
                              //           ),
                              //         ),
                              //         Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.spaceAround,
                              //           children: [
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   child: Center(
                              //                     child: Column(
                              //                       children: [
                              //                         // Image.asset(
                              //                         //   'assets/images/product_corner.png',
                              //                         //   width: isHorizontal
                              //                         //       ? 60.r
                              //                         //       : 45.r,
                              //                         //   height: isHorizontal
                              //                         //       ? 60.r
                              //                         //       : 45.r,
                              //                         // ),
                              //                         // SizedBox(
                              //                         //   height:
                              //                         //       screenHeight * 0.015,
                              //                         // ),
                              //                         // Text(
                              //                         //   'Product Corner',
                              //                         //   style: TextStyle(
                              //                         //     fontSize: isHorizontal
                              //                         //         ? 17.sp
                              //                         //         : 13.sp,
                              //                         //     fontWeight:
                              //                         //         FontWeight.w600,
                              //                         //     fontFamily: 'Segoe ui',
                              //                         //     color: Colors.black54,
                              //                         //     overflow:
                              //                         //         TextOverflow.ellipsis,
                              //                         //   ),
                              //                         //   textAlign: TextAlign.center,
                              //                         //   maxLines: 1,
                              //                         // ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 onTap: () {
                              //                   // Navigator.of(context).push(
                              //                   //   MaterialPageRoute(
                              //                   //     builder: (context) =>
                              //                   //         ProductCornerScreen(),
                              //                   //   ),
                              //                   // );
                              //                 },
                              //               ),
                              //             ),
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   child: Center(
                              //                     child: Column(
                              //                       children: [
                              //                         Image.asset(
                              //                           'assets/images/inkaro.png',
                              //                           width: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                           height: isHorizontal
                              //                               ? 55.r
                              //                               : 45.r,
                              //                         ),
                              //                         SizedBox(
                              //                           height: screenHeight *
                              //                               0.015,
                              //                         ),
                              //                         Text(
                              //                           'Inkaro',
                              //                           style: TextStyle(
                              //                               fontSize:
                              //                                   isHorizontal
                              //                                       ? 17.sp
                              //                                       : 13.sp,
                              //                               fontWeight:
                              //                                   FontWeight.w600,
                              //                               fontFamily:
                              //                                   'Segoe ui',
                              //                               color:
                              //                                   Colors.black54),
                              //                           textAlign:
                              //                               TextAlign.center,
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 onTap: () {
                              //                   Navigator.of(context).push(
                              //                       MaterialPageRoute(
                              //                           builder: (context) =>
                              //                               ListCustomerInkaroScreen(
                              //                                   int.parse(
                              //                                       idSales!))));
                              //                 },
                              //               ),
                              //             ),
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   // child: Center(
                              //                   //   child: Column(
                              //                   //     children: [
                              //                   //       Image.asset(
                              //                   //         'assets/images/mon_contract.png',
                              //                   //         width: isHorizontal ? 55.r : 45.r,
                              //                   //         height: isHorizontal ? 55.r : 45.r,
                              //                   //       ),
                              //                   //       SizedBox(
                              //                   //         height: screenHeight * 0.015,
                              //                   //       ),
                              //                   //       Text(
                              //                   //         'Monitoring',
                              //                   //         style: TextStyle(
                              //                   //             fontSize: isHorizontal ? 17.sp : 13.sp,
                              //                   //             fontWeight: FontWeight.w600,
                              //                   //             fontFamily: 'Segoe ui',
                              //                   //             color: Colors.black54),
                              //                   //         textAlign: TextAlign.center,
                              //                   //       ),
                              //                   //     ],
                              //                   //   ),
                              //                   // ),
                              //                 ),
                              //                 onTap: () {
                              //                   // Navigator.of(context).push(
                              //                   //   MaterialPageRoute(
                              //                   //     builder: (context) => SearchContract(),
                              //                   //   ),
                              //                   // );
                              //                 },
                              //               ),
                              //             ),
                              //             Expanded(
                              //               flex: 1,
                              //               child: InkWell(
                              //                 child: Padding(
                              //                   padding: EdgeInsets.all(5),
                              //                   // child: Center(
                              //                   //   child: Column(
                              //                   //     children: [
                              //                   //       Image.asset(
                              //                   //         'assets/images/renew_contract.png',
                              //                   //         width: isHorizontal ? 55.r : 45.r,
                              //                   //         height: isHorizontal ? 55.r : 45.r,
                              //                   //       ),
                              //                   //       SizedBox(
                              //                   //         height: screenHeight * 0.015,
                              //                   //       ),
                              //                   //       Text(
                              //                   //         'Ubah Kontrak',
                              //                   //         style: TextStyle(
                              //                   //           fontSize: isHorizontal ? 17.sp : 13.sp,
                              //                   //           fontWeight: FontWeight.w600,
                              //                   //           fontFamily: 'Segoe ui',
                              //                   //           color: Colors.black54,
                              //                   //         ),
                              //                   //         textAlign: TextAlign.center,
                              //                   //         maxLines: 1,
                              //                   //         overflow: TextOverflow.ellipsis,
                              //                   //       ),
                              //                   //     ],
                              //                   //   ),
                              //                   // ),
                              //                 ),
                              //                 onTap: () {
                              //                   // Navigator.of(context).push(
                              //                   //   MaterialPageRoute(
                              //                   //     builder: (context) => RenewalContract(
                              //                   //       keyword: '',
                              //                   //       isAdmin: false,
                              //                   //     ),
                              //                   //   ),
                              //                   // );
                              //                 },
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //         Padding(
                              //           padding: const EdgeInsets.symmetric(
                              //             vertical: 5,
                              //           ),
                              //           child: Text(
                              //             'Pilih Menu',
                              //             style: TextStyle(
                              //               fontSize:
                              //                   isHorizontal ? 10.sp : 5.sp,
                              //               fontWeight: FontWeight.w600,
                              //               fontFamily: 'Segoe ui',
                              //               color: Colors.white,
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //     );
                              //   },
                              // );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : role == "ADMIN" && divisi == "AR"
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: isHorizontal ? 0.h : 0.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/check_in_attendance.png',
                                          width: isHorizontal ? 55.r : 45.r,
                                          height: isHorizontal ? 55.r : 45.r,
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.015,
                                        ),
                                        Text(
                                          'Masuk',
                                          style: TextStyle(
                                              fontSize:
                                                  isHorizontal ? 17.sp : 13.sp,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Segoe ui',
                                              color: Colors.black54),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  await Permission.camera.request();
                                  if (await Permission.camera.isGranted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AttendanceScreen(
                                          isCekin: true,
                                        ),
                                      ),
                                    );
                                  } else {
                                    print('Access camera tidak diizinkan');
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/check_out_attendance.png',
                                          width: isHorizontal ? 55.r : 45.r,
                                          height: isHorizontal ? 55.r : 45.r,
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.015,
                                        ),
                                        Text(
                                          'Pulang',
                                          style: TextStyle(
                                              fontSize:
                                                  isHorizontal ? 17.sp : 13.sp,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Segoe ui',
                                              color: Colors.black54),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  await Permission.camera.request();
                                  if (await Permission.camera.isGranted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AttendanceScreen(
                                          isCekin: false,
                                        ),
                                      ),
                                    );
                                  } else {
                                    print('Access camera tidak diizinkan');
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/e-form.png',
                                          width: isHorizontal ? 55.r : 45.r,
                                          height: isHorizontal ? 55.r : 45.r,
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.015,
                                        ),
                                        Text(
                                          'E-form',
                                          style: TextStyle(
                                              fontSize:
                                                  isHorizontal ? 17.sp : 13.sp,
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
                                      builder: (context) => EformScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/inkaro.png',
                                          width: isHorizontal ? 55.r : 45.r,
                                          height: isHorizontal ? 55.r : 45.r,
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.015,
                                        ),
                                        Text(
                                          'Inkaro',
                                          style: TextStyle(
                                            fontSize:
                                                isHorizontal ? 17.sp : 13.sp,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Segoe ui',
                                            color: Colors.black54,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                    ),
                                    context: context,
                                    builder: (context) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          top: 25.00,
                                          bottom: 25.00,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10.0.sp,
                                                    right: 5.0.sp),
                                                child: TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                    textStyle: TextStyle(
                                                        color: Colors.white),
                                                    backgroundColor:
                                                        Colors.green,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10.sp),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0.sp),
                                                    ),
                                                  ),
                                                  onPressed: () => {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CompleteInkaroApproval(),
                                                      ),
                                                    )
                                                  },
                                                  icon: Icon(
                                                    Icons.text_snippet,
                                                    color: Colors.white,
                                                    size: 20.0.sp,
                                                  ),
                                                  label: Text(
                                                    'Kontrak Inkaro',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13.0.sp,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 5.0.sp,
                                                    right: 10.0.sp),
                                                child: TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                    textStyle: TextStyle(
                                                        color: Colors.white),
                                                    backgroundColor:
                                                        Colors.green,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10.sp),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0.sp),
                                                    ),
                                                  ),
                                                  onPressed: () => {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PencairanInkaroApproval(),
                                                      ),
                                                    )
                                                  },
                                                  icon: Icon(
                                                    Icons.card_giftcard_sharp,
                                                    color: Colors.white,
                                                    size: 20.0.sp,
                                                  ),
                                                  label: Text(
                                                    'Pencairan Inkaro',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13.0.sp,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: isHorizontal ? 10.h : 7.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
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
                                              fontSize:
                                                  isHorizontal ? 17.sp : 13.sp,
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
                                  checkSigned(idSales, role, context,
                                      isConnected: isConnected);
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
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
                                              fontSize:
                                                  isHorizontal ? 17.sp : 13.sp,
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
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
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
                                              fontSize:
                                                  isHorizontal ? 17.sp : 13.sp,
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
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Center(
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
                                            fontSize:
                                                isHorizontal ? 17.sp : 13.sp,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Segoe ui',
                                            color: Colors.black54,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
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
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHorizontal ? 20.h : 15.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
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
                                              fontSize:
                                                  isHorizontal ? 17.sp : 13.sp,
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
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/check_in_attendance.png',
                                          width: isHorizontal ? 55.r : 45.r,
                                          height: isHorizontal ? 55.r : 45.r,
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.015,
                                        ),
                                        Text(
                                          'Masuk',
                                          style: TextStyle(
                                              fontSize:
                                                  isHorizontal ? 17.sp : 13.sp,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Segoe ui',
                                              color: Colors.black54),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  await Permission.camera.request();
                                  if (await Permission.camera.isGranted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AttendanceScreen(
                                          isCekin: true,
                                        ),
                                      ),
                                    );
                                  } else {
                                    print('Access camera tidak diizinkan');
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/check_out_attendance.png',
                                          width: isHorizontal ? 55.r : 45.r,
                                          height: isHorizontal ? 55.r : 45.r,
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.015,
                                        ),
                                        Text(
                                          'Pulang',
                                          style: TextStyle(
                                              fontSize:
                                                  isHorizontal ? 17.sp : 13.sp,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Segoe ui',
                                              color: Colors.black54),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  await Permission.camera.request();
                                  if (await Permission.camera.isGranted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AttendanceScreen(
                                          isCekin: false,
                                        ),
                                      ),
                                    );
                                  } else {
                                    print('Access camera tidak diizinkan');
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/more.png',
                                          width: isHorizontal ? 55.r : 45.r,
                                          height: isHorizontal ? 55.r : 45.r,
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.015,
                                        ),
                                        Text(
                                          'Menu Lain',
                                          style: TextStyle(
                                              fontSize:
                                                  isHorizontal ? 17.sp : 13.sp,
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
                                  // Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //     builder: (context) => EformScreen(),
                                  //   ),
                                  // );
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Wrap(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 15,
                                              horizontal: 15,
                                            ),
                                            child: Text(
                                              'Pilih Menu',
                                              style: TextStyle(
                                                fontSize: isHorizontal
                                                    ? 17.sp
                                                    : 13.sp,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Segoe ui',
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/entry_customer_new.png',
                                                            width: isHorizontal
                                                                ? 60.r
                                                                : 45.r,
                                                            height: isHorizontal
                                                                ? 60.r
                                                                : 45.r,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.015,
                                                          ),
                                                          Text(
                                                            'Kustomer',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    isHorizontal
                                                                        ? 17.sp
                                                                        : 13.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily:
                                                                    'Segoe ui',
                                                                color: Colors
                                                                    .black54),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    checkSigned(
                                                        idSales, role, context,
                                                        isConnected:
                                                            isConnected);
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/e_contract_new.png',
                                                            width: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                            height: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.015,
                                                          ),
                                                          Text(
                                                            'E-Kontrak',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    isHorizontal
                                                                        ? 17.sp
                                                                        : 13.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily:
                                                                    'Segoe ui',
                                                                color: Colors
                                                                    .black54),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    checkCustomer(
                                                        idSales!, context);
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/mon_contract.png',
                                                            width: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                            height: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.015,
                                                          ),
                                                          Text(
                                                            'Monitoring',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    isHorizontal
                                                                        ? 17.sp
                                                                        : 13.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily:
                                                                    'Segoe ui',
                                                                color: Colors
                                                                    .black54),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            SearchContract(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/renew_contract.png',
                                                            width: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                            height: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.015,
                                                          ),
                                                          Text(
                                                            'Ubah Kontrak',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  isHorizontal
                                                                      ? 17.sp
                                                                      : 13.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily:
                                                                  'Segoe ui',
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RenewalContract(
                                                          keyword: '',
                                                          isAdmin: false,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                            child: Text(
                                              'Pilih Menu',
                                              style: TextStyle(
                                                fontSize:
                                                    isHorizontal ? 10.sp : 5.sp,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Segoe ui',
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/agenda_menu_new.png',
                                                            width: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                            height: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.015,
                                                          ),
                                                          Text(
                                                            'Aktivitas',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    isHorizontal
                                                                        ? 17.sp
                                                                        : 13.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily:
                                                                    'Segoe ui',
                                                                color: Colors
                                                                    .black54),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DailyActivity(
                                                          isAdmin: false,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/check_in_attendance.png',
                                                            width: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                            height: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.015,
                                                          ),
                                                          Text(
                                                            'Masuk',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    isHorizontal
                                                                        ? 17.sp
                                                                        : 13.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily:
                                                                    'Segoe ui',
                                                                color: Colors
                                                                    .black54),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    await Permission.camera
                                                        .request();
                                                    if (await Permission
                                                        .camera.isGranted) {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AttendanceScreen(
                                                            isCekin: true,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      print(
                                                          'Access camera tidak diizinkan');
                                                    }
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/check_out_attendance.png',
                                                            width: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                            height: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.015,
                                                          ),
                                                          Text(
                                                            'Pulang',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    isHorizontal
                                                                        ? 17.sp
                                                                        : 13.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily:
                                                                    'Segoe ui',
                                                                color: Colors
                                                                    .black54),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    await Permission.camera
                                                        .request();
                                                    if (await Permission
                                                        .camera.isGranted) {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AttendanceScreen(
                                                            isCekin: false,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      print(
                                                          'Access camera tidak diizinkan');
                                                    }
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/e-form.png',
                                                            width: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                            height: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.015,
                                                          ),
                                                          Text(
                                                            'E-form',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  isHorizontal
                                                                      ? 17.sp
                                                                      : 13.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily:
                                                                  'Segoe ui',
                                                              color: Colors
                                                                  .black54,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            EformScreen(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                            child: Text(
                                              'Pilih Menu',
                                              style: TextStyle(
                                                fontSize:
                                                    isHorizontal ? 10.sp : 5.sp,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Segoe ui',
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/inkaro.png',
                                                            width: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                            height: isHorizontal
                                                                ? 55.r
                                                                : 45.r,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.015,
                                                          ),
                                                          Text(
                                                            'Inkaro',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    isHorizontal
                                                                        ? 17.sp
                                                                        : 13.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily:
                                                                    'Segoe ui',
                                                                color: Colors
                                                                    .black54),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  15.sp),
                                                          topRight:
                                                              Radius.circular(
                                                                  15.sp),
                                                        ),
                                                      ),
                                                      context: context,
                                                      builder: (context) {
                                                        return Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            top: 25.00.sp,
                                                            bottom: 25.00.sp,
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: 10.0
                                                                          .sp,
                                                                      right: 5.0
                                                                          .sp),
                                                                  child:
                                                                      TextButton
                                                                          .icon(
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      textStyle:
                                                                          TextStyle(
                                                                              color: Colors.white),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green,
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              10.sp),
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0.sp),
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () => {
                                                                      Navigator.of(
                                                                              context)
                                                                          .push(
                                                                              MaterialPageRoute(builder: (context) => ListCustomerInkaroScreen(int.parse(idSales!))))
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .text_snippet,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 20.0
                                                                          .sp,
                                                                    ),
                                                                    label: Text(
                                                                      'Kontrak Inkaro',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize: 13.0
                                                                              .sp,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: 5.0
                                                                          .sp,
                                                                      right: 10.0
                                                                          .sp),
                                                                  child:
                                                                      TextButton
                                                                          .icon(
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      textStyle:
                                                                          TextStyle(
                                                                              color: Colors.white),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green,
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              10.sp),
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0.sp),
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () => {
                                                                      Navigator.of(
                                                                              context)
                                                                          .push(
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              PencairanInkaroApproval(),
                                                                        ),
                                                                      )
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .card_giftcard_sharp,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 20.0
                                                                          .sp,
                                                                    ),
                                                                    label: Text(
                                                                      'Pencairan Inkaro',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize: 13.0
                                                                              .sp,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/pos_material.png',
                                                            width: isHorizontal
                                                                ? 60.r
                                                                : 45.r,
                                                            height: isHorizontal
                                                                ? 60.r
                                                                : 45.r,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                screenHeight * 0.015,
                                                          ),
                                                          Text(
                                                            'POS Material',
                                                            style: TextStyle(
                                                              fontSize: isHorizontal
                                                                  ? 17.sp
                                                                  : 13.sp,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              fontFamily: 'Segoe ui',
                                                              color: Colors.black54,
                                                              overflow:
                                                                  TextOverflow.ellipsis,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Posmaterial_Screen(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    // child: Center(
                                                    //   child: Column(
                                                    //     children: [
                                                    //       Image.asset(
                                                    //         'assets/images/cashback.png',
                                                    //         width: isHorizontal ? 55.r : 45.r,
                                                    //         height: isHorizontal ? 55.r : 45.r,
                                                    //       ),
                                                    //       SizedBox(
                                                    //         height: screenHeight * 0.015,
                                                    //       ),
                                                    //       Text(
                                                    //         'Cashback',
                                                    //         style: TextStyle(
                                                    //             fontSize: isHorizontal ? 17.sp : 13.sp,
                                                    //             fontWeight: FontWeight.w600,
                                                    //             fontFamily: 'Segoe ui',
                                                    //             color: Colors.black54),
                                                    //         textAlign: TextAlign.center,
                                                    //       ),
                                                    //     ],
                                                    //   ),
                                                    // ),
                                                  ),
                                                  onTap: () {
                                                    // Navigator.of(context).push(
                                                    //   MaterialPageRoute(
                                                    //     builder: (context) => CashbackScreen(),
                                                    //   ),
                                                    // );
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    // child: Center(
                                                    //   child: Column(
                                                    //     children: [
                                                    //       Image.asset(
                                                    //         'assets/images/renew_contract.png',
                                                    //         width: isHorizontal ? 55.r : 45.r,
                                                    //         height: isHorizontal ? 55.r : 45.r,
                                                    //       ),
                                                    //       SizedBox(
                                                    //         height: screenHeight * 0.015,
                                                    //       ),
                                                    //       Text(
                                                    //         'Ubah Kontrak',
                                                    //         style: TextStyle(
                                                    //           fontSize: isHorizontal ? 17.sp : 13.sp,
                                                    //           fontWeight: FontWeight.w600,
                                                    //           fontFamily: 'Segoe ui',
                                                    //           color: Colors.black54,
                                                    //         ),
                                                    //         textAlign: TextAlign.center,
                                                    //         maxLines: 1,
                                                    //         overflow: TextOverflow.ellipsis,
                                                    //       ),
                                                    //     ],
                                                    //   ),
                                                    // ),
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
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                            child: Text(
                                              'Pilih Menu',
                                              style: TextStyle(
                                                fontSize:
                                                    isHorizontal ? 10.sp : 5.sp,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Segoe ui',
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
    ),
  );
}
