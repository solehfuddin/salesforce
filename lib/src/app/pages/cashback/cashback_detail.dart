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
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/settings_cashback.dart';
import 'package:sample/src/domain/entities/cashback_attachment.dart';
import 'package:sample/src/domain/entities/cashback_header.dart';
import 'package:sample/src/domain/entities/cashback_line.dart';
import 'package:sample/src/domain/service/service_cashback.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CashbackDetail extends StatefulWidget {
  CashbackHeader? itemHeader;
  bool isSales;
  bool showDownload;

  CashbackDetail({
    Key? key,
    required this.isSales,
    this.itemHeader,
    this.showDownload = true,
  }) : super(key: key);

  @override
  State<CashbackDetail> createState() => _CashbackDetailState();
}

class _CashbackDetailState extends State<CashbackDetail> {
  TextEditingController txtReason = new TextEditingController();
  ServiceCashback cashback = new ServiceCashback();
  List<String> selectedTargetProddiv = List.empty(growable: true);
  Future<List<CashbackLine>>? selectedProductLine;
  late Future<CashbackAttachment> cashbackAttachment;
  List<CashbackLine> selectedLine = List.empty(growable: true);

  String? id, name, username, role, divisi;
  String? idSales, nameSales, tokenSales;
  bool _permissionReady = false;
  bool _isHorizontal = false;
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

    getRole();
    getSalesToken(widget.itemHeader?.id ?? '');
    FlutterDownloader.registerCallback(downloadCallback);

    if (widget.itemHeader!.targetProduct!.isNotEmpty) {
      selectedTargetProddiv = widget.itemHeader!.targetProduct!.split(",");
    }

    print(widget.itemHeader!.id);

    selectedProductLine = cashback.getCashbackLine(
      context,
      isMounted: mounted,
      cashbackId: widget.itemHeader!.id ?? '',
    );

