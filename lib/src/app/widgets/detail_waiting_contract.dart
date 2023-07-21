import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
// import 'package:sample/src/domain/entities/customer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/domain/entities/customer_noimage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class DetailWaitingContract extends StatefulWidget {
  List<Contract> item;
  int position;
  String reasonSM;
  String reasonAM;
  bool? isNewCust = false;
  dynamic idCustomer;
  String? ttdCustomer = '';
  CustomerNoImage? customer;

  DetailWaitingContract(
    this.item,
    this.position,
    this.reasonSM,
    this.reasonAM, {
    this.isNewCust,
    this.customer,
    this.idCustomer,
    this.ttdCustomer,
  });

  @override
  State<DetailWaitingContract> createState() => _DetailWaitingContractState();
}

class _DetailWaitingContractState extends State<DetailWaitingContract> {
  String? id, role, username, name, divisi;
  late bool _permissionReady;
  late String _localPath;
  final ReceivePort _port = ReceivePort();

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");
      divisi = preferences.getString("divisi");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
    _permissionReady = false;
    _retryRequestPermission();

    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_contract_waiting',
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

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
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
      if (await Permission.storage.request().isGranted) {
        setState(() {
          isPermit = true;
        });
      } else if (await Permission.storage.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.storage.request().isDenied) {
        setState(() {
          isPermit = false;
        });
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
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
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

  donwloadContract(
    String idCust,
    String custName,
    String locatedFile,
  ) async {
    // var url = '$PDFURL/contract_pdf/$idCust';
    var url = '$PDFURL/newcontract_pdf/$idCust';

    await FlutterDownloader.enqueue(
      url: url,
      fileName: "Contract $custName.pdf",
      requiresStorageNotLow: true,
      savedDir: locatedFile,
      showNotification: true,
      openFileFromNotification: true,
    );
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
      padding: EdgeInsets.all(isHorizontal ? 25.r : 15.r),
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
                  widget.item[widget.position].customerShipName != ''
                      ? widget.item[widget.position].customerShipName
                      : widget.customer!.namaUsaha,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isHorizontal ? 27.sp : 15.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.bold,
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
                      widget.item[widget.position].status.contains('Pending') ||
                              widget.item[widget.position].status
                                  .contains('PENDING')
                          ? Colors.grey[600]
                          : widget.item[widget.position].status
                                      .contains('ACTIVE') ||
                                  widget.item[widget.position].status
                                      .contains('active')
                              ? Colors.blue[600]
                              : Colors.red[600],
                  borderRadius:
                      BorderRadius.circular(isHorizontal ? 15.r : 10.r),
                ),
                child: Text(
                  widget.item[widget.position].status,
                  style: TextStyle(
                    fontSize: isHorizontal ? 22.sp : 12.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            widget.item[widget.position].status.contains('Pending') ||
                    widget.item[widget.position].status.contains('PENDING')
                ? 'Pengajuan e-kontrak sedang diproses'
                : widget.item[widget.position].status.contains('ACTIVE') ||
                        widget.item[widget.position].status.contains('active')
                    ? 'Pengajuan e-kontrak diterima'
                    : 'Pengajuan e-kontrak ditolak',
            style: TextStyle(
              fontSize: isHorizontal ? 20.sp : 14.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: widget.item[widget.position].status.contains('Pending') ||
                      widget.item[widget.position].status.contains('PENDING')
                  ? Colors.grey[600]
                  : widget.item[widget.position].status.contains('Accepted') ||
                          widget.item[widget.position].status
                              .contains('ACCEPTED')
                      ? Colors.green[600]
                      : Colors.red[700],
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            'Diajukan tgl : ${convertDateIndo(widget.item[widget.position].dateAdded)}',
            style: TextStyle(
              fontSize: isHorizontal ? 20.sp : 12.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
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
              fontSize: isHorizontal ? 30.sp : 18.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 10.h,
          ),
          Row(
            children: [
              SizedBox(
                width: isHorizontal ? 10.w : 15.w,
              ),
              SizedBox(
                width: isHorizontal ? 30.w : 45.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isHorizontal ? 10.r : 5.r,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius:
                        BorderRadius.circular(isHorizontal ? 10.r : 5.r),
                  ),
                  child: Center(
                    child: Text(
                      'SM',
                      style: TextStyle(
                        fontSize: isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 15.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Manager',
                      style: TextStyle(
                        fontSize: isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      widget.item[widget.position].approvalSm == "0" ||
                              widget.item[widget.position].approvalSm == ''
                          ? 'Menunggu Persetujuan Sales Manager'
                          : widget.item[widget.position].approvalSm == "1"
                              ? 'Disetujui oleh ${capitalize(widget.item[widget.position].salesManager)} ${convertDateWithMonthHour(
                                  widget.item[widget.position].dateApprovalSm,
                                  isPukul: true,
                                )}'
                              : 'Ditolak oleh ${capitalize(widget.item[widget.position].salesManager)} ${convertDateWithMonthHour(
                                  widget.item[widget.position].dateApprovalSm,
                                  isPukul: true,
                                )}',
                      style: TextStyle(
                        fontSize: isHorizontal ? 22.sp : 14.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.justify,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    widget.item[widget.position].approvalSm.contains('2')
                        ? SizedBox(
                            height: isHorizontal ? 8.h : 5.h,
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                    widget.item[widget.position].approvalSm.contains('2')
                        ? Text(
                            'Keterangan : ',
                            style: TextStyle(
                              fontSize: isHorizontal ? 25.sp : 15.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                    widget.item[widget.position].approvalSm.contains('2')
                        ? Text(
                            widget.reasonSM,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 10.h,
          ),
          Row(
            children: [
              SizedBox(
                width: isHorizontal ? 10.w : 15.w,
              ),
              SizedBox(
                width: isHorizontal ? 30.w : 45.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isHorizontal ? 10.r : 5.r,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius:
                        BorderRadius.circular(isHorizontal ? 10.r : 5.r),
                  ),
                  child: Center(
                    child: Text(
                      'AM',
                      style: TextStyle(
                        fontSize: isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 15.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AR Manager',
                      style: TextStyle(
                        fontSize: isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      widget.item[widget.position].approvalAm == "0" ||
                              widget.item[widget.position].approvalSm == ''
                          ? 'Menunggu Persetujuan AR Manager'
                          : widget.item[widget.position].approvalAm == "1"
                              ? 'Disetujui oleh ${capitalize(widget.item[widget.position].arManager)} ${convertDateWithMonthHour(
                                  widget.item[widget.position].dateApprovalAm,
                                  isPukul: true,
                                )}'
                              : 'Ditolak oleh ${capitalize(widget.item[widget.position].arManager)} ${convertDateWithMonthHour(
                                  widget.item[widget.position].dateApprovalAm,
                                  isPukul: true,
                                )}',
                      style: TextStyle(
                        fontSize: isHorizontal ? 22.sp : 14.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.justify,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    widget.item[widget.position].approvalAm.contains('2')
                        ? SizedBox(
                            height: isHorizontal ? 8.h : 5.h,
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                    widget.item[widget.position].approvalAm.contains('2')
                        ? Text(
                            'Keterangan : ',
                            style: TextStyle(
                              fontSize: isHorizontal ? 25.sp : 15.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                    widget.item[widget.position].approvalAm.contains('2')
                        ? Text(
                            widget.reasonAM,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.h,
          ),
          !widget.item[widget.position].status.contains('ACTIVE')
              ? Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      primary: Colors.orange[800],
                      padding: EdgeInsets.symmetric(
                          horizontal: isHorizontal ? 40.r : 20.r,
                          vertical: 10.r),
                    ),
                    child: Text(
                      'Detail Kontrak',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Segoe ui',
                      ),
                    ),
                    onPressed: () {
                      //Loloskan kontrak yang masih pending untuk view detail kontrak (req harmanto)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailContract(
                            widget.item[widget.position],
                            divisi!,
                            widget.ttdCustomer!,
                            username!,
                            true,
                            isContract: true,
                            isAdminRenewal: true,
                            isNewCust: false,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ArgonButton(
                      height: 40,
                      width: 120,
                      borderRadius: 30.0,
                      color: Colors.blue[700],
                      child: Text(
                        "Unduh Kontrak",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                      loader: Container(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      onTap: (startLoading, stopLoading, btnState) {
                        if (btnState == ButtonState.Idle) {
                          if (_permissionReady) {
                            donwloadContract(
                                widget.item[widget.position].idCustomer,
                                widget.customer!.namaUsaha,
                                _localPath);
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        primary: Colors.red[800],
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Tutup',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
