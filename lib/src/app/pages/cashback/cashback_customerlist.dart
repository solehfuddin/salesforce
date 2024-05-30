import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/cashback/cashback_management.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/domain/entities/opticwithaddress.dart';

// ignore: must_be_immutable
class CashbackCustomerList extends StatefulWidget {
  List<OpticWithAddress> listOptic = List.empty(growable: true);

  bool isHorizontal;
  CashbackCustomerList({
    Key? key,
    required this.isHorizontal,
    required this.listOptic,
  }) : super(key: key);

  @override
  State<CashbackCustomerList> createState() => _CashbackCustomerListState();
}

class _CashbackCustomerListState extends State<CashbackCustomerList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.listOptic.length,
        padding: EdgeInsets.symmetric(
          horizontal: widget.isHorizontal ? 23.r : 15.r,
          vertical: widget.isHorizontal ? 12.r : 10.r,
        ),
        itemBuilder: (context, position) {
          return Card(
            elevation: 2,
            child: ClipPath(
              child: InkWell(
                child: Container(
                  height: widget.isHorizontal ? 120.h : 90.h,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                          color: MyColors.greenAccent,
                          width: widget.isHorizontal ? 4.w : 5.w),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isHorizontal ? 20.r : 15.r,
                      vertical: 8.r,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.listOptic[position].namaUsaha ??
                                    'Unknown Name',
                                style: TextStyle(
                                  fontSize: widget.isHorizontal ? 20.sp : 15.sp,
                                  fontFamily: 'Segoe ui',
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              SizedBox(
                                width: widget.isHorizontal ? 250.w : 200.w,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'Nomor akun : ',
                                        style: TextStyle(
                                            fontSize: widget.isHorizontal
                                                ? 16.sp
                                                : 11.sp,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              SizedBox(
                                width: 200.w,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        widget.listOptic[position].noAccount ??
                                            '',
                                        style: TextStyle(
                                          fontSize: widget.isHorizontal
                                              ? 17.sp
                                              : 12.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Lihat Cashback',
                          style: TextStyle(
                            fontSize: widget.isHorizontal ? 20.sp : 14.sp,
                            fontFamily: 'Segoe Ui',
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CashbackManagement(
                        isHorizontal: widget.isHorizontal,
                        optic: widget.listOptic[position],
                      ),
                    ),
                  );
                },
              ),
              clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          );
        });
  }
}
