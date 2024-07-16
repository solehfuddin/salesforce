import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/domain/service/service_cashback.dart';

// ignore: camel_case_types
class Marketingexpense_Formpemilik extends StatefulWidget {
  const Marketingexpense_Formpemilik({Key? key}) : super(key: key);

  @override
  State<Marketingexpense_Formpemilik> createState() =>
      _Marketingexpense_FormpemilikState();
}

// ignore: camel_case_types
class _Marketingexpense_FormpemilikState
    extends State<Marketingexpense_Formpemilik> {
  ServiceCashback serviceCashback = ServiceCashback();
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  @override
  void initState() {
    super.initState();
  }

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
          color: MyColors.greenAccent,
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
                    'Informasi Pemilik',
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
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      'Nama Pemilik',
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
                    TextFormField(
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Nama Pemilik',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Segoe ui',
                          fontSize:
                              meController.isHorizontal.value ? 24.sp : 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 2.h,
                        ),
                        errorText: meController.validateDataName.value
                            ? null
                            : 'Nama belum diisi',
                      ),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize:
                            meController.isHorizontal.value ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLength: 16,
                      controller: meController.txtOwner.value,
                      onChanged: (value) {
                        if (value.length > 3) {
                          meController.validateDataName.value = true;

                          if (value.length > 3 &&
                              meController.validateDataNik.value) {
                            meController.enableRekening.value = true;
                          }
                        } else {
                          meController.validateDataName.value = false;
                          meController.enableRekening.value = false;
                        }
                      },
                      onSaved: (value) {
                        meController.dataName.value = meController.txtOwner.value.text;
                      },
                    ),
                    SizedBox(
                      height: meController.isHorizontal.value ? 22.h : 12.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'KTP',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: meController.isHorizontal.value
                                  ? 20.sp
                                  : 12.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15.w,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'NPWP',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: meController.isHorizontal.value
                                  ? 20.sp
                                  : 12.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: meController.isHorizontal.value ? 18.h : 8.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Ktp',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Segoe ui',
                                fontSize: meController.isHorizontal.value
                                    ? 24.sp
                                    : 14.sp,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 2.h,
                              ),
                              errorText: meController.validateDataNik.value
                                  ? null
                                  : 'Ktp belum diisi',
                            ),
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: meController.isHorizontal.value
                                  ? 25.sp
                                  : 15.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w600,
                            ),
                            maxLength: 16,
                            controller: meController.txtKtp.value,
                            onChanged: (value) {
                              if (value.length > 15) {
                                meController.validateDataNik.value = true;
                                meController.dataNik.value = value;

                                if (meController.validateDataName.value &&
                                    value.length > 15) {
                                  meController.enableRekening.value = true;
                                }
                              } else {
                                meController.validateDataNik.value = false;
                                meController.enableRekening.value = false;
                              }
                            },
                            onSaved: (value) =>
                                meController.dataNik.value = meController.txtKtp.value.text,
                          ),
                        ),
                        SizedBox(
                          width: 15.w,
                        ),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Npwp',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Segoe ui',
                                fontSize: meController.isHorizontal.value
                                    ? 24.sp
                                    : 14.sp,
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
                              fontSize: meController.isHorizontal.value
                                  ? 25.sp
                                  : 15.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w600,
                            ),
                            maxLength: 15,
                            controller: meController.txtNpwp.value,
                            onChanged: (value) => meController.dataNpwp.value = value,
                            onSaved: (value) =>
                                meController.dataNpwp.value = meController.txtNpwp.value.text,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: meController.isHorizontal.value ? 22.h : 12.h,
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
