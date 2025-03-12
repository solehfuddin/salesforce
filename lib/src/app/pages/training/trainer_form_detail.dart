import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/training_controller.dart';
import 'package:sample/src/domain/service/service_training.dart';

import '../../../domain/entities/agenda_training.dart';

// ignore: must_be_immutable
class TrainerFormDetail extends StatefulWidget {
  bool isHorizontal = false;

  TrainerFormDetail({
    Key? key,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  State<TrainerFormDetail> createState() => _TrainerFormDetailState();
}

class _TrainerFormDetailState extends State<TrainerFormDetail> {
  ServiceTraining serviceTraining = new ServiceTraining();
  TrainingController controller = Get.find<TrainingController>();
  TextEditingController controllerAgenda = TextEditingController();

  List<AgendaTraining> itemAgenda = List.empty(growable: true);
  String search = '';

  @override
  void initState() {
    super.initState();

    serviceTraining.getSearchAgenda(context, input: search).then((value) {
      itemAgenda = value;
    });
  }

  getSelectedAgenda() {
    setState(() {
      controllerAgenda.clear();

      itemAgenda.forEach((e) {
        if (e.ischecked) {
          controllerAgenda.text += e.agenda + ";";
        }
      });

      controller.trainingMateri.value = controllerAgenda.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Mekanisme Training',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // SizedBox(width: 10.w,),
                // Expanded(
                //   flex: 1,
                //   child: Text(
                //     'Materi Training',
                //     style: TextStyle(
                //       color: Colors.black54,
                //       fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                //       fontFamily: 'Montserrat',
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
              ],
            ),
            SizedBox(
              height: widget.isHorizontal ? 18.h : 8.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isHorizontal ? 10.r : 5.r,
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
                      value: controller.trainingMechanism.value,
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Segoe ui',
                        fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      items: [
                        'OFFLINE KUNJUNGAN',
                        'ONLINE GOOGLE MEET',
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
                          fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onChanged: (String? _value) {
                        controller.trainingMechanism.value = _value!;
                      },
                    ),
                  ),
                ),
                // SizedBox(width: 10.w,),
                // Expanded(
                //   flex: 1,
                //   child: Container(
                //     padding: EdgeInsets.symmetric(
                //       horizontal: widget.isHorizontal ? 10.r : 5.r,
                //     ),
                //     decoration: BoxDecoration(
                //       border: Border.all(
                //         color: Colors.black54,
                //       ),
                //       borderRadius: BorderRadius.circular(5.r),
                //     ),
                //     child: DropdownButton(
                //       underline: SizedBox(),
                //       isExpanded: true,
                //       value: controller.trainingMateri.value,
                //       style: TextStyle(
                //         color: Colors.black54,
                //         fontFamily: 'Segoe ui',
                //         fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                //         fontWeight: FontWeight.w600,
                //       ),
                //       items: [
                //         'PENGENALAN LENSA',
                //         'FRAME',
                //         'LEINZ REGULAR',
                //         'LEINZ PREMIUM',
                //         'HANDLING COMPLAINT',
                //         'LAINNYA',
                //       ].map((e) {
                //         return DropdownMenuItem(
                //             value: e,
                //             child: Text(
                //               e,
                //               style: TextStyle(
                //                 color: Colors.black54,
                //               ),
                //             ));
                //       }).toList(),
                //       hint: Text(
                //         'Pilih materi training',
                //         style: TextStyle(
                //           color: Colors.black54,
                //           fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                //           fontWeight: FontWeight.w600,
                //           fontFamily: 'Segoe ui',
                //         ),
                //       ),
                //       onChanged: (String? _value) {
                //         controller.trainingMateri.value = _value!;
                //       },
                //     ),
                //   ),
                // ),
              ],
            ),
            SizedBox(
              height: widget.isHorizontal ? 22.h : 10.h,
            ),
            Text(
              'Agenda Training',
              style: TextStyle(
                color: Colors.black54,
                fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: widget.isHorizontal ? 22.h : 10.h,
            ),
            TextFormField(
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Agenda',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 2.h,
                  horizontal: 10.w,
                ),
                errorText:
                    controllerAgenda.text.isEmpty ? 'Agenda belum diisi' : null,
                suffixIcon: IconButton(
                  onPressed: () {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return dialogAgenda(
                            isHorizontal: widget.isHorizontal,
                          );
                        });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 30.r,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                fontFamily: 'Segoe Ui',
              ),
              maxLength: 50,
              controller: controllerAgenda,
            ),
            SizedBox(
              height: widget.isHorizontal ? 22.h : 10.h,
            ),
            Text(
              'Catatan Sales',
              style: TextStyle(
                color: Colors.black54,
                fontFamily: 'Segoe ui',
                fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: widget.isHorizontal ? 18.h : 8.h,
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
              style: TextStyle(
                color: Colors.black54,
                fontFamily: 'Segoe ui',
                fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (value) {
                controller.trainingNotes.value = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget dialogAgenda({bool isHorizontal = false}) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: Center(
          child: Text('Pilih Agenda'),
        ),
        content: Container(
          height: MediaQuery.of(context).size.height / 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SizedBox(
                  height: 100.h,
                  child: itemAgenda.length > 0
                      ? listAgendaWidget(
                          itemAgenda,
                        )
                      : Center(
                          child: Text('Data tidak ditemukan'),
                        ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        getSelectedAgenda();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text("Pilih"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget listAgendaWidget(List<AgendaTraining> item) {
    return StatefulBuilder(builder: (context, setState) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: item.length,
        itemBuilder: (BuildContext context, int index) {
          String _key = item[index].agenda;
          return CheckboxListTile(
            value: item[index].ischecked,
            title: Text(_key),
            onChanged: (bool? val) {
              setState(() {
                item[index].ischecked = val!;
              });
            },
          );
        },
      );
    });
  }
}
