import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/product.dart';

// ignore: must_be_immutable
class CashbackDialogProduct extends StatefulWidget {
  final Function(String? varName, dynamic input) updateParent;
  List<Product> item = List.empty(growable: true);
  bool isHorizontal = false;
  CashbackDialogProduct({
    Key? key,
    required this.updateParent,
    required this.isHorizontal,
    required this.item,
  }) : super(key: key);

  @override
  State<CashbackDialogProduct> createState() => _CashbackDialogProductState();
}

class _CashbackDialogProductState extends State<CashbackDialogProduct> {
  List<Product> selectedProduct = List.empty(growable: true);
  TextEditingController controllerPercentProduct = new TextEditingController();
  TextEditingController controllerValueProduct = new TextEditingController();
  String diskon = '';
  bool isPercentProduct = true;
  bool checkAllProdduct = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      scrollable: true,
      title: Text(
        'Pilih Produk Lensa',
        textAlign: TextAlign.center,
      ),
      actions: [
        Container(
          width: 300.w,
          padding: EdgeInsets.only(left: 7.0, right: 7.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Text(
                          'Cashback %',
                          style: TextStyle(
                            fontSize: widget.isHorizontal ? 14.sp : 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Switch(
                          value: isPercentProduct,
                          onChanged: widget.item.any((element) =>
                                  element.ischecked == true ? true : false)
                              ? (value) {
                                  setState(() {
                                    isPercentProduct = value;
                                    diskon = "";
                                    controllerPercentProduct.clear();
                                    controllerValueProduct.clear();
                                  });
                                }
                              : null,
                          activeTrackColor: Colors.blue.shade400,
                          activeColor: Colors.blue,
                        ),
                        SizedBox(
                          height: 28.h,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          "Masukan nominal cashback : ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.sp,
                            fontFamily: 'Montserrat',
                          ),
                          textAlign: TextAlign.justify,
                          softWrap: true,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Visibility(
                          visible: isPercentProduct ? true : false,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50.w,
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  textAlign: TextAlign.center,
                                  enabled: widget.item.any((element) =>
                                      element.ischecked == true ? true : false),
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
                                  controller: controllerPercentProduct,
                                  onChanged: (value) {
                                    print('Value : $value');

                                    if (value.length > 0) {
                                      if (double.parse(value) >= 80) {
                                        controllerPercentProduct.value =
                                            TextEditingValue(
                                          text: "80",
                                        );
                                      }
                                      diskon = value.replaceAll('.', ',');
                                    }
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
                                    fontSize:
                                        widget.isHorizontal ? 24.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 50.w,
                              ),
                            ],
                          ),
                          replacement: Row(
                            children: [
                              SizedBox(
                                width: 15.w,
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                height: 40.h,
                                child: Text(
                                  'Rp. ',
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
                                width: 10.w,
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      enabled: widget.item.any((element) =>
                                          element.ischecked == true
                                              ? true
                                              : false),
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
                                      onChanged: (value) => diskon = value,
                                      controller: controllerValueProduct,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 20.w,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                  onPressed: () async {
                    selectedProduct.clear();
                    isPercentProduct
                        ? controllerPercentProduct.clear()
                        : controllerValueProduct.clear();

                    widget.item.forEach((element) {
                      if (element.ischecked) {
                        element.diskon = diskon;
                        selectedProduct.add(element);
                      }
                    });
                    widget.updateParent('setItemProduct', selectedProduct);
                    widget.updateParent('setPercentProduct', isPercentProduct);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
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
              value: checkAllProdduct,
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
                  checkAllProdduct = val!;
                  widget.item.forEach((element) {
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
              itemCount: widget.item.length,
              itemBuilder: (BuildContext context, int index) {
                String _key = widget.item[index].proddesc;
                return CheckboxListTile(
                  value: widget.item[index].ischecked,
                  title: Text(_key),
                  onChanged: (bool? val) {
                    setState(() {
                      widget.item[index].ischecked = val!;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
