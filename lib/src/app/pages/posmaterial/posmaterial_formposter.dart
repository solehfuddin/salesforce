import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formattachment.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_itemposter.dart';
import 'package:sample/src/app/utils/custom.dart';
// import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/posmaterial_content.dart';
import 'package:sample/src/domain/entities/posmaterial_poster.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';

import '../../../domain/entities/posmaterial_lineposter.dart';
import '../../controllers/posmaterial_controller.dart';

// ignore: camel_case_types, must_be_immutable
class Posmaterial_Formposter extends StatefulWidget {
  final Function(String? varName, dynamic input) notifyParent;
  List<PosMaterialLinePoster> listPosterLine = List.empty(growable: true);
  bool isHorizontal = false;

  // TextEditingController controllerProductWidth = new TextEditingController();
  // TextEditingController controllerProductHeight = new TextEditingController();
  // TextEditingController controllerProductQty = new TextEditingController();
  TextEditingController controllerNotes = new TextEditingController();

  // String selectedMaterialId;
  // String selectedContentId;

  // String selectedMaterial = 'Albatros';
  // String selectedContent = 'Leinz Logo';
  String selectedDeliveryMethod = 'Kirim ke optik';
  String omzetOptik = "";

  bool isProspectCustomer = false;
  bool isDesignOnly = false;
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
    required this.isDesignOnly,
    required this.listPosterLine,
    // required this.controllerProductWidth,
    // required this.controllerProductHeight,
    // required this.controllerProductQty,
    required this.omzetOptik,
    required this.controllerNotes,
    // required this.selectedMaterialId,
    // required this.selectedMaterial,
    // required this.selectedContentId,
    // required this.selectedContent,
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
  PosmaterialController posController = Get.find<PosmaterialController>();
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

  Future<String>? futureEstimated;
  String? estimatedPrice;
  String attachmentRencanaLokasi = 'Lampiran Rencana Lokasi';
  String attachmentKtp = 'Lampiran KTP';
  String attachmentNpwp = 'Lampiran NPWP';
  String attachmentOmzet = 'Lampiran Omzet';
  String base64RencanaLokasi = '';
  String base64Ktp = '';
  String base64Npwp = '';
  String base64Omzet = '';
  bool isValidData = false;

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

