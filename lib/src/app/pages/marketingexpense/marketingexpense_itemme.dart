import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';

// ignore: camel_case_types, must_be_immutable
class Marketingexpense_Itemme extends StatefulWidget {
  bool isHorizontal = false;

  Marketingexpense_Itemme({
    Key? key,
    required this.isHorizontal,
  }) : super(key: key);

  @override
  State<Marketingexpense_Itemme> createState() =>
      _Marketingexpense_ItemmeState();
}

//ignore: camel_case_types
class _Marketingexpense_ItemmeState extends State<Marketingexpense_Itemme> {
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();
  List<TextEditingController> listControllerTitle = List.empty(growable: true);
  List<TextEditingController> listControllerValue = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    listControllerValue.clear();
    listControllerTitle.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: meController.listMELine.length,
      itemBuilder: (context, index) {
        meController.listMELine.forEach((element) {
          listControllerValue.add(
            new TextEditingController.fromValue(
              TextEditingValue(
                text: meController.listMELine[index].price.toString(),
              ),
            ),
          );

          listControllerTitle.add(
            new TextEditingController.fromValue(
              TextEditingValue(
                text: meController.listMELine[index].judul.toString(),
              ),
            ),
          );
        });

        return Column(
          children: [
            SizedBox(
              height: widget.isHorizontal ? 10.h : 5.h,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'Jenis Entertaint',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15.w,
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Biaya',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 35.w,
                ),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Transport',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Segoe ui',
                        fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                    controller: listControllerTitle[index],
                    onChanged: (value) {
                      meController.listMELine[index].judul = value;
                    },
                    maxLength: 50,
                  ),
                ),
                SizedBox(
                  width: 8.w,
                ),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    inputFormatters: [
                      ThousandsSeparatorInputFormatter(),
                    ],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Segoe ui',
                        fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                    controller: listControllerValue[index],
                    onChanged: (value) {
                      meController.listMELine[index].price = value;
                    },
                    maxLength: 10,
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        print('Delete');
                        meController.listMELine.removeAt(index);
                      },
                      child: Icon(
                        Icons.dangerous_outlined,
                        color: Colors.red.shade500,
                        size: 30.r,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
