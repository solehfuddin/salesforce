import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sample/src/app/pages/cashback/cashback_widgettype.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/settings_cashback.dart';

import '../../../domain/entities/cashback_rekening.dart';
import '../../controllers/marketingexpense_controller.dart';
import '../../utils/thousandformatter.dart';
import 'cashback_newrekening.dart';
import 'cashback_oldrekening.dart';

// ignore: must_be_immutable
class CashbackFormContract extends StatefulWidget {
  final Function(String? varName, dynamic input) updateParent;
  TextEditingController controllerStartDate = new TextEditingController();
  TextEditingController controllerEndDate = new TextEditingController();
  TextEditingController controllerWithdrawDuration =
      new TextEditingController();
  TextEditingController controllerNomorSp = TextEditingController();
  TextEditingController controllerPercent = TextEditingController();
  TextEditingController controllerValues = TextEditingController();
  TextEditingController controllerPayDate = TextEditingController();

  CashbackRekening cashbackRekening = new CashbackRekening();

  bool isHorizontal = false;
  bool isCashbackValue = true;
  bool isWalletAvail = false;
  bool isActiveRekening = false;
  bool validateStartDate = false;
  bool validateEndDate = false;
  bool validateWithdrawDuration = false;
  String selectedWithdrawProcess = 'TAGIHAN LUNAS';
  String selectedPaymentTermint = '7 hari';
  String billNumber, shipNumber;

  CashbackType cashbackType = CashbackType.BY_TARGET;

  CashbackFormContract({
    Key? key,
    required this.cashbackType,
    required this.updateParent,
    required this.isHorizontal,
    required this.isWalletAvail,
    required this.isActiveRekening,
    required this.billNumber,
    required this.shipNumber,
    required this.isCashbackValue,
    required this.validateStartDate,
    required this.validateEndDate,
    required this.validateWithdrawDuration,
    required this.selectedWithdrawProcess,
    required this.selectedPaymentTermint,
    required this.controllerStartDate,
    required this.controllerEndDate,
    required this.controllerWithdrawDuration,
    required this.controllerNomorSp,
    required this.controllerPercent,
    required this.controllerValues,
    required this.controllerPayDate,
    required this.cashbackRekening,
  }) : super(key: key);

  @override
  State<CashbackFormContract> createState() => _CashbackFormContractState();
}

class _CashbackFormContractState extends State<CashbackFormContract> {
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();
  final format = DateFormat("dd MMM yyyy");

  late FocusNode focusPercent, focusValue;

  @override
  void initState() {
    super.initState();
    focusPercent = FocusNode();
    focusValue = FocusNode();

    if (widget.controllerNomorSp.text.isNotEmpty)
    {
      meController.validateNomorSp.value = true;
    }

    if (widget.controllerPayDate.text.isNotEmpty)
    {
      meController.validatePayDate.value = true;
    }

    if (widget.controllerPercent.text.isNotEmpty)
    {
      meController.validatePercent.value = true;
      meController.isMePercent.value = false;
    }

    if (widget.controllerValues.text.isNotEmpty)
    {
      meController.validateValues.value = true;
      meController.isMePercent.value = true;
    }
  }

  @override
  void dispose() {
    focusPercent.dispose();
    focusValue.dispose();
    super.dispose();
  }

