// import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/cashback/cashback_detail.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/settings_cashback.dart';
import 'package:sample/src/app/utils/settings_posmaterial.dart';
import 'package:sample/src/domain/entities/cashback_header.dart';

// ignore: must_be_immutable
class CashbackDialogStatus extends StatefulWidget {
  CashbackHeader item;
  bool isSales;
  bool showDownload;

  CashbackDialogStatus({
    Key? key,
    required this.item,
    this.isSales = false,
    this.showDownload = true,
  }) : super(key: key);

  @override
  State<CashbackDialogStatus> createState() => _CashbackDialogStatusState();
}

class _CashbackDialogStatusState extends State<CashbackDialogStatus> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(isHorizontal: true);
      }

      return childWidget(isHorizontal: false);
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    return Container(
      padding: EdgeInsets.all(isHorizontal ? 20.r : 15.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  widget.item.opticName ?? '-',
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isHorizontal ? 16.sp : 14.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: isHorizontal ? 7.r : 5.r,
                  horizontal: isHorizontal ? 15.r : 10.r,
                ),
                decoration: BoxDecoration(
                  color:
                      setCashbackStatusColor(widget.item.status ?? 'PENDING'),
                  borderRadius:
                      BorderRadius.circular(isHorizontal ? 15.r : 10.r),
                ),
                child: Text(
                  widget.item.status ?? 'PENDING',
                  style: TextStyle(
                    fontSize: isHorizontal ? 15.sp : 12.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          Text(
            setCashbackStatus(
              widget.item.status ?? 'PENDING',
            ),
            style: TextStyle(
              fontFamily: 'Monserrat',
              fontSize: isHorizontal ? 15.sp : 13.sp,
              fontWeight: FontWeight.w500,
              color: setCashbackStatusColor(widget.item.status ?? 'PENDING'),
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tanggal pengajuan : ${convertDateWithMonth(widget.item.insertDate ?? '2024-01-01')}',
                style: TextStyle(
                  fontSize: isHorizontal ? 15.sp : 12.sp,
                  fontFamily: 'Montserrrat',
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
              Visibility(
                visible: widget.isSales,
                child: SizedBox(
                  height: 10.h,
                ),
                replacement: InkWell(
                  child: Text(
                    'Detail Cashback',
                    style: TextStyle(
                      fontSize: isHorizontal ? 15.sp : 12.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CashbackDetail(
                          isSales: widget.isSales,
                          itemHeader: widget.item,
                          showDownload: widget.showDownload,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 3.h,
          ),
          Divider(
            color: Colors.black54,
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            'Detail Status',
            style: TextStyle(
              fontSize: isHorizontal ? 18.sp : 16.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 10.h : 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              getDetailStatus(
                isHorizontal,
                context,
                pic: 'General Manager',
                picAlias: 'GM',
                picName: widget.item.gmName!,
                picReason: widget.item.reasonGm!,
                approvalStatus: widget.item.approvalGm!,
                dateApproved: widget.item.dateApprovalGm != ''
                    ? convertDateWithMonthHour(
                        widget.item.dateApprovalGm!,
                      )
                    : '-',
              ),
              getDetailStatus(
                isHorizontal,
                context,
                pic: 'Sales Manager',
                picAlias: 'SM',
                picName: widget.item.smName!,
                picReason: widget.item.reasonSm!,
                approvalStatus: widget.item.approvalSm!,
                dateApproved: widget.item.dateApprovalSm != ''
                    ? convertDateWithMonthHour(
                        widget.item.dateApprovalSm!,
                      )
                    : '-',
              ),
            ],
          ),
          SizedBox(
            height: 15.h,
          ),
          Visibility(
            visible: widget.item.status == 'REJECT' ? true : false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keterangan : ',
                  style: TextStyle(
                    fontSize: isHorizontal ? 15.sp : 14.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Visibility(
                  visible: widget.item.reasonSm!.length > 0 ? true : false,
                  child: Text(
                    'Catatan SM : ${widget.item.reasonSm!}',
                    style: TextStyle(
                      fontSize: isHorizontal ? 15.sp : 12.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  replacement: SizedBox(
                    width: 5.w,
                  ),
                ),
                Visibility(
                  visible: widget.item.reasonGm!.length > 0 ? true : false,
                  child: Text(
                    'Catatan GM : ${widget.item.reasonGm!}',
                    style: TextStyle(
                      fontSize: isHorizontal ? 15.sp : 12.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  replacement: SizedBox(
                    width: 5.w,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Divider(
            color: Colors.black54,
          ),
          SizedBox(
            height: 7.h,
          ),
          Center(
            child: EasyButton(
              idleStateWidget: Text(
                "Tutup",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 16.sp : 14.sp,
                    fontWeight: FontWeight.w700),
              ),
              loadingStateWidget: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
              useEqualLoadingStateWidgetDimension: true,
              useWidthAnimation: true,
              height: isHorizontal ? 40.h : 40.h,
              width: isHorizontal ? 90.w : 120.w,
              borderRadius: isHorizontal ? 50.r : 30.r,
              buttonColor: Colors.blue.shade700,
              elevation: 2.0,
              contentGap: 6.0,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