    cashbackAttachment = cashback.getAttachment(context,
        isMounted: mounted, idCashback: widget.itemHeader?.id ?? '');
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      name = preferences.getString("name");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");
    });
  }

  getSalesToken(String idCashback) {
    cashback
        .generateTokenSales(context: context, idCashback: idCashback)
        .then((value) {
      idSales = value.id;
      nameSales = value.name;
      tokenSales = value.token;
    });
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
        // externalStorageDirPath = await AndroidPathProvider.downloadsPath;
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

  void callApprove(BuildContext context, String _idCashback) {
    if (role == 'ADMIN' && divisi == 'SALES') {
      cashback.approveCashback(
        context: context,
        idCashback: _idCashback,
        idSales: idSales ?? '',
        nameSales: nameSales ?? '',
        tokenSales: tokenSales ?? '',
        opticName: widget.itemHeader?.opticName ?? '',
        managerName: name ?? '',
        approverSm: username ?? '',
      );
    }

    if (role == 'ADMIN' && divisi == 'GM') {
      cashback.approveCashback(
        context: context,
        idCashback: _idCashback,
        idSales: idSales ?? '',
        nameSales: nameSales ?? '',
        tokenSales: tokenSales ?? '',
        opticName: widget.itemHeader?.opticName ?? '',
        managerName: name ?? '',
        approverGm: username ?? '',
      );
    }
  }

  void callReject(
    BuildContext context,
    bool isHorizontal,
    String _idCashback,
  ) {
    if (txtReason.text.isNotEmpty) {
      if (role == 'ADMIN' && divisi == 'SALES') {
        cashback.rejectCashback(
          context: context,
          isHorizontal: false,
          mounted: mounted,
          idCashback: _idCashback,
          idSales: idSales ?? '',
          nameSales: nameSales ?? '',
          tokenSales: tokenSales ?? '',
          opticName: widget.itemHeader?.opticName ?? '',
          managerName: name!,
          approverSm: username ?? '',
          reasonSm: txtReason.text,
        );
      }

      if (role == 'ADMIN' && divisi == 'GM') {
        cashback.rejectCashback(
          context: context,
          idCashback: _idCashback,
          idSales: idSales ?? '',
          nameSales: nameSales ?? '',
          tokenSales: tokenSales ?? '',
          opticName: widget.itemHeader?.opticName ?? '',
          managerName: name ?? '',
          approverGm: username ?? '',
          reasonGm: txtReason.text,
        );
      }
    } else {
      handleStatus(
        context,
        'Harap lengkapi data terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    }
  }

  onPressedDownload() async {
    if (_permissionReady) {
      donwloadPdfCashback(
        widget.itemHeader?.id ?? '',
        widget.itemHeader?.opticName ?? 'Optik',
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

  onPressedReject() async {
    handleRejection(
      context,
      isHorizontal: _isHorizontal,
      idPos: widget.itemHeader?.id ?? '',
    );

    return () {};
  }

  onPressedApprove() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
      () => callApprove(
        context,
        widget.itemHeader?.id ?? '',
      ),
    );
    return () {};
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 &&
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(isHorizontal: true);
      }
      return childWidget(isHorizontal: false);
    });
  }

  Widget childWidget({
    bool isHorizontal = false,
  }) {
    _isHorizontal = isHorizontal;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity.w,
              height: isHorizontal ? 200.h : 230.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25.r),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: isHorizontal ? 20.r : 15.r,
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(CircleBorder()),
                        padding: MaterialStateProperty.all(EdgeInsets.all(8.r)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/cashback_banner.png',
                  ),
                  fit: isHorizontal ? BoxFit.cover : BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 30.w : 15.w,
                vertical: isHorizontal ? 20.h : 10.h,
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
                          widget.itemHeader!.id ?? '',
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tipe cashback : ${capitalize(widget.itemHeader!.cashbackType!.toLowerCase())}',
                        style: TextStyle(
                          fontSize: isHorizontal ? 14.sp : 12.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        convertDateWithMonth(
                          widget.itemHeader!.insertDate!,
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
                        visible: !widget.isSales,
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
                                  widget.itemHeader!.salesName!,
                                ),
                                style: TextStyle(
                                  fontSize: isHorizontal ? 13.sp : 11.sp,
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
                        visible: !widget.isSales,
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
                              widget.itemHeader!.status ?? '',
                            ),
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          widget.itemHeader!.status ?? '',
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
                  SizedBox(
                    height: 2.h,
                  ),
                  Divider(
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  cashbackDetailOptikWidget(
                    isHorizontal: isHorizontal,
                    itemHeader: widget.itemHeader,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  cashbackDetailPemilikWidget(
                    isHorizontal: isHorizontal,
                    itemHeader: widget.itemHeader,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  cashbackDetailKontrakWidget(
                    isHorizontal: isHorizontal,
                    itemHeader: widget.itemHeader,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  cashbackLineTargetWidget(
                    isHorizontal: isHorizontal,
                    itemHeader: widget.itemHeader,
                    selectedTargetProddiv: selectedTargetProddiv,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  cashbackLineProductWidget(
                    isHorizontal: isHorizontal,
                    itemHeader: widget.itemHeader,
                    selectedProductLine: selectedProductLine,
                  ),
                  FutureBuilder(
                    future: cashbackAttachment,
                    builder: (_, AsyncSnapshot<CashbackAttachment> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return cashbackLampiranWidget(
                            isHor: isHorizontal,
                            context: context,
                            attachmentSign: snapshot.data?.attachmentSign ?? '',
                            attchmentOther:
                                snapshot.data?.attachmentOther ?? '',
                          );
                        } else {
                          return cashbackLampiranWidget(
                            isHor: isHorizontal,
                            context: context,
                            attachmentSign: '',
                            attchmentOther: '',
                          );
                        }
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 35.h,
                  ),
                  Visibility(
                    visible: widget.showDownload,
                    replacement: handleAction(),
                    child: Center(
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
                        height: isHorizontal ? 50.h : 40.h,
                        width: isHorizontal ? 90.w : 150.w,
                        borderRadius: 30.r,
                        buttonColor: Colors.blue.shade700,
                        elevation: 2.0,
                        contentGap: 6.0,
                        onPressed: onPressedDownload,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget handleAction({bool isHorizontal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 30.r : 20.r,
            vertical: 5.r,
          ),
          alignment: Alignment.centerRight,
          child: EasyButton(
            idleStateWidget: Text(
              "Reject",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 24.sp : 14.sp,
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
            height: isHorizontal ? 60.h : 40.h,
            width: isHorizontal ? 80.w : 100.w,
            borderRadius: isHorizontal ? 60.r : 30.r,
            buttonColor: Colors.red.shade700,
            elevation: 2.0,
            contentGap: 6.0,
            onPressed: onPressedReject,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 30.r : 20.r,
            vertical: 5.r,
          ),
          alignment: Alignment.centerRight,
          child: EasyButton(
            idleStateWidget: Text(
              "Approve",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 24.sp : 14.sp,
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
            height: isHorizontal ? 60.h : 40.h,
            width: isHorizontal ? 80.w : 100.w,
            borderRadius: isHorizontal ? 60.r : 30.r,
            buttonColor: Colors.blue.shade600,
            elevation: 2.0,
            contentGap: 6.0,
            onPressed: onPressedApprove,
          ),
        ),
      ],
    );
  }

  handleRejection(BuildContext context,
      {bool isHorizontal = false, String idPos = ''}) {
    AlertDialog alert = AlertDialog(
      scrollable: true,
      title: Center(
        child: Text(
          "Mengapa kontrak tidak disetujui ?",
          style: TextStyle(
            fontSize: isHorizontal ? 20.sp : 14.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
                errorText: txtReason.text.isEmpty ? 'Data wajib diisi' : null,
              ),
              keyboardType: TextInputType.multiline,
              minLines: isHorizontal ? 3 : 4,
              maxLines: isHorizontal ? 4 : 5,
              maxLength: 100,
              controller: txtReason,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Ok',
            style: TextStyle(
              fontSize: isHorizontal ? 22.sp : 14.sp,
            ),
          ),
          onPressed: () {
            callReject(
              context,
              isHorizontal,
              idPos,
            );
          },
        ),
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: isHorizontal ? 22.sp : 14.sp,
            ),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alert,
      barrierDismissible: false,
    );
  }
}
