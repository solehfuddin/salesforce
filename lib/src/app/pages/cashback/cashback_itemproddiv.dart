import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/proddiv.dart';

// ignore: must_be_immutable
class CashbackItemProddiv extends StatefulWidget {
  final Function(String? varName, dynamic input) updateParent;
  List<Proddiv> selectedItemProdDiv = List.empty(growable: true);
  bool isHorizontal = false;
  bool isPercentProdDiv = true;

  CashbackItemProddiv({
    Key? key,
    required this.updateParent,
    required this.isHorizontal,
    required this.isPercentProdDiv,
    required this.selectedItemProdDiv,
  }) : super(key: key);

  @override
  State<CashbackItemProddiv> createState() => _CashbackItemProddivState();
}

class _CashbackItemProddivState extends State<CashbackItemProddiv> {
  late TextEditingController controllerPercentProddiv;
  List<TextEditingController> listControllerPercent =
      List.empty(growable: true);
  List<TextEditingController> listControllerValue = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.selectedItemProdDiv.length,
      itemBuilder: (context, index) {
        listControllerPercent.clear();
        listControllerValue.clear();

        widget.selectedItemProdDiv.forEach((element) {
          listControllerPercent.add(
            new TextEditingController.fromValue(
              new TextEditingValue(
                text: widget.selectedItemProdDiv[index].diskon
                    .replaceAll(',', '.'),
              ),
            ),
          );

          listControllerValue.add(new TextEditingController.fromValue(
            new TextEditingValue(
              text: widget.selectedItemProdDiv[index].diskon.toString(),
            ),
          ));
        });

        return Padding(
          padding: EdgeInsets.only(bottom: 10.r, right: 3.r),
          child: Row(
            children: [
              Expanded(
                flex: widget.isHorizontal ? 5 : 4,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: widget.isHorizontal ? 5.r : 5.r,
                    top: 2.r,
                    bottom: 2.r,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proddiv : ' +
                            widget.selectedItemProdDiv[index].proddiv,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(widget.selectedItemProdDiv[index].alias),
                      SizedBox(
                        height: 25.h,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: widget.isPercentProdDiv ? 2 : 3,
                child: Visibility(
                  visible: widget.isPercentProdDiv,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20.w,
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
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
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
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
                          controller: listControllerPercent[index],
                          onChanged: (value) {
                            if (value.length > 0) {
                              if (double.parse(value) >= 80) {
                                value = "80";
                                listControllerPercent[index].value =
                                    TextEditingValue(text: "80");
                              }

                              widget.selectedItemProdDiv[index].diskon = value;
                            }
                          },
                          onSaved: (value) {
                            widget.updateParent('setDiskonProddiv',
                                widget.selectedItemProdDiv[index].diskon);
                          },
                          maxLength: 4,
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
                            fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                    ],
                  ),
                  replacement: Row(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        height: 40.h,
                        child: Text(
                          'Rp. ',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            TextFormField(
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
                              // initialValue: ThousandsSeparatorInputFormatter()
                              //     .formatEditUpdate(
                              //       TextEditingValue.empty,
                              //       TextEditingValue(
                              //         text: widget
                              //             .selectedItemProdDiv[index].diskon
                              //             .toString(),
                              //       ),
                              //     )
                              //     .text,
                              controller: listControllerValue[index],
                              onChanged: (value) {
                                widget.selectedItemProdDiv[index].diskon =
                                    value;
                              },
                              onSaved: (value) {
                                widget.updateParent('setItemDiskon',
                                    widget.selectedItemProdDiv[index].diskon);
                              },
                              maxLength: 11,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
