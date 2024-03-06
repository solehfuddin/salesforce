import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formattachment.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/posmaterial_content.dart';
import 'package:sample/src/domain/entities/posmaterial_poster.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';

// ignore: camel_case_types, must_be_immutable
class Posmaterial_Formposter extends StatefulWidget {
  final Function(String? varName, dynamic input) notifyParent;
  bool isHorizontal = false;

  TextEditingController controllerProductWidth = new TextEditingController();
  TextEditingController controllerProductHeight = new TextEditingController();
  TextEditingController controllerProductQty = new TextEditingController();

  String selectedMaterialId;
  String selectedContentId;

  String selectedMaterial = 'Albatros';
  String selectedContent = 'Leinz Logo';
  String selectedDeliveryMethod = 'Kirim ke optik';

  bool isProspectCustomer = false;
  bool validateProductWidth = false;
  bool validateProductHeight = false;
  bool validateQtyItem = false;
  bool validateLampiranRencana = false;
  bool validateLampiranKtp = false;
  bool validateLampiranOmzet = false;

  Posmaterial_Formposter({
    Key? key,
    required this.isHorizontal,
    required this.isProspectCustomer,
    required this.controllerProductWidth,
    required this.controllerProductHeight,
    required this.controllerProductQty,
    required this.selectedMaterialId,
    required this.selectedMaterial,
    required this.selectedContentId,
    required this.selectedContent,
    required this.selectedDeliveryMethod,
    required this.notifyParent,
    required this.validateProductWidth,
    required this.validateProductHeight,
    required this.validateQtyItem,
    required this.validateLampiranRencana,
    required this.validateLampiranKtp,
    required this.validateLampiranOmzet,
  }) : super(key: key);

  @override
  State<Posmaterial_Formposter> createState() => _Posmaterial_FormposterState();
}

// ignore: camel_case_types
class _Posmaterial_FormposterState extends State<Posmaterial_Formposter> {
  TextEditingController txtAttachmentRencana = new TextEditingController();
  TextEditingController txtAttachmentKtp = new TextEditingController();
  TextEditingController txtAttachmentNpwp = new TextEditingController();
  TextEditingController txtAttachmentOmzet = new TextEditingController();

  ServicePosMaterial service = new ServicePosMaterial();
  Future<List<PosMaterialPoster>>? futurePosterList;
  Future<List<PosMaterialContent>>? futureContentList;
  List<PosMaterialPoster>? _posterList = List.empty(growable: true);
  List<PosMaterialContent>? _contentList = List.empty(growable: true);
  List<String>? posterList = List.empty(growable: true);
  List<String>? contentList = List.empty(growable: true);

  String attachmentRencanaLokasi = 'Lampiran Rencana Lokasi';
  String attachmentKtp = 'Lampiran KTP';
  String attachmentNpwp = 'Lampiran NPWP';
  String attachmentOmzet = 'Lampiran Omzet';
  String base64RencanaLokasi = '';
  String base64Ktp = '';
  String base64Npwp = '';
  String base64Omzet = '';

  @override
  void initState() {
    super.initState();
    _convertPoster();
    _convertContent();
  }

  void _convertPoster() async {
    futurePosterList = service.getPosMaterialPoster(context, mounted);
    _posterList = await futurePosterList;

    for (int i = 0; i < _posterList!.length; i++) {
      setState(() {
        posterList?.add(_posterList![i].posterMaterial!);
      });
    }
  }

  void _convertContent() async {
    futureContentList = service.getPosMaterialContent(context, mounted);
    _contentList = await futureContentList;

    for (int i = 0; i < _contentList!.length; i++) {
      setState(() {
        contentList?.add(_contentList![i].posterContent!);
      });
    }
  }

  updateSelectedAttachment(dynamic varName, dynamic input) {
    setState(() {
      switch (varName) {
        case 'Lampiran Rencana Lokasi':
          base64RencanaLokasi = input;
          widget.notifyParent('Lampiran Rencana Lokasi', base64RencanaLokasi);
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
        case 'Lampiran Rencana Lokasi':
          widget.validateLampiranRencana = input;
          widget.notifyParent('validateLampiranRencanaLokasi', input);
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
                color: Colors.red,
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
                  'Form POS Material Poster',
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
                          'Material (Bahan)',
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
                          'Lebar',
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
                          'Tinggi',
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
                            value: widget.selectedMaterial,
                            style: TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Segoe ui',
                              fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            items: posterList?.map((item) {
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
                              'Pilih bahan',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            onChanged: (String? _value) {
                              setState(() {
                                widget.selectedMaterial = _value!;
                                int? index = _posterList?.indexWhere(
                                    (item) => item.posterMaterial == _value);

                                widget.selectedMaterialId =
                                    _posterList![index!].posterMaterialId!;

                                widget.notifyParent('selectedMaterial', _value);
                                widget.notifyParent('selectedMaterialId',
                                    widget.selectedMaterialId);
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
                            errorText:
                                widget.validateProductWidth ? null : 'Isi',
                          ),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.w600,
                          ),
                          controller: widget.controllerProductWidth,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              widget.notifyParent('validateProductWidth', true);
                            } else {
                              widget.notifyParent(
                                  'validateProductWidth', false);
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
                            errorText:
                                widget.validateProductHeight ? null : 'Isi',
                          ),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.w600,
                          ),
                          controller: widget.controllerProductHeight,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              widget.notifyParent(
                                  'validateProductHeight', true);
                            } else {
                              widget.notifyParent(
                                  'validateProductHeight', false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 12.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Konten',
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
                            value: widget.selectedContent,
                            style: TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Segoe ui',
                              fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            items: contentList?.map((item) {
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
                              'Pilih konten',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Segoe ui',
                              ),
                            ),
                            onChanged: (String? _value) {
                              setState(() {
                                widget.selectedContent = _value!;
                                int? index = _contentList!.indexWhere(
                                    (item) => item.posterContent == _value);
                                widget.selectedContentId =
                                    _contentList![index].posterContentId!;

                                widget.notifyParent('selectedContent', _value);
                                widget.notifyParent('selectedContentId',
                                    widget.selectedContentId);
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
                      attachmentTitle: attachmentRencanaLokasi,
                      notifyParent: updateSelectedAttachment,
                      flagParent: updateValidatedAttachment,
                      validateAttachment: widget.validateLampiranRencana,
                      txtPathAttachment: txtAttachmentRencana,
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
                      validateAttachment: widget.validateLampiranKtp,
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
                        validateAttachment: widget.validateLampiranOmzet,
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
