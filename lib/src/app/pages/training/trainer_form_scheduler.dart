import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sample/src/app/controllers/training_controller.dart';
import 'package:sample/src/domain/entities/offline_trainer.dart';
import 'package:sample/src/domain/entities/online_trainer.dart';
import 'package:sample/src/domain/service/service_marketingexpense.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_pickerr/time_pickerr.dart';

import '../../../domain/entities/holiday_format.dart';
import '../../../domain/entities/trainer.dart';

// ignore: must_be_immutable
class TrainerFormScheduler extends StatefulWidget {
  bool isHorizontal = false;
  TrainerFormScheduler({
    Key? key,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  State<TrainerFormScheduler> createState() => _TrainerFormSchedulerState();
}

class _TrainerFormSchedulerState extends State<TrainerFormScheduler> {
  TrainingController controller = Get.find<TrainingController>();
  ServiceMarketingExpense serviceME = ServiceMarketingExpense();
  late Trainer trainer;
  List<OfflineTrainer> listOffline = List.empty(growable: true);
  List<OnlineTrainer> listOnline = List.empty(growable: true);
  List<HolidayFormat> listHoliday = List.empty(growable: true);
  List<HolidayFormat> listEnableHoliday = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    trainer = controller.trainer.value;

    String format = DateFormat('yyyy-MM-dd').format(DateTime.now());
    controller.selectedDate.value = format;

    print("""
    Trainer Id : ${trainer.id}
    Trainer Name : ${trainer.name}
    Offline Start : ${trainer.offlineStart}
    Offline Until : ${trainer.offlineUntil}
    """);

    serviceME
        .getOfflineTrainer(mounted, context, key: trainer.id ?? '')
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
        .getOnlineTrainer(mounted, context, key: trainer.id ?? '')
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
    }
    // else if (stDate1.day == 31 && stDate1.month == 12) {
    //   for (int st = stDate1.day; st <= edDate1.day; st++) {
    //     listEnableHoliday.add(HolidayFormat(
    //         day: st - stDate1.day,
    //         month: stDate1.month + 1,
    //         year: stDate1.year + 1));

    //     print("""
    //           Online
    //           Int Day  = $st
    //           Int Month = ${stDate1.month}
    //           Int Year = ${stDate1.year}
    //           """);
    //   }
    // }
    else {
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

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penjadwalan training',
              style: TextStyle(
                fontFamily: 'Segoe ui',
                fontSize: widget.isHorizontal ? 18.sp : 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
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
              height: widget.isHorizontal ? 10.h : 8.h,
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
                      width: widget.isHorizontal ? 10.w : 5.w,
                    ),
                    Material(
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.isHorizontal ? 20.r : 15.r,
                            vertical: widget.isHorizontal ? 15.r : 8.r,
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
                              fontSize: widget.isHorizontal ? 20.sp : 14.sp,
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
                      width: widget.isHorizontal ? 10.w : 5.w,
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
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
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
                          fontSize: widget.isHorizontal ? 25.sp : 15.sp,
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
                      width: widget.isHorizontal ? 10.w : 5.w,
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
          ],
        ),
      ),
    );
  }
}
