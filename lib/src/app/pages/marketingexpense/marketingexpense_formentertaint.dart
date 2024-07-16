import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_itemme.dart';
import 'package:sample/src/app/widgets/multiImage.dart';
import 'package:sample/src/domain/entities/marketingexpense_line.dart';

// ignore: camel_case_types
class Marketingexpense_Formentertaint extends StatefulWidget {
  const Marketingexpense_Formentertaint({Key? key}) : super(key: key);

  @override
  State<Marketingexpense_Formentertaint> createState() =>
      _Marketingexpense_FormentertaintState();
}

// ignore: camel_case_types
class _Marketingexpense_FormentertaintState
    extends State<Marketingexpense_Formentertaint> {
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.only(
          left: meController.isHorizontal.value ? 10.r : 5.r,
          right: meController.isHorizontal.value ? 10.r : 5.r,
          top: meController.isHorizontal.value ? 20.r : 10.r,
          bottom: meController.isHorizontal.value ? 20.r : 5.r,
        ),
        child: Card(
          elevation: 2,
          borderOnForeground: true,
          color: Colors.orange.shade700,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.r,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: meController.isHorizontal.value ? 20.r : 10.r,
                ),
                child: Center(
                  child: Text(
                    'Informasi Entertaint',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: meController.isHorizontal.value ? 26.sp : 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(
                  meController.isHorizontal.value ? 24.r : 12.r,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tambahkan item entertaint',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize:
                                meController.isHorizontal.value ? 20.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
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
                                    maxHeight: meController.isHorizontal.value
                                        ? 40.r
                                        : 30.r,
                                    maxWidth: meController.isHorizontal.value
                                        ? 40.r
                                        : 30.r,
                                  ),
                                  icon: const Icon(Icons.add),
                                  iconSize: meController.isHorizontal.value
                                      ? 20.r
                                      : 15.r,
                                  color: Colors.white,
                                  onPressed: () {
                                    meController.listMELine.add(
                                      MarketingExpenseLine(
                                        judul: "",
                                        price: "",
                                      ),
                                    );

                                    meController.listMEAttachment
                                        .forEach((element) {
                                      print(element.path);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Visibility(
                          visible:
                              meController.listMELine.length > 0 ? true : false,
                          child: Center(
                            child: Marketingexpense_Itemme(
                              isHorizontal: meController.isHorizontal.value,
                            ),
                          ),
                          replacement: Padding(
                            padding: EdgeInsets.only(
                              top: 70.r,
                              bottom: 70.r,
                              left: 10.r,
                              right: 10.r,
                            ),
                            child: Center(
                              child: Text(
                                'Belum ada produk',
                                style: TextStyle(
                                  fontSize: meController.isHorizontal.value
                                      ? 20.sp
                                      : 12.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'Tambahkan attachment',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize:
                            meController.isHorizontal.value ? 20.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    MultiImage(
                      dottedColor: Colors.blue.shade800,
                      backgroundColor: Colors.blue.shade100,
                      buttonBackgroundColor: Colors.blue.shade800,
                      labelColor: Colors.blue.shade900,
                      listAttachment: meController.listMEAttachment,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
