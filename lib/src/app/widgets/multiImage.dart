import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class MultiImage extends StatefulWidget {
  double height;
  Color dottedColor;
  Color backgroundColor;
  Color buttonBackgroundColor;
  Color buttonTextColor;
  Color labelColor;
  RxList<XFile> listAttachment;

  MultiImage({
    Key? key,
    this.height = 160,
    this.dottedColor = Colors.blue,
    this.backgroundColor = Colors.blue,
    this.buttonBackgroundColor = Colors.blue,
    this.buttonTextColor = Colors.white,
    this.labelColor = Colors.blue,
    required this.listAttachment,
  }) : super(key: key);

  @override
  State<MultiImage> createState() => _MultiImageState();
}

class _MultiImageState extends State<MultiImage> {
  List<XFile>? listImage = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      color: widget.dottedColor,
      radius: Radius.circular(12),
      strokeWidth: 2.r,
      dashPattern: [8, 6],
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
          ),
          child: InkWell(
            onTap: () => chooseImageMulti(),
            child: Visibility(
              visible: listImage != null
                  ? listImage!.length > 0
                      ? false
                      : true
                  : true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => chooseImageMulti(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.buttonBackgroundColor,
                    ),
                    child: Text(
                      'Upload Image',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Segoe ui',
                        color: widget.buttonTextColor,
                      ),
                    ),
                  ),
                  Text(
                    'JPG, PNG, JPEG',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: widget.labelColor,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              replacement: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                mainAxisSpacing: 8.r,
                crossAxisSpacing: 8.r,
                padding: EdgeInsets.all(10.r),
                children: [
                  if (listImage != null)
                    for (var i in listImage!)
                      Image.file(
                        File(i.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void chooseImageMulti() async {
    ImagePicker()
        .pickMultiImage(
      imageQuality: 25,
    )
        .then((value) {
      setState(() {
        if (value.isNotEmpty) {
          listImage?.addAll(value);
          widget.listAttachment.value = listImage!;
        }
      });
    });
  }
}
