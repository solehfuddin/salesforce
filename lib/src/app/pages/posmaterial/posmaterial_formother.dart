import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formattachment.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';

// ignore: camel_case_types, must_be_immutable
class Posmaterial_formother extends StatefulWidget {
  final Function(String? varName, dynamic input) notifyParent;
  bool isHorizontal = false;

  TextEditingController controllerProductName = new TextEditingController();
  TextEditingController controllerProductQty = new TextEditingController();

  String selectedDeliveryMethod = 'Kirim ke optik';

  bool isCustomerProspect = false;
  bool validateProductName = false;
  bool validateProductQty = false;
  bool validateLampiranKtp = false;
  bool validateLampiranOmzet = false;

  Posmaterial_formother({
    Key? key,
    required this.isHorizontal,
    required this.isCustomerProspect,
    required this.controllerProductName,
    required this.controllerProductQty,
    required this.selectedDeliveryMethod,
    required this.notifyParent,
    required this.validateProductName,
    required this.validateProductQty,
    required this.validateLampiranKtp,
    required this.validateLampiranOmzet,
  }) : super(key: key);

  @override
  State<Posmaterial_formother> createState() => _Posmaterial_formotherState();
}

// ignore: camel_case_types
class _Posmaterial_formotherState extends State<Posmaterial_formother> {
  TextEditingController txtAttachmentKtp = new TextEditingController();
  TextEditingController txtAttachmentNpwp = new TextEditingController();
  TextEditingController txtAttachmentOmzet = new TextEditingController();

  String attachmentKtp = 'Lampiran KTP';
  String attachmentNpwp = 'Lampiran NPWP';
  String attachmentOmzet = 'Lampiran Omzet';

  String base64Ktp = '';
  String base64Npwp = '';
  String base64Omzet = '';

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
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.r),
                  topRight: Radius.circular(10.r),
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: widget.isHorizontal ? 20.r : 10.r,
              ),
              child: Center(
                child: Text(
                  'Form POS Material Other',
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
                        flex: 3,
                        child: Text(
                          'Nama Produk',
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
                          'Qty',
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
                        flex: 3,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                              hintText: 'Isi nama produk',
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
                              errorText: widget.validateProductName
                                  ? null
                                  : 'Isi nama produk'),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.w600,
                          ),
                          controller: widget.controllerProductName,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              widget.notifyParent('validateProductName', true);
                            } else {
                              widget.notifyParent('validateProductName', false);
                            }
                          },
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
                              errorText: widget.validateProductName
                                  ? null
                                  : 'Isi qty'),
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
              visible: widget.isCustomerProspect,
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
