import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sample/src/domain/entities/online_trainer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/service/service_marketingexpense.dart';
import '../../controllers/marketingexpense_controller.dart';
import '../../utils/custom.dart';

// ignore: must_be_immutable
class ProfileScheduleOnline extends StatefulWidget {
  bool isHorizontal;
  ProfileScheduleOnline({
    Key? key,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  State<ProfileScheduleOnline> createState() => _ProfileScheduleOnlineState();
}

class _ProfileScheduleOnlineState extends State<ProfileScheduleOnline> {
  ServiceMarketingExpense serviceMe = new ServiceMarketingExpense();
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  List<OnlineTrainer> listOnline = List.empty(growable: true);

  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';
  String search = '';
  String? divisi = '';
  String? status = '';

   @override
  void initState() {
    super.initState();
    getRole();
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");
      name = preferences.getString("name") ?? '';
      status = preferences.getString("status") ?? '';

      if (id != null) {
        meController
            .getOnlineTrainer(mounted, context, key: id ?? '')
            .then((value) {
          setState(() {
            listOnline.addAll(value);

            listOnline.forEach((element) {
              print("""
              Id online : ${element.idOnline}
              """);
            });
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 5.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 8.w,
                ),
                child: Text(
                  'Tambahkan jadwal online',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: widget.isHorizontal ? 20.sp : 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 8.w),
                child: Container(
                  decoration: const ShapeDecoration(
                    color: Colors.lightBlue,
                    shape: CircleBorder(),
                  ),
                  child: Ink(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          constraints: BoxConstraints(
                            maxHeight: widget.isHorizontal ? 40.r : 30.r,
                            maxWidth: widget.isHorizontal ? 40.r : 30.r,
                          ),
                          icon: const Icon(Icons.add),
                          iconSize: widget.isHorizontal ? 20.r : 15.r,
                          color: Colors.white,
                          onPressed: () async {
                            await showCalendarDatePicker2Dialog(
                              context: context,
                              config:
                                  CalendarDatePicker2WithActionButtonsConfig(
                                calendarType: CalendarDatePicker2Type.range,
                              ),
                              dialogSize: Size(325, 400),
                              borderRadius: BorderRadius.circular(15.r),
                            ).then((value) {
                              print(value);
                              if (value != null) {
                                var edDate;
                                final stDate =
                                    DateFormat('yyyy-MM-dd').format(value[0]!);
                                if (value.length > 1) {
                                  edDate = DateFormat('yyyy-MM-dd')
                                      .format(value[1]!);
                                } else {
                                  edDate = stDate;
                                }

                                print("""
                                      Start Date : $stDate,
                                      End Date : $edDate,
                                      """);

                                setState(() {
                                  listOnline.add(OnlineTrainer(
                                    idOnline: '',
                                    idTrainer: id,
                                    onlineStart: "$stDate 00:00:01",
                                    onlineUntil: "$edDate 23:59:59",
                                  ));

                                  listOnline.forEach((element) {
                                    print("""
                                    id : ${element.idOnline}
                                    st date : ${element.onlineStart}
                                    ed date : ${element.onlineUntil}
                                    """);
                                  });
                                });

                                serviceMe
                                    .insertOnlineTrainer(
                                  context: context,
                                  isHorizontal: widget.isHorizontal,
                                  isInsert: true,
                                  mounted: mounted,
                                  item: listOnline,
                                )
                                    .then((value) {
                                  listOnline.clear();

                                  meController
                                      .getOnlineTrainer(mounted, context,
                                          key: id ?? '')
                                      .then((value) {
                                    setState(() {
                                      listOnline.addAll(value);

                                      listOnline.forEach((element) {
                                        print("""
                                        Id offline : ${element.idOnline}
                                        """);
                                      });
                                    });
                                  });
                                });
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 7.h,
          ),
          Visibility(
            visible: listOnline.length > 0 ? true : false,
            child: Column(
              children: [
                itemOnline(),
                SizedBox(
                  height: 7.h,
                ),
              ],
            ),
            replacement: Padding(
              padding: EdgeInsets.only(
                top: 70.r,
                bottom: 70.r,
                left: 10.r,
                right: 10.r,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/not_found.png',
                        width: widget.isHorizontal ? 150.w : 200.w,
                        height: widget.isHorizontal ? 150.h : 200.h,
                      ),
                    ),
                    Text(
                      'Data tidak ditemukan',
                      style: TextStyle(
                        fontSize: widget.isHorizontal ? 14.sp : 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[600],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemOnline() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: listOnline.length,
      itemBuilder: (context, pos) {
        return Container(
          margin: EdgeInsets.symmetric(
            vertical: 5.h,
            horizontal: 10.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(5.r),
            ),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 5.h,
                      left: 5.h,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () async {
                          List<DateTime?> _value = List.empty(growable: true);
                          if (listOnline[pos].onlineStart != null &&
                              listOnline[pos].onlineUntil != null) {
                            _value.add(DateFormat("yyyy-MM-dd hh:mm:ss")
                                .parse(listOnline[pos].onlineStart!));
                            _value.add(DateFormat("yyyy-MM-dd hh:mm:ss")
                                .parse(listOnline[pos].onlineUntil!));
                          }

                          await showCalendarDatePicker2Dialog(
                            context: context,
                            config: CalendarDatePicker2WithActionButtonsConfig(
                              calendarType: CalendarDatePicker2Type.range,
                            ),
                            dialogSize: Size(325, 400),
                            borderRadius: BorderRadius.circular(15.r),
                            value: _value,
                          ).then((value) {
                            print(value);
                            if (value != null) {
                              var edDate;
                              final stDate =
                                  DateFormat('yyyy-MM-dd').format(value[0]!);
                              if (value.length > 1) {
                                edDate =
                                    DateFormat('yyyy-MM-dd').format(value[1]!);
                              } else {
                                edDate = stDate;
                              }

                              print("""
                              Start Date : $stDate,
                              End Date : $edDate,
                              """);

                              setState(() {
                                listOnline[pos].onlineStart =
                                    "$stDate 00:00:01";
                                listOnline[pos].onlineUntil =
                                    "$edDate 23:59:59";
                              });

                              serviceMe
                                  .insertOnlineTrainer(
                                context: context,
                                isHorizontal: widget.isHorizontal,
                                isInsert: false,
                                mounted: mounted,
                                item: listOnline,
                              )
                                  .then((value) {
                                listOnline.clear();

                                meController
                                    .getOnlineTrainer(mounted, context,
                                        key: id ?? '')
                                    .then((value) {
                                  setState(() {
                                    listOnline.addAll(value);

                                    listOnline.forEach((element) {
                                      print("""
                                        Id online : ${element.idOnline}
                                        """);
                                    });
                                  });
                                });
                              });
                            }
                          });
                        },
                        child: Icon(
                          Icons.date_range,
                          color: Colors.blue.shade500,
                          size: 22.r,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 5.h,
                      right: 5.h,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          print('Delete ${listOnline[pos].idOnline}');
                          serviceMe
                              .deleteOnlineTrainer(
                            context: context,
                            item: listOnline[pos],
                          )
                              .then((value) {
                            listOnline.clear();

                            meController
                                .getOnlineTrainer(mounted, context,
                                    key: id ?? '')
                                .then((value) {
                              setState(() {
                                listOnline.addAll(value);

                                listOnline.forEach((element) {
                                  print("""
                                        Id offline : ${element.idOnline}
                                        """);
                                });
                              });
                            });
                          });
                        },
                        child: Icon(
                          Icons.dangerous_outlined,
                          color: Colors.red.shade500,
                          size: 22.r,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 8.w,
                      ),
                      child: Text(
                        'Online Start',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 8.w,
                      ),
                      child: Align(
                        child: Text(
                          'Online Until',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 7.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 8.w,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black54,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Text(
                            listOnline[pos].onlineStart != null
                                ? convertDateWithMonth(
                                    listOnline[pos].onlineStart!)
                                : '-- Belum Dipilih --',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w600,
                              color: listOnline[pos].onlineStart != null
                                  ? Colors.black54
                                  : Colors.red.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 8.w,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black54,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Text(
                            listOnline[pos].onlineUntil != null
                                ? convertDateWithMonth(
                                    listOnline[pos].onlineUntil!)
                                : '-- Belum Dipilih --',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w600,
                              color: listOnline[pos].onlineStart != null
                                  ? Colors.black54
                                  : Colors.red.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // SizedBox(
              //   height: 8.h,
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: 8.w,
              //   ),
              //   child: Text(
              //     'Offline Reason',
              //     style: TextStyle(
              //       fontSize: 14.sp,
              //       fontFamily: 'Segoe ui',
              //       fontWeight: FontWeight.w600,
              //       color: Colors.black54,
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: 7.h,
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: 8.w,
              //   ),
              //   child: Container(
              //     padding:
              //         EdgeInsets.symmetric(horizontal: 10.r, vertical: 7.r),
              //     decoration: BoxDecoration(
              //         color: Colors.white70,
              //         border: Border.all(color: Colors.black54),
              //         borderRadius: BorderRadius.circular(5.r)),
              //     child: DropdownButton(
              //       underline: SizedBox(),
              //       isExpanded: true,
              //       value: listOnline[pos].offlineReason!.isNotEmpty
              //           ? listOnline[pos].offlineReason
              //           : _choosenOfflineReason,
              //       style: TextStyle(
              //         color: Colors.black54,
              //         fontFamily: 'Segoe Ui',
              //         fontSize: 14.sp,
              //         fontWeight: FontWeight.w600,
              //       ),
              //       items: [
              //         'CUTI',
              //         'SAKIT',
              //         'LIBUR',
              //         'LAINNYA',
              //       ].map((e) {
              //         return DropdownMenuItem(
              //           value: e,
              //           child: Text(e, style: TextStyle(color: Colors.black54)),
              //         );
              //       }).toList(),
              //       hint: Text(
              //         "Select Reason",
              //         style: TextStyle(
              //             color: Colors.black54,
              //             fontSize: 14.sp,
              //             fontWeight: FontWeight.w600,
              //             fontFamily: 'Segoe Ui'),
              //       ),
              //       onChanged: (value) {
              //         setState(() {
              //           _choosenOfflineReason = value.toString();
              //           listOnline[pos].offlineReason = value.toString();
              //         });

              //         serviceMe
              //             .insertOfflineTrainer(
              //           context: context,
              //           isHorizontal: widget.isHorizontal,
              //           isInsert: false,
              //           mounted: mounted,
              //           item: listOnline,
              //         )
              //             .then((value) {
              //           listOnline.clear();

              //           meController
              //               .getOfflineTrainer(mounted, context, key: id ?? '')
              //               .then((value) {
              //             setState(() {
              //               listOnline.addAll(value);

              //               listOnline.forEach((element) {
              //                 print("""
              //                 Id offline : ${element.idOffline}
              //                 """);
              //               });
              //             });
              //           });
              //         });
              //       },
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 8.h,
              ),
            ],
          ),
        );
      },
    );
  }
}