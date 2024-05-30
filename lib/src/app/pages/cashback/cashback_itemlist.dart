import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/cashback/cashback_detail.dart';
import 'package:sample/src/app/pages/cashback/cashback_dialogstatus.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/settings_cashback.dart';
import 'package:sample/src/domain/entities/cashback_resheader.dart';

// ignore: must_be_immutable
class CashbackItemList extends StatelessWidget {
  CashbackResHeader? itemHeader;
  bool isHorizontal = false;
  bool isSales = false;
  bool isPending;
  bool showDownload;

  CashbackItemList({
    Key? key,
    this.itemHeader,
    required this.isSales,
    required this.isHorizontal,
    this.isPending = false,
    this.showDownload = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Visibility(
          visible: isSales,
          child: ListView.builder(
              scrollDirection: isSales ? Axis.horizontal : Axis.vertical,
              shrinkWrap: true,
              itemCount: itemHeader!.count,
              itemBuilder: (context, position) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: isSales ? 0.h : 3.h),
                  width: itemHeader!.count! > 1
                      ? 320.w
                      : MediaQuery.of(context).size.width - 20.w,
                  child: Card(
                    elevation: 4,
                    borderOnForeground: true,
                    color: Colors.white,
                    shadowColor: Colors.black87,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            top: isHorizontal ? 13.h : 8.h,
                            left: isHorizontal ? 15.h : 10.h,
                            right: isHorizontal ? 15.h : 10.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      !isSales
                                          ? itemHeader!.cashback[position]
                                                  .opticName ??
                                              ''
                                          : itemHeader!.cashback[position].id ??
                                              '',
                                      style: TextStyle(
                                        fontFamily: 'Segoe Ui',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: isHorizontal ? 12.sp : 14.sp,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Tgl diajukan',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontFamily: 'Segoe ui',
                                      fontSize: isHorizontal ? 15.sp : 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tipe cashback : ${capitalize(itemHeader!.cashback[position].cashbackType!.toLowerCase())}',
                                    style: TextStyle(
                                      fontSize: isHorizontal ? 14.sp : 12.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    convertDateWithMonth(
                                      itemHeader!
                                          .cashback[position].insertDate!,
                                    ),
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontFamily: 'Segoe ui',
                                      fontSize: isHorizontal ? 15.sp : 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                children: [
                                  Visibility(
                                    visible: !isSales,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isHorizontal ? 10.h : 8.h,
                                        vertical: isHorizontal ? 5.h : 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade900,
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person_rounded,
                                            color: Colors.white,
                                            size: 18.sp,
                                          ),
                                          SizedBox(
                                            width: 3.w,
                                          ),
                                          Text(
                                            capitalize(
                                              itemHeader!.cashback[position]
                                                  .salesName!,
                                            ),
                                            style: TextStyle(
                                              fontSize:
                                                  isHorizontal ? 13.sp : 11.sp,
                                              fontFamily: 'Montserrat',
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    replacement: SizedBox(
                                      height: 5.h,
                                    ),
                                  ),
                                  Visibility(
                                    visible: !isSales,
                                    child: SizedBox(
                                      width: 5.w,
                                    ),
                                    replacement: SizedBox(
                                      height: 5.h,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isHorizontal ? 10.h : 8.h,
                                      vertical: isHorizontal ? 8.h : 4.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getCashbackColor(
                                        getCashbackStatus(
                                          itemHeader!
                                                  .cashback[position].status ??
                                              '',
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      itemHeader!.cashback[position].status ??
                                          '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Montserrat',
                                        fontSize: isHorizontal ? 12.sp : 11.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Divider(
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10.h,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    !isSales ? 'Id optik' : 'Durasi Kontrak',
                                    style: TextStyle(
                                      fontFamily: 'Segoe ui',
                                      fontSize: isHorizontal ? 15.sp : 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    !isSales
                                        ? 'Tipe optik'
                                        : 'Kontrak Berakhir',
                                    style: TextStyle(
                                      fontFamily: 'Segoe ui',
                                      fontSize: isHorizontal ? 15.sp : 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    !isSales
                                        ? itemHeader!.cashback[position]
                                                .shipNumber ??
                                            ''
                                        : '${itemHeader!.cashback[position].targetDuration} bulan',
                                    style: TextStyle(
                                      fontFamily: 'Segoe ui',
                                      fontSize: isHorizontal ? 15.sp : 14.sp,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    !isSales
                                        ? itemHeader!
                                                .cashback[position].opticType ??
                                            ''
                                        : convertDateWithMonth(itemHeader!
                                            .cashback[position].endPeriode!),
                                    style: TextStyle(
                                      fontFamily: 'Segoe ui',
                                      fontSize: isHorizontal ? 15.sp : 14.sp,
                                      color: !isSales
                                          ? Colors.black45
                                          : Colors.red.shade400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cashback',
                                    style: TextStyle(
                                      fontFamily: 'Segoe ui',
                                      fontSize: isHorizontal ? 15.sp : 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Lama pencairan',
                                    style: TextStyle(
                                      fontFamily: 'Segoe ui',
                                      fontSize: isHorizontal ? 15.sp : 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Visibility(
                                    visible: double.parse(itemHeader!
                                                    .cashback[position]
                                                    .cashbackPercentage ??
                                                '0') >
                                            0
                                        ? true
                                        : false,
                                    child: Text(
                                      '${itemHeader!.cashback[position].cashbackPercentage} %',
                                      style: TextStyle(
                                        fontFamily: 'Segoe ui',
                                        fontSize: isHorizontal ? 15.sp : 14.sp,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    replacement: Text(
                                      convertToIdr(
                                        int.parse(itemHeader!.cashback[position]
                                                .cashbackValue ??
                                            "0"),
                                        0,
                                      ),
                                      style: TextStyle(
                                        fontFamily: 'Segoe ui',
                                        fontSize: isHorizontal ? 15.sp : 14.sp,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${itemHeader!.cashback[position].withdrawDuration ?? ''} hari',
                                    style: TextStyle(
                                      fontFamily: 'Segoe ui',
                                      fontSize: isHorizontal ? 15.sp : 14.sp,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            Visibility(
                              visible: isSales,
                              child: Expanded(
                                flex: 3,
                                child: Container(
                                  height: 38.h,
                                  color: Colors.teal.shade600,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: ContinuousRectangleBorder(),
                                      primary: Colors.teal.shade600,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                    onPressed: () {
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
                                            return CashbackDialogStatus(
                                              item: itemHeader!
                                                  .cashback[position],
                                              isSales: isSales,
                                            );
                                          });
                                    },
                                    child: Text(
                                      'View Status',
                                      style: TextStyle(
                                        fontFamily: 'Segoe ui',
                                        fontSize: isHorizontal ? 16.sp : 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              replacement: SizedBox(
                                height: 10.h,
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: 38.h,
                                color: Colors.blueGrey.shade400,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: ContinuousRectangleBorder(),
                                    primary: Colors.blueGrey.shade400,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => CashbackDetail(
                                          isSales: isSales,
                                          itemHeader:
                                              itemHeader!.cashback[position],
                                          showDownload: showDownload,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'View Detail',
                                    style: TextStyle(
                                      fontFamily: 'Segoe ui',
                                      fontSize: isHorizontal ? 16.sp : 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          replacement: ListView.builder(
              scrollDirection: isSales ? Axis.horizontal : Axis.vertical,
              shrinkWrap: true,
              itemCount: itemHeader!.count,
              padding: EdgeInsets.symmetric(vertical: 5.h),
              itemBuilder: (context, position) {
                return Card(
                  elevation: 4,
                  borderOnForeground: true,
                  color: Colors.white,
                  shadowColor: Colors.black87,
                  margin: EdgeInsets.symmetric(vertical: 5.h),
                  child: InkWell(
                    onTap: () {
                      isPending
                          ? Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CashbackDetail(
                                  isSales: isSales,
                                  itemHeader: itemHeader!.cashback[position],
                                  showDownload: showDownload,
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
                                return CashbackDialogStatus(
                                  item: itemHeader!.cashback[position],
                                  isSales: isSales,
                                );
                              });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isHorizontal ? 12.r : 5.r,
                        vertical: isHorizontal ? 12.r : 5.r,
                      ),
                      padding: EdgeInsets.only(
                        top: isHorizontal ? 13.h : 8.h,
                        left: isHorizontal ? 15.h : 10.h,
                        right: isHorizontal ? 15.h : 10.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  !isSales
                                      ? itemHeader!
                                              .cashback[position].opticName ??
                                          ''
                                      : itemHeader!.cashback[position].id ?? '',
                                  style: TextStyle(
                                    fontFamily: 'Segoe Ui',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    fontSize: isHorizontal ? 12.sp : 14.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Text(
                                  'Tipe cashback : ${capitalize(itemHeader!.cashback[position].cashbackType!.toLowerCase())}',
                                  style: TextStyle(
                                    fontSize: isHorizontal ? 14.sp : 12.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Visibility(
                                  visible: !isSales,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isHorizontal ? 10.h : 8.h,
                                      vertical: isHorizontal ? 5.h : 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade900,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.person_rounded,
                                          color: Colors.white,
                                          size: 18.sp,
                                        ),
                                        SizedBox(
                                          width: 3.w,
                                        ),
                                        Text(
                                          capitalize(
                                            itemHeader!
                                                .cashback[position].salesName!,
                                          ),
                                          style: TextStyle(
                                            fontSize:
                                                isHorizontal ? 13.sp : 11.sp,
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  replacement: SizedBox(
                                    height: 5.h,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                convertDateWithMonth(
                                  itemHeader!.cashback[position].insertDate!,
                                ),
                                style: TextStyle(
                                  color: Colors.red,
                                  fontFamily: 'Segoe ui',
                                  fontSize: isHorizontal ? 15.sp : 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 12.h,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(8.h),
                                ),
                                padding: EdgeInsets.all(5.w),
                                child: Center(
                                  child: Image.asset(
                                    itemHeader!.cashback[position]
                                                .cashbackType ==
                                            "BY PRODUCT"
                                        ? "assets/images/cashback_product.png"
                                        : itemHeader!.cashback[position]
                                                    .cashbackType ==
                                                "BY TARGET"
                                            ? "assets/images/cashback_target.png"
                                            : "assets/images/cashback_combine.png",
                                    width: 25.w,
                                    height: 25.h,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
