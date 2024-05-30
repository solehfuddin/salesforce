import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formattachment.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/posmaterial_item.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';

// ignore: camel_case_types, must_be_immutable
class Posmaterial_Formkit extends StatefulWidget {
  final Function(String? varName, dynamic input) notifyParent;
  bool isHorizontal = false;

  TextEditingController controllerProductQty = new TextEditingController();
  String selectedProductId;
  String selectedProductKit;
  String selectedDeliveryMethod;

  bool isProspectCustomer = false;
  bool validateQtyItem = false;
  bool validateLampiranKtp = false;
  bool validateLampiranOmzet = false;

  Posmaterial_Formkit({
    Key? key,
    required this.isHorizontal,
    required this.isProspectCustomer,
    required this.controllerProductQty,
    required this.selectedProductId,
    required this.selectedProductKit,
    required this.selectedDeliveryMethod,
    required this.notifyParent,
    required this.validateQtyItem,
    required this.validateLampiranKtp,
    required this.validateLampiranOmzet,
  }) : super(key: key);

  @override
  State<Posmaterial_Formkit> createState() => _Posmaterial_FormkitState();
}

// ignore: camel_case_types
class _Posmaterial_FormkitState extends State<Posmaterial_Formkit> {
  TextEditingController txtAttachmentKtp = new TextEditingController();
  TextEditingController txtAttachmentNpwp = new TextEditingController();
  TextEditingController txtAttachmentOmzet = new TextEditingController();

  ServicePosMaterial service = new ServicePosMaterial();
  Future<List<PosMaterialItem>>? futureItemList;
  List<PosMaterialItem>? _list = List.empty(growable: true);
  List<String>? itemList = List.empty(growable: true);

  String attachmentKtp = 'Lampiran KTP';
  String attachmentNpwp = 'Lampiran NPWP';
  String attachmentOmzet = 'Lampiran Omzet';
  String base64Ktp = '';
  String base64Npwp = '';
  String base64Omzet = '';

  @override
  void initState() {
    super.initState();
    convertList();
  }

  updateSelectedAttachment(dynamic varName, dynamic input) {
    setState(() {
      switch (varName) {
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

  void convertList() async {
    futureItemList = service.getPosMaterialItem(context, mounted,
        productType: 'MATERIAL_KIT');
    _list = await futureItemList;

    setState(() {
      for (int i = 0; i < _list!.length; i++) {
        itemList?.add(_list![i].productName!);
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
                color: Colors.orange,
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
                  'Form POS Material Kit',
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
                            value: widget.selectedProductKit,
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
                                  ));
                            }).toList(),
                            hint: Text(
                              'Pilih item pos material',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            onChanged: (String? _value) {
                              setState(() {
                                widget.selectedProductKit = _value!;
                                int? index = _list?.indexWhere(
                                    (item) => item.productName == _value);
                                widget.selectedProductId =
                                    _list![index!].productId!;

                                widget.notifyParent(
                                  'selectedProductKit',
                                  _value,
                                );

                                widget.notifyParent(
                                  'kitId',
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
                          maxLength: 3,
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
                          fontSize: widget.isHorizontal ? 25.sp : 15.sp,
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
                    height: widget.isHorizontal ? 25.h : 15.h,
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
                      attachmentTitle: attachmentKtp,
                      notifyParent: updateSelectedAttachment,
                      flagParent: updateValidatedAttachment,
                      // validateAttachment: widget.validateLampiranKtp,
                      validateAttachment: true,
                      txtPathAttachment: txtAttachmentKtp,
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
                      txtPathAttachment: txtAttachmentNpwp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.isHorizontal ? 25.h : 15.h,
            ),
            Visibility(
              visible: widget.isProspectCustomer,
              child: SizedBox(
                width: widget.isHorizontal ? 40.h : 20.h,
              ),
              replacement: Container(
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
                        txtPathAttachment: txtAttachmentOmzet,
                      ),
                    ),
                  ],
                ),
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
