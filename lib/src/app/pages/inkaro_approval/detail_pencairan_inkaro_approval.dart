import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:http/http.dart' as http;
import 'package:sample/src/domain/entities/list_pencairan_inkaro_detail.dart';
import 'package:sample/src/domain/entities/list_pencairan_inkaro_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class DetailPencairanInkaroApproval extends StatefulWidget {
  ListPencairanInkaroHeader inkaroPencairanHeader;
  bool? isPending = true;

  DetailPencairanInkaroApproval(
    this.inkaroPencairanHeader, {
    this.isPending,
  });

  @override
  State<DetailPencairanInkaroApproval> createState() =>
      _DetailPencairanInkaroApprovalState();
}

class _DetailPencairanInkaroApprovalState
    extends State<DetailPencairanInkaroApproval> {
  String search = '';
  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';
  String? divisi = '';

  String namaUsaha = '';
  String namaPJ = '';
  String telpPJ = '';
  String alamatUsaha = '';
  bool _isHorizontal = false;
  bool _isLoading = true;
  late String tokenSales;

  late bool _permissionReady;
  late String _localPath;
  final ReceivePort _port = ReceivePort();

  final format = DateFormat("dd MMM yyyy");
  var thisYear, nextYear;

  List<ListPencairanInkaroDetail> listPencairanInkaroDetail =
      List.empty(growable: true);

  TextEditingController textReason = new TextEditingController();
  bool _isReason = false;

  getListInkaro() async {
    const timeout = 15;
    var url =
        '$API_URL/inkaro/getPencairanInkaroDetail?id_pencairan_inkaro_header=${widget.inkaroPencairanHeader.nomorPencairan}&id_optik=${widget.inkaroPencairanHeader.shipNumberOptik}';
    print(url);
    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      try {
        var data = convert.json.decode(response.body);
        final bool sts = data['status'];
        if (sts) {
          var rest = data['data'];
          setState(() {
            listPencairanInkaroDetail = rest
                .map<ListPencairanInkaroDetail>(
                    (json) => ListPencairanInkaroDetail.fromJson(json))
                .toList();
          });
        }

        print(data['data']);

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
          });
        });
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  getSalesToken(int input) async {
    const timeout = 15;
    var url = '$API_URL/users?id=$input';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = convert.json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          tokenSales = data['data']['gentoken'];
          print('Token sales : $tokenSales');
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleConnectionAdmin(context);
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  approvalInkaro(
    String idPencairan,
    String approvalStatus,
    String approvalReason,
    String approver, {
    bool isHorizontal = false,
  }) async {
    const timeout = 15;
    var url = divisi == 'AR'
        ? '$API_URL/inkaro/approvalAMPencairanInkaro'
        : '$API_URL/inkaro/approvalSMPencairanInkaro';
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {"api-key-trl": API_KEY},
        body: {
          'id_pencairan': idPencairan,
          'approval_status': approvalStatus,
          'approval_reason': approvalReason,
          'approver': approver,
        },
      ).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = convert.json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (sts) {
          //Approve Kontrak
          handleStatus(
            context,
            capitalize(msg),
            sts,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        } else {
          handleStatus(
            context,
            msg,
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
        if (mounted) {
          handleStatus(
            context,
            e.toString(),
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : $e');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      }
    }
  }

  handleRejection(BuildContext context, {bool isHorizontal = false}) {
    AlertDialog alert = AlertDialog(
      scrollable: true,
      title: Center(
        child: Text(
          "Mengapa inkaro tidak disetujui ?",
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
                errorText: !_isReason ? 'Data wajib diisi' : null,
              ),
              keyboardType: TextInputType.multiline,
              minLines: isHorizontal ? 3 : 4,
              maxLines: isHorizontal ? 4 : 5,
              maxLength: 100,
              controller: textReason,
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
            approvalInkaro(
              widget.inkaroPencairanHeader.pencairanInkaroId,
              "REJECT",
              textReason.text,
              id!,
              isHorizontal: isHorizontal,
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

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");
      divisi = preferences.getString("divisi");

      var formatter = new DateFormat('yyyy');
      thisYear = formatter.format(DateTime.now());
      nextYear = int.parse(thisYear) + 1;

      print('This Year : $thisYear');
      print('Next Year : $nextYear');

      print("Dashboard : $role");
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      getRole();
      getListInkaro();
    });
  }

  onPressedDownload() async {
    if (_permissionReady) {
      downloadPencairanInkaro(
        widget.inkaroPencairanHeader.nomorPencairan,
        widget.inkaroPencairanHeader.shipNumberOptik,
        _localPath,
      );
      showStyledToast(
        child:
            Text('Sedang mengunduh file'),
        context: context,
        backgroundColor: Colors.blue,
        borderRadius:
            BorderRadius.circular(15.r),
        duration: Duration(seconds: 2),
      );
    } else {
      showStyledToast(
        child: Text(
            'Tidak mendapat izin penyimpanan'),
        context: context,
        backgroundColor: Colors.red,
        borderRadius:
            BorderRadius.circular(15.r),
        duration: Duration(seconds: 2),
      );
    }

    return () {};
  }

  onPressedReject() async {
    handleRejection(
      context,
      isHorizontal: _isHorizontal,
    );

    return () {};
  }

  onPressedApprove() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
      () => approvalInkaro(
        widget.inkaroPencairanHeader.pencairanInkaroId,
        "APPROVE",
        "",
        id!,
        isHorizontal: _isHorizontal,
      ),
    );

    return () {};
  }

  @override
  void initState() {
    _permissionReady = false;
    _retryRequestPermission();

    super.initState();
    getRole();
    getListInkaro();

    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_customer',
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
    // send.send([id, status, progress]);

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

  downloadPencairanInkaro(
    String idPencairan,
    String shipNumber,
    String locatedFile,
  ) async {
    var url =
        '$WEBADMIN/inkaro_result/dokumenpencairan_pdf/?idPencairan=$idPencairan&shipNumber=$shipNumber';
    print(url);
    await FlutterDownloader.enqueue(
      url: url,
      fileName: "Pencairan Inkaro $idPencairan ($shipNumber).pdf",
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
        return masterChild(isHor: true);
      }

      return masterChild(isHor: false);
    });
  }

  Widget masterChild({bool isHor = false}) {
    _isHorizontal = isHor;
    
    return Scaffold(
      body: RefreshIndicator(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity.w,
                height: isHor ? 220.h : 240.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30.r),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: isHor ? 20.r : 15.r,
                        ),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(CircleBorder()),
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(8.r)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 25.r,
                          left: 10.r,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'DETAIL PENCAIRAN INKARO',
                                style: TextStyle(
                                  fontSize: isHor ? 22.sp : 17.sp,
                                  // fontFamily: 'Segoe ui',
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 5.0.sp,
                              ),
                              Text(
                                widget.inkaroPencairanHeader.namaOptik,
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 12.sp,
                                  // fontFamily: 'Segoe ui',
                                  // fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/inkaro-bumper.jpg'),
                    fit: isHor ? BoxFit.cover : BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0.sp, right: 30.0.sp, top: 5.sp),
                        child: Container(
                          margin: EdgeInsets.only(top: 5.sp),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(
                                  color: Colors.black26, width: 1.0.sp),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 15.0.sp, bottom: 5.0.sp),
                                          child: Text(
                                            'Nomor Pencairan',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 10.0),
                                          child: Text(widget
                                              .inkaroPencairanHeader
                                              .nomorPencairan),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 15.0.sp, bottom: 5.0.sp),
                                          child: Text(
                                            'Total Inkaro',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 10.0),
                                          child: Text(
                                            convertToIdr(
                                                int.parse(widget.inkaroPencairanHeader
                                                                .totalInkaroAfterPPH !=
                                                            '' &&
                                                        widget.inkaroPencairanHeader
                                                                .totalInkaroAfterPPH !=
                                                            null
                                                    ? widget
                                                        .inkaroPencairanHeader
                                                        .totalInkaroAfterPPH
                                                    : widget
                                                        .inkaroPencairanHeader
                                                        .totalInkaro),
                                                0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 10.0.sp, bottom: 5.0.sp),
                                      child: Text(
                                        'Periode Transaksi',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10.0),
                                      child: Text((widget.inkaroPencairanHeader
                                                      .startPeriode !=
                                                  ''
                                              ? DateFormat("dd MMM yyyy")
                                                  .format(DateTime.parse(widget
                                                      .inkaroPencairanHeader
                                                      .startPeriode))
                                              : '-') +
                                          ' s/d ' +
                                          (widget.inkaroPencairanHeader.endPeriode != ''
                                              ? DateFormat("dd MMM yyyy")
                                                  .format(DateTime.parse(
                                                      widget.inkaroPencairanHeader.endPeriode))
                                              : '-')),
                                    ),
                                  ],
                                ),
                              ]),
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 10.0.sp),
                                    child: Text(
                                      'List Penerima Inkaro :',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              _isLoading
                                  ? Column(
                                      children: [
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        Center(
                                          child: Text(
                                            'Processing ...',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        listPencairanInkaroDetail.length > 0
                                            ? ListView.builder(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount:
                                                    listPencairanInkaroDetail
                                                        .length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 10.sp),
                                                    width: double.infinity.w,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10.0.sp,
                                                              horizontal:
                                                                  10.sp),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top:
                                                                        10.0.sp,
                                                                    bottom:
                                                                        5.0.sp,
                                                                    left:
                                                                        10.0.sp,
                                                                    right: 10.0
                                                                        .sp),
                                                            child: Text(
                                                              listPencairanInkaroDetail[
                                                                      index]
                                                                  .namaPenerima,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left:
                                                                        10.0.sp,
                                                                    right: 10.0
                                                                        .sp),
                                                            child: Text(
                                                              "Rekening : " +
                                                                  listPencairanInkaroDetail[
                                                                          index]
                                                                      .noRekening +
                                                                  " ( " +
                                                                  listPencairanInkaroDetail[
                                                                          index]
                                                                      .bank +
                                                                  " )",
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                fontFamily:
                                                                    'Montserrat',
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8.0.sp),
                                                            child: Divider(
                                                              thickness: 1,
                                                              color: Colors
                                                                  .black26,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        5.0.sp,
                                                                    left:
                                                                        10.0.sp,
                                                                    right: 10.0
                                                                        .sp),
                                                            child: Text(
                                                              "Jumlah Inkaro : " +
                                                                  convertToIdr(
                                                                      int.parse(
                                                                          listPencairanInkaroDetail[index]
                                                                              .totalInkaro),
                                                                      0),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 12.sp,
                                                                fontFamily:
                                                                    'Montserrat',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                })
                                            : Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 20.0),
                                                    child: Text(
                                                        'Penerima Belum Ada'),
                                                  ),
                                                ],
                                              ),
                                      ],
                                    )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: isHor ? 20.h : 10.h,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(left: 30.sp, right: 5.sp),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.sp),
                                ),
                                border: Border.all(
                                  color: Colors.black26,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10.sp,
                                        right: 10.sp,
                                        top: 10.sp,
                                        bottom: 10.sp),
                                    child: Text(
                                      widget.inkaroPencairanHeader.approvalSM ==
                                              'PENDING'
                                          ? 'Menunggu SM'
                                          : widget.inkaroPencairanHeader
                                                      .approvalSM ==
                                                  'APPROVE'
                                              ? 'Disetujui SM'
                                              : 'Ditolak SM',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10.sp,
                                        right: 10.sp,
                                        bottom: 10.sp),
                                    child: Text(
                                      (widget.inkaroPencairanHeader
                                                  .approvalSMName !=
                                              ''
                                          ? '( ' +
                                              widget.inkaroPencairanHeader
                                                  .approvalSMName +
                                              ' )'
                                          : '-'),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10.sp,
                                        right: 10.sp,
                                        bottom: 10.sp),
                                    child: Text(
                                      (widget.inkaroPencairanHeader
                                                  .dateApprovalSM !=
                                              ''
                                          ? DateFormat("dd MMM yyyy").format(
                                              DateTime.parse(widget
                                                  .inkaroPencairanHeader
                                                  .dateApprovalSM))
                                          : '-'),
                                      style: TextStyle(
                                        fontSize: 10.5.sp,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(right: 30.sp, left: 5.sp),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.sp),
                                ),
                                border: Border.all(
                                  color: Colors.black26,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10.sp,
                                        right: 10.sp,
                                        top: 10.sp,
                                        bottom: 10.sp),
                                    child: Text(
                                      widget.inkaroPencairanHeader.approvalAM ==
                                              'PENDING'
                                          ? 'Menunggu AR'
                                          : widget.inkaroPencairanHeader
                                                      .approvalAM ==
                                                  'APPROVE'
                                              ? 'Disetujui AR'
                                              : 'Ditolak AR',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10.sp,
                                        right: 10.sp,
                                        bottom: 10.sp),
                                    child: Text(
                                      (widget.inkaroPencairanHeader
                                                  .approvalAMName !=
                                              ''
                                          ? '( ' +
                                              widget.inkaroPencairanHeader
                                                  .approvalAMName +
                                              ' )'
                                          : '-'),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10.sp,
                                        right: 10.sp,
                                        bottom: 10.sp),
                                    child: Text(
                                      (widget.inkaroPencairanHeader
                                                  .dateApprovalAM !=
                                              ''
                                          ? DateFormat("dd MMM yyyy").format(
                                              DateTime.parse(widget
                                                  .inkaroPencairanHeader
                                                  .dateApprovalAM))
                                          : '-'),
                                      style: TextStyle(
                                        fontSize: 10.5.sp,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      widget.inkaroPencairanHeader.approvalSM == 'REJECT'
                          ? Container(
                              margin: EdgeInsets.only(
                                  left: 30.sp, right: 30.sp, top: 10.sp),
                              width: double.infinity.w,
                              decoration: BoxDecoration(
                                color: Colors.red[300],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 10),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 5.0.sp,
                                          bottom: 5.0.sp,
                                          left: 10.0.sp,
                                          right: 10.0.sp),
                                      child: Text(
                                        "Alasan Reject : " +
                                            widget.inkaroPencairanHeader
                                                .reasonRejectSM,
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : widget.inkaroPencairanHeader.approvalAM == 'REJECT'
                              ? Container(
                                  margin: EdgeInsets.only(
                                      left: 30.sp, right: 30.sp, top: 10.sp),
                                  width: double.infinity.w,
                                  decoration: BoxDecoration(
                                    color: Colors.red[300],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0,
                                              bottom: 5.0,
                                              left: 10.0,
                                              right: 10.0),
                                          child: Text(
                                            "Alasan Reject : " +
                                                widget.inkaroPencairanHeader
                                                    .reasonRejectAM,
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : SizedBox(),
                      SizedBox(height: 15.sp),
                      role == 'ADMIN'
                          ? (widget.inkaroPencairanHeader.approvalSM ==
                                          'PENDING' &&
                                      divisi == 'SALES') ||
                                  (widget.inkaroPencairanHeader.approvalAM ==
                                          'PENDING' &&
                                      divisi == 'AR')
                              ? Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 30.sp),
                                  child: handleAction(
                                    isHorizontal: isHor,
                                  ),
                                )
                              : SizedBox(
                                  height: isHor ? 20.h : 10.h,
                                )
                          : SizedBox(
                              height: isHor ? 20.h : 10.h,
                            ),
                      widget.inkaroPencairanHeader.approvalAM == 'APPROVE'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30.sp,
                                    vertical: 5.r,
                                  ),
                                  alignment: Alignment.centerRight,
                                  child: EasyButton(
                                    idleStateWidget: Text(
                                      "PDF Pencairan",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    loadingStateWidget:
                                        CircularProgressIndicator(
                                      strokeWidth: 3.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                    useEqualLoadingStateWidgetDimension: true,
                                    useWidthAnimation: true,
                                    height: 40.h,
                                    width: 100.w,
                                    borderRadius: 10.r,
                                    buttonColor: Colors.red.shade700,
                                    elevation: 2.0,
                                    contentGap: 6.0,
                                    onPressed: onPressedDownload,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(height: 25.sp),
                    ],
                  )),
            ],
          ),
        ),
        onRefresh: _refreshData,
      ),
    );
  }

  Widget handleAction({bool isHorizontal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(
            top: 10.r,
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
          padding: EdgeInsets.only(
            top: 10.r,
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
}
