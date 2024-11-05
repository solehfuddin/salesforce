import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_detail.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_dialogstatus.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/marketingexpense_resheader.dart';

// ignore: camel_case_types, must_be_immutable
class Marketingexpense_itemapproval extends StatelessWidget {
  MarketingExpenseResHeader itemList;
  bool isHorizontal = false;
  bool isPending = false;

  Marketingexpense_itemapproval({
    Key? key,
    required this.itemList,
    required this.isHorizontal,
    required this.isPending,
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
                  height: 65.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: isHorizontal ? 8.r : 4.r,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visibility(
                      //   visible: itemList.list[position].isTraining == "YES"
                      //       ? true
                      //       : false,
                      //   child: Container(
                      //     padding: EdgeInsets.symmetric(
                      //       horizontal: 10.h,
                      //     ),
                      //     width: 41.w,
                      //     height: double.infinity,
                      //     decoration: BoxDecoration(
                      //       color: Colors.blue.shade50,
                      //       borderRadius: BorderRadius.circular(12.r),
                      //     ),
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Text(
                      //           '12',
                      //           style: TextStyle(
                      //             fontFamily: 'Segoe Ui',
                      //             fontSize: 18.sp,
                      //             fontWeight: FontWeight.w600,
                      //             color: Colors.black87,
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           height: 3.h,
                      //         ),
                      //         Text(
                      //           'Wed',
                      //           style: TextStyle(
                      //             fontFamily: 'Montserrat',
                      //             fontSize: 10.sp,
                      //             color: Colors.black87,
                      //           ),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      //   replacement: Container(
                      //     width: 41.w,
                      //     decoration: BoxDecoration(
                      //       color: Colors.blue.shade50,
                      //       borderRadius: BorderRadius.circular(12.r),
                      //     ),
                      //     child: Center(
                      //       child: Image.asset(
                      //         'assets/images/marketing_expense.png',
                      //         width: 31.w,
                      //         height: 31.h,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diajukan : ${itemList.list[position].salesName}',
                                  style: TextStyle(
                                    fontFamily: 'Segoe Ui',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Text(
                                  itemList.list[position].opticName ?? '-',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: 'Segoe ui',
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              convertDateWithMonth(
                                  itemList.list[position].insertDate!),
                              style: TextStyle(
                                fontFamily: 'Segoe Ui',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 15.r,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  isPending
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Marketingexpense_Detail(
                              item: itemList.list[position],
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
                              child: Marketingexpense_Dialogstatus(
                                item: itemList.list[position],
                              ),
                            );
                          },
                        );
                },
              ),
            );
          }),
    );
  }
}
