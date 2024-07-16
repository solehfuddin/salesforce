import 'dart:isolate';
import 'dart:ui';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_detail.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/settings_marketingexpense.dart';
import 'package:sample/src/domain/entities/marketingexpense_header.dart';

// ignore: camel_case_types, must_be_immutable
class Marketingexpense_Dialogstatus extends StatefulWidget {
  MarketingExpenseHeader item;
  Marketingexpense_Dialogstatus({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<Marketingexpense_Dialogstatus> createState() =>
      _Marketingexpense_DialogstatusState();
}

// ignore: camel_case_types
class _Marketingexpense_DialogstatusState
    extends State<Marketingexpense_Dialogstatus> {
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    meController.retryRequestPermission();

    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_marketingexpense',
    );

    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      setState(() {
        print("Id : $id");
        print("Status : $status");
        print("Progress : $progress");
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');

    if (send != null) {
      send.send([id, status, progress]);
    }
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
            setMEStatus(
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
              InkWell(
                child: Text(
                  'Detail ME',
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
                      builder: (context) => Marketingexpense_Detail(
                        item: widget.item,
                        isAdmin: false,
                      ),
                    ),
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
                picName: widget.item.smName!,
                picReason: widget.item.reasonSM!,
                approvalStatus: widget.item.approvalSM!,
                dateApproved: convertDateWithMonthHour(
                  widget.item.dateApprovalSM!,
                ),
              ),
              getDetailStatus(
                isHorizontal,
                context,
                pic: 'General Manager',
                picAlias: 'GM',
                picName: widget.item.gmName!,
                picReason: widget.item.reasonGM!,
                approvalStatus: widget.item.approvalGM!,
                dateApproved: convertDateWithMonthHour(
                  widget.item.dateApprovalGM!,
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
                  visible: widget.item.reasonSM!.length > 0 ? true : false,
                  child: Text(
                    'Catatan SM : ${widget.item.reasonSM!}',
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
                  visible: widget.item.reasonGM!.length > 0 ? true : false,
                  child: Text(
                    'Catatan GM : ${widget.item.reasonGM!}',
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
            child: ArgonButton(
              height: isHorizontal ? 40.h : 40.h,
              width: isHorizontal ? 90.w : 120.w,
              borderRadius: isHorizontal ? 50.r : 30.r,
              color: Colors.blue[700],
              child: Text(
                "Unduh Pdf",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 16.sp : 14.sp,
                    fontWeight: FontWeight.w700),
              ),
              loader: Container(
                padding: EdgeInsets.all(8.r),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              onTap: (startLoading, stopLoading, btnState) {
                if (btnState == ButtonState.Idle) {
                  if (meController.permissionReady.value) {
                    donwloadPdfME(
                      widget.item.id ?? '',
                      widget.item.opticName ?? 'Optik',
                      meController.localPath.value,
                    );

                    showStyledToast(
                      child: Text('Sedang mengunduh file'),
                      context: context,
                      backgroundColor: Colors.blue,
                      borderRadius: BorderRadius.circular(15.r),
                      duration: Duration(seconds: 2),
                    );
                  } else {
                    showStyledToast(
                      child: Text('Tidak mendapat izin penyimpanan'),
                      context: context,
                      backgroundColor: Colors.red,
                      borderRadius: BorderRadius.circular(15.r),
                      duration: Duration(seconds: 2),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
