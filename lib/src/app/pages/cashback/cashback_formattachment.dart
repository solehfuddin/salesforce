import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formattachment.dart';
import 'package:sample/src/app/widgets/dialogImage.dart';
import 'package:signature/signature.dart';

// ignore: must_be_immutable
class CashbackFormAttachment extends StatefulWidget {
  final Function(String? varName, dynamic input) notifyParent;
  TextEditingController txtAttachmentSign = new TextEditingController();
  TextEditingController txtAttachmentOther = new TextEditingController();

  bool isHorizontal;
  bool isUpdateForm = false;
  bool validateLampiranSign = false;
  String base64Sign = '', base64Other = '';

  CashbackFormAttachment({
    Key? key,
    required this.isHorizontal,
    required this.isUpdateForm,
    required this.notifyParent,
    required this.txtAttachmentSign,
    required this.txtAttachmentOther,
    required this.validateLampiranSign,
    required this.base64Sign,
    required this.base64Other,
  }) : super(key: key);

  @override
  State<CashbackFormAttachment> createState() => _CashbackFormAttachmentState();
}

class _CashbackFormAttachmentState extends State<CashbackFormAttachment> {
  String attachmentSign = 'Lampiran ttd owner';
  String attachmentOther = 'Lampiran tambahan';
  late String tmpBase64Sign, tmpBase64Other;
  bool validateLampiranOther = false;

  final SignatureController _signController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();

    _signController.addListener(() async {
      var data = await _signController.toPngBytes();
      widget.notifyParent('validateLampiranSign', false);

      if (_signController.isNotEmpty) {
        print("Sign : ${base64Encode(data!)}");
        updateSelectedAttachment("Lampiran ttd owner", base64Encode(data));
        widget.notifyParent('Lampiran Sign', base64Encode(data));
        widget.notifyParent('validateLampiranSign', true);
      }
    });

    if (widget.base64Sign.isNotEmpty) {
      tmpBase64Sign = widget.base64Sign;
    } else {
      tmpBase64Sign = '';
    }

    if (widget.base64Other.isNotEmpty) {
      tmpBase64Other = widget.base64Other;
    } else {
      tmpBase64Other = '';
    }
  }

  updateSelectedAttachment(dynamic varName, dynamic input) {
    setState(() {
      switch (varName) {
        case 'Lampiran ttd owner':
          widget.base64Sign = input;
          widget.notifyParent('Lampiran Sign', widget.base64Sign);

          print("Reprint Sign : $input");
          break;
        case 'Lampiran tambahan':
          print('Callback tambahan : $input');
          widget.base64Other = input;
          widget.notifyParent('Lampiran Tambahan', widget.base64Other);
          break;
        default:
      }
    });
  }

  updateValidatedAttachment(dynamic varName, dynamic input) {
    setState(() {
      switch (varName) {
        case 'Lampiran ttd owner':
          widget.validateLampiranSign = input;
          widget.notifyParent('validateLampiranSign', input);
          break;
        case 'Lampiran tambahan':
          validateLampiranOther = true;
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
                color: Colors.teal.shade400,
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
                  'Lampiran Cashback',
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
                  Text(
                    'Ttd Pihak Optik',
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Signature(
                      controller: _signController,
                      height: widget.isHorizontal ? 180.h : 150.h,
                      backgroundColor: Colors.blueGrey.shade50,
                    ),
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 8.h : 5.h,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        backgroundColor: Colors.red[500],
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.isHorizontal ? 30.r : 20.r,
                          vertical: widget.isHorizontal ? 15.r : 10.r,
                        ),
                      ),
                      child: Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.isHorizontal ? 18.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onPressed: () {
                        _signController.clear();
                      },
                    ),
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 20.h : 15.h,
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
                ],
              ),
            ),
            Visibility(
              visible: widget.isUpdateForm,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: widget.isHorizontal ? 24.w : 12.w,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Visibility(
                        //   visible: widget.base64Sign != '',
                        //   child: InkWell(
                        //     child: ClipRRect(
                        //       borderRadius: BorderRadius.circular(
                        //         8.r,
                        //       ),
                        //       child: Image.memory(
                        //         base64Decode(tmpBase64Sign),
                        //         width: widget.isHorizontal ? 95.w : 75.w,
                        //         height: widget.isHorizontal ? 110.h : 75.h,
                        //         fit: widget.isHorizontal
                        //             ? BoxFit.cover
                        //             : BoxFit.cover,
                        //         filterQuality: FilterQuality.medium,
                        //       ),
                        //     ),
                        //     onTap: () async {
                        //       await showDialog(
                        //         context: context,
                        //         builder: (BuildContext context) {
                        //           return DialogImage(
                        //             attachmentSign,
                        //             widget.base64Sign,
                        //           );
                        //         },
                        //       );
                        //     },
                        //   ),
                        //   replacement: SizedBox(
                        //     width: 5,
                        //   ),
                        // ),
                        // SizedBox(
                        //   width: 10.w,
                        // ),
                        Visibility(
                          visible: widget.base64Other != '',
                          child: InkWell(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                8.r,
                              ),
                              child: Image.memory(
                                base64Decode(tmpBase64Other),
                                width: widget.isHorizontal ? 95.w : 75.w,
                                height: widget.isHorizontal ? 110.h : 75.h,
                                fit: widget.isHorizontal
                                    ? BoxFit.cover
                                    : BoxFit.cover,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DialogImage(
                                    attachmentOther,
                                    widget.base64Other,
                                  );
                                },
                              );
                            },
                          ),
                          replacement: SizedBox(
                            width: 5,
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: widget.base64Other != '',
                      child: SizedBox(
                        height: widget.isHorizontal ? 15.h : 8.h,
                      ),
                      replacement: SizedBox(
                        width: 5.w,
                      ),
                    ),
                  ],
                ),
              ),
              replacement: SizedBox(
                width: 5.w,
              ),
            ),
            // Container(
            //   margin: EdgeInsets.symmetric(
            //     horizontal: widget.isHorizontal ? 24.w : 12.w,
            //   ),
            //   child: Stack(
            //     children: [
            //       Container(
            //         width: double.maxFinite,
            //         child: Posmaterial_formattachment(
            //           isHorizontal: widget.isHorizontal,
            //           attachmentTitle: attachmentSign,
            //           notifyParent: updateSelectedAttachment,
            //           flagParent: updateValidatedAttachment,
            //           base64Image: widget.base64Sign,
            //           validateAttachment: widget.validateLampiranSign,
            //           txtPathAttachment: widget.txtAttachmentSign,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
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
                      attachmentTitle: attachmentOther,
                      notifyParent: updateSelectedAttachment,
                      flagParent: updateValidatedAttachment,
                      base64Image: widget.base64Other,
                      validateAttachment: true,
                      txtPathAttachment: widget.txtAttachmentOther,
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
