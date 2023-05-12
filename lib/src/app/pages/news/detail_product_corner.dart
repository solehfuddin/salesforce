import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/domain/entities/item_corner.dart';

// ignore: must_be_immutable
class DetailProductCorner extends StatefulWidget {
  ItemCorner itemCorner;
  DetailProductCorner(this.itemCorner);

  @override
  State<DetailProductCorner> createState() => _DetailProductCornerState();
}

class _DetailProductCornerState extends State<DetailProductCorner> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          widget.itemCorner.titleCorner ?? "",
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: Colors.black54,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                color: Colors.grey.shade400,
                height: 4,
              ),
              widget.itemCorner.isImageValid
                  ? Center(
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 10,
                        ),
                        child: Image.network(
                          widget.itemCorner.imgCorner,
                          width: 135.w,
                          height: 135.h,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Image.asset(
                              'assets/images/not_found.png',
                              width: 130.w,
                              height: 130.h,
                            );
                          },
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 50,
                        ),
                        child: Image.asset(
                          'assets/images/not_found.png',
                          width: 135.w,
                          height: 135.h,
                        ),
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Divider(
                  color: Colors.grey.shade400,
                  height: 4,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 17,
                ),
                child: Row(
                  children: [
                    Text(
                      "Kategori : ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: 'Segoe ui',
                      ),
                    ),
                    Text(
                      widget.itemCorner.titleCategories ?? "",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontFamily: 'Montserrat',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 17,
                ),
                child: Row(
                  children: [
                    Text(
                      "Subkategori : ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: 'Segoe ui',
                      ),
                    ),
                    Text(
                      widget.itemCorner.titleSubcategories ?? "",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontFamily: 'Montserrat',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 17,
                ),
                child: Text(
                  "Detail : ",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Segoe ui',
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Html(
                  data: widget.itemCorner.bodyCorner,
                  style: {
                    'html': Style(
                      textAlign: TextAlign.justify,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
