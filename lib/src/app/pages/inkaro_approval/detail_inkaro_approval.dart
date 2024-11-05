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
import 'package:sample/src/domain/entities/list_inkaro_detail.dart';
import 'package:sample/src/domain/entities/list_inkaro_header.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class DetailInkaroApproval extends StatefulWidget {
  ListInkaroHeader inkaroHeader;
  bool? isPending = true;

  DetailInkaroApproval(
    this.inkaroHeader, {
    this.isPending,
  });

  @override
  State<DetailInkaroApproval> createState() => _DetailInkaroApprovalState();
}

class _DetailInkaroApprovalState extends State<DetailInkaroApproval> {
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
  bool _isLoading = true;
  bool _isHorizontal = false;
  late String tokenSales;

  final format = DateFormat("dd MMM yyyy");
  var thisYear, nextYear;

  List<ListInkaroDetail> listInkaroDetailReguler = List.empty(growable: true);
  List<ListInkaroDetail> listInkaroDetailProgram = List.empty(growable: true);
  List<ListInkaroDetail> listInkaroDetailManual = List.empty(growable: true);

  TextEditingController textReason = new TextEditingController();
  bool _isReason = false;

  late bool _permissionReady;
  late String _localPath;
  final ReceivePort _port = ReceivePort();

  getListInkaro() async {
    const timeout = 15;
    var url =
        '$API_URL/inkaro/getInkaroDetail?id_inkaro_header=${widget.inkaroHeader.inkaroContractId}';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      try {
        var data = convert.json.decode(response.body);
        final bool sts = data['status'];
        if (sts) {
          var rest = data['data'];
          print(rest['program']);
          setState(() {
            listInkaroDetailReguler = rest['reguler']
                .map<ListInkaroDetail>(
                    (json) => ListInkaroDetail.fromJson(json))
                .toList();
            listInkaroDetailProgram = rest['program']
                .map<ListInkaroDetail>(
                    (json) => ListInkaroDetail.fromJson(json))
                .toList();
            listInkaroDetailManual = rest['manual']
                .map<ListInkaroDetail>(
                    (json) => ListInkaroDetail.fromJson(json))
                .toList();
          });
        }

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
    String idContract,
    String approvalStatus,
    String contractStatus,
    String approvalReason,
    String approvalSM, {
    bool isHorizontal = false,
  }) async {
    const timeout = 15;
    var url = '$API_URL/inkaro/approvalSMContractInkaro';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {"api-key-trl": API_KEY},
        body: {
          'id_contract': idContract,
          'approval_status': approvalStatus,
          'contract_status': contractStatus,
          'approval_reason': approvalReason,
          'approver_sm': approvalSM,
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
          //Send to sales spesifik
          if (approvalStatus == "APPROVE") {
            pushNotif(
              15,
              3,
              idUser: widget.inkaroHeader.createBy,
              rcptToken: tokenSales,
              admName: username,
              opticName: widget.inkaroHeader.customerShipName,
            );
          } else {
            pushNotif(
              16,
              3,
              idUser: widget.inkaroHeader.createBy,
              rcptToken: tokenSales,
              admName: username,
              opticName: widget.inkaroHeader.customerShipName,
            );
          }

          print(msg);

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
              widget.inkaroHeader.inkaroContractId,
              "REJECT",
              "INACTIVE",
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

      if (double.tryParse(widget.inkaroHeader.createBy) == null) {
        print('The input is not a numeric string');
      } else {
        print('Yes, it is a numeric string');
        getSalesToken(int.parse(widget.inkaroHeader.createBy));
      }
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
      downloadContractInkaro(
        int.parse(widget.inkaroHeader.inkaroContractId),
        widget.inkaroHeader.customerShipName,
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
        child:
            Text('Tidak mendapat izin penyimpanan'),
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
    );

    return () {};
  }

  onPressedApprove() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
      () => approvalInkaro(
        widget.inkaroHeader.inkaroContractId,
        "APPROVE",
        "ACTIVE",
        "",
        id!,
        isHorizontal: _isHorizontal,
      ),
    );

    return () {};
  }

