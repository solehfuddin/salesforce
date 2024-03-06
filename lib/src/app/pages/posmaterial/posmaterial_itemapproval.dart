import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_detail.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_dialogstatus.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/settings_posmaterial.dart';
import 'package:sample/src/domain/entities/posmaterial_resheader.dart';

// ignore: must_be_immutable
class PosMaterialItemApproval extends StatefulWidget {
  PosMaterialResHeader itemList;
  bool isHorizontal = false;
  bool isPending = false;
  PosMaterialItemApproval({
    Key? key,
    required this.itemList,
    required this.isHorizontal,
    required this.isPending,
  }) : super(key: key);

  @override
  State<PosMaterialItemApproval> createState() =>
      _PosMaterialItemApprovalState();
}

class _PosMaterialItemApprovalState extends State<PosMaterialItemApproval> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: widget.isHorizontal ? 20.r : 10.r,
        vertical: widget.isHorizontal ? 12.r : 6.r,
      ),
      child: ListView.builder(
          shrinkWrap: false,
          itemCount: widget.itemList.count,
          itemBuilder: (context, position) {
            return Card(
              elevation: 2,
              borderOnForeground: true,
              color: Colors.white,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: InkWell(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: widget.isHorizontal ? 22.r : 10.r,
                    vertical: widget.isHorizontal ? 22.r : 11.r,
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
                              widget.itemList.header[position].opticName!,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: widget.isHorizontal ? 15.sp : 14.sp,
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
                                  setPosType(widget
                                      .itemList.header[position].posType!),
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                              widget.isHorizontal ? 8.r : 4.r,
                            ),
                            child: Text(
                              widget.itemList.header[position].posType!,
                              style: TextStyle(
                                fontSize: widget.isHorizontal ? 13.sp : 11.sp,
                                fontFamily: 'Segoe ui',
                                color: getPosColor(
                                  setPosType(
                                    widget.itemList.header[position].posType!,
                                  ),
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: widget.isHorizontal ? 6.r : 4.r,
                      ),
                      Divider(
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(
                        height: widget.isHorizontal ? 6.r : 4.r,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: widget.isHorizontal ? 100.r : 38.r,
                            height: widget.isHorizontal ? 100.r : 38.r,
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.isHorizontal ? 12.r : 7.r,
                            ),
                            decoration: BoxDecoration(
                              color: getPosColorAccent(
                                setPosType(
                                  widget.itemList.header[position].posType!,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(
                                10.r,
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                getImagePos(
                                  widget.itemList.header[position].posType!,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: widget.isHorizontal ? 22.r : 10.r,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diajukan : ${widget.itemList.header[position].salesName!}',
                                  style: TextStyle(
                                    fontSize:
                                        widget.isHorizontal ? 15.sp : 13.sp,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 4.r,
                                ),
                                Container(
                                  child: Text(
                                    '${widget.itemList.header[position].opticType!} CUSTOMER',
                                    style: TextStyle(
                                      fontSize:
                                          widget.isHorizontal ? 13.sp : 11.sp,
                                      fontFamily: 'Segoe ui',
                                      fontWeight: FontWeight.w600,
                                      color: getCustomerColor(widget.itemList
                                          .header[position].opticType!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: widget.isHorizontal ? 12.r : 7.r,
                          ),
                          Text(
                            convertDateWithMonth(
                              widget.itemList.header[position].insertDate!,
                            ),
                            style: TextStyle(
                              fontSize: widget.isHorizontal ? 15.sp : 13.sp,
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
                  widget.isPending
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PosMaterialDetail(
                              item: widget.itemList.header[position],
                              isAdmin: true,
                            ),
                          ),
                        )
                      : showModalBottomSheet(
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
                                item: widget.itemList.header[position],
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
