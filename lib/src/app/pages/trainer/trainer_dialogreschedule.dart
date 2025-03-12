import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_pickerr/time_pickerr.dart';

import '../../../domain/entities/holiday_format.dart';
import '../../../domain/entities/offline_trainer.dart';
import '../../../domain/entities/online_trainer.dart';
import '../../../domain/entities/training_header.dart';
import '../../../domain/service/service_marketingexpense.dart';
import '../../controllers/training_controller.dart';
import '../../utils/config.dart';
import '../../utils/custom.dart';

// ignore: must_be_immutable
class TrainerDialogReschedule extends StatefulWidget {
  TrainingHeader item;
  TrainerDialogReschedule({Key? key, required this.item}) : super(key: key);

  @override
  State<TrainerDialogReschedule> createState() =>
      _TrainerDialogRescheduleState();
}

class _TrainerDialogRescheduleState extends State<TrainerDialogReschedule> {
  TrainingController controller = Get.find<TrainingController>();
  ServiceMarketingExpense serviceME = ServiceMarketingExpense();
  List<OfflineTrainer> listOffline = List.empty(growable: true);
  List<OnlineTrainer> listOnline = List.empty(growable: true);
  List<HolidayFormat> listHoliday = List.empty(growable: true);
  List<HolidayFormat> listEnableHoliday = List.empty(growable: true);

  @override
  void initState() {
    super.initState();

    String format = DateFormat('yyyy-MM-dd').format(DateTime.now());
    controller.selectedDate.value = format;

    serviceME
        .getOfflineTrainer(mounted, context, key: widget.item.trainerId ?? '')
        .then((value) {
      listOffline.addAll(value);

      listOffline.forEach((element) {
        generateDayBetweenTwoDate(
          element.offlineStart,
          element.offlineUntil,
          element.offlineReason,
        );
      });
    });

    serviceME
        .getOnlineTrainer(mounted, context, key: widget.item.trainerId ?? '')
        .then((value) {
      listOnline.addAll(value);

      listOnline.forEach((element) {
        generateDayBetweenTwoDateEnable(
            element.onlineStart, element.onlineUntil);
      });
    });
  }

  void generateDayBetweenTwoDate(
    String? startDate,
    String? endDate,
    String? reason,
  ) {
    DateTime stDate = DateTime.parse(startDate!);
    DateTime edDate = DateTime.parse(endDate!);

    print("""
    Int Start : ${stDate.day}
    Mon Start : ${stDate.month}
    Int End : ${edDate.day}
    Mon End : ${edDate.month}
    """);

    if (stDate.day == 31 && stDate.month == 12) {
      for (int st = stDate.day; st <= edDate.day + stDate.day; st++) {
        if (st > DateTime(stDate.year, stDate.month + 1, 0).day) {
          listHoliday.add(HolidayFormat(
            day: st - stDate.day,
            month: 01,
            year: stDate.year + 1,
            reason: reason,
          ));

          print("""
              Offline
              Int Day  = ${st - stDate.day}
              Int Month = 01
              Int Year = ${stDate.year + 1}
            """);
        } else {
          listHoliday.add(HolidayFormat(
            day: st,
            month: stDate.month,
            year: stDate.year,
            reason: reason,
          ));

          print("""
              Offline
              Int Day  = $st
              Int Month = ${stDate.month}
              Int Year = ${stDate.year}
              """);
        }
      }
    } else {
      if (stDate.day > edDate.day) {
        for (int st = stDate.day; st <= edDate.day + stDate.day; st++) {
          if (st > DateTime(stDate.year, stDate.month + 1, 0).day) {
            listHoliday.add(HolidayFormat(
              day: st - stDate.day,
              month: stDate.month + 1,
              year: stDate.year,
              reason: reason,
            ));

            print("""
          Offline
          Int Day  = ${st - stDate.day}
          Int Month = ${stDate.month + 1}
          Int Year = ${stDate.year}
          """);
          } else {
            listHoliday.add(HolidayFormat(
              day: st,
              month: stDate.month,
              year: stDate.year,
              reason: reason,
            ));

            print("""
          Offline
          Int Day  = $st
          Int Month = ${stDate.month}
          Int Year = ${stDate.year}
          """);
          }
        }
      } else {
        for (int st = stDate.day; st <= edDate.day; st++) {
          listHoliday.add(HolidayFormat(
            day: st,
            month: stDate.month,
            year: stDate.year,
            reason: reason,
          ));

          print("""
              Offline
              Int Day  = $st
              Int Month = ${stDate.month}
              Int Year = ${stDate.year}
              """);
        }
      }
    }
  }

