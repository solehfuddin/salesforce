import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formattachment.dart';
// import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/posmaterial_item.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';

// ignore: camel_case_types, must_be_immutable
class Posmaterial_formcustom extends StatefulWidget {
  final Function(String? varName, dynamic input) notifyParent;
  TextEditingController controllerProductQty = new TextEditingController();
  TextEditingController controllerNotes = new TextEditingController();
  TextEditingController controllerProductEstimate = new TextEditingController();

  TextEditingController txtAttachmentDesainParaf = new TextEditingController();
  TextEditingController txtAttachmentKtp = new TextEditingController();
  TextEditingController txtAttachmentNpwp = new TextEditingController();
  TextEditingController txtAttachmentOmzet = new TextEditingController();

  bool isProspectCustomer = false;
  bool isHorizontal = false;
  bool validateQtyItem = false;
  bool validateEstimatePrice = false;
  bool validateLampiranParaf = false;
  bool validateLampiranKtp = false;
  bool validateLampiranOmzet = false;

  String selectedProductId;
  String selectedProductCustom;
  String selectedDeliveryMethod;

  Posmaterial_formcustom({
    Key? key,
    required this.isHorizontal,
    required this.isProspectCustomer,
    required this.controllerProductQty,
    required this.controllerNotes,
    required this.controllerProductEstimate,
    required this.txtAttachmentDesainParaf,
    required this.txtAttachmentKtp,
    required this.txtAttachmentNpwp,
    required this.txtAttachmentOmzet,
    required this.selectedProductId,
    required this.selectedProductCustom,
    required this.selectedDeliveryMethod,
    required this.notifyParent,
    required this.validateQtyItem,
    required this.validateEstimatePrice,
    required this.validateLampiranParaf,
    required this.validateLampiranKtp,
    required this.validateLampiranOmzet,
  }) : super(key: key);

  @override
  State<Posmaterial_formcustom> createState() => _Posmaterial_formcustomState();
}

// ignore: camel_case_types
class _Posmaterial_formcustomState extends State<Posmaterial_formcustom> {
  ServicePosMaterial service = new ServicePosMaterial();
  Future<List<PosMaterialItem>>? futureList;
  List<PosMaterialItem>? _list = List.empty(growable: true);
  List<String>? itemList = List.empty(growable: true);

  int selectedProductPrice = 0;
  String attachmentDesainParaf = 'Lampiran Desain Paraf';
  String attachmentKtp = 'Lampiran KTP';
  String attachmentNpwp = 'Lampiran NPWP';
  String attachmentOmzet = 'Lampiran Omzet';
  String base64DesainParaf = '';
  String base64Ktp = '';
  String base64Npwp = '';
  String base64Omzet = '';

  @override
  void initState() {
    super.initState();
    convertList();
  }

  void convertList() async {
    futureList =
        service.getPosMaterialItem(context, mounted, productType: 'CUSTOM');
    _list = await futureList;

    setState(() {
      for (int i = 0; i < _list!.length; i++) {
        itemList?.add(_list![i].productName!);
        selectedProductPrice = int.parse(_list![0].productPrice ?? "0");
      }
    });

    print('Call custom convert list function');
  }

  updateSelectedAttachment(dynamic varName, dynamic input) {
    setState(() {
      switch (varName) {
        case 'Lampiran Desain Paraf':
          base64DesainParaf = input;
          widget.notifyParent('Lampiran Desain Paraf', base64DesainParaf);
          break;
        case 'Lampiran KTP':
          base64Ktp = input;
          widget.notifyParent('Lampiran KTP', base64Ktp);
          break;
        case 'Lampiran NPWP':
          base64Npwp = input;
          widget.notifyParent('Lampiran NPWP', base64Npwp);
          break;
        case 'Lampiran Omzet':
          base64Omzet = input;
          widget.notifyParent('Lampiran Omzet', base64Omzet);
          break;
        default:
      }
    });
  }

