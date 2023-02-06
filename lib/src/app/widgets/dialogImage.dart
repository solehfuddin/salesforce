import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

// ignore: must_be_immutable
class DialogImage extends StatefulWidget {
  dynamic text, path;

  DialogImage(this.text, this.path);

  @override
  State<DialogImage> createState() => _DialogImageState();
}

class _DialogImageState extends State<DialogImage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600 ||
            MediaQuery.of(context).orientation == Orientation.landscape) {
          return childImage(
            isHorizontal: true,
          );
        }
        return childImage(
          isHorizontal: false,
        );
      },
    );
  }

  Widget childImage({bool isHorizontal = false}) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.text}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close_rounded),
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
          Container(
            width: isHorizontal ? 150.w : 230.w,
            height: isHorizontal ? 220.h : 230.h,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.r),
                bottomRight: Radius.circular(10.r),
              ),
              child: ZoomOverlay(
                minScale: 0.5, // Optional
                maxScale: 3.0, // Optional
                twoTouchOnly: true, // Defaults to false
                child: Image.memory(
                  base64Decode(widget.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
