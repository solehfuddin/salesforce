// import 'package:easy_loading_button/easy_loading_button.dart';
// import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/trainer/trainer_confirm.dart';
import 'package:sample/src/domain/entities/training_header.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
// import 'package:social_share/social_share.dart';

import '../../utils/custom.dart';
import '../../utils/settings_training.dart';

// ignore: camel_case_types, must_be_immutable
class Training_DialogStatus extends StatefulWidget {
  TrainingHeader item;
  Training_DialogStatus({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<Training_DialogStatus> createState() => _Training_DialogStatusState();
}

// ignore: camel_case_types
class _Training_DialogStatusState extends State<Training_DialogStatus> {
  // AppinioSocialShare appShare = AppinioSocialShare();

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
                  color: setStatusColor(widget.item.status ?? 'PENDING'),
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
            setStatus(
              widget.item.status ?? 'PENDING',
            ),
            style: TextStyle(
              fontFamily: 'Monserrat',
              fontSize: isHorizontal ? 15.sp : 13.sp,
              fontWeight: FontWeight.w500,
              color: setStatusColor(widget.item.status ?? 'PENDING'),
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
                visible: widget.item.mechanism != "OFFLINE KUNJUNGAN" &&
                    widget.item.status == "CONFIRMED",
                child: InkWell(
                  child: Text(
                    'Share Link',
                    style: TextStyle(
                      fontSize: isHorizontal ? 15.sp : 12.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () {
                    print("Training link : ${widget.item.invitationTraining}");
                    SocialSharingPlus.shareToSocialMedia(
                      SocialPlatform.whatsapp,
                      widget.item.invitationTraining ?? "",
                    );
                  },
                ),
              ),
              if (widget.item.status == "APPROVE")
                InkWell(
                  child: Text(
                    'Confirm Schedule',
                    style: TextStyle(
                      fontSize: isHorizontal ? 15.sp : 12.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w400,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();

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
                          child: TrainerConfirm(
                            item: widget.item,
                          ),
                        );
                      },
                    );
                  },
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              getDetailStatus(
                isHorizontal,
                context,
                pic: 'Sales Manager',
                picAlias: 'SM',
                picName: widget.item.nameSm!,
                picReason: widget.item.reasonSm!,
                approvalStatus: widget.item.approvalSm!,
                dateApproved: convertDateWithMonthHour(
                  widget.item.dateSm!,
                ),
              ),
              getDetailStatus(
                isHorizontal,
                context,
                pic: 'Brand Manager',
                picAlias: 'BM',
                picName: widget.item.nameAdm!,
                picReason: widget.item.reasonAdm!,
                approvalStatus: widget.item.approvalAdm!,
                dateApproved: convertDateWithMonthHour(
                  widget.item.dateAdm!,
                ),
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
                  ),
                  replacement: SizedBox(
                    width: 5.w,
                  ),
                ),
                Visibility(
                  visible: widget.item.reasonAdm!.length > 0 ? true : false,
                  child: Text(
                    'Catatan BM : ${widget.item.reasonAdm!}',
                    style: TextStyle(
                      fontSize: isHorizontal ? 15.sp : 12.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  replacement: SizedBox(
                    width: 5.w,
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(
          //   height: 5.h,
          // ),
          // Divider(
          //   color: Colors.black54,
          // ),
          // SizedBox(
          //   height: 7.h,
          // ),
          // Center(
          //   child: EasyButton(
          //     idleStateWidget: Text(
          //       "Unduh Pdf",
          //       style: TextStyle(
          //           color: Colors.white,
          //           fontSize: isHorizontal ? 16.sp : 14.sp,
          //           fontWeight: FontWeight.w700),
          //     ),
          //     loadingStateWidget: CircularProgressIndicator(
          //       strokeWidth: 3.0,
          //       valueColor: AlwaysStoppedAnimation<Color>(
          //         Colors.white,
          //       ),
          //     ),
          //     useEqualLoadingStateWidgetDimension: true,
          //     useWidthAnimation: true,
          //     height: isHorizontal ? 40.h : 40.h,
          //     width: isHorizontal ? 90.w : 120.w,
          //     borderRadius: isHorizontal ? 50.r : 30.r,
          //     buttonColor: Colors.blue.shade700,
          //     elevation: 2.0,
          //     contentGap: 6.0,
          //     onPressed: () {},
          //   ),
          // ),
        ],
      ),
    );
  }
}
