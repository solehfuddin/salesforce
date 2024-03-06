import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

// ignore: camel_case_types, must_be_immutable
class Posmaterial_formattachment extends StatefulWidget {
  TextEditingController txtPathAttachment = new TextEditingController();

  final Function(String? varName, dynamic input) notifyParent;
  final Function(String? varName, bool? input) flagParent;
  bool isHorizontal = false;
  bool validateAttachment = false;
  String? attachmentTitle = '';

  Posmaterial_formattachment({
    Key? key,
    required this.isHorizontal,
    required this.attachmentTitle,
    required this.notifyParent,
    required this.flagParent,
    required this.validateAttachment,
    required this.txtPathAttachment,
  }) : super(key: key);

  @override
  State<Posmaterial_formattachment> createState() =>
      _Posmaterial_formattachmentState();
}

// ignore: camel_case_types
class _Posmaterial_formattachmentState
    extends State<Posmaterial_formattachment> {
  String base64Image = '';
  String tmpName = '';

  @override
  void initState() {
    super.initState();

    if (tmpName == '') {
      widget.txtPathAttachment.text = '${widget.attachmentTitle} belum dipilih';
    } else {
      widget.txtPathAttachment.text = tmpName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      // key: Posmaterial_formattachment.formKey,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: TextFormField(
            // enabled: false,
            readOnly: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: widget.attachmentTitle,
              labelText: widget.attachmentTitle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  5.r,
                ),
              ),
              errorText: widget.validateAttachment
                  ? null
                  : '${widget.attachmentTitle} belum dipilih',
            ),
            controller: widget.txtPathAttachment,
            style: TextStyle(
              fontSize: widget.isHorizontal ? 25.sp : 15.sp,
              fontFamily: 'Segoe ui',
            ),
            onChanged: (value) {
              if (base64Image.isNotEmpty) {
                widget.flagParent(widget.attachmentTitle, true);
              } else {
                widget.flagParent(widget.attachmentTitle, false);
              }
            },
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
        Ink(
          decoration: const ShapeDecoration(
            color: Colors.blue,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
            ),
            iconSize: widget.isHorizontal ? 40.r : 27.r,
            onPressed: () {
              chooseImage();
            },
          ),
        ),
      ],
    );
  }

  Future chooseImage() async {
    var imgFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );

    setState(() {
      if (imgFile != null) {
        File tmpFile = File(imgFile.path);
        tmpName = tmpFile.path.split('/').last;

        base64Image = base64Encode(Io.File(imgFile.path).readAsBytesSync());
        widget.notifyParent(widget.attachmentTitle, base64Image);

        widget.txtPathAttachment.text = tmpName;
        widget.flagParent(widget.attachmentTitle, true);
      }
    });
  }
}