  void generateDayBetweenTwoDateEnable(String? startDate, String? endDate) {
    DateTime stDate1 = DateTime.parse(startDate!);
    DateTime edDate1 = DateTime.parse(endDate!);

    print("""
    Int Start : ${stDate1.day}
    Int End : ${edDate1.day}
    """);

    if (stDate1.day > edDate1.day) {
      for (int st = stDate1.day; st <= edDate1.day + stDate1.day; st++) {
        if (st > DateTime(stDate1.year, stDate1.month + 1, 0).day) {
          listEnableHoliday.add(HolidayFormat(
              day: st - stDate1.day,
              month: stDate1.month + 1,
              year: stDate1.year));

          print("""
          Online
          Int Day  = ${st - stDate1.day}
          Int Month = ${stDate1.month + 1}
          Int Year = ${stDate1.year}
          """);
        } else {
          listEnableHoliday.add(
              HolidayFormat(day: st, month: stDate1.month, year: stDate1.year));

          print("""
          Online
          Int Day  = $st
          Int Month = ${stDate1.month}
          Int Year = ${stDate1.year}
          """);
        }
      }
    } else {
      for (int st = stDate1.day; st <= edDate1.day; st++) {
        listEnableHoliday.add(
            HolidayFormat(day: st, month: stDate1.month, year: stDate1.year));

        print("""
              Online
              Int Day  = $st
              Int Month = ${stDate1.month}
              Int Year = ${stDate1.year}
              """);
      }
    }
  }

  onButtonPressed() async {
    print("""
    id_training : ${widget.item.id},
    training_date : ${controller.selectedDate},
    training_time : ${controller.trainingTime},
    training_duration : ${controller.trainingDuration},
    """);

    await Future.delayed(
      const Duration(milliseconds: 1500),
      () => changeSchedule(),
    );

    return () {};
  }