  @override
  void initState() {
    super.initState();
    getRole();
    getListInkaro();

    _permissionReady = false;
    _retryRequestPermission();

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

  downloadContractInkaro(
    int idContract,
    String custName,
    String locatedFile,
  ) async {
    convert.Codec<String, String> stringToBase64 =
        convert.utf8.fuse(convert.base64);
    String encoded =
        (stringToBase64.encode(idContract.toString())).replaceAll('=', '');
    var url = '$WEBADMIN/download/inkaro_pdf/$encoded';

    await FlutterDownloader.enqueue(
      url: url,
      fileName: "Kontrak Inkaro $custName.pdf",
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
                height: isHor ? 200.h : 220.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30.r),
                      child: ElevatedButton(
                        onPressed: () {
                          // widget.isAdminRenewal!
                          //     ? Navigator.of(context).pushReplacement(
                          //         MaterialPageRoute(
                          //             builder: (context) => AdminScreen()))
                          //     : Navigator.pop(context);

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
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.r,
                        vertical: widget.inkaroHeader.customerShipName == "null"
                            ? 3.r
                            : widget.inkaroHeader.customerShipName.length > 32
                                ? 3.r
                                : 5.r,
                      ),
                      child: Center(
                        child: Text(
                          'KONTRAK INKARO',
                          style: TextStyle(
                            fontSize: isHor ? 25.sp : 18.sp,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/inkaro-bumper.png'),
                    fit: isHor ? BoxFit.cover : BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              SizedBox(
                height: 5.r,
              ),
              _isLoading
                  ? SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.r,
                            vertical: 5.r,
                          ),
                          alignment: Alignment.centerRight,
                          child: EasyButton(
                            idleStateWidget: Text(
                              "PDF Kontrak",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
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
                    ),
              _isLoading
                  ? Column(
                      children: [
                        SizedBox(
                          height: 5.h,
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
                              fontSize: 15.sp,
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
                  : Card(
                      margin: EdgeInsets.all(10.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(15),
                          // implement shadow effect
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black38, // shadow color
                                blurRadius: 5, // shadow radius
                                offset: Offset(3, 3), // shadow offset
                                spreadRadius:
                                    0.1, // The amount the box should be inflated prior to applying the blur
                                blurStyle: BlurStyle.normal // set blur style
                                ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: isHor ? 18.h : 8.h,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.inkaroHeader.customerShipName,
                                      style: TextStyle(
                                          fontSize: isHor ? 18.sp : 14.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Periode : " +
                                          DateFormat("dd MMM yyyy").format(
                                              DateTime.parse(widget
                                                  .inkaroHeader.startPeriode)) +
                                          ' sampai ' +
                                          DateFormat("dd MMM yyyy").format(
                                              DateTime.parse(widget
                                                  .inkaroHeader.endPeriode)),
                                      style: TextStyle(
                                        // fontSize: isHorizontal ? 18.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        // fontWeight: FontWeight.w600
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 18.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black12,
                                                width: 2)),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 10,
                                            bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              widget.inkaroHeader.namaStaff,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "NPWP",
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            Text(
                                              widget.inkaroHeader.npwp,
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.h,
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "NIK",
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            Text(
                                              widget.inkaroHeader.nikKTP,
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rekening/e-wallet Tujuan',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Bank / e-Wallet",
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            Text(
                                              widget.inkaroHeader.namaBank,
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.h,
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Nomor Rekening",
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            Text(
                                              widget.inkaroHeader.nikKTP,
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Atas Nama",
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            Text(
                                              widget.inkaroHeader.anRekening,
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.h,
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Telp Konfirmasi",
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            Text(
                                              widget
                                                  .inkaroHeader.telpKonfirmasi,
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              Card(
                margin: EdgeInsets.all(10.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    // implement shadow effect
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black38, // shadow color
                          blurRadius: 5, // shadow radius
                          offset: Offset(3, 3), // shadow offset
                          spreadRadius:
                              0.1, // The amount the box should be inflated prior to applying the blur
                          blurStyle: BlurStyle.normal // set blur style
                          ),
                    ],
                  ),
                  child: ExpansionTile(
                    title: Text(
                      'INKARO REGULER',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: <Widget>[
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'BRAND',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Percent',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Inkaro',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              listInkaroDetailReguler.length > 0
                                  ? ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: listInkaroDetailReguler.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 10.r, right: 3.r),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  listInkaroDetailReguler[index]
                                                      .descKategori,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  listInkaroDetailReguler[index]
                                                      .inkaroPercent,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  convertToIdr(
                                                      int.parse(
                                                          listInkaroDetailReguler[
                                                                  index]
                                                              .inkaroValue),
                                                      0),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: 30.r,
                                          bottom: 30.r,
                                          left: 10.r,
                                          right: 10.r),
                                      child: Center(
                                        child: Text(
                                          'Inkaro Reguler Tidak Ada',
                                          style: TextStyle(
                                            fontSize: isHor ? 24.sp : 14.sp,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(10.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    // implement shadow effect
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black38, // shadow color
                          blurRadius: 5, // shadow radius
                          offset: Offset(3, 3), // shadow offset
                          spreadRadius:
                              0.1, // The amount the box should be inflated prior to applying the blur
                          blurStyle: BlurStyle.normal // set blur style
                          ),
                    ],
                  ),
                  child: ExpansionTile(
                    title: Text(
                      'INKARO PROGRAM',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // subtitle: Text('Trailing expansion arrow icon'),
                    children: <Widget>[
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'BRAND',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Percent',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Inkaro',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              listInkaroDetailProgram.length > 0
                                  ? ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: listInkaroDetailProgram.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 10.r, right: 3.r),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  listInkaroDetailProgram[index]
                                                      .descSubcategory,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  listInkaroDetailProgram[index]
                                                      .inkaroPercent,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  convertToIdr(
                                                      int.parse(
                                                          listInkaroDetailProgram[
                                                                  index]
                                                              .inkaroValue),
                                                      0),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: 30.r,
                                          bottom: 30.r,
                                          left: 10.r,
                                          right: 10.r),
                                      child: Center(
                                        child: Text(
                                          'Inkaro Program Tidak Ada',
                                          style: TextStyle(
                                            fontSize: isHor ? 24.sp : 14.sp,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(10.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    // implement shadow effect
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black38, // shadow color
                          blurRadius: 5, // shadow radius
                          offset: Offset(3, 3), // shadow offset
                          spreadRadius:
                              0.1, // The amount the box should be inflated prior to applying the blur
                          blurStyle: BlurStyle.normal // set blur style
                          ),
                    ],
                  ),
                  child: ExpansionTile(
                    title: Text(
                      'INKARO MANUAL',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // subtitle: Text('Trailing expansion arrow icon'),
                    children: <Widget>[
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'BRAND',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Inkaro',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              listInkaroDetailManual.length > 0
                                  ? ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: listInkaroDetailManual.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 10.r, right: 3.r),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  listInkaroDetailManual[index]
                                                      .descSubcategory,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  convertToIdr(
                                                      int.parse(
                                                          listInkaroDetailManual[
                                                                  index]
                                                              .inkaroValue),
                                                      0),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: 30.r,
                                          bottom: 30.r,
                                          left: 10.r,
                                          right: 10.r),
                                      child: Center(
                                        child: Text(
                                          'Inkaro Manual Tidak Ada',
                                          style: TextStyle(
                                            fontSize: isHor ? 24.sp : 14.sp,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: isHor ? 20.h : 10.h,
              ),
              role == 'ADMIN' && divisi == 'SALES' ? 
              widget.isPending!
                  ? handleAction(
                      isHorizontal: isHor,
                    )
                  : SizedBox(): SizedBox(),
              SizedBox(
                height: isHor ? 20.h : 10.h,
              ),
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
}
