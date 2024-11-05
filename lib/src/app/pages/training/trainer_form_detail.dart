import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/training_controller.dart';

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
  TrainingController controller = Get.find<TrainingController>();

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
                SizedBox(width: 10.w,),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Materi Training',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
                SizedBox(width: 10.w,),
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
                      value: controller.trainingMateri.value,
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Segoe ui',
                        fontSize: widget.isHorizontal ? 18.sp : 12.sp,
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
                          fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onChanged: (String? _value) {
                        controller.trainingMateri.value = _value!;
                      },
                    ),
                  ),
                ),
              ],
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
}