  changeSchedule({
    bool isChangePassword = false,
    bool isHorizontal = false,
  }) async {
    const timeout = 15;
    var url = '$API_URL/training/reschedule';

    try {
      var response = await http.put(
        Uri.parse(url),
        body: {
          'id_training': widget.item.id,
          'training_date': controller.selectedDate.value,
          'training_time': controller.trainingTime.value,
          'training_duration': controller.trainingDuration.value.toString(),
        },
      ).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (sts) {
          print('Response sts: $sts');
          controller.clearState();
          Navigator.of(context, rootNavigator: true).pop();

          if (mounted) {
            print('Mounting context');

            handleStatus(
              context,
              capitalize(msg),
              sts,
              isHorizontal: isHorizontal,
              isLogout: false,
            );

            // pushNotif(
            //   30,
            //   3,
            //   salesName: widget.item.salesName,
            //   idUser: widget.item.createdBy,
            //   rcptToken: widget.item.salesToken,
            //   opticName: widget.item.opticName,
            // );
          }
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

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

  Widget childWidget({bool isHorizontal = false}) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(isHorizontal ? 20.r : 15.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.trainerName ?? '',
                      style: TextStyle(
                        fontFamily: 'Segoe Ui',
                        fontSize: isHorizontal ? 20.sp : 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Container(
                      child: Row(
                        children: [
                          Text(
                            widget.item.agenda!.length > 40
                                ? widget.item.agenda!.substring(0, 40) + '...'
                                : widget.item.agenda!,
                            style: TextStyle(
                              fontFamily: 'Segoe Ui',
                              fontSize: isHorizontal ? 14.sp : 11.sp,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Visibility(
                    visible: widget.item.trainerPhoto!.isEmpty ? true : false,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        height: 40.h,
                        width: 40.w,
                        child: Image.asset(
                          'assets/images/profile.png',
                          height: 40.h,
                          width: 40.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    replacement: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        height: 40.h,
                        width: 40.w,
                        child: Image.memory(
                          Base64Decoder().convert(
                            widget.item.trainerPhoto!,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 6.h,
            ),
            Container(
              color: Colors.orange.shade50,
              height: 25.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: 8.w,
                    ),
                    child: Row(children: [
                      Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          size: 15.r,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      SizedBox(
                        width: 3.w,
                      ),
                      Text(
                        convertDateWithMonth(widget.item.scheduleDate ?? '-'),
                        style: TextStyle(
                          fontFamily: 'Segoe Ui',
                          fontSize: isHorizontal ? 15.sp : 12.sp,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      right: 8.w,
                    ),
                    child: Row(children: [
                      Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: Icon(
                          Icons.watch_later_outlined,
                          size: 15.r,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      SizedBox(
                        width: 3.w,
                      ),
                      Text(
                        '${widget.item.scheduleStartTime} - ${widget.item.scheduleEndTime} WIB',
                        style: TextStyle(
                          fontFamily: 'Segoe Ui',
                          fontSize: isHorizontal ? 15.sp : 12.sp,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 6.h,
            ),
            Text(
              'Catatan Trainer : ${widget.item.rescheduleNotes ?? ''}',
              style: TextStyle(
                fontFamily: 'Segoe Ui',
                fontSize: isHorizontal ? 14.sp : 11.sp,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.justify,
            ),
            TableCalendar(
              focusedDay: controller.dateSelection.value,
              firstDay: controller.dateNow.value,
              lastDay: controller.dateNow.value.add(
                Duration(days: 365),
              ),
              selectedDayPredicate: (day) =>
                  isSameDay(controller.dateSelection.value, day),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultDecoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
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
                  color: Colors.white,
                ),
                holidayDecoration: BoxDecoration(
                  color: Colors.red.shade300,
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
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                leftChevronVisible: true,
                rightChevronVisible: true,
                titleTextFormatter: (date, locale) =>
                    DateFormat.yMMMM(locale).format(date),
                titleCentered: false,
                titleTextStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
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
              headerVisible: true,
              locale: "id_ID",
              onDaySelected: (selectedDay, focusedDay) {
                if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
                  if (listEnableHoliday.any((e) =>
                      e.day == selectedDay.day &&
                      e.month == selectedDay.month &&
                      e.year == selectedDay.year)) {
                    String format =
                        DateFormat('yyyy-MM-dd').format(selectedDay);
                    controller.selectedDate.value = format;
                    controller.dateSelection.value = focusedDay;

                    print(
                        'Date Selected : ${DateFormat('yyy-MM-dd').format(controller.dateSelection.value)}');
                  } else {
                    print('Tanggal tersebut libur');
                    Get.snackbar(
                      'Informasi',
                      'Hari libur tidak dapat dipilih',
                      colorText: Colors.white,
                      backgroundColor: Colors.red.shade500,
                      animationDuration: Duration(seconds: 1),
                      duration: Duration(seconds: 2),
                    );
                  }
                } else if (listHoliday.any((e) =>
                    e.day == selectedDay.day &&
                    e.month == selectedDay.month &&
                    e.year == selectedDay.year)) {
                  String? reason = '';
                  listHoliday.forEach((e) {
                    if (e.day == selectedDay.day &&
                        e.month == selectedDay.month &&
                        e.year == selectedDay.year) {
                      reason = e.reason;
                    }
                  });
                  print('Tanggal trainer berhalangan');
                  Get.snackbar(
                    'Informasi',
                    'Trainer berhalangan karena ${reason?.toLowerCase()}',
                    backgroundColor: Colors.amber.shade500,
                    animationDuration: Duration(seconds: 1),
                    duration: Duration(seconds: 2),
                  );
                } else {
                  String format = DateFormat('yyyy-MM-dd').format(selectedDay);
                  controller.selectedDate.value = format;
                  controller.dateSelection.value = focusedDay;

                  print(
                      'Date Selected : ${DateFormat('yyy-MM-dd').format(controller.dateSelection.value)}');
                }
              },
            ),
            SizedBox(
              height: isHorizontal ? 10.h : 8.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Waktu : ',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(
                      width: isHorizontal ? 10.w : 5.w,
                    ),
                    Material(
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isHorizontal ? 20.r : 15.r,
                            vertical: isHorizontal ? 15.r : 8.r,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            controller.trainingTime.toString(),
                            style: TextStyle(
                              fontSize: isHorizontal ? 20.sp : 14.sp,
                              fontFamily: 'Segoe Ui',
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomHourPicker(
                                elevation: 2,
                                title: 'Waktu Training',
                                onPositivePressed: (context, time) {
                                  print(DateFormat("HH:mm:ss").format(time));
                                  controller.trainingTime.value =
                                      DateFormat("HH : mm").format(time);
                                  Get.back();
                                },
                                onNegativePressed: (context) {
                                  print('onNegative');
                                  Get.back();
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Durasi : ',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(
                      width: isHorizontal ? 10.w : 5.w,
                    ),
                    Container(
                      width: 50.w,
                      height: 35.h,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 25.sp : 15.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 2.h,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: isHorizontal ? 25.sp : 15.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (value) {
                          if (value.length > 0) {
                            controller.trainingDuration.value =
                                int.parse(value);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: isHorizontal ? 10.w : 5.w,
                    ),
                    Text(
                      'Jam',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 15.h,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: EasyButton(
                idleStateWidget: Text(
                  "Simpan",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700),
                ),
                loadingStateWidget: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
                useEqualLoadingStateWidgetDimension: true,
                useWidthAnimation: true,
                height: 33.h,
                width: 90.w,
                borderRadius: 20.r,
                buttonColor: Colors.blue.shade600,
                elevation: 2.0,
                onPressed: onButtonPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
