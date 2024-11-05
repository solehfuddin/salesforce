import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sample/src/app/controllers/training_controller.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_pickerr/time_pickerr.dart';

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
                Duration(days: 90),
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
                  print('Tanggal tersebut libur');
                  Get.snackbar(
                    'Informasi',
                    'Hari libur tidak dapat dipilih',
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
                          if (value.length > 0)
                          {
                            controller.trainingDuration.value = int.parse(value);
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
