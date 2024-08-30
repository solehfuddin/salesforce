import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_detail.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/settings_posmaterial.dart';
import 'package:sample/src/domain/entities/posmaterial_header.dart';

// ignore: must_be_immutable
class PosMaterialDialogStatus extends StatefulWidget {
  PosMaterialHeader item;
  PosMaterialDialogStatus({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<PosMaterialDialogStatus> createState() =>
      _PosMaterialDialogStatusState();
}

class _PosMaterialDialogStatusState extends State<PosMaterialDialogStatus> {
  bool _permissionReady = false;
  late String _localPath;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _retryRequestPermission();

    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_posmaterial',
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

  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');

    if (send != null) {
      send.send([id, status, progress]);
    }
  }

  Future<void> _retryRequestPermission() async {
    final hasGranted = await _checkPermission();
    if (hasGranted) {
      await _prepareSaveDir();
    }

    setState(() {
      _permissionReady = hasGranted;
    });
  }

  Future<bool> _checkPermission() async {
    if (Platform.isIOS) {
      return true;
    }

    bool isPermit = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      late final Map<Permission, PermissionStatus> statusess;

      if (androidInfo.version.sdkInt < 33) {
        statusess = await [Permission.storage].request();
      } else {
        statusess =
            await [Permission.notification, Permission.mediaLibrary].request();
      }

      var allAccepted = true;
      statusess.forEach((permission, status) {
        if (status != PermissionStatus.granted) {
          allAccepted = false;
        }
      });

      if (allAccepted) {
        setState(() {
          isPermit = true;
        });
      } else {
        await openAppSettings();
      }
    }
    return isPermit;
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    final savedDir = Directory(_localPath);
    final hasExisted = savedDir.existsSync();
    if (!hasExisted) {
      await savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    String? externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        final directory = Directory('/storage/emulated/0/Download');
        externalStorageDirPath = directory.path;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  onButtonPressed() async {
    if (_permissionReady) {
      donwloadPdfPOS(
        widget.item.id ?? '',
        widget.item.opticName ?? 'Optik',
        _localPath,
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

    return () {};
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
            setPosStatus(
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
                  'Detail POS',
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
                      builder: (context) => PosMaterialDetail(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDetailStatus(
                isHorizontal,
                context,
                pic: 'Sales Manager',
                picAlias: 'SM',
                picName: widget.item.smName!,
                picReason: widget.item.reasonSm!,
                approvalStatus: widget.item.approvalSm!,
                dateApproved: convertDateWithMonthHour(
                  widget.item.dateApprovelSm!,
                ),
              ),
              getDetailStatus(
                isHorizontal,
                context,
                pic: 'Brand Manager',
                picAlias: 'BM',
                picName: widget.item.admName!,
                picReason: widget.item.reasonAdm!,
                approvalStatus: widget.item.approvalAdm!,
                dateApproved: convertDateWithMonthHour(
                  widget.item.dateApprovelAdm!,
                ),
              ),
              getDetailStatus(
                isHorizontal,
                context,
                pic: 'General Manager',
                picAlias: 'GM',
                picName: widget.item.gmName!,
                picReason: widget.item.reasonGm!,
                approvalStatus: widget.item.approvalGm!,
                dateApproved: convertDateWithMonthHour(
                  widget.item.dateApprovelGm!,
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
                Visibility(
                  visible: widget.item.reasonGm!.length > 0 ? true : false,
                  child: Text(
                    'Catatan GM : ${widget.item.reasonGm!}',
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
            child: EasyButton(
              idleStateWidget: Text(
                "Unduh Pdf",
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
              onPressed: onButtonPressed,
            ),
          ),
        ],
      ),
    );
  }
}