  updateSelected(dynamic variableName, dynamic returnVal) {
    setState(() {
      switch (variableName) {
        case 'selectedCashbackType':
          if (returnVal == "By Product") {
            widget.cashbackType = CashbackType.BY_PRODUCT;
          } else if (returnVal == "By Target") {
            widget.cashbackType = CashbackType.BY_TARGET;
          } else if (returnVal == "Combine") {
            widget.cashbackType = CashbackType.COMBINE;
          } else {
            widget.cashbackType = CashbackType.BY_SP;
          }

          widget.updateParent('setSelectedCashbackType', widget.cashbackType);
          break;
        case 'updateNewRekening':
          widget.cashbackRekening = returnVal;
          widget.isActiveRekening = true;

          widget.updateParent('updateNewRekening', widget.cashbackRekening);
          widget.updateParent('setActiveRekening', true);
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.only(
          left: widget.isHorizontal ? 10.r : 5.r,
          right: widget.isHorizontal ? 10.r : 5.r,
          top: widget.isHorizontal ? 20.r : 10.r,
          bottom: widget.isHorizontal ? 20.r : 5.r,
        ),
        child: Card(
          elevation: 2,
          borderOnForeground: true,
          color: MyColors.purpleColor,
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
                  vertical: widget.isHorizontal ? 20.r : 10.r,
                ),
                child: Center(
                  child: Text(
                    'Informasi Cashback',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.isHorizontal ? 26.sp : 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(
                  widget.isHorizontal ? 24.r : 12.r,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      maintainAnimation: true,
                      maintainState: true,
                      visible: widget.cashbackType == CashbackType.BY_SP
                          ? true
                          : false,
                      child: AnimatedOpacity(
                        duration: const Duration(
                          milliseconds: 1500,
                        ),
                        curve: Curves.fastOutSlowIn,
                        opacity:
                            widget.cashbackType == CashbackType.BY_SP ? 1 : 0,
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
                                          ? 24.sp
                                          : 14.sp,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Switch(
                                    value: meController.isSpSatuan.value,
                                    onChanged: (value) {
                                      meController.isSpSatuan.value = value;

                                      if (value) {
                                        widget.controllerStartDate.clear();
                                        widget.controllerEndDate.clear();

                                        meController.validateStartDate.value =
                                            false;
                                        meController.validateEndDate.value =
                                            false;
                                      } else {
                                        widget.controllerNomorSp.clear();
                                        meController.validateNomorSp.value =
                                            false;
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
                            Visibility(
                              visible: meController.isSpSatuan.value,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    height: meController.isHorizontal.value
                                        ? 18.h
                                        : 8.h,
                                  ),
                                  TextFormField(
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: InputDecoration(
                                      hintText: 'Nomor SP',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Segoe ui',
                                        fontSize:
                                            meController.isHorizontal.value
                                                ? 24.sp
                                                : 14.sp,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 2.h,
                                      ),
                                      errorText:
                                          meController.validateNomorSp.value
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
                                    controller: widget.controllerNomorSp,
                                    onChanged: (value) {
                                      meController.nomorSp.value = value;

                                      if (value.isNotEmpty) {
                                        meController.validateNomorSp.value =
                                            true;
                                      } else {
                                        meController.validateNomorSp.value =
                                            false;
                                      }
                                    },
                                  ),
                                ],
                              ),
                              replacement: Column(
                                children: [
                                  Center(
                                    child: Text(
                                      'Periode kontrak Sp',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize:
                                            meController.isHorizontal.value
                                                ? 24.sp
                                                : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: meController.isHorizontal.value
                                        ? 20.h
                                        : 12.h,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: DateTimeFormField(
                                          decoration: InputDecoration(
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.never,
                                            labelText: widget
                                                    .controllerStartDate
                                                    .text
                                                    .isNotEmpty
                                                ? widget
                                                    .controllerStartDate.text
                                                : 'dd mon yyyy',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.r),
                                            ),
                                            errorText: meController
                                                    .validateStartDate.value
                                                ? null
                                                : 'Wajib diisi',
                                            hintStyle: TextStyle(
                                              fontSize: meController
                                                      .isHorizontal.value
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
                                          autovalidateMode:
                                              AutovalidateMode.always,
                                          onDateSelected: (DateTime value) {
                                            widget.controllerStartDate.text =
                                                DateFormat('dd MMM yyyy')
                                                    .format(value);
                                            meController.startDate.value =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(value);
                                            meController
                                                .validateStartDate.value = true;

                                            widget.updateParent(
                                                'setDateStart', value);
                                            widget.updateParent(
                                                'validateStartDate', true);
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                      ),
                                      Container(
                                        alignment: Alignment.topCenter,
                                        height: meController
                                                    .validateStartDate.value &&
                                                meController
                                                    .validateEndDate.value
                                            ? 20.h
                                            : 40.h,
                                        child: Text(
                                          's/d',
                                          style: TextStyle(
                                            color: Colors.black45,
                                            fontSize:
                                                meController.isHorizontal.value
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
                                            labelText: widget.controllerEndDate
                                                    .text.isNotEmpty
                                                ? widget.controllerEndDate.text
                                                : 'dd mon yyyy',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.r),
                                            ),
                                            errorText: meController
                                                    .validateEndDate.value
                                                ? null
                                                : 'Wajib diisi',
                                            hintStyle: TextStyle(
                                              fontSize: meController
                                                      .isHorizontal.value
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
                                          autovalidateMode:
                                              AutovalidateMode.always,
                                          onDateSelected: (DateTime value) {
                                            widget.controllerEndDate.text =
                                                DateFormat('dd MMM yyyy')
                                                    .format(value);
                                            meController.endDate.value =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(value);
                                            meController.validateEndDate.value =
                                                true;
                                            widget.updateParent(
                                                'setDateEnd', value);
                                            widget.updateParent(
                                                'validateEndDate', true);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: meController.isHorizontal.value
                                        ? 22.h
                                        : 12.h,
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
                                          ? 24.sp
                                          : 14.sp,
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
                                        meController.validateValues.value =
                                            true;
                                        meController.validatePercent.value =
                                            false;
                                        widget.controllerValues.clear();
                                      } else {
                                        focusValue.requestFocus();
                                        meController.validatePercent.value =
                                            true;
                                        meController.validateValues.value =
                                            false;
                                        widget.controllerPercent.clear();
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
                                        TextInputType.numberWithOptions(
                                            decimal: true),
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
                                        fontSize:
                                            meController.isHorizontal.value
                                                ? 24.sp
                                                : 14.sp,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 2.h,
                                      ),
                                      errorText:
                                          meController.validatePercent.value
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
                                    controller: widget.controllerPercent,
                                    onChanged: (value) {
                                      if (value.length > 0) {
                                        if (double.parse(value) >= 10) {
                                          widget.controllerPercent.value =
                                              TextEditingValue(
                                            text: "10",
                                          );
                                        }

                                        meController.percentValues.value =
                                            widget.controllerPercent.value.text;
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
                                    enabled: meController.isMePercent.value
                                        ? false
                                        : true,
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Segoe ui',
                                        fontSize:
                                            meController.isHorizontal.value
                                                ? 24.sp
                                                : 14.sp,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 2.h,
                                      ),
                                      errorText:
                                          meController.validateValues.value
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
                                    controller: widget.controllerValues,
                                    onChanged: (value) {
                                      meController.nominalValues.value = value;
                                      meController.validateValues.value = true;
                                    },
                                    onSaved: (newValue) {
                                      meController.nominalValues.value =
                                          newValue!;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(
                            //   height:
                            //       meController.isHorizontal.value ? 22.h : 12.h,
                            // ),
                            // Marketingexpense_Rekening(),
                            SizedBox(
                              height:
                                  meController.isHorizontal.value ? 22.h : 12.h,
                            ),
                            Text(
                              'Pembayaran paling lambat',
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
                            DateTimeFormField(
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                labelText:
                                    widget.controllerPayDate.text.isNotEmpty
                                        ? widget.controllerPayDate.text
                                        : 'dd mon yyyy',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                errorText: meController.validatePayDate.value
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
                                widget.controllerPayDate.text =
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
                      replacement: SizedBox(
                        width: 5.w,
                      ),
                    ),
                    Visibility(
                      maintainAnimation: true,
                      maintainState: true,
                      visible: widget.cashbackType != CashbackType.BY_SP,
                      child: AnimatedOpacity(
                        duration: const Duration(
                          milliseconds: 1500,
                        ),
                        curve: Curves.fastEaseInToSlowEaseOut,
                        opacity:
                            widget.cashbackType != CashbackType.BY_SP ? 1 : 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Periode kontrak cashback',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: widget.isHorizontal ? 20.h : 12.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: DateTimeFormField(
                                    decoration: InputDecoration(
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      labelText: widget.controllerStartDate.text
                                              .isNotEmpty
                                          ? widget.controllerStartDate.text
                                          : 'dd mon yyyy',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                      ),
                                      errorText: widget.validateStartDate
                                          ? null
                                          : 'Wajib diisi',
                                      hintStyle: TextStyle(
                                        fontSize:
                                            widget.isHorizontal ? 24.sp : 14.sp,
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
                                      print('start date : $value');
                                      widget.controllerStartDate.text =
                                          DateFormat('yyyy-MM-dd')
                                              .format(value);
                                      widget.updateParent(
                                          'setDateStart', value);
                                      widget.updateParent(
                                          'validateStartDate', true);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Container(
                                  alignment: Alignment.topCenter,
                                  height: widget.validateStartDate &&
                                          widget.validateEndDate
                                      ? 20.h
                                      : 40.h,
                                  child: Text(
                                    's/d',
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontSize:
                                          widget.isHorizontal ? 24.sp : 14.sp,
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
                                      labelText: widget
                                              .controllerEndDate.text.isNotEmpty
                                          ? widget.controllerEndDate.text
                                          : 'dd mon yyyy',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                      ),
                                      errorText: widget.validateEndDate
                                          ? null
                                          : 'Wajib diisi',
                                      hintStyle: TextStyle(
                                        fontSize:
                                            widget.isHorizontal ? 24.sp : 14.sp,
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
                                      print('end date : $value');
                                      widget.controllerEndDate.text =
                                          DateFormat('yyyy-MM-dd')
                                              .format(value);
                                      widget.updateParent('setDateEnd', value);
                                      widget.updateParent(
                                          'validateEndDate', true);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: widget.isHorizontal ? 22.h : 12.h,
                            ),
                            Text(
                              'Pencairan cashback setelah',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: widget.isHorizontal ? 18.h : 8.h,
                            ),
                            Container(
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
                                value: widget.selectedWithdrawProcess,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'Segoe ui',
                                  fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: [
                                  'TAGIHAN LUNAS',
                                  'PERIODE KONTRAK BERAKHIR',
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
                                  'Pilih proses pencairan',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize:
                                        widget.isHorizontal ? 24.sp : 14.sp,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Segoe ui',
                                  ),
                                ),
                                onChanged: (String? _value) {
                                  setState(() {
                                    widget.selectedWithdrawProcess = _value!;
                                    widget.updateParent(
                                        'setSelectedWithdrawProcess', _value);
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: widget.isHorizontal ? 22.h : 12.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Durasi Pencairan',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize:
                                          widget.isHorizontal ? 24.sp : 14.sp,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    'Termin pembayaran',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize:
                                          widget.isHorizontal ? 24.sp : 14.sp,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 15.w,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: widget
                                                      .validateWithdrawDuration
                                                  ? 15.h
                                                  : 15.h,
                                            ),
                                            TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey.shade400,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Segoe ui',
                                                  fontSize: widget.isHorizontal
                                                      ? 24.sp
                                                      : 14.sp,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.r),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 10.w,
                                                  vertical: 2.h,
                                                ),
                                                errorText: widget
                                                        .validateWithdrawDuration
                                                    ? null
                                                    : 'Wajib Isi',
                                              ),
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: widget.isHorizontal
                                                    ? 25.sp
                                                    : 15.sp,
                                                fontFamily: 'Segoe ui',
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLength: 3,
                                              controller: widget
                                                  .controllerWithdrawDuration,
                                              onChanged: (value) {
                                                if (value.length > 0) {
                                                  widget.updateParent(
                                                      'validateWithdrawDuration',
                                                      true);
                                                } else {
                                                  widget.updateParent(
                                                      'validateWithdrawDuration',
                                                      false);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      Container(
                                        alignment: Alignment.topCenter,
                                        height: widget.validateWithdrawDuration
                                            ? 25.h
                                            : 20.h,
                                        child: Text(
                                          'Hari',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: widget.isHorizontal
                                                ? 24.sp
                                                : 14.sp,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15.w,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 17.w,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          widget.isHorizontal ? 10.r : 5.r,
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
                                      value: widget.selectedPaymentTermint,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontFamily: 'Segoe ui',
                                        fontSize:
                                            widget.isHorizontal ? 25.sp : 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      items: [
                                        '7 hari',
                                        '14 hari',
                                        '30 hari',
                                        '45 hari',
                                        '60 hari',
                                        '90 hari',
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
                                        'Pilih termin pembayaran',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: widget.isHorizontal
                                              ? 24.sp
                                              : 14.sp,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Segoe ui',
                                        ),
                                      ),
                                      onChanged: (String? _value) {
                                        setState(() {
                                          widget.selectedPaymentTermint =
                                              _value!;
                                          widget.updateParent(
                                              'setSelectedPaymentTermint',
                                              _value);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      replacement: SizedBox(
                        height: 8.h,
                      ),
                    ),
                    SizedBox(
                      height: meController.isHorizontal.value ? 22.h : 12.h,
                    ),
                    Text(
                      'Mekanisme cashback',
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
                    Visibility(
                      visible:
                          meController.selectedPayment.value == "TRANSFER BANK"
                              ? true
                              : false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: widget.isHorizontal ? 22.h : 12.h,
                          ),
                          Text(
                            'Informasi Rekening',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  onPressed: widget.isWalletAvail
                                      ? () {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return StatefulBuilder(
                                                  builder: (context, state) {
                                                return AlertDialog(
                                                  scrollable: true,
                                                  title: Center(
                                                    child:
                                                        Text('Pilih Rekening'),
                                                  ),
                                                  content: CashbackOldRekening(
                                                    isHorizontal:
                                                        widget.isHorizontal,
                                                    updateParent:
                                                        updateSelected,
                                                    noAccount:
                                                        widget.billNumber,
                                                  ),
                                                );
                                              });
                                            },
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade400,
                                  ),
                                  icon: Icon(Icons.check_circle),
                                  label: Text(
                                    'Pilih Rekening',
                                  ),
                                ),
                              ),
                              SizedBox(width: 15.w),
                              Expanded(
                                flex: 4,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      elevation: 2,
                                      backgroundColor: Colors.white,
                                      isDismissible: true,
                                      enableDrag: false,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                      ),
                                      context: context,
                                      builder: (context) {
                                        return CashbackNewRekening(
                                          isHorizontal: widget.isHorizontal,
                                          billNumber: widget.billNumber,
                                          shipNumber: widget.shipNumber,
                                          updateParent: updateSelected,
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade400,
                                  ),
                                  icon: Icon(
                                    Icons.add_circle_rounded,
                                  ),
                                  label: Text(
                                    'Tambah rekening baru',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          widget.isActiveRekening
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.r,
                                    vertical: 5.r,
                                  ),
                                  child: Card(
                                    elevation: 2,
                                    child: Container(
                                      height:
                                          widget.isHorizontal ? 115.h : 65.h,
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            widget.isHorizontal ? 25.r : 15.r,
                                        vertical:
                                            widget.isHorizontal ? 20.r : 10.r,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '${widget.cashbackRekening.getNamaRekening} (${widget.cashbackRekening.getBankName})',
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.isHorizontal
                                                            ? 24.sp
                                                            : 14.sp,
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'Nomor Rekening : ${widget.cashbackRekening.getNomorRekening}',
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.isHorizontal
                                                            ? 24.sp
                                                            : 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Segoe ui',
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Image.asset(
                                            'assets/images/success.png',
                                            width: widget.isHorizontal
                                                ? 45.r
                                                : 25.r,
                                            height: widget.isHorizontal
                                                ? 45.r
                                                : 25.r,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Card(
                                  elevation: 3,
                                  child: Container(
                                    height: widget.isHorizontal ? 115.h : 65.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          widget.isHorizontal ? 25.r : 15.r,
                                      vertical:
                                          widget.isHorizontal ? 20.r : 10.r,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                'Tidak ada informasi rekening',
                                                style: TextStyle(
                                                  fontSize: widget.isHorizontal
                                                      ? 24.sp
                                                      : 14.sp,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red.shade700,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                'Pilih rekening atau buat rekening baru',
                                                style: TextStyle(
                                                  fontSize: widget.isHorizontal
                                                      ? 24.sp
                                                      : 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Segoe ui',
                                                  color: Colors.black45,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Image.asset(
                                          'assets/images/failure.png',
                                          width:
                                              widget.isHorizontal ? 45.r : 25.r,
                                          height:
                                              widget.isHorizontal ? 45.r : 25.r,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      replacement: SizedBox(
                        width: 5.w,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Center(
                      child: Text(
                        'Tipe Cashback',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CashbackWidgetType(
                            updateParent: updateSelected,
                            isHorizontal: widget.isHorizontal,
                            isSelected:
                                widget.cashbackType == CashbackType.BY_TARGET
                                    ? true
                                    : false,
                            cardIcon: 'assets/images/cashback_target.png',
                            cardTitle: 'By Target',
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          CashbackWidgetType(
                            updateParent: updateSelected,
                            isHorizontal: widget.isHorizontal,
                            isSelected:
                                widget.cashbackType == CashbackType.BY_PRODUCT
                                    ? true
                                    : false,
                            cardIcon: 'assets/images/cashback_product.png',
                            cardTitle: 'By Product',
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          CashbackWidgetType(
                            updateParent: updateSelected,
                            isHorizontal: widget.isHorizontal,
                            isSelected:
                                widget.cashbackType == CashbackType.COMBINE
                                    ? true
                                    : false,
                            cardIcon: 'assets/images/cashback_combine.png',
                            cardTitle: 'Combine',
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          CashbackWidgetType(
                            updateParent: updateSelected,
                            isHorizontal: widget.isHorizontal,
                            isSelected:
                                widget.cashbackType == CashbackType.BY_SP
                                    ? true
                                    : false,
                            cardIcon: 'assets/images/cashback_sp.png',
                            cardTitle: 'By SP',
                          ),
                        ],
                      ),
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
