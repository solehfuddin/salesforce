import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:sample/src/domain/service/service_cashback.dart';

// ignore: must_be_immutable
class CashbackFormTarget extends StatefulWidget {
  final Function(String? varName, dynamic input) updateParent;
  TextEditingController controllerTargetValue = new TextEditingController();
  TextEditingController controllerCashbackPercent = new TextEditingController();
  TextEditingController controllerCashbackValue = new TextEditingController();

  List<Proddiv> selectedItemProdDiv = List.empty(growable: true);

  bool isHorizontal = false;
  bool validateCashbackValue = false;
  bool validateTargetValue = false;
  String targetDuration = '';
  String targetProduct = '';

  CashbackFormTarget({
    Key? key,
    required this.updateParent,
    required this.isHorizontal,
    required this.validateTargetValue,
    required this.validateCashbackValue,
    required this.targetDuration,
    required this.targetProduct,
    required this.selectedItemProdDiv,
    required this.controllerTargetValue,
    required this.controllerCashbackPercent,
    required this.controllerCashbackValue,
  }) : super(key: key);

  @override
  State<CashbackFormTarget> createState() => _CashbackFormTargetState();
}

class _CashbackFormTargetState extends State<CashbackFormTarget> {
  ServiceCashback serviceCashback = new ServiceCashback();

  List<Proddiv> itemProdDiv = List.empty(growable: true);
  bool checkAllProduct = false;
  bool isPercent = false;

  @override
  void initState() {
    super.initState();

    if (widget.controllerCashbackPercent.text.isNotEmpty)
    {
      if (double.parse(widget.controllerCashbackPercent.text) > 0)
      {
        isPercent = true;
      }
    }

    if (widget.controllerCashbackValue.text.isNotEmpty)
    {
      if (int.parse(widget.controllerCashbackValue.text.replaceAll('.', '')) > 0)
      {
        isPercent = false;
      }
    }

    serviceCashback
        .getProddivCashbackCustom(context, isMounted: mounted)
        .then((value) {
      itemProdDiv.addAll(value);

      if (widget.selectedItemProdDiv.isNotEmpty) {
        for (int i = 0; i < itemProdDiv.length; i++) {
          for (int j = 0; j < widget.selectedItemProdDiv.length; j++)
          {
            if (itemProdDiv[i].alias == widget.selectedItemProdDiv[j].alias)
            {
              itemProdDiv[i].ischecked = true;
            }
          }
        }
      }
    });
  }