  updateValidatedAttachment(dynamic varName, dynamic input) {
    setState(() {
      switch (varName) {
        case 'Lampiran Desain Paraf':
          widget.validateLampiranParaf = input;
          widget.notifyParent('validateLampiranParaf', input);
          // if (!input)
          // {
          // txtAttachmentDesainParaf.clear();
          // }
          break;
        case 'Lampiran KTP':
          widget.validateLampiranKtp = input;
          widget.notifyParent('validateLampiranKtp', input);
          break;
        case 'Lampiran Omzet':
          widget.validateLampiranOmzet = input;
          widget.notifyParent('validateLampiranOmzet', input);
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: widget.isHorizontal ? 20.r : 10.r,
        right: widget.isHorizontal ? 20.r : 10.r,
        top: widget.isHorizontal ? 20.r : 5.r,
        bottom: widget.isHorizontal ? 20.r : 10.r,
      ),
      child: Card(
        elevation: 2,
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
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    10.r,
                  ),
                  topRight: Radius.circular(
                    10.r,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: widget.isHorizontal ? 20.r : 10.r,
              ),
              child: Center(
                child: Text(
                  'Form POS Material Custom',
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
                  SizedBox(
                    height: 3.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Jenis Item',
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
                        child: Text(
                          'Qty Item',
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
                  SizedBox(
                    height: widget.isHorizontal ? 18.h : 8.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
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
                            value: widget.selectedProductCustom,
                            style: TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Segoe ui',
                              fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            items: itemList?.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            }).toList(),
                            hint: Text(
                              'Pilih item',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            onChanged: (String? _value) {
                              setState(() {
                                widget.selectedProductCustom = _value!;
                                int? index = _list?.indexWhere(
                                    (item) => item.productName == _value);
                                widget.selectedProductId =
                                    _list![index!].productId!;

                                selectedProductPrice =
                                    int.parse(_list![index].productPrice!);

                                // int estimate = selectedProductPrice  * int.parse(widget.controllerProductQty.text.isNotEmpty ? widget.controllerProductQty.text.replaceAll('.', '') : "0");

                                // widget.controllerProductEstimate.text = convertThousand(estimate, 0);

                                widget.notifyParent(
                                  'selectedProductCustom',
                                  _value,
                                );

                                widget.notifyParent(
                                  'productId',
                                  widget.selectedProductId,
                                );
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                          maxLength: 6,
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 2.h,
                            ),
                            errorText: widget.validateQtyItem ? null : 'Isi',
                          ),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.w600,
                          ),
                          controller: widget.controllerProductQty,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              widget.notifyParent('validateQtyItem', true);
                              // int estimate = selectedProductPrice  * int.parse(widget.controllerProductQty.text.isNotEmpty ? widget.controllerProductQty.text.replaceAll('.', '') : "0");

                              // widget.controllerProductEstimate.text = convertThousand(estimate, 0);
                            } else {
                              widget.notifyParent('validateQtyItem', false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 12.h,
                  ),
                  Text(
                    'Estimasi Harga',
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
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    maxLength: 13,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Segoe ui',
                        fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 2.h,
                      ),
                      errorText: widget.validateEstimatePrice
                          ? null
                          : 'Isi Estimasi Harga',
                    ),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        widget.notifyParent('validateEstimatePrice', true);
                      } else {
                        widget.notifyParent('validateEstimatePrice', false);
                      }
                    },
                    controller: widget.controllerProductEstimate,
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 12.h,
                  ),
                  Text(
                    'Metode pengiriman',
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
                      value: widget.selectedDeliveryMethod,
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Segoe ui',
                        fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      items: [
                        'Kirim ke optik',
                        'Kirim ke stockist',
                        'Diambil langsung oleh sales',
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
                        'Pilih metode pengiriman',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onChanged: (String? _value) {
                        setState(() {
                          widget.selectedDeliveryMethod = _value!;
                          widget.notifyParent('selectedDeliveryMethod', _value);
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 12.h,
                  ),
                  Text(
                    'Catatan',
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
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 150,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                    controller: widget.controllerNotes,
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 12.h,
                  ),
                  Text(
                    'Lampiran Dokumen',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 10.h : 5.h,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: widget.isHorizontal ? 24.w : 12.w,
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.maxFinite,
                    child: Posmaterial_formattachment(
                      isHorizontal: widget.isHorizontal,
                      attachmentTitle: attachmentDesainParaf,
                      notifyParent: updateSelectedAttachment,
                      flagParent: updateValidatedAttachment,
                      validateAttachment: widget.validateLampiranParaf,
                      txtPathAttachment: widget.txtAttachmentDesainParaf,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.isHorizontal ? 25.h : 15.h,
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: widget.isHorizontal ? 24.w : 12.w,
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.maxFinite,
                    child: Posmaterial_formattachment(
                      isHorizontal: widget.isHorizontal,
                      attachmentTitle: attachmentKtp,
                      notifyParent: updateSelectedAttachment,
                      flagParent: updateValidatedAttachment,
                      // validateAttachment: widget.validateLampiranKtp,
                      validateAttachment: true,
                      txtPathAttachment: widget.txtAttachmentKtp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.isHorizontal ? 25.h : 15.h,
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: widget.isHorizontal ? 24.w : 12.w,
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.maxFinite,
                    child: Posmaterial_formattachment(
                      isHorizontal: widget.isHorizontal,
                      attachmentTitle: attachmentNpwp,
                      notifyParent: updateSelectedAttachment,
                      flagParent: updateValidatedAttachment,
                      validateAttachment: true,
                      txtPathAttachment: widget.txtAttachmentNpwp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.isHorizontal ? 25.h : 15.h,
            ),
            // Visibility(
            //   visible: widget.isProspectCustomer,
            //   child: SizedBox(
            //     width: widget.isHorizontal ? 40.h : 20.h,
            //   ),
            //   replacement: Container(
            //     margin: EdgeInsets.symmetric(
            //       horizontal: widget.isHorizontal ? 24.w : 12.w,
            //     ),
            //     child: Stack(
            //       children: [
            //         Container(
            //           width: double.maxFinite,
            //           child: Posmaterial_formattachment(
            //             isHorizontal: widget.isHorizontal,
            //             attachmentTitle: attachmentOmzet,
            //             notifyParent: updateSelectedAttachment,
            //             flagParent: updateValidatedAttachment,
            //             // validateAttachment: widget.validateLampiranOmzet,
            //             validateAttachment: true,
            //             txtPathAttachment: widget.txtAttachmentOmzet,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            if (widget.isProspectCustomer)
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: widget.isHorizontal ? 24.w : 12.w,
                ),
                child: Stack(
                  children: [
                    Container(
                      width: double.maxFinite,
                      child: Posmaterial_formattachment(
                        isHorizontal: widget.isHorizontal,
                        attachmentTitle: attachmentOmzet,
                        notifyParent: updateSelectedAttachment,
                        flagParent: updateValidatedAttachment,
                        // validateAttachment: widget.validateLampiranOmzet,
                        validateAttachment: true,
                        txtPathAttachment: widget.txtAttachmentOmzet,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: widget.isHorizontal ? 40.h : 20.h,
            ),
          ],
        ),
      ),
    );
  }
}