  deleteLinePos(dynamic varName, dynamic input) {
    setState(() {
      switch (varName) {
        case 'deleteLine':
          widget.listPosterLine.removeAt(input);
          break;
        case 'updateLine':
          isValidData = input;
          break;
      }
    });
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
  
  onButtonPressed() async {
    futureEstimated = service.estimasiLinePosMaterial(
      context: context,
      isHorizontal: widget.isHorizontal,
      mounted: mounted,
      item: widget.listPosterLine,
    );
    estimatedPrice = await futureEstimated;

    setState(() {
      print("""
          Estimate Pos : $estimatedPrice
        """);
    });

    return () {};
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
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       flex: 3,
                  //       child: Text(
                  //         'Material (Bahan)',
                  //         style: TextStyle(
                  //           color: Colors.black87,
                  //           fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                  //           fontFamily: 'Montserrat',
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 10.w,
                  //     ),
                  //     Expanded(
                  //       flex: 1,
                  //       child: Text(
                  //         'Lebar',
                  //         style: TextStyle(
                  //           color: Colors.black87,
                  //           fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                  //           fontFamily: 'Montserrat',
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 10.w,
                  //     ),
                  //     Expanded(
                  //       flex: 1,
                  //       child: Text(
                  //         'Tinggi',
                  //         style: TextStyle(
                  //           color: Colors.black87,
                  //           fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                  //           fontFamily: 'Montserrat',
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: widget.isHorizontal ? 18.h : 8.h,
                  // ),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Expanded(
                  //       flex: 3,
                  //       child: Container(
                  //         padding: EdgeInsets.symmetric(
                  //           horizontal: widget.isHorizontal ? 10.r : 5.r,
                  //         ),
                  //         decoration: BoxDecoration(
                  //           border: Border.all(
                  //             color: Colors.black54,
                  //           ),
                  //           borderRadius: BorderRadius.circular(5.r),
                  //         ),
                  //         child: DropdownButton(
                  //           underline: SizedBox(),
                  //           isExpanded: true,
                  //           value: widget.selectedMaterial,
                  //           style: TextStyle(
                  //             color: Colors.black54,
                  //             fontFamily: 'Segoe ui',
                  //             fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //           items: posterList?.map((item) {
                  //             return DropdownMenuItem(
                  //                 value: item,
                  //                 child: Text(
                  //                   item,
                  //                   style: TextStyle(
                  //                     color: Colors.black54,
                  //                   ),
                  //                 ));
                  //           }).toList(),
                  //           hint: Text(
                  //             'Pilih bahan',
                  //             style: TextStyle(
                  //               color: Colors.black54,
                  //               fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                  //               fontWeight: FontWeight.w600,
                  //               fontFamily: 'Segoe ui',
                  //             ),
                  //           ),
                  //           onChanged: (String? _value) {
                  //             setState(() {
                  //               widget.selectedMaterial = _value!;
                  //               int? index = _posterList?.indexWhere(
                  //                   (item) => item.posterMaterial == _value);

                  //               widget.selectedMaterialId =
                  //                   _posterList![index!].posterMaterialId!;

                  //               widget.notifyParent('selectedMaterial', _value);
                  //               widget.notifyParent('selectedMaterialId',
                  //                   widget.selectedMaterialId);
                  //             });
                  //           },
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 10.w,
                  //     ),
                  //     Expanded(
                  //       flex: 1,
                  //       child: TextFormField(
                  //         textAlign: TextAlign.center,
                  //         keyboardType: TextInputType.number,
                  //         inputFormatters: [ThousandsSeparatorInputFormatter()],
                  //         maxLength: 3,
                  //         decoration: InputDecoration(
                  //           hintText: '0',
                  //           hintStyle: TextStyle(
                  //             color: Colors.grey.shade400,
                  //             fontWeight: FontWeight.w600,
                  //             fontFamily: 'Segoe ui',
                  //             fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                  //           ),
                  //           border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(5.r),
                  //           ),
                  //           contentPadding: EdgeInsets.symmetric(
                  //             horizontal: 10.w,
                  //             vertical: 2.h,
                  //           ),
                  //           errorText:
                  //               widget.validateProductWidth ? null : 'Isi',
                  //         ),
                  //         style: TextStyle(
                  //           color: Colors.black54,
                  //           fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                  //           fontFamily: 'Segoe ui',
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //         controller: widget.controllerProductWidth,
                  //         onChanged: (value) {
                  //           if (value.isNotEmpty) {
                  //             widget.notifyParent('validateProductWidth', true);
                  //           } else {
                  //             widget.notifyParent(
                  //                 'validateProductWidth', false);
                  //           }
                  //         },
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 10.w,
                  //     ),
                  //     Expanded(
                  //       flex: 1,
                  //       child: TextFormField(
                  //         textAlign: TextAlign.center,
                  //         keyboardType: TextInputType.number,
                  //         inputFormatters: [ThousandsSeparatorInputFormatter()],
                  //         maxLength: 3,
                  //         decoration: InputDecoration(
                  //           hintText: '0',
                  //           hintStyle: TextStyle(
                  //             color: Colors.grey.shade400,
                  //             fontWeight: FontWeight.w600,
                  //             fontFamily: 'Segoe ui',
                  //             fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                  //           ),
                  //           border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(5.r),
                  //           ),
                  //           contentPadding: EdgeInsets.symmetric(
                  //             horizontal: 10.w,
                  //             vertical: 2.h,
                  //           ),
                  //           errorText:
                  //               widget.validateProductHeight ? null : 'Isi',
                  //         ),
                  //         style: TextStyle(
                  //           color: Colors.black54,
                  //           fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                  //           fontFamily: 'Segoe ui',
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //         controller: widget.controllerProductHeight,
                  //         onChanged: (value) {
                  //           if (value.isNotEmpty) {
                  //             widget.notifyParent(
                  //                 'validateProductHeight', true);
                  //           } else {
                  //             widget.notifyParent(
                  //                 'validateProductHeight', false);
                  //           }
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: widget.isHorizontal ? 22.h : 12.h,
                  // ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       flex: 4,
                  //       child: Text(
                  //         'Konten',
                  //         style: TextStyle(
                  //           color: Colors.black87,
                  //           fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                  //           fontFamily: 'Montserrat',
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 10.w,
                  //     ),
                  //     Expanded(
                  //       flex: 1,
                  //       child: Text(
                  //         'Qty',
                  //         style: TextStyle(
                  //           color: Colors.black87,
                  //           fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                  //           fontFamily: 'Montserrat',
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: widget.isHorizontal ? 18.h : 8.h,
                  // ),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Expanded(
                  //       flex: 4,
                  //       child: Container(
                  //         padding: EdgeInsets.symmetric(
                  //           horizontal: widget.isHorizontal ? 10.r : 5.r,
                  //         ),
                  //         decoration: BoxDecoration(
                  //           border: Border.all(
                  //             color: Colors.black54,
                  //           ),
                  //           borderRadius: BorderRadius.circular(5.r),
                  //         ),
                  //         child: DropdownButton(
                  //           underline: SizedBox(),
                  //           isExpanded: true,
                  //           value: widget.selectedContent,
                  //           style: TextStyle(
                  //             color: Colors.black54,
                  //             fontFamily: 'Segoe ui',
                  //             fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //           items: contentList?.map((item) {
                  //             return DropdownMenuItem(
                  //               value: item,
                  //               child: Text(
                  //                 item,
                  //                 style: TextStyle(
                  //                   color: Colors.black54,
                  //                 ),
                  //               ),
                  //             );
                  //           }).toList(),
                  //           hint: Text(
                  //             'Pilih konten',
                  //             style: TextStyle(
                  //               color: Colors.black54,
                  //               fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                  //               fontWeight: FontWeight.w600,
                  //               fontFamily: 'Segoe ui',
                  //             ),
                  //           ),
                  //           onChanged: (String? _value) {
                  //             setState(() {
                  //               widget.selectedContent = _value!;
                  //               int? index = _contentList!.indexWhere(
                  //                   (item) => item.posterContent == _value);
                  //               widget.selectedContentId =
                  //                   _contentList![index].posterContentId!;

                  //               widget.notifyParent('selectedContent', _value);
                  //               widget.notifyParent('selectedContentId',
                  //                   widget.selectedContentId);
                  //             });
                  //           },
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 10.w,
                  //     ),
                  //     Expanded(
                  //       flex: 1,
                  //       child: TextFormField(
                  //         textAlign: TextAlign.center,
                  //         keyboardType: TextInputType.number,
                  //         inputFormatters: [ThousandsSeparatorInputFormatter()],
                  //         maxLength: 3,
                  //         decoration: InputDecoration(
                  //           hintText: '0',
                  //           hintStyle: TextStyle(
                  //             color: Colors.grey.shade400,
                  //             fontWeight: FontWeight.w600,
                  //             fontFamily: 'Segoe ui',
                  //             fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                  //           ),
                  //           border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(5.r),
                  //           ),
                  //           contentPadding: EdgeInsets.symmetric(
                  //             horizontal: 10.w,
                  //             vertical: 2.h,
                  //           ),
                  //           errorText: widget.validateQtyItem ? null : 'Isi',
                  //         ),
                  //         style: TextStyle(
                  //           color: Colors.black54,
                  //           fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                  //           fontFamily: 'Segoe ui',
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //         controller: widget.controllerProductQty,
                  //         onChanged: (value) {
                  //           if (value.isNotEmpty) {
                  //             widget.notifyParent('validateQtyItem', true);
                  //           } else {
                  //             widget.notifyParent('validateQtyItem', false);
                  //           }
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tambahkan item poster',
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
                                  setState(() {
                                    widget.listPosterLine.add(
                                      PosMaterialLinePoster(
                                        materialId: "POSID-001",
                                        material: "Albatros",
                                        width: "",
                                        height: "",
                                        contentId: "CONID-001",
                                        content: "Leinz Logo",
                                        qty: "",
                                        validateProductWidth: false,
                                        validateProductHeight: false,
                                        validateQtyItem: false,
                                      ),
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
                  Visibility(
                    visible: widget.listPosterLine.length > 0 ? true : false,
                    child: Center(
                      child: Posmaterial_Itemposter(
                        notifyParent: deleteLinePos,
                        listPosterLine: widget.listPosterLine,
                        isHorizontal: widget.isHorizontal,
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
                          'Belum ada data',
                          style: TextStyle(
                            fontSize: widget.isHorizontal ? 20.sp : 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: widget.isHorizontal ? 22.h : 5.h,
                  // ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: EasyButton(
                      idleStateWidget: Text(
                        "Hitung Estimasi",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.isHorizontal ? 18.sp : 14.sp,
                            fontWeight: FontWeight.w700),
                      ),
                      loadingStateWidget: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                      useEqualLoadingStateWidgetDimension: true,
                      useWidthAnimation: true,
                      height: widget.isHorizontal ? 50.h : 40.h,
                      width: widget.isHorizontal ? 120.w : 140.w,
                      borderRadius: widget.isHorizontal ? 60.r : 30.r,
                      buttonColor: Colors.blue.shade700,
                      elevation: 2.0,
                      contentGap: 6.0,
                      onPressed: isValidData
                          ? onButtonPressed
                          : null,
                    ),
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 12.h,
                  ),
                  if (estimatedPrice != '')
                    Container(
                      margin: EdgeInsets.only(
                        top: 5.r,
                        bottom: 8.r,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.r,
                        vertical: 8.r,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          5.r,
                        ),
                        color: Colors.greenAccent.shade700,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white70,
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Flexible(
                            child: Text(
                              'Estimasi POS : ${convertToIdr(double.parse(estimatedPrice ?? "0"), 0)}',
                              overflow: TextOverflow.visible,
                              softWrap: true,
                              style: TextStyle(
                                height: 1.45,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.omzetOptik != '')
                    Container(
                      margin: EdgeInsets.only(
                        top: 5.r,
                        bottom: 8.r,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.r,
                        vertical: 8.r,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          5.r,
                        ),
                        color: Colors.blueAccent.shade700,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white70,
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Flexible(
                            child: Text(
                              'Max alokasi POS : ${convertToIdr(double.parse(widget.omzetOptik), 0)}',
                              overflow: TextOverflow.visible,
                              softWrap: true,
                              style: TextStyle(
                                height: 1.45,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: widget.isHorizontal ? 18.h : 10.h,
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
                  Row(
                    children: [
                      Switch(
                        value: widget.isDesignOnly,
                        onChanged: (value) {
                          setState(() {
                            widget.isDesignOnly = value;
                            widget.notifyParent('isDesignOnly', value);
                          });
                        },
                        activeTrackColor: Colors.blue.shade400,
                        activeColor: Colors.blue,
                      ),
                      Expanded(
                        child: Text(
                          'Hanya desain, biaya pencetakan ditanggung optik.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: widget.isHorizontal ? 14.sp : 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ],
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
            //             txtPathAttachment: txtAttachmentOmzet,
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
                        txtPathAttachment: txtAttachmentOmzet,
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
