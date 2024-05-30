import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/cashback/cashback_dialogproddiv.dart';
import 'package:sample/src/app/pages/cashback/cashback_dialogproduct.dart';
import 'package:sample/src/app/pages/cashback/cashback_itemproddiv.dart';
import 'package:sample/src/app/pages/cashback/cashback_itemproduct.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:sample/src/domain/entities/product.dart';
import 'package:sample/src/domain/service/service_cashback.dart';

// ignore: must_be_immutable
class CashbackFormProduct extends StatefulWidget {
  final Function(String? varName, dynamic input) updateParent;
  List<Proddiv> selectedItemProdDiv = List.empty(growable: true);
  List<Product> selectedItemProduct = List.empty(growable: true);

  bool isHorizontal = false;
  bool isUpdateForm = false;
  String idCashback = '';

  CashbackFormProduct({
    Key? key,
    required this.updateParent,
    required this.isHorizontal,
    required this.isUpdateForm,
    required this.idCashback,
    required this.selectedItemProdDiv,
    required this.selectedItemProduct,
  }) : super(key: key);

  @override
  State<CashbackFormProduct> createState() => _CashbackFormProductState();
}

class _CashbackFormProductState extends State<CashbackFormProduct> {
  ServiceCashback serviceCashback = new ServiceCashback();

  List<Proddiv> itemProdDiv = List.empty(growable: true);
  List<Product> itemProduct = List.empty(growable: true);
  List<Proddiv> localProdDiv = List.empty(growable: true);
  List<Product> localProduct = List.empty(growable: true);
  bool isPercentProdDiv = true, isPercentProduct = true;

  @override
  void initState() {
    super.initState();

    if (widget.selectedItemProdDiv.isNotEmpty) {
      localProdDiv.addAll(widget.selectedItemProdDiv);
      widget.selectedItemProdDiv.forEach((element) {
        setState(() {
          if (element.diskon.contains(".") || element.diskon.length < 3)
          {
            isPercentProdDiv = true;
            element.diskon = element.diskon.replaceAll(".", ",");
          }
          else
          {
            isPercentProdDiv = false;
          }
        });
      });

      print('Is percent proddiv : $isPercentProdDiv');
    }

    if (widget.selectedItemProduct.isNotEmpty) {
      localProduct.addAll(widget.selectedItemProduct);
      widget.selectedItemProduct.forEach((element) {
        setState(() {
          if (element.diskon.contains(".") || element.diskon.length < 3)
          {
            isPercentProduct = true;
            element.diskon = element.diskon.replaceAll(".", ",");
          }
          else
          {
            isPercentProduct = false;
          }
        });
      });

      print('Is percent product: $isPercentProduct');
    }

    serviceCashback
        .getProddivCashback(
      context,
      isMounted: mounted,
    )
        .then((value) {
      itemProdDiv.addAll(value);

      if (widget.selectedItemProdDiv.isNotEmpty) {
        for (int i = 0; i < itemProdDiv.length; i++) {
          for (int j = 0; j < widget.selectedItemProdDiv.length; j++) {
            if (itemProdDiv[i].alias == widget.selectedItemProdDiv[j].alias) {
              itemProdDiv[i].ischecked = true;
            }
          }
        }
      }
    });

    serviceCashback
        .getProductCashback(
      context,
      isMounted: mounted,
    )
        .then((value) {
      itemProduct.addAll(value);

      if (widget.selectedItemProduct.isNotEmpty) {
        for (int i = 0; i < itemProduct.length; i++) {
          for (int j = 0; j < widget.selectedItemProduct.length; j++) {
            if (itemProduct[i].proddesc ==
                widget.selectedItemProduct[j].proddesc) {
              itemProduct[i].ischecked = true;
            }
          }
        }
      }
    });
  }

  updateSelected(dynamic variableName, dynamic returVal) {
    setState(() {
      switch (variableName) {
        case 'setItemProddiv':
          // widget.selectedItemProdDiv.clear();
          // widget.selectedItemProdDiv.addAll(returVal);
          // widget.selectedItemProdDiv.forEach((element) {
          //   print('Proddiv - ${element.proddiv} : ${element.diskon}');
          // });
          // widget.updateParent('setLineProddiv', widget.selectedItemProdDiv);

          localProdDiv.clear();
          localProdDiv.addAll(returVal);
          localProdDiv.forEach((element) {
            print('Proddiv - ${element.proddiv} : ${element.diskon}');
          });

          widget.updateParent('setLineProddiv', localProdDiv);
          break;
        case 'setItemProduct':
          // widget.selectedItemProduct.clear();
          // widget.selectedItemProduct.addAll(returVal);
          // widget.selectedItemProduct.forEach((element) {
          //   print('Product - ${element.proddesc} : ${element.diskon}');
          // });
          // widget.updateParent('setLineProduct', widget.selectedItemProduct);

          localProduct.clear();
          localProduct.addAll(returVal);
          localProduct.forEach((element) {
            print('Product - ${element.proddesc} : ${element.diskon}');
          });
          widget.updateParent('setLineProduct', localProduct);
          break;
        case 'setDiskonProddiv':
          // widget.updateParent('setLineProddiv', widget.selectedItemProdDiv);
          widget.updateParent('setLineProddiv', localProdDiv);
          break;
        case 'setDiskonProduct':
          // widget.updateParent('setLineProduct', widget.selectedItemProduct);
          widget.updateParent('setLineProduct', localProduct);
          break;
        case 'setPercentProddiv':
          isPercentProdDiv = returVal;
          break;
        case 'setPercentProduct':
          isPercentProduct = returVal;
          break;
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
        color: Colors.amber.shade700,
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
                  'Cashback Product',
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pembelian produk divisi',
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
                                        return CashbackDialogProddiv(
                                          updateParent: updateSelected,
                                          isHorizontal: widget.isHorizontal,
                                          item: itemProdDiv,
                                        );
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
                    height: widget.isHorizontal ? 10.h : 7.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nama Produk',
                        style: TextStyle(
                          fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Nominal cashback',
                        style: TextStyle(
                          fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Visibility(
                    // visible:
                    //     widget.selectedItemProdDiv.length > 0 ? true : false,
                    visible: localProdDiv.length > 0 ? true : false,
                    child: CashbackItemProddiv(
                      isHorizontal: widget.isHorizontal,
                      updateParent: updateSelected,
                      isPercentProdDiv: isPercentProdDiv,
                      selectedItemProdDiv: localProdDiv,
                      // selectedItemProdDiv: widget.selectedItemProdDiv,
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
                            fontSize: widget.isHorizontal ? 20.sp : 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(
                widget.isHorizontal ? 24.r : 12.r,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pembelian produk khusus',
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
                                        return CashbackDialogProduct(
                                          updateParent: updateSelected,
                                          isHorizontal: widget.isHorizontal,
                                          item: itemProduct,
                                        );
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
                    height: widget.isHorizontal ? 10.h : 7.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nama Produk',
                        style: TextStyle(
                          fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Nominal cashback',
                        style: TextStyle(
                          fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Visibility(
                    // visible:
                    //     widget.selectedItemProduct.length > 0 ? true : false,
                    visible: localProduct.length > 0 ? true : false,
                    child: Center(
                      child: CashbackItemProduct(
                        isHorizontal: widget.isHorizontal,
                        updateParent: updateSelected,
                        isPercentProduct: isPercentProduct,
                        // selectedItemProduct: widget.selectedItemProduct,
                        selectedItemProduct: localProduct,
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
}