  setSelectedItemProdDiv() {
    setState(() {
      widget.selectedItemProdDiv.clear();
      widget.updateParent('setTargetProduct', '');
    });
    itemProdDiv.forEach((element) {
      if (element.ischecked) {
        setState(() {
          widget.selectedItemProdDiv.add(element);
        });
        widget.targetProduct =
            widget.selectedItemProdDiv.map((i) => i.alias).toList().join(',');
        widget.updateParent('setTargetProduct', widget.targetProduct);
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
                vertical: widget.isHorizontal ? 20.r : 10.r,
              ),
              child: Center(
                child: Text(
                  'Cashback By Target',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Target pembelian',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Cashback value',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Switch(
                              value: isPercent,
                              onChanged: (value) {
                                setState(() {
                                  isPercent = value;
                                  widget.controllerCashbackPercent.clear();
                                  widget.controllerCashbackValue.clear();
                                  widget.updateParent(
                                      'validateCashbackValue', false);
                                });
                              },
                              activeTrackColor: Colors.blue.shade400,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
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
                            errorText: widget.validateTargetValue
                                ? null
                                : 'Wajib diisi',
                          ),
                          inputFormatters: [
                            ThousandsSeparatorInputFormatter(),
                          ],
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLength: 14,
                          controller: widget.controllerTargetValue,
                          onChanged: (value) {
                            if (value.length > 5) {
                              widget.updateParent('validateTargetValue', true);
                            } else {
                              widget.updateParent('validateTargetValue', false);
                            }
                          },
                          onSaved: (newValue) =>
                              widget.controllerTargetValue.text = newValue!,
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Expanded(
                        flex: 1,
                        child: Visibility(
                          visible: isPercent,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
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
                                    errorText: widget.validateCashbackValue
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
                                    fontSize:
                                        widget.isHorizontal ? 25.sp : 15.sp,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLength: 4,
                                  controller: widget.controllerCashbackPercent,
                                  onChanged: (value) {
                                    print('Value : $value');

                                    if (value.length > 0) {
                                      if (double.parse(value) >= 10) {
                                        widget.controllerCashbackPercent.value =
                                            TextEditingValue(
                                          text: "10",
                                        );
                                      }

                                      widget.updateParent(
                                          'validateCashbackValue', true);
                                      widget.updateParent(
                                          'setIsCashbackValue', false);
                                    } else {
                                      widget.updateParent(
                                          'validateCashbackValue', false);
                                    }
                                  },
                                  onSaved: (value) => widget
                                      .controllerCashbackPercent.text = value!,
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
                                    fontSize:
                                        widget.isHorizontal ? 24.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80.w,
                              ),
                            ],
                          ),
                          replacement: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: widget.validateCashbackValue
                                          ? 0.h
                                          : 0.h,
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
                                          fontSize: widget.isHorizontal
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
                                        errorText: widget.validateCashbackValue
                                            ? null
                                            : 'Wajib diisi',
                                      ),
                                      inputFormatters: [
                                        ThousandsSeparatorInputFormatter(),
                                      ],
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize:
                                            widget.isHorizontal ? 25.sp : 15.sp,
                                        fontFamily: 'Segoe ui',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLength: 11,
                                      controller:
                                          widget.controllerCashbackValue,
                                      onChanged: (value) {
                                        if (value.length > 5) {
                                          widget.updateParent(
                                              'validateCashbackValue', true);
                                          widget.updateParent(
                                              'setIsCashbackValue', true);
                                        } else {
                                          widget.updateParent(
                                              'validateCashbackValue', false);
                                        }
                                      },
                                      onSaved: (newValue) => widget
                                          .controllerCashbackValue
                                          .text = newValue!,
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
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 15.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pembelian produk lensa',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: widget.isHorizontal ? 20.sp : 14.sp,
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
                                  maxHeight: widget.isHorizontal ? 40.r : 30.r,
                                  maxWidth: widget.isHorizontal ? 40.r : 30.r,
                                ),
                                icon: const Icon(Icons.add),
                                iconSize: widget.isHorizontal ? 20.r : 15.r,
                                color: Colors.white,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return dialogTargetLensa(itemProdDiv);
                                      });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 10.h : 5.h,
                  ),
                  Text(
                    'Nama Produk',
                    style: TextStyle(
                      fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Visibility(
                    visible:
                        widget.selectedItemProdDiv.length > 0 ? true : false,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.selectedItemProdDiv.length,
                      itemBuilder: (_, index) {
                        return Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: widget.isHorizontal ? 5.r : 5.r,
                                bottom: widget.isHorizontal ? 10.r : 5.r,
                              ),
                              child: Text(
                                widget.selectedItemProdDiv[index].alias,
                                style: TextStyle(
                                  fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    replacement: Padding(
                      padding: EdgeInsets.only(
                          top: 70.r, bottom: 70.r, left: 10.r, right: 10.r),
                      child: Center(
                        child: Text(
                          'Belum ada produk',
                          style: TextStyle(
                            fontSize: widget.isHorizontal ? 20.sp : 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
    );
  }

  Widget dialogTargetLensa(List<Proddiv> item) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(
          'Pilih Produk Lensa',
          textAlign: TextAlign.center,
        ),
        actions: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setSelectedItemProdDiv();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  )),
              margin: EdgeInsets.only(bottom: 10.h),
              child: CheckboxListTile(
                value: checkAllProduct,
                title: Padding(
                  padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pilih Semua",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
                onChanged: (bool? val) {
                  setState(() {
                    checkAllProduct = val!;
                    item.forEach((element) {
                      element.ischecked = val;
                    });
                  });
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1,
              height: 300.h,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: item.length,
                itemBuilder: (BuildContext context, int index) {
                  String _key = item[index].alias;
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
              ),
            ),
          ],
        ),
      );
    });
  }
}
