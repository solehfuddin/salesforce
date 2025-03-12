import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/activity/detail_activity.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sample/src/app/widgets/dialogactivity.dart';
import 'package:sample/src/domain/entities/salesact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// ignore: must_be_immutable
class DailyActivity extends StatefulWidget {
  bool isAdmin = false;
  int dailyInt = 0;

  DailyActivity({
    required this.isAdmin,
    this.dailyInt = 0,
  });

  @override
  State<DailyActivity> createState() => _DailyActivityState();
}

class _DailyActivityState extends State<DailyActivity> {
  Future<List<Salesact>>? _listFuture;
  List<Salesact> tempList = List.empty(growable: true);
  String actDate = '';
  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';
  int selectedIndex = 0;
  DateTime now = DateTime.now();
  late DateTime selDateTime, firstDayInit;
  var selectedDate = '';
  bool isDataFound = true;

  @override
  void initState() {
    super.initState();
    getRole();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    actDate = convertDateWithMonth(formattedDate);
    selDateTime = DateTime.now();
    firstDayInit = DateTime(now.year, now.month - 3, 1);
    selectedIndex = int.parse(formattedDate.substring(8, 10)) - 1;
    selectedDate = formattedDate;
    print("Tgl sekarang : $selectedIndex");
    print("Tanggal : $selectedDate");
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");

      print('ID user : $id');
      _listFuture = getDailyAct(id!, selectedDate);
    });
  }

  Future<List<Salesact>> getDailyAct(String input, String tgl) async {
    setState(() {
      isDataFound = true;
    });
    tempList.clear();

    List<Salesact> list = List.empty(growable: true);
    const timeout = 15;
    var url = widget.isAdmin
        ? '$API_URL/sales_activity?manager_id=$id&date=$tgl'
        : '$API_URL/sales_activity?sales_id=$id&date=$tgl';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest.map<Salesact>((json) => Salesact.fromJson(json)).toList();
          print("List Size: ${list.length}");

          setState(() {
            tempList.addAll(list);
          });
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }

    setState(() {
      isDataFound = false;
    });

    return list;
  }

  tandaiAktivitas(String idManager, String idAct, String opticName,
      String idSales, String tokenSales) async {
    const timeout = 15;
    var url = '$API_URL/sales_activity/mengetahui';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id': idAct,
          'area_manager_id': idManager,
        },
      ).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);

          //Send to sales spesifik
          pushNotif(
            11,
            3,
            idUser: idSales,
            rcptToken: tokenSales,
            admName: username,
            opticName: opticName,
          );
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _listFuture = getDailyAct(id!, selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childActivity(isHorizontal: true);
      }

      return childActivity(isHorizontal: false);
    });
  }

  Widget childActivity({bool isHorizontal = false}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: widget.isAdmin
          ? null
          : AppBar(
              backgroundColor: Colors.white70,
              title: Text(
                'Aktivitas Harian',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: isHorizontal ? 18.sp : 18.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 0.0,
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  if (role == 'ADMIN') {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => AdminScreen()));
                  } else if (role == 'SALES') {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: isHorizontal ? 18.sp : 18.sp,
                  color: Colors.black54,
                ),
              ),
            ),
      floatingActionButton: Visibility(
        visible: widget.isAdmin ? false : true,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.add_task_rounded,
            color: Colors.green.shade600,
          ),
          mini: true,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailActivity(
                  dateSelected: selectedDate,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isHorizontal ? 5.w : 5.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: isHorizontal ? 10.h : 15.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 20.r : 10.r,
              ),
              child: Text(
                '${convertDateWithMonth(selectedDate)}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: isHorizontal ? 16.sp : 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(
              height: isHorizontal ? 10.h : 15.h,
            ),
            TableCalendar(
              focusedDay: selDateTime,
              firstDay: widget.isAdmin
                  ? firstDayInit
                  : now.add(
                      Duration(days: 0),
                    ),
              // : now.add(
              //     Duration(
              //       days: widget.dailyInt,
              //     ),
              //   ),

              lastDay: now,
              selectedDayPredicate: (day) => isSameDay(selDateTime, day),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedTextStyle: TextStyle(
                  color: Colors.white,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.green.shade200,
                  shape: BoxShape.circle,
                ),
                holidayTextStyle: TextStyle(
                  color: Colors.red.shade700,
                ),
                holidayDecoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekendStyle: TextStyle(
                  color: Colors.red.shade700,
                ),
              ),
              calendarFormat: CalendarFormat.week,
              holidayPredicate: (day) {
                if (day.weekday == 6 || day.weekday == 7) {
                  print('Holiday at ${day.day} - ${day.month} - ${day.year}');
                  return true;
                }

                return false;
              },
              headerVisible: false,
              locale: "id_ID",
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  String format = DateFormat('yyyy-MM-dd').format(selectedDay);
                  selectedDate = format;
                  selDateTime = focusedDay;
                  _listFuture = getDailyAct(id!, selectedDate);
                });
              },
            ),
            SizedBox(
              height: isHorizontal ? 3.h : 10.h,
            ),
            Container(
              height: isHorizontal ? 3.h : 1.3.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
            SizedBox(
              height: isHorizontal ? 5.h : 5.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isHorizontal ? 20.r : 10.r,
                    vertical: isHorizontal ? 10.r : 15.r,
                  ),
                  child: Text(
                    'List Aktivitas',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isHorizontal ? 16.sp : 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                widget.isAdmin
                    ? InkWell(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isHorizontal ? 20.r : 10.r,
                            vertical: isHorizontal ? 25.r : 15.r,
                          ),
                          child: Text(
                            'Tandai semua',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: isHorizontal ? 17.sp : 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            for (int i = 0; i < tempList.length; i++) {
                              print('Id Act : ${tempList[i].actId}');
                              print('Agenda : ${tempList[i].agenda}');
                              print('Optik  : ${tempList[i].optik}');

                              if (tempList[i].mengetahui == "0") {
                                tandaiAktivitas(
                                  id!,
                                  tempList[i].actId,
                                  tempList[i].optik,
                                  tempList[i].salesId,
                                  tempList[i].salesToken != ''
                                      ? tempList[i].salesToken
                                      : "",
                                );
                              }
                            }

                            _refreshData();
                          });
                        },
                      )
                    : SizedBox(
                        width: 10.w,
                      ),
              ],
            ),
            isDataFound
                ? Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 5.r,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : tempList.length > 0
                    ? Expanded(
                        child: SizedBox(
                          height: 100.h,
                          child: FutureBuilder(
                              future: _listFuture,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Salesact>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasError) {
                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Center(
                                            child: Image.asset(
                                              'assets/images/not_found.png',
                                              width:
                                                  isHorizontal ? 340.r : 300.r,
                                              height:
                                                  isHorizontal ? 340.r : 300.r,
                                            ),
                                          ),
                                          Text(
                                            'Data tidak ditemukan',
                                            style: TextStyle(
                                              fontSize:
                                                  isHorizontal ? 28.sp : 18.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red[600],
                                              fontFamily: 'Montserrat',
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  } else {
                                    return listViewWidget(
                                      snapshot.data!,
                                      snapshot.data!.length,
                                      isHorizontal: isHorizontal,
                                    );
                                  }
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              }),
                        ),
                      )
                    : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/not_found.png',
                                  width: isHorizontal ? 150.w : 230.w,
                                  height: isHorizontal ? 150.h : 230.h,
                                ),
                              ),
                              Text(
                                'Data tidak ditemukan',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 16.sp : 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                  fontFamily: 'Montserrat',
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget listViewWidget(List<Salesact> data, int len,
      {bool isHorizontal = false}) {
    return RefreshIndicator(
      child: ListView.builder(
          itemCount: len,
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 20.r : 5.r,
            vertical: isHorizontal ? 20.r : 10.r,
          ),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, position) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      SizedBox(
                        height: isHorizontal ? 14.h : 19.h,
                      ),
                      Center(
                        child: Text(
                          data[position].timeStart.substring(10, 16),
                          style: TextStyle(
                            fontSize: isHorizontal ? 16.sp : 14.sp,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Card(
                    elevation: 2,
                    child: InkWell(
                        child: Container(
                          height: isHorizontal ? 75.h : 80.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isHorizontal ? 15.r : 10.r,
                              vertical: 8.r,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    widget.isAdmin
                                        ? Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.r,
                                              vertical: 3.r,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade600,
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Text(
                                              data[position].salesName,
                                              style: TextStyle(
                                                fontSize: isHorizontal
                                                    ? 16.sp
                                                    : 14.sp,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : SizedBox(
                                            height: 10.h,
                                          ),
                                    widget.isAdmin
                                        ? SizedBox(
                                            width: isHorizontal ? 5.w : 10.w,
                                          )
                                        : SizedBox(
                                            height: 5.h,
                                          ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        data[position].agenda,
                                        style: TextStyle(
                                            fontSize:
                                                isHorizontal ? 16.sp : 15.sp,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87),
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        data[position].optik,
                                        style: TextStyle(
                                          fontSize:
                                              isHorizontal ? 16.sp : 14.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.r,
                                        vertical: 3.r,
                                      ),
                                      decoration: BoxDecoration(
                                        color: data[position].mengetahui == "0"
                                            ? Colors.red.shade100
                                            : Colors.green.shade100,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        data[position].mengetahui == "0"
                                            ? "Menunggu"
                                            : "Dikonfirmasi",
                                        style: TextStyle(
                                          fontSize:
                                              isHorizontal ? 14.sp : 12.sp,
                                          fontFamily: 'Segoe ui',
                                          fontWeight: FontWeight.w600,
                                          color:
                                              data[position].mengetahui == "0"
                                                  ? Colors.red.shade600
                                                  : Colors.green.shade600,
                                        ),
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          if (widget.isAdmin) {
                            setState(() {
                              tandaiAktivitas(
                                id!,
                                data[position].actId,
                                data[position].optik,
                                data[position].salesId,
                                data[position].salesToken != ''
                                    ? data[position].salesToken
                                    : "",
                              );

                              Future.delayed(Duration(seconds: 1)).then(
                                (_) => _refreshData(),
                              );
                            });
                          }

                          dialogDetail(
                            context,
                            data[position],
                            isAdmin: widget.isAdmin,
                          );
                        }),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
              ],
            );
          }),
      onRefresh: _refreshData,
    );
  }

  dialogDetail(BuildContext context, Salesact data, {bool isAdmin = false}) {
    return showModalBottomSheet(
      elevation: 2,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.r),
          topRight: Radius.circular(15.r),
        ),
      ),
      context: context,
      builder: (context) => DialogActivity(
        data,
        isAdmin,
      ),
    );
  }
}
