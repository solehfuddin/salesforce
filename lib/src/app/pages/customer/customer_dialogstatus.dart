import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/change_customer.dart';
import '../../utils/custom.dart';
import '../../utils/settings_cashback.dart';
import '../../utils/settings_posmaterial.dart';
import 'detail_changecustomer.dart';

// ignore: must_be_immutable
class CustomerDialogStatus extends StatefulWidget {
  ChangeCustomer item;
  String? username, divisi, role;
  bool isSales;
  bool showDownload;
  CustomerDialogStatus({
    Key? key,
    required this.item,
    this.isSales = false,
    this.username,
    this.divisi,
    this.role,
    this.showDownload = true,
  }) : super(key: key);

  @override
  State<CustomerDialogStatus> createState() => _CustomerDialogStatusState();
}

class _CustomerDialogStatusState extends State<CustomerDialogStatus> {
  @override
  void initState() {
    super.initState();

    print("Dialog is sales : ${widget.isSales}");
  }

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
                  widget.item.namaUsaha ?? '-',
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
            setCustomerStatus(
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
                'Tanggal pengajuan : ${convertDateWithMonth(widget.item.dateAdded ?? '2024-01-01')}',
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
                    'Detail Perubahan',
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
                        builder: (context) => DetailChangeCustomer(
                          customer: widget.item,
                          username: widget.username,
                          divisi: widget.divisi,
                          role: widget.role,
                          isPending: false,
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
                pic: 'Sales Manager',
                picAlias: 'SM',
                picName: widget.item.namaSM!,
                picReason: widget.item.reasonSM!,
                approvalStatus: widget.item.ttdSM!,
                dateApproved: widget.item.dateApprovedSM != ''
                    ? convertDateWithMonthHour(
                        widget.item.dateApprovedSM!,
                      )
                    : '-',
              ),
              getDetailStatus(
                isHorizontal,
                context,
                pic: 'AR Manager',
                picAlias: 'AM',
                picName: widget.item.namaAR!,
                picReason: widget.item.reasonAR!,
                approvalStatus: widget.item.ttdAR!,
                dateApproved: widget.item.dateApprovedAR != ''
                    ? convertDateWithMonthHour(
                        widget.item.dateApprovedAR!,
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
                  visible: widget.item.reasonSM!.length > 0 ? true : false,
                  child: Text(
                    'Catatan SM : ${widget.item.reasonSM!}',
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
                  visible: widget.item.reasonAR!.length > 0 ? true : false,
                  child: Text(
                    'Catatan AM : ${widget.item.reasonAR!}',
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
