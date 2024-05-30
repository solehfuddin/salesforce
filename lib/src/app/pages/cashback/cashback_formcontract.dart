import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sample/src/app/pages/cashback/cashback_widgettype.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/settings_cashback.dart';

// ignore: must_be_immutable
class CashbackFormContract extends StatefulWidget {
  final Function(String? varName, dynamic input) updateParent;
  TextEditingController controllerStartDate = new TextEditingController();
  TextEditingController controllerEndDate = new TextEditingController();
  TextEditingController controllerWithdrawDuration =
      new TextEditingController();

  bool isHorizontal = false;
  bool isCashbackValue = true;
  bool validateStartDate = false;
  bool validateEndDate = false;
  bool validateWithdrawDuration = false;
  String selectedWithdrawProcess = 'TAGIHAN LUNAS';
  String selectedPaymentTermint = '7 hari';

  CashbackType cashbackType = CashbackType.BY_TARGET;

  CashbackFormContract({
    Key? key,
    required this.cashbackType,
    required this.updateParent,
    required this.isHorizontal,
    required this.isCashbackValue,
    required this.validateStartDate,
    required this.validateEndDate,
    required this.validateWithdrawDuration,
    required this.selectedWithdrawProcess,
    required this.selectedPaymentTermint,
    required this.controllerStartDate,
    required this.controllerEndDate,
    required this.controllerWithdrawDuration,
  }) : super(key: key);

  @override
  State<CashbackFormContract> createState() => _CashbackFormContractState();
}

class _CashbackFormContractState extends State<CashbackFormContract> {
  final format = DateFormat("dd MMM yyyy");  

  updateSelected(dynamic variableName, dynamic returnVal) {
    setState(() {
      switch (variableName) {
        case 'selectedCashbackType':
          if (returnVal == "By Product") {
            widget.cashbackType = CashbackType.BY_PRODUCT;
          } else if (returnVal == "By Target") {
            widget.cashbackType = CashbackType.BY_TARGET;
          } else {
            widget.cashbackType = CashbackType.COMBINE;
          }

          widget.updateParent('setSelectedCashbackType', widget.cashbackType);
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: widget.controllerStartDate.text.isNotEmpty ? widget.controllerStartDate.text : 'dd mon yyyy',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            errorText:
                                widget.validateStartDate ? null : 'Wajib diisi',
                            hintStyle: TextStyle(
                              fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                                DateFormat('yyyy-MM-dd').format(value);
                            widget.updateParent('setDateStart', value);
                            widget.updateParent('validateStartDate', true);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        height:
                            widget.validateStartDate && widget.validateEndDate
                                ? 20.h
                                : 40.h,
                        child: Text(
                          's/d',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: widget.controllerEndDate.text.isNotEmpty ? widget.controllerEndDate.text : 'dd mon yyyy',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            errorText:
                                widget.validateEndDate ? null : 'Wajib diisi',
                            hintStyle: TextStyle(
                              fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                                DateFormat('yyyy-MM-dd').format(value);
                            widget.updateParent('setDateEnd', value);
                            widget.updateParent('validateEndDate', true);
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
                          fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                            fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                            fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                                    height: widget.validateWithdrawDuration ? 15.h : 15.h,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Segoe ui',
                                        fontSize:
                                            widget.isHorizontal ? 24.sp : 14.sp,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 2.h,
                                      ),
                                      errorText: widget.validateWithdrawDuration
                                          ? null
                                          : 'Wajib Isi',
                                    ),
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                                      fontFamily: 'Segoe ui',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLength: 3,
                                    controller: widget.controllerWithdrawDuration,
                                    onChanged: (value) {
                                      if (value.length > 0) {
                                        widget.updateParent(
                                            'validateWithdrawDuration', true);
                                      } else {
                                        widget.updateParent(
                                            'validateWithdrawDuration', false);
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
                              height: widget.validateWithdrawDuration ? 25.h :  20.h,
                              child: Text(
                                'Hari',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                            value: widget.selectedPaymentTermint,
                            style: TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Segoe ui',
                              fontSize: widget.isHorizontal ? 25.sp : 15.sp,
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
                                fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            onChanged: (String? _value) {
                              setState(() {
                                widget.selectedPaymentTermint = _value!;
                                widget.updateParent(
                                    'setSelectedPaymentTermint', _value);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CashbackWidgetType(
                        updateParent: updateSelected,
                        isHorizontal: widget.isHorizontal,
                        isSelected: widget.cashbackType == CashbackType.BY_TARGET
                            ? true
                            : false,
                        cardIcon: 'assets/images/cashback_target.png',
                        cardTitle: 'By Target',
                      ),
                      CashbackWidgetType(
                        updateParent: updateSelected,
                        isHorizontal: widget.isHorizontal,
                        isSelected: widget.cashbackType == CashbackType.BY_PRODUCT
                            ? true
                            : false,
                        cardIcon: 'assets/images/cashback_product.png',
                        cardTitle: 'By Product',
                      ),
                      CashbackWidgetType(
                        updateParent: updateSelected,
                        isHorizontal: widget.isHorizontal,
                        isSelected:
                            widget.cashbackType == CashbackType.COMBINE ? true : false,
                        cardIcon: 'assets/images/cashback_combine.png',
                        cardTitle: 'Combine',
                      ),
                    ],
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
    );
  }
}
