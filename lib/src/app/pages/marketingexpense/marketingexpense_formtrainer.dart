import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:date_field/date_field.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_pickerr/time_pickerr.dart';

import '../../../domain/entities/trainer.dart';
import 'marketingexpense_widgettrainer.dart';

// ignore: camel_case_types
class Marketingexpense_Formtrainer extends StatefulWidget {
  const Marketingexpense_Formtrainer({Key? key}) : super(key: key);

  @override
  State<Marketingexpense_Formtrainer> createState() =>
      _Marketingexpense_FormtrainerState();
}

// ignore: camel_case_types
class _Marketingexpense_FormtrainerState
    extends State<Marketingexpense_Formtrainer> {
  List<Trainer> _list = List.empty(growable: true);

  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  TextEditingController controllerNotes = TextEditingController();

  @override
  void initState() {
    super.initState();
    meController.getAllTrainer(mounted, context).then((value) {
      // value.forEach((element) {
      //   print("""
      //   trainer : ${element.name}
      //   """);
      // });
      setState(() {
        _list.addAll(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(
          isHorizontal: true,
        );
      }

      return childWidget(
        isHorizontal: false,
      );
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.desciptionColor,
        title: Text(
          'Pengajuan Training',
          style: TextStyle(
            color: Colors.white,
            fontSize: isHorizontal ? 20.sp : 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: isHorizontal ? 20.r : 18.r,
          ),
        ),
      ),
      body: Obx(
        () => Container(
          padding: EdgeInsets.only(
            left: meController.isHorizontal.value ? 10.r : 5.r,
            right: meController.isHorizontal.value ? 10.r : 5.r,
            top: meController.isHorizontal.value ? 20.r : 10.r,
            bottom: meController.isHorizontal.value ? 20.r : 5.r,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: meController.isHorizontal.value ? 22.h : 12.h,
                    ),
                    Text(
                      'Pilih Trainer',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize:
                            meController.isHorizontal.value ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: meController.isHorizontal.value ? 18.h : 8.h,
                    ),
                    SizedBox(
                      height: 105.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var i in _list)
                            Marketingexpense_widgettrainer(
                              trainer: i,
                              isSelected:
                                  i.name == meController.selectedTrainer.value
                                      ? true
                                      : false,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: meController.isHorizontal.value ? 22.h : 12.h,
                ),
                Text(
                  'Mekanisme Training',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: meController.isHorizontal.value ? 24.sp : 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: meController.isHorizontal.value ? 18.h : 8.h,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: meController.isHorizontal.value ? 10.r : 5.r,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black54,
                    ),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: DropdownButton(
                    underline: SizedBox(),
                    isExpanded: true,
                    value: meController.trainingMechanism.value,
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Segoe ui',
                      fontSize: meController.isHorizontal.value ? 25.sp : 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    items: [
                      'OFFLINE KUNJUNGAN',
                      'ONLINE GOOGLE MEETING',
                      'ONLINE ZOOM',
                    ].map((e) {
                      return DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ));
                    }).toList(),
                    hint: Text(
                      'Pilih mekanisme training',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize:
                            meController.isHorizontal.value ? 24.sp : 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Segoe ui',
                      ),
                    ),
                    onChanged: (String? _value) {
                      meController.trainingMechanism.value = _value!;
                    },
                  ),
                ),
                SizedBox(
                  height: meController.isHorizontal.value ? 22.h : 12.h,
                ),
                Text(
                  'Materi Training',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: meController.isHorizontal.value ? 24.sp : 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: meController.isHorizontal.value ? 18.h : 8.h,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: meController.isHorizontal.value ? 10.r : 5.r,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black54,
                    ),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: DropdownButton(
                    underline: SizedBox(),
                    isExpanded: true,
                    value: meController.trainingMateri.value,
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Segoe ui',
                      fontSize: meController.isHorizontal.value ? 25.sp : 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    items: [
                      'PENGENALAN LENSA',
                      'FRAME',
                      'LEINZ REGULAR',
                      'LEINZ PREMIUM',
                      'LAINNYA',
                    ].map((e) {
                      return DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ));
                    }).toList(),
                    hint: Text(
                      'Pilih materi training',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize:
                            meController.isHorizontal.value ? 24.sp : 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Segoe ui',
                      ),
                    ),
                    onChanged: (String? _value) {
                      meController.trainingMateri.value = _value!;
                    },
                  ),
                ),
                SizedBox(
                  height: meController.isHorizontal.value ? 22.h : 12.h,
                ),
                Text(
                  'Tanggal Training',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: meController.isHorizontal.value ? 24.sp : 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: meController.isHorizontal.value ? 18.h : 10.h,
                ),
                TableCalendar(
                  focusedDay: meController.dateSelection.value,
                  firstDay: meController.dateNow.value,
                  lastDay: meController.dateNow.value.add(
                    Duration(days: 90),
                  ),
                  selectedDayPredicate: (day) =>
                      isSameDay(meController.dateSelection.value, day),
                  // selectedDayPredicate: (day) ,
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
                  calendarFormat: CalendarFormat.week,
                  holidayPredicate: (day) {
                    if (day.weekday == 6 || day.weekday == 7) {
                      print(
                          'Holiday at ${day.day} - ${day.month} - ${day.year}');
                      return true;
                    }

                    return false;
                  },
                  headerVisible: false,
                  locale: "id_ID",
                  onDaySelected: (selectedDay, focusedDay) {
                    // setState(() {
                    //   String format =
                    //       DateFormat('yyyy-MM-dd').format(selectedDay);
                    //   selectedDate = format;
                    //   selDateTime = focusedDay;
                    //   _listFuture = getDailyAct(id!, selectedDate);
                    // });

                    if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
                      print('Tanggal tersebut libur');
                      Get.snackbar(
                        'Informasi',
                        'Tidak dapat memilih tanggal merah',
                        backgroundColor: Colors.amber.shade500,
                        animationDuration: Duration(seconds: 1),
                        duration: Duration(seconds: 2),
                      );
                    } else {
                      String format =
                          DateFormat('yyyy-MM-dd').format(selectedDay);
                      meController.selectedDate.value = format;
                      meController.dateSelection.value = focusedDay;

                      print(
                          'Date Selected : ${DateFormat('yyy-MM-dd').format(meController.dateSelection.value)}');
                    }
                  },
                ),
                SizedBox(
                  height: meController.isHorizontal.value ? 22.h : 12.h,
                ),
                Text(
                  'Waktu Training',
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Segoe ui',
                    fontSize: meController.isHorizontal.value ? 24.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: meController.isHorizontal.value ? 18.h : 8.h,
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomHourPicker(
                          elevation: 2,
                          title: 'Select Time',
                          onPositivePressed: (context, time) {
                            print(DateFormat("HH:mm:ss").format(time));
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
                  child: Text('Sample'),
                ),
                DateTimeFormField(
                  decoration: InputDecoration(
                    hintText: 'dd mon yyyy',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    // errorText:
                    //     _isTanggalLahir ? 'Data wajib diisi' : null,
                    hintStyle: TextStyle(
                      fontSize: meController.isHorizontal.value ? 24.sp : 14.sp,
                      fontFamily: 'Segoe Ui',
                    ),
                  ),
                  // dateFormat: DateFormat("dd MMM yyyy"),
                  use24hFormat: false,
                  mode: DateTimeFieldPickerMode.time,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  initialDate: DateTime.now(),
                  autovalidateMode: AutovalidateMode.always,
                  // validator: (DateTime? e) =>
                  //     (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
                  onDateSelected: (DateTime value) {
                    // print('before date : $value');
                    // tanggalLahir =
                    //     DateFormat('yyyy-MM-dd').format(value);
                    // textTanggalLahir.text = tanggalLahir;
                    // print('after date : $tanggalLahir');
                  },
                ),
                SizedBox(
                  height: meController.isHorizontal.value ? 22.h : 12.h,
                ),
                Text(
                  'Catatan',
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Segoe ui',
                    fontSize: meController.isHorizontal.value ? 24.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: meController.isHorizontal.value ? 18.h : 8.h,
                ),
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 150,
                  style: TextStyle(
                    color: Colors.black54,
                    fontFamily: 'Segoe ui',
                    fontSize: meController.isHorizontal.value ? 25.sp : 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  controller: controllerNotes,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
