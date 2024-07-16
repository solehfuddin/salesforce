import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_rekening.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';

// ignore: camel_case_types
class Marketingexpense_Formdetail extends StatefulWidget {
  const Marketingexpense_Formdetail({Key? key}) : super(key: key);

  @override
  State<Marketingexpense_Formdetail> createState() =>
      _Marketingexpense_FormdetailState();
}

// ignore: camel_case_types
class _Marketingexpense_FormdetailState
    extends State<Marketingexpense_Formdetail> {
  TextEditingController controllerStartDate = TextEditingController();
  TextEditingController controllerEndDate = TextEditingController();
  TextEditingController controllerPayDate = TextEditingController();
  TextEditingController controllerNomorSp = TextEditingController();
  TextEditingController controllerPercent = TextEditingController();
  TextEditingController controllerValues = TextEditingController();
  late FocusNode focusPercent, focusValue;

  final format = DateFormat("dd MMM yyyy");
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  @override
  void initState() {
    super.initState();
    focusPercent = FocusNode();
    focusValue = FocusNode();
  }

  @override
  void dispose() {
    focusPercent.dispose();
    focusValue.dispose();
    super.dispose();
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
          color: Colors.blue.shade700,
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
                    'Informasi Detail',
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
                    Container(
                      height: 15.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Sp Satuan',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: meController.isHorizontal.value
                                  ? 22.sp
                                  : 12.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch(
                            value: meController.isSpSatuan.value,
                            onChanged: (value) {
                              meController.isSpSatuan.value = value;
                            },
                            activeTrackColor: Colors.blue.shade400,
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Visibility(
                      visible: meController.isSpSatuan.value,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            'Nomor Sp satuan',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: meController.isHorizontal.value
                                  ? 24.sp
                                  : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height:
                                meController.isHorizontal.value ? 18.h : 8.h,
                          ),
                          TextFormField(
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'Nomor SP',
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
                              errorText: meController.validateNomorSp.value
                                  ? null
                                  : 'Nomor Sp belum diisi',
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
                            controller: controllerNomorSp,
                            onChanged: (value) {
                              meController.validateNomorSp.value = true;
                              meController.nomorSp.value = value;
                            },
                            onSaved: (value) {
                              meController.nomorSp.value = value ?? '';
                            },
                          ),
                        ],
                      ),
                      replacement: Column(
                        children: [
                          Center(
                            child: Text(
                              'Periode kontrak marketing expense',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: meController.isHorizontal.value
                                    ? 24.sp
                                    : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                meController.isHorizontal.value ? 20.h : 12.h,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: DateTimeFormField(
                                  decoration: InputDecoration(
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    labelText:
                                        controllerStartDate.text.isNotEmpty
                                            ? controllerStartDate.text
                                            : 'dd mon yyyy',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                    errorText:
                                        meController.validateStartDate.value
                                            ? null
                                            : 'Wajib diisi',
                                    hintStyle: TextStyle(
                                      fontSize: meController.isHorizontal.value
                                          ? 24.sp
                                          : 14.sp,
                                      fontFamily: 'Segoe Ui',
                                    ),
                                  ),
                                  dateFormat: format,
                                  mode: DateTimeFieldPickerMode.date,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2050),
                                  initialDate: DateTime.now(),
                                  autovalidateMode: AutovalidateMode.always,
                                  onDateSelected: (DateTime value) {
                                    controllerStartDate.text =
                                        DateFormat('dd MMM yyyy').format(value);
                                    meController.startDate.value =
                                        DateFormat('yyyy-MM-dd').format(value);
                                    meController.validateStartDate.value = true;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                height: meController.validateStartDate.value &&
                                        meController.validateEndDate.value
                                    ? 20.h
                                    : 40.h,
                                child: Text(
                                  's/d',
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: meController.isHorizontal.value
                                        ? 24.sp
                                        : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Expanded(
                                flex: 1,
                                child: DateTimeFormField(
                                  decoration: InputDecoration(
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    labelText: controllerEndDate.text.isNotEmpty
                                        ? controllerEndDate.text
                                        : 'dd mon yyyy',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                    errorText:
                                        meController.validateEndDate.value
                                            ? null
                                            : 'Wajib diisi',
                                    hintStyle: TextStyle(
                                      fontSize: meController.isHorizontal.value
                                          ? 24.sp
                                          : 14.sp,
                                      fontFamily: 'Segoe Ui',
                                    ),
                                  ),
                                  dateFormat: format,
                                  mode: DateTimeFieldPickerMode.date,
                                  firstDate: DateTime(2024),
                                  lastDate: DateTime(2050),
                                  initialDate: DateTime.now(),
                                  autovalidateMode: AutovalidateMode.always,
                                  onDateSelected: (DateTime value) {
                                    controllerEndDate.text =
                                        DateFormat('dd MMM yyyy').format(value);
                                    meController.endDate.value =
                                        DateFormat('yyyy-MM-dd').format(value);
                                    meController.validateEndDate.value = true;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height:
                                meController.isHorizontal.value ? 22.h : 12.h,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Container(
                      height: 15.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Nominal dalam persen (%)',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: meController.isHorizontal.value
                                  ? 22.sp
                                  : 12.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch(
                            value: meController.isMePercent.value,
                            onChanged: (value) {
                              meController.isMePercent.value = value;

                              if (value) {
                                focusPercent.requestFocus();
                                meController.validateValues.value = true;
                                meController.validatePercent.value = false;
                              } else {
                                focusValue.requestFocus();
                                meController.validatePercent.value = true;
                                meController.validateValues.value = false;
                              }
                            },
                            activeTrackColor: Colors.blue.shade400,
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            // focusNode: focusPercent,
                            // readOnly: !meController.validatePercent.value ? true : false,
                            enabled: !meController.validatePercent.value
                                ? true
                                : false,
                            decoration: InputDecoration(
                              hintText: '0',
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
                              errorText: meController.validatePercent.value
                                  ? null
                                  : 'Wajib diisi',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[0-9.]"),
                              ),
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                                  final text = newValue.text;
                                  return text.isEmpty
                                      ? newValue
                                      : double.tryParse(text) == null
                                          ? oldValue
                                          : newValue;
                                },
                              ),
                            ],
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: meController.isHorizontal.value
                                  ? 25.sp
                                  : 15.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w600,
                            ),
                            maxLength: 4,
                            controller: controllerPercent,
                            onChanged: (value) {
                              if (value.length > 0) {
                                if (double.parse(value) >= 10) {
                                  controllerPercent.value = TextEditingValue(
                                    text: "10",
                                  );
                                }

                                meController.percentValues.value = controllerPercent.value.text;
                              }
                            },
                            onEditingComplete: () {
                              meController.validatePercent.value = true;
                            },
                            onSaved: (value) {
                              // controllerPercent.text = value!;
                              meController.percentValues.value = value!;
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Container(
                          alignment: Alignment.topCenter,
                          height: 40.h,
                          child: Text(
                            '%',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: meController.isHorizontal.value
                                  ? 24.sp
                                  : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            // focusNode: focusValue,
                            enabled:
                                meController.isMePercent.value ? false : true,
                            decoration: InputDecoration(
                              hintText: '0',
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
                              errorText: meController.validateValues.value
                                  ? null
                                  : 'Wajib diisi',
                            ),
                            inputFormatters: [
                              ThousandsSeparatorInputFormatter(),
                            ],
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: meController.isHorizontal.value
                                  ? 25.sp
                                  : 15.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w600,
                            ),
                            maxLength: 11,
                            controller: controllerValues,
                            onChanged: (value) {
                              meController.nominalValues.value = value;
                              meController.validateValues.value = true;
                            },
                            onSaved: (newValue) {
                              meController.nominalValues.value = newValue!;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: meController.isHorizontal.value ? 22.h : 12.h,
                    ),
                    Text(
                      'Mekanisme marketing expense',
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            meController.isHorizontal.value ? 10.r : 5.r,
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
                        value: meController.selectedPayment.value,
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Segoe ui',
                          fontSize:
                              meController.isHorizontal.value ? 25.sp : 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        items: [
                          'DEPOSIT',
                          'POTONG TAGIHAN',
                          'TRANSFER BANK',
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
                          'Pilih mekanisme marketing expense',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize:
                                meController.isHorizontal.value ? 24.sp : 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                          ),
                        ),
                        onChanged: (String? value) {
                          meController.selectedPayment.value = value!;
                        },
                      ),
                    ),
                    SizedBox(
                      height: meController.isHorizontal.value ? 22.h : 12.h,
                    ),
                    Marketingexpense_Rekening(),
                    SizedBox(
                      height: meController.isHorizontal.value ? 22.h : 12.h,
                    ),
                    Text(
                      'Pembayaran paling lambat',
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
                    DateTimeFormField(
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: controllerPayDate.text.isNotEmpty
                            ? controllerPayDate.text
                            : 'dd mon yyyy',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        errorText: meController.validatePayDate.value
                            ? null
                            : 'Wajib diisi',
                        hintStyle: TextStyle(
                          fontSize:
                              meController.isHorizontal.value ? 24.sp : 14.sp,
                          fontFamily: 'Segoe Ui',
                        ),
                      ),
                      dateFormat: format,
                      mode: DateTimeFieldPickerMode.date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050),
                      initialDate: DateTime.now(),
                      autovalidateMode: AutovalidateMode.always,
                      onDateSelected: (DateTime value) {
                        controllerPayDate.text =
                            DateFormat('dd MMM yyyy').format(value);
                        meController.payDate.value =
                            DateFormat('yyyy-MM-dd').format(value);
                        meController.validatePayDate.value = true;
                      },
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
