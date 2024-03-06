import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/settings_posmaterial.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_dialogstatus.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/posmaterial_resheader.dart';

// ignore: camel_case_types, must_be_immutable
class Posmaterial_itemlist extends StatelessWidget {
  PosMaterialResHeader itemList;
  bool isHorizontal = false;

  Posmaterial_itemlist({
    Key? key,
    required this.isHorizontal,
    required this.itemList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 20.r : 15.r,
        vertical: isHorizontal ? 12.r : 7.r,
      ),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: this.itemList.count,
          itemBuilder: (context, position) {
            return Card(
              elevation: 2,
              borderOnForeground: true,
              color: Colors.white,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10.r,
                ),
              ),
              child: InkWell(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isHorizontal ? 22.r : 10.r,
                    vertical: isHorizontal ? 24.r : 12.r,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              this.itemList.header[position].opticName!,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                fontFamily: 'Segoe ui',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                6.r,
                              ),
                              border: Border.all(
                                color: getPosColor(
                                  setPosType(
                                      this.itemList.header[position].posType!),
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                              isHorizontal ? 10.r : 5.r,
                            ),
                            child: Text(
                              this.itemList.header[position].posType!,
                              style: TextStyle(
                                fontSize: isHorizontal ? 13.sp : 11.sp,
                                fontFamily: 'Segoe ui',
                                color: getPosColor(
                                  setPosType(
                                      this.itemList.header[position].posType!),
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: isHorizontal ? 6.r : 4.r,
                      ),
                      Divider(
                        color: Colors.black38,
                      ),
                      SizedBox(
                        height: isHorizontal ? 6.r : 3.r,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: isHorizontal ? 100.r : 45.r,
                            height: isHorizontal ? 100.r : 45.r,
                            padding: EdgeInsets.symmetric(
                              horizontal: isHorizontal ? 12.r : 7.r,
                            ),
                            decoration: BoxDecoration(
                              color: getPosColorAccent(
                                setPosType(
                                    this.itemList.header[position].posType!),
                              ),
                              borderRadius: BorderRadius.circular(
                                10.r,
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                getImagePos(
                                    this.itemList.header[position].posType!),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: isHorizontal ? 22.r : 10.r,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  this
                                      .itemList
                                      .header[position]
                                      .deliveryMethod!,
                                  style: TextStyle(
                                    fontSize: isHorizontal ? 15.sp : 13.sp,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 4.r,
                                ),
                                Container(
                                  child: Text(
                                    this.itemList.header[position].status!,
                                    style: TextStyle(
                                      fontSize: isHorizontal ? 13.sp : 11.sp,
                                      fontFamily: 'Segoe ui',
                                      fontWeight: FontWeight.w600,
                                      color: setStatusColor(this
                                          .itemList
                                          .header[position]
                                          .status!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: isHorizontal ? 12.r : 7.r,
                          ),
                          Text(
                            convertDateWithMonth(
                                this.itemList.header[position].insertDate!),
                            style: TextStyle(
                              fontSize: isHorizontal ? 15.sp : 13.sp,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      elevation: 2,
                      enableDrag: true,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                            15.r,
                          ),
                          topRight: Radius.circular(
                            15.r,
                          ),
                        ),
                      ),
                      builder: (context) {
                        return SingleChildScrollView(
                          child: PosMaterialDialogStatus(
                            item: itemList.header[position],
                          ),
                        );
                      });
                },
              ),
            );
          }),
    );
  }
}
