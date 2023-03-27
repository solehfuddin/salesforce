import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/attendance/attendance_prominent.dart';
import 'package:sample/src/app/pages/attendance/attendance_service.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/mylocation.dart';
import 'package:sample/src/app/widgets/areabanner.dart';
import 'package:sample/src/app/widgets/areaheader.dart';
import 'package:sample/src/app/widgets/areamenu.dart';
import 'package:sample/src/app/widgets/areapoint.dart';
import 'package:sample/src/app/widgets/customAppbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({Key? key}) : super(key: key);

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  MyLocation _myLocation = MyLocation();
  late SharedPreferences preferences;
  String? id = '';
  String? role = '';
  String? name = '';
  String? username = '';
  String? divisi = '';
  String? userUpper = '';
  bool? isProminentAccess = false;
  bool isPermissionCamera = false;
  bool isLocationService = false;
  bool isPermissionService = false;

  getRole() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      name = preferences.getString("name");
      username = preferences.getString("username");
      userUpper = username?.toUpperCase();
      divisi = preferences.getString("divisi");
      isProminentAccess = preferences.getBool("check_prominent") ?? false;
      // ttdSales = preferences.getString("ttduser") ?? '';

      // print("Dashboard : $role");
      // print("TTD Sales : $ttdSales");

      // getMonitoringSales(int.parse(id!));
      // getPerformSales(stDate, edDate);
      // checkPassword(int.parse(id!));
      // getLocalNotif();

      // if (ttdSales == '') {
      //   handleSigned(context);
      // }
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();

    checkPermission();
  }

  void checkPermission() async {
    isPermissionService = await _myLocation.isPermissionEnable();
    setState(() {
      if (!isProminentAccess!) {
        dialogProminentService(context);
      }
      else
      {
        checkService();
      }
    });
  }

  void checkService() async {
    isLocationService = await _myLocation.isServiceEnable();
    setState(() {
      if (isPermissionService && isLocationService) {
        print('Granted');
      } else {
        dialogLocationService(context);
      }
    });
  }

  Future<bool> _onBackPressed() async {
    handleLogout(context);
    return false;
  }

  dialogLocationService(BuildContext context) {
    return showModalBottomSheet(
      elevation: 2,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (context) {
        return AttendanceService();
      },
    );
  }

  dialogProminentService(BuildContext context) {
    return showModalBottomSheet(
      elevation: 2,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (context) {
        return AttendanceProminent();
      },
    ).whenComplete(
      () {
        preferences.setBool("check_prominent", true);
        checkService();
      },
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      // getMonitoringSales(int.parse(id!));
      // getPerformSales(stDate, edDate);

      // checkPassword(int.parse(id!));
      // if (ttdSales == '') {
      //   handleSigned(context);
      // }
      // getLocalNotif();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: _onBackPressed,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600 ||
                MediaQuery.of(context).orientation == Orientation.landscape) {
              return Scaffold(
                appBar: CustomAppBar(
                  isHorizontal: true,
                  isBadge: false,
                ),
                // body: RefreshIndicator(
                //     child: CustomScrollView(
                //       physics: ClampingScrollPhysics(),
                //       slivers: [
                //         areaHeader(
                //           screenHeight,
                //           userUpper,
                //           context,
                //           isHorizontal: true,
                //         ),
                //         areaPoint(
                //           screenHeight * 1.8,
                //           context,
                //           isHorizontal: true,
                //         ),
                //         areaMenu(
                //           screenHeight,
                //           context,
                //           id,
                //           role,
                //           isConnected: true,
                //           isHorizontal: true,
                //         ),
                //         _hidePerform
                //             ? SliverPadding(
                //                 padding: EdgeInsets.only(
                //                   left: 35.r,
                //                   right: 35.r,
                //                   top: 0.r,
                //                 ),
                //               )
                //             : SliverPadding(
                //           padding: EdgeInsets.only(
                //             left: 18.r,
                //             right: 18.r,
                //             top: 5.r,
                //             bottom: 15.r,
                //           ),
                //           sliver: SliverToBoxAdapter(
                //             child: StatefulBuilder(
                //               builder:
                //                   (BuildContext context, StateSetter state) {
                //                 return Text(
                //                   'Penjualan',
                //                   style: TextStyle(
                //                     fontSize: 21.sp,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 );
                //               },
                //             ),
                //           ),
                //         ),
                //         _hidePerform
                //             ? SliverPadding(
                //                 padding: EdgeInsets.only(
                //                   left: 18.r,
                //                   right: 18.r,
                //                   top: 0.r,
                //                 ),
                //               )
                //             : areaInfoDonutUser(
                //                 sales: listPerform,
                //                 totalSales: _totalSales,
                //                 context: context,
                //                 stDate: stDate,
                //                 edDate: edDate,
                //                 isHorizontal: true,
                //               ),
                //         areaHeaderMonitoring(isHorizontal: true),
                //         _isLoading
                //             ? areaLoading(
                //                 isHorizontal: true,
                //               )
                //             : listMonitoring.length > 0
                //                 ? areaMonitoring(
                //                     listMonitoring,
                //                     context,
                //                     ttdSales!,
                //                     username!,
                //                     divisi!,
                //                     isHorizontal: true,
                //                   )
                //                 : areaMonitoringNotFound(
                //                     context,
                //                     isHorizontal: true,
                //                   ),
                //         areaButtonMonitoring(
                //           context,
                //           listMonitoring.length > 0 ? true : false,
                //           isHorizontal: true,
                //         ),
                //         areaFeature(
                //           screenHeight,
                //           context,
                //           isHorizontal: true,
                //         ),
                //         areaBanner(
                //           screenHeight,
                //           context,
                //           isHorizontal: true,
                //         ),
                //       ],
                //     ),
                //     onRefresh: _refreshData,),
              );
            }

            return Scaffold(
              appBar: CustomAppBar(
                isHorizontal: false,
                isBadge: false,
              ),
              body: RefreshIndicator(
                child: CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  slivers: [
                    areaHeader(
                      screenHeight,
                      userUpper,
                      context,
                      isHorizontal: false,
                    ),
                    areaPoint(
                      screenHeight,
                      context,
                      isHorizontal: false,
                    ),
                    areaMenu(
                      screenHeight,
                      context,
                      id,
                      role,
                      isConnected: true,
                      isHorizontal: false,
                    ),
                    // _hidePerform
                    //     ? SliverPadding(
                    //         padding: EdgeInsets.only(
                    //           left: 35.r,
                    //           right: 35.r,
                    //           top: 0.r,
                    //         ),
                    //       )
                    //     : SliverPadding(
                    //   padding: EdgeInsets.only(
                    //     left: 20.r,
                    //     right: 20.r,
                    //     top: 5.r,
                    //     bottom: 10.r,
                    //   ),
                    //   sliver: SliverToBoxAdapter(
                    //     child: StatefulBuilder(
                    //       builder: (BuildContext context, StateSetter state) {
                    //         return Text(
                    //           'Penjualan',
                    //           style: TextStyle(
                    //             fontSize: 21.sp,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // ),
                    // _hidePerform
                    //     ? SliverPadding(
                    //         padding: EdgeInsets.only(
                    //           left: 35.r,
                    //           right: 35.r,
                    //           top: 0.r,
                    //         ),
                    //       )
                    //     : areaInfoDonutUser(
                    //         sales: listPerform,
                    //         totalSales: _totalSales,
                    //         context: context,
                    //         stDate: stDate,
                    //         edDate: edDate,
                    //         isHorizontal: false,
                    //       ),
                    // areaHeaderMonitoring(
                    //   isHorizontal: false,
                    // ),
                    // _isLoading
                    //     ? areaLoading(
                    //         isHorizontal: false,
                    //       )
                    //     : listMonitoring.length > 0
                    //         ? areaMonitoring(
                    //             listMonitoring,
                    //             context,
                    //             ttdSales!,
                    //             username!,
                    //             divisi!,
                    //             isHorizontal: false,
                    //           )
                    //         : areaMonitoringNotFound(
                    //             context,
                    //             isHorizontal: false,
                    //           ),
                    // areaButtonMonitoring(
                    //   context,
                    //   listMonitoring.length > 0 ? true : false,
                    //   isHorizontal: false,
                    // ),
                    // areaFeature(
                    //   screenHeight,
                    //   context,
                    //   isHorizontal: false,
                    // ),
                    areaBanner(
                      screenHeight,
                      context,
                      isHorizontal: false,
                    ),
                  ],
                ),
                onRefresh: _refreshData,
              ),
            );
          },
        ),
      ),
    );
  }
}
