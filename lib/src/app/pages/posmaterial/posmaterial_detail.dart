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
import 'package:sample/src/app/utils/settings_posmaterial.dart';
import 'package:sample/src/domain/entities/posmaterial_attachment.dart';
import 'package:sample/src/domain/entities/posmaterial_header.dart';
import 'package:sample/src/domain/entities/posmaterial_review.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/posmaterial_lineposter.dart';

// ignore: must_be_immutable
class PosMaterialDetail extends StatefulWidget {
  PosMaterialHeader item;
  bool? isAdmin;

  PosMaterialDetail({
    Key? key,
    required this.item,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<PosMaterialDetail> createState() => _PosMaterialDetailState();
}

class _PosMaterialDetailState extends State<PosMaterialDetail> {
  List<PosMaterialLinePoster> listLinePoster = List.empty(growable: true);
  TextEditingController txtReason = new TextEditingController();
  ServicePosMaterial service = new ServicePosMaterial();
  Future<PosMaterialAttachment>? attachment;
  Future<PosMaterialReview>? review;

  bool _permissionReady = false;
  bool _isHorizontal = false;
  late String _localPath;
  final ReceivePort _port = ReceivePort();
  String? id, name, username, role, divisi;
  String? idSales, nameSales, tokenSales;

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

    getRole();
    getSalesToken(widget.item.id!);
    callReview(
      widget.item.shipNumber!,
      int.parse(widget.item.price!),
    );

    if (widget.item.posType == 'POSTER') {
      service
          .getPosMaterialLine(context, mounted, widget.item.id ?? "")
          .then((value) {
        setState(() {
          listLinePoster = value;
        });
      });
    }
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
            await [Permission.notification, Permission.photos].request();
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

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      name = preferences.getString("name");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");

      callAttachment();
    });
  }

  getSalesToken(String idPos) {
    service
        .generateTokenSales(context: context, idPosMaterial: idPos)
        .then((value) {
      idSales = value.id;
      nameSales = value.name;
      tokenSales = value.token;
    });
  }

  void callAttachment() {
    attachment = service.getPosMaterialAttachment(
      context,
      mounted,
      widget.item.id!,
    );
  }

  void callReview(String shipNumber, int priceEstimate) {
    review = service.getReviewPos(
      isHorizontal: false,
      mounted: mounted,
      context: context,
      shipNumber: shipNumber,
      priceEstimate: priceEstimate,
    );
  }

  void callApprove(BuildContext context, String _idPos) {
    if (role == 'ADMIN' && divisi == 'SALES') {
      service.approvePos(
        context: context,
        isHorizontal: false,
        mounted: mounted,
        idPos: _idPos,
        idSales: idSales ?? '',
        nameSales: nameSales ?? '',
        tokenSales: tokenSales ?? '',
        opticName: widget.item.opticName!,
        managerName: name ?? '',
        approverSm: username ?? '',
      );
    }

    if (role == 'ADMIN' && divisi == 'MARKETING') {
      service.approvePos(
        context: context,
        isHorizontal: false,
        mounted: mounted,
        idPos: _idPos,
        idSales: idSales ?? '',
        nameSales: nameSales ?? '',
        tokenSales: tokenSales ?? '',
        opticName: widget.item.opticName!,
        managerName: name ?? '',
        approverBm: username ?? '',
      );
    }

    if (role == 'ADMIN' && divisi == 'GM') {
      service.approvePos(
        context: context,
        isHorizontal: false,
        mounted: mounted,
        idPos: _idPos,
        idSales: idSales ?? '',
        nameSales: nameSales ?? '',
        tokenSales: tokenSales ?? '',
        opticName: widget.item.opticName!,
        managerName: name ?? '',
        approverGm: username ?? '',
      );
    }
  }

  void callReject(
    BuildContext context,
    bool isHorizontal,
    String _idPos,
  ) {
    if (txtReason.text.isNotEmpty) {
      if (role == 'ADMIN' && divisi == 'SALES') {
        service.rejectPos(
          context: context,
          isHorizontal: false,
          mounted: mounted,
          idPos: _idPos,
          idSales: idSales ?? '',
          nameSales: nameSales ?? '',
          tokenSales: tokenSales ?? '',
          opticName: widget.item.opticName!,
          managerName: name!,
          approverSm: username ?? '',
          reasonSm: txtReason.text,
        );
      }

      if (role == 'ADMIN' && divisi == 'MARKETING') {
        service.rejectPos(
          context: context,
          isHorizontal: false,
          mounted: mounted,
          idPos: _idPos,
          idSales: idSales ?? '',
          nameSales: nameSales ?? '',
          tokenSales: tokenSales ?? '',
          opticName: widget.item.opticName!,
          managerName: name!,
          approverBm: username ?? '',
          reasonBm: txtReason.text,
        );
      }

      if (role == 'ADMIN' && divisi == 'GM') {
        service.rejectPos(
          context: context,
          isHorizontal: false,
          mounted: mounted,
          idPos: _idPos,
          idSales: idSales ?? '',
          nameSales: nameSales ?? '',
          tokenSales: tokenSales ?? '',
          opticName: widget.item.opticName!,
          managerName: name!,
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

  onPressedReject() async {
    handleRejection(
      context,
      isHorizontal: _isHorizontal,
      idPos: widget.item.id!,
    );

    return () {};
  }

  onPressedApprove() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
      () => callApprove(
        context,
        widget.item.id!,
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

  Widget childWidget({bool isHorizontal = false}) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity.w,
              height: isHorizontal ? 200.h : 220.h,
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
                    'assets/images/banner_pos.png',
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
                      Text(
                        'Diajukan ${widget.item.salesName} - ${convertDateWithMonth(widget.item.insertDate!)}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: isHorizontal ? 15.sp : 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            6.r,
                          ),
                          border: Border.all(
                            color: getPosColor(
                              setPosType(
                                widget.item.posType!,
                              ),
                            ),
                          ),
                        ),
                        padding: EdgeInsets.all(
                          isHorizontal ? 8.r : 4.r,
                        ),
                        child: Text(
                          widget.item.posType! == "KEMEJA_LEINZ_HIJAU" ? "KEMEJA_LEINZ": widget.item.posType!,
                          style: TextStyle(
                            fontSize: isHorizontal ? 14.sp : 12.sp,
                            fontFamily: 'Montserrat',
                            color: getPosColor(
                              setPosType(
                                widget.item.posType!,
                              ),
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Divider(
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    'Data optik',
                    style: TextStyle(
                      fontSize: isHorizontal ? 18.sp : 16.sp,
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 15.h : 10.h,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 5.w,
                        ),
                        VerticalDivider(
                          color: Colors.grey[600],
                          thickness: isHorizontal ? 5 : 3.5,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                'Nama optik : ',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: isHorizontal ? 14.sp : 12.sp,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              Text(
                                widget.item.opticName!,
                                style: TextStyle(
                                  fontFamily: 'Segoe ui',
                                  fontSize: isHorizontal ? 14.sp : 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tipe kustomer : ',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: isHorizontal ? 14.sp : 12.sp,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Nomor Akun : ',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: isHorizontal ? 14.sp : 12.sp,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${widget.item.opticType!} CUSTOMER',
                                    style: TextStyle(
                                      fontSize: isHorizontal ? 14.sp : 12.sp,
                                      fontFamily: 'Segoe ui',
                                      fontWeight: FontWeight.w600,
                                      color: getCustomerColor(
                                        widget.item.opticType!,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    widget.item.shipNumber!,
                                    style: TextStyle(
                                      fontSize: isHorizontal ? 14.sp : 12.sp,
                                      fontFamily: 'Segoe ui',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                'Alamat optik : ',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: isHorizontal ? 14.sp : 12.sp,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              Text(
                                widget.item.opticAddress!,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: isHorizontal ? 15.sp : 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Text(
                    'Pos material ${widget.item.posType!.replaceAll('_', ' ').toLowerCase()}',
                    style: TextStyle(
                      fontSize: isHorizontal ? 18.sp : 16.sp,
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w600,
                      color: getPosColor(
                        setPosType(
                          widget.item.posType!,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Visibility(
                    visible: listLinePoster.isNotEmpty,
                    child: FutureBuilder(
                      future: service.getPosMaterialLine(
                        context,
                        mounted,
                        widget.item.id ?? "",
                      ),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<PosMaterialLinePoster>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data!.isNotEmpty) {
                            double noteHeight = widget.item.notes!.isNotEmpty ? 70.h : 0.h;
                            return SizedBox(
                              height: 95.h * snapshot.data!.length + 35.h + noteHeight,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  VerticalDivider(
                                    color: getPosColor(
                                        setPosType("POSTER")),
                                    thickness: isHorizontal ? 5 : 3.5,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: snapshot.data?.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return detailPosPosterLine(
                                              isHorizontal: isHorizontal,
                                              item: snapshot.data?[index],
                                            );
                                          },
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                            vertical: isHorizontal ? 10.h : 5.h,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Metode pengiriman :',
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: isHorizontal
                                                          ? 14.sp
                                                          : 12.sp,
                                                      color:
                                                          Colors.grey.shade400,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Estimasi Harga :',
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: isHorizontal
                                                          ? 14.sp
                                                          : 12.sp,
                                                      color:
                                                          Colors.grey.shade400,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    widget.item.deliveryMethod!,
                                                    style: TextStyle(
                                                      fontFamily: 'Segoe ui',
                                                      fontSize: isHorizontal
                                                          ? 16.sp
                                                          : 14.sp,
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    widget.item.posterDesignOnly ==
                                                            '0'
                                                        ? widget.item
                                                                    .priceAdjustment !=
                                                                '0'
                                                            ? convertToIdr(
                                                                int.parse(widget
                                                                    .item
                                                                    .priceAdjustment!),
                                                                0)
                                                            : convertToIdr(
                                                                int.parse(widget
                                                                    .item
                                                                    .price!),
                                                                0)
                                                        : '0',
                                                    style: TextStyle(
                                                      fontFamily: 'Segoe ui',
                                                      fontSize: isHorizontal
                                                          ? 16.sp
                                                          : 14.sp,
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              Visibility(
                                                visible: widget
                                                        .item.notes!.isNotEmpty
                                                    ? true
                                                    : false,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Catatan :',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: isHorizontal
                                                            ? 14.sp
                                                            : 12.sp,
                                                        color: Colors
                                                            .grey.shade400,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 3.h,
                                                    ),
                                                    Text(
                                                      widget.item.notes!,
                                                      style: TextStyle(
                                                        fontFamily: 'Segoe ui',
                                                        fontSize: isHorizontal
                                                            ? 16.sp
                                                            : 14.sp,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5.h,
                                                    ),
                                                  ],
                                                ),
                                                replacement: SizedBox(
                                                  width: 5.w,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return SizedBox(
                              width: 5.w,
                            );
                          }
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                    replacement: IntrinsicHeight(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5.w,
                          ),
                          VerticalDivider(
                            color: getPosColor(setPosType(widget.item.posType)),
                            thickness: isHorizontal ? 5 : 3.5,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(
                            child: getDetailPos(
                              isHorizontal: isHorizontal,
                              item: widget.item,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Divider(
                    color: Colors.grey.shade400,
                  ),
                  Visibility(
                    visible: widget.item.posterDesignOnly == '0' ? true : false,
                    child: FutureBuilder(
                      future: review,
                      builder: (BuildContext context,
                          AsyncSnapshot<PosMaterialReview> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data!.posEstimation! > 0) {
                            return posReview(
                              snapshot.data!.review ?? '',
                              snapshot.data!.status!,
                            );
                          } else {
                            return SizedBox(
                              width: 5.w,
                            );
                          }
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                    replacement: posReview(
                      'Hanya desain, biaya pencetakan ditanggung optik.',
                      true,
                    ),
                  ),
                  FutureBuilder(
                    future: attachment,
                    builder: (BuildContext context,
                        AsyncSnapshot<PosMaterialAttachment> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data!.id!.isNotEmpty) {
                          return posLampiranWidget(
                            isHor: isHorizontal,
                            context: context,
                            attachment: snapshot.data,
                          );
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/not_found.png',
                                  width: isHorizontal ? 150.w : 200.w,
                                  height: isHorizontal ? 150.h : 200.h,
                                ),
                              ),
                              Text(
                                'Data tidak ditemukan',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 14.sp : 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          );
                        }
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
                    visible: widget.isAdmin!,
                    child: handleAction(),
                    replacement: SizedBox(
                      width: 5.w,
                    ),
                    // replacement: Center(
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
                    //     height: isHorizontal ? 50.h : 40.h,
                    //     width: isHorizontal ? 90.w : 150.w,
                    //     borderRadius: 30.r,
                    //     buttonColor: Colors.blue.shade700,
                    //     elevation: 2.0,
                    //     contentGap: 6.0,
                    //     onPressed: onButtonPressed,
                    //   ),
                    // ),
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
    _isHorizontal = isHorizontal;
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
            buttonColor: Colors.blue.shade700,
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
