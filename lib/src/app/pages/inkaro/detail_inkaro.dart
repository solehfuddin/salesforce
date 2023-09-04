// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/customer_inkaro.dart';
import 'package:sample/src/domain/entities/inkaro_manual.dart';
import 'package:sample/src/domain/entities/inkaro_program.dart';
import 'package:sample/src/domain/entities/inkaro_reguler.dart';
import 'package:sample/src/domain/entities/list_inkaro_detail.dart';
import 'package:sample/src/domain/entities/list_inkaro_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class DetailInkaroScreen extends StatefulWidget {
  final List<ListCustomerInkaro> customerList;
  final int positionCustomer;
  final List<ListInkaroHeader> listInkaroHeader;
  final int positionInkaro;

  @override
  _DetailInkaroScreenState createState() => _DetailInkaroScreenState();

  DetailInkaroScreen(this.customerList, this.positionCustomer,
      this.listInkaroHeader, this.positionInkaro);
}

class _DetailInkaroScreenState extends State<DetailInkaroScreen> {
  final globalKey = GlobalKey();

  String search = '';
  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';

  String namaUsaha = '';
  String namaPJ = '';
  String telpPJ = '';
  String alamatUsaha = '';
  String allValueManual = '';

  late bool _permissionReady;
  late String _localPath;
  final ReceivePort _port = ReceivePort();

  bool checkAllInkaroReguler = false,
      checkAllInkaroProgram = false,
      checkAllInkaroManual = false,
      isSwitchedHouseBrandProgram = false,
      isSwitchedHouseBrandManual = false,
      checkSetAllValueManual = false;

  String? _choosenFilterSubcatProg, _choosenFilterSubcatManual;

  final format = DateFormat("dd MMM yyyy");
  var thisYear, nextYear;

  List<ListInkaroDetail> listInkaroDetailReguler = List.empty(growable: true);
  List<ListInkaroDetail> listInkaroDetailProgram = List.empty(growable: true);
  List<ListInkaroDetail> listInkaroDetailManual = List.empty(growable: true);

  List<InkaroReguler> _dataFilterSubcat = List.empty(growable: true);

  Future<List<InkaroReguler>> getCategoryForFilterSubcat() async {
    const timeout = 15;
    var url = '$API_URL/inkaro/filter_category_inkaro';
    List<InkaroReguler> list = List.empty(growable: true);
    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      try {
        var data = convert.json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          list = rest
              .map<InkaroReguler>((json) => InkaroReguler.fromJson(json))
              .toList();
          setState(() {
            _dataFilterSubcat = list;
          });
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }

    return list;
  }

  void refreshListAfterTambahData(List<ListInkaroDetail> _listInkaroReguler) =>
      setState(() {
        List<ListInkaroDetail> listInkaroDetailRefresh =
            List.empty(growable: true);
        listInkaroDetailRefresh.addAll(_listInkaroReguler);

        // Clear Old Data List Inkaro
        listInkaroDetailReguler.clear();
        listInkaroDetailProgram.clear();
        listInkaroDetailManual.clear();

        // Update List Inkaro
        for (int i = 0; i < listInkaroDetailRefresh.length; i++) {
          switch (listInkaroDetailRefresh[i].typeInkaro) {
            case "reguler":
              listInkaroDetailReguler.add(listInkaroDetailRefresh[i]);
              break;
            case "program":
              listInkaroDetailProgram.add(listInkaroDetailRefresh[i]);
              break;
            case "manual":
              listInkaroDetailManual.add(listInkaroDetailRefresh[i]);
              break;
          }
        }
      });

  List<InkaroReguler> itemInkaroReguler = List.empty(growable: true);
  Future<List<InkaroReguler>> getOptionInkaroReguler() async {
    List<InkaroReguler> listTemp = List.empty(growable: true);
    const timeout = 15;
    var url =
        '$API_URL/inkaro/category_inkaro?typeGet=not_include_contract&id_contract=' +
            widget.listInkaroHeader[widget.positionInkaro].inkaroContractId +
            '&type_inkaro=reguler';
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
            listTemp = rest
                .map<InkaroReguler>((json) => InkaroReguler.fromJson(json))
                .toList();
            itemInkaroReguler = rest
                .map<InkaroReguler>((json) => InkaroReguler.fromJson(json))
                .toList();
          });
        } else {
          listTemp.clear();
          itemInkaroReguler.clear();
        }
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

    return listTemp;
  }

  List<InkaroReguler> inkaroRegSelected = List.empty(growable: true);
  getSelectedInkaroReguler() {
    setState(() {
      inkaroRegSelected = List.empty(growable: true);
      inkaroProgSelected = List.empty(growable: true);
      inkaroManualSelected = List.empty(growable: true);
      if (itemInkaroReguler.isNotEmpty) {
        for (int i = 0; i < itemInkaroReguler.length; i++) {
          if (itemInkaroReguler[i].ischecked) {
            setState(() {
              inkaroRegSelected.add(itemInkaroReguler[i]);
            });
          }
        }
      }
    });
  }

  List<InkaroProgram> itemInkaroProgram = List.empty(growable: true);
  Future<List<InkaroProgram>> getOptionInkaroProgram() async {
    List<InkaroProgram> listTemp = List.empty(growable: true);
    String houseBrand = isSwitchedHouseBrandProgram ? 'on' : 'off';
    const timeout = 15;
    var url =
        '$API_URL/inkaro/category_inkaro?typeGet=not_include_contract&id_contract=' +
            widget.listInkaroHeader[widget.positionInkaro].inkaroContractId +
            '&type_inkaro=program&category=${_choosenFilterSubcatProg.toString()}&house_brand=$houseBrand';
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
            listTemp = rest
                .map<InkaroProgram>((json) => InkaroProgram.fromJson(json))
                .toList();
            itemInkaroProgram = rest
                .map<InkaroProgram>((json) => InkaroProgram.fromJson(json))
                .toList();
          });
        } else {
          listTemp.clear();
          itemInkaroProgram.clear();
        }
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

    return listTemp;
  }

  List<InkaroProgram> inkaroProgSelected = List.empty(growable: true);
  getSelectedInkaroProgram() {
    setState(() {
      inkaroRegSelected = List.empty(growable: true);
      inkaroProgSelected = List.empty(growable: true);
      inkaroManualSelected = List.empty(growable: true);
      if (itemInkaroProgram.isNotEmpty) {
        for (int i = 0; i < itemInkaroProgram.length; i++) {
          if (itemInkaroProgram[i].ischecked) {
            setState(() {
              inkaroProgSelected.add(itemInkaroProgram[i]);
            });
          }
        }
      }
    });
  }

  List<InkaroManual> itemInkaroManual = List.empty(growable: true);
  Future<List<InkaroManual>> getOptionInkaroManual() async {
    List<InkaroManual> listTemp = List.empty(growable: true);
    String houseBrand = isSwitchedHouseBrandManual ? 'on' : 'off';
    const timeout = 15;
    var url =
        '$API_URL/inkaro/category_inkaro?typeGet=not_include_contract&id_contract=' +
            widget.listInkaroHeader[widget.positionInkaro].inkaroContractId +
            '&type_inkaro=manual&category=${_choosenFilterSubcatManual.toString()}&house_brand=$houseBrand';
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
            listTemp = rest
                .map<InkaroManual>((json) => InkaroManual.fromJson(json))
                .toList();
            itemInkaroManual = rest
                .map<InkaroManual>((json) => InkaroManual.fromJson(json))
                .toList();
          });
        } else {
          listTemp.clear();
          itemInkaroManual.clear();
        }
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

    return listTemp;
  }

  List<InkaroManual> inkaroManualSelected = List.empty(growable: true);
  getSelectedInkaroManual() {
    setState(() {
      inkaroRegSelected = List.empty(growable: true);
      inkaroProgSelected = List.empty(growable: true);
      inkaroManualSelected = List.empty(growable: true);
      if (itemInkaroManual.isNotEmpty) {
        for (int i = 0; i < itemInkaroManual.length; i++) {
          if (itemInkaroManual[i].ischecked) {
            setState(() {
              if (checkSetAllValueManual) {
                itemInkaroManual[i].inkaroValue =
                    allValueManual.replaceAll(".", "");
                inkaroManualSelected.add(itemInkaroManual[i]);
              } else {
                inkaroManualSelected.add(itemInkaroManual[i]);
              }
            });
          }
        }
      }
    });
  }

  getListInkaro() async {
    const timeout = 15;
    var url =
        '$API_URL/inkaro/getInkaroDetail?id_inkaro_header=${widget.listInkaroHeader[widget.positionInkaro].inkaroContractId}&sort=DESC_CATEGORY,DESC_SUBCATEGORY:ASC';

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

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");

      var formatter = new DateFormat('yyyy');
      thisYear = formatter.format(DateTime.now());
      nextYear = int.parse(thisYear) + 1;

      print('This Year : $thisYear');
      print('Next Year : $nextYear');

      print("Dashboard : $role");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
    getListInkaro();
    getCategoryForFilterSubcat();

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

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    // send.send([id, status, progress]);

    if (send != null)
    {
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
        return childInkaroHeader(isHorizontal: true);
      }

      return childInkaroHeader(isHorizontal: false);
    });
  }

  Widget childInkaroHeader({bool isHorizontal = false}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Detail Inkaro',
          style: TextStyle(
            color: Colors.black54,
            fontSize: isHorizontal ? 20.sp : 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black54,
            size: isHorizontal ? 20.sp : 18.r,
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              widget.listInkaroHeader[widget.positionInkaro].approvalSM ==
                      "REJECT"
                  ? Card(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Color(0xFFffa45e),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 20.0, right: 20.0, bottom: 10.0),
                          child: Text(
                            "Alasan Reject : " +
                                widget.listInkaroHeader[widget.positionInkaro]
                                    .reasonSM
                                    .toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.00,
                                fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
              Card(
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
                    padding: EdgeInsets.only(
                        top: 15.0.sp,
                        left: 15.0.sp,
                        right: 15.0.sp,
                        bottom: 10.0.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.r,
                                vertical: 5.r,
                              ),
                              alignment: Alignment.centerRight,
                              child: ArgonButton(
                                height: 40.h,
                                width: 100.w,
                                borderRadius: 10.r,
                                color: Colors.red[700],
                                child: Text(
                                  "PDF Kontrak",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
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
                                    if (_permissionReady) {
                                      downloadContractInkaro(
                                        int.parse(widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .inkaroContractId),
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .customerShipName,
                                        _localPath,
                                      );
                                      showStyledToast(
                                        child: Text('Sedang mengunduh file'),
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
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHorizontal ? 18.h : 8.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                namaUsaha = widget
                                    .customerList[widget.positionCustomer]
                                    .namaUsaha,
                                style: TextStyle(
                                    fontSize: isHorizontal ? 18.sp : 14.sp,
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
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .startPeriode)) +
                                    ' sampai ' +
                                    DateFormat("dd MMM yyyy").format(
                                        DateTime.parse(widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .endPeriode)),
                                style: TextStyle(
                                    // fontSize: isHorizontal ? 18.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontSize: 11.sp
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
                                padding: EdgeInsets.only(bottom: 5.sp),
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black12, width: 2)),
                                ),
                                child: Text(
                                  widget.listInkaroHeader[widget.positionInkaro]
                                      .nomorKontrak,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.sp),
                                  textAlign: TextAlign.center,
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
                                        "Nama Staff",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 11.sp),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .namaStaff,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.sp),
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
                                        "Jabatan",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 11.sp),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .jabatan,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.sp),
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
                                            fontSize: 11.sp),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                                .listInkaroHeader[
                                                    widget.positionInkaro]
                                                .npwp
                                                .isEmpty
                                            ? '-'
                                            : widget
                                                .listInkaroHeader[
                                                    widget.positionInkaro]
                                                .npwp,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.sp),
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
                                            fontSize: 11.sp),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .nikKTP,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.sp),
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
                                            fontSize: 11.sp),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .namaBank,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.sp),
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
                                            fontSize: 11.sp),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .nikKTP,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.sp),
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
                                            fontSize: 11.sp),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .anRekening,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.sp),
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
                                            fontSize: 11.sp),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        widget
                                            .listInkaroHeader[
                                                widget.positionInkaro]
                                            .telpKonfirmasi,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.sp),
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
                          height: 10.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Interval Pembayaran",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 11.sp),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      widget
                                          .listInkaroHeader[
                                              widget.positionInkaro]
                                          .intervalPembayaran,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.sp),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Catatan",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 11.sp),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      widget
                                                  .listInkaroHeader[
                                                      widget.positionInkaro]
                                                  .notes !=
                                              ''
                                          ? widget
                                              .listInkaroHeader[
                                                  widget.positionInkaro]
                                              .notes
                                          : '-',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.sp),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(children: [
                          Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  handleVerifEditHeaderInkaro(
                                      context,
                                      widget.listInkaroHeader,
                                      widget.positionInkaro);
                                },
                                style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.0.sp, vertical: 10.0.sp),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    primary: Colors.blue[500]),
                                child: Text(
                                  "Ubah Data",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13.sp),
                                ),
                              )),
                        ])
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
                          fontSize: 13.sp,
                        ),
                      ),
                      children: <Widget>[
                        Card(
                          color: Colors.white,
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.sp, vertical: 10.sp),
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
                                            fontSize: 11.sp,
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
                                            fontSize: 11.sp,
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
                                            fontSize: 11.sp,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Hapus',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.sp,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  listInkaroDetailReguler.length > 0
                                      ? SingleChildScrollView(
                                          physics: ScrollPhysics(),
                                          child: ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: listInkaroDetailReguler
                                                  .length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 1.sp,
                                                      bottom: 1.sp,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            listInkaroDetailReguler[
                                                                    index]
                                                                .descKategori,
                                                            style: TextStyle(
                                                              fontSize: 11.sp,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            listInkaroDetailReguler[
                                                                    index]
                                                                .inkaroPercent,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 11.sp,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            convertToIdr(
                                                                int.parse(listInkaroDetailReguler[
                                                                        index]
                                                                    .inkaroValue),
                                                                0),
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                              fontSize: 11.sp,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                            flex: 2,
                                                            child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left: 10
                                                                            .sp),
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child:
                                                                    TextButton(
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Colors.red[
                                                                            600],
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await handleVerifUpdateInkaroItem(
                                                                        context,
                                                                        widget
                                                                            .customerList,
                                                                        widget
                                                                            .positionCustomer,
                                                                        widget
                                                                            .listInkaroHeader,
                                                                        widget
                                                                            .positionInkaro,
                                                                        inkaroRegSelected,
                                                                        inkaroProgSelected,
                                                                        inkaroManualSelected,
                                                                        refreshListAfterTambahData,
                                                                        listInkaroDetailReguler,
                                                                        index,
                                                                        "delete");
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .white,
                                                                    size:
                                                                        15.0.sp,
                                                                  ),
                                                                ))),
                                                      ],
                                                    ));
                                              }),
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
                                                    fontSize: isHorizontal
                                                        ? 24.sp
                                                        : 14.sp,
                                                    fontFamily: 'Montserrat',
                                                  ))))
                                ],
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.0.sp),
                          child: Row(children: [
                            Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      checkAllInkaroReguler = false;
                                    });
                                    await getOptionInkaroReguler();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return dialogInkaroReguler();
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0.sp,
                                          vertical: 15.0.sp),
                                      primary: Colors.blue[700]),
                                  child: Text(
                                    "+ Tambah Inkaro Reguler",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13.sp),
                                  ),
                                )),
                          ]),
                        ),
                      ],
                    ),
                  )),
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
                          fontSize: 13.sp),
                    ),
                    // subtitle: Text('Trailing expansion arrow icon'),
                    children: <Widget>[
                      Card(
                        color: Colors.white,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.sp, vertical: 10.sp),
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
                                            fontSize: 11.sp),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Percent',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.sp),
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
                                            fontSize: 11.sp),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Hapus',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.sp),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                listInkaroDetailProgram.length > 0
                                    ? SingleChildScrollView(
                                        physics: ScrollPhysics(),
                                        child: ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:
                                                listInkaroDetailProgram.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                  padding: EdgeInsets.only(
                                                    top: 1.sp,
                                                    bottom: 1.sp,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 4,
                                                        child: Text(
                                                          listInkaroDetailProgram[
                                                                  index]
                                                              .descSubcategory,
                                                          style: TextStyle(
                                                              fontSize: 11.sp),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          listInkaroDetailProgram[
                                                                  index]
                                                              .inkaroPercent,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 11.sp),
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
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              fontSize: 11.sp),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 2,
                                                          child: Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 10
                                                                          .sp),
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: TextButton(
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors.red[
                                                                          600],
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  await handleVerifUpdateInkaroItem(
                                                                      context,
                                                                      widget
                                                                          .customerList,
                                                                      widget
                                                                          .positionCustomer,
                                                                      widget
                                                                          .listInkaroHeader,
                                                                      widget
                                                                          .positionInkaro,
                                                                      inkaroRegSelected,
                                                                      inkaroProgSelected,
                                                                      inkaroManualSelected,
                                                                      refreshListAfterTambahData,
                                                                      listInkaroDetailProgram,
                                                                      index,
                                                                      "delete");
                                                                },
                                                                child: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 15.0.sp,
                                                                ),
                                                              ))),
                                                    ],
                                                  ));
                                            }))
                                    : Padding(
                                        padding: EdgeInsets.only(
                                            top: 30.r,
                                            bottom: 30.r,
                                            left: 10.r,
                                            right: 10.r),
                                        child: Center(
                                            child:
                                                Text('Inkaro Program Tidak Ada',
                                                    style: TextStyle(
                                                      fontSize: isHorizontal
                                                          ? 24.sp
                                                          : 14.sp,
                                                      fontFamily: 'Montserrat',
                                                    ))))
                              ],
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(children: [
                          Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await getOptionInkaroProgram();
                                  setState(() {
                                    _choosenFilterSubcatProg = null;
                                    checkAllInkaroProgram = false;
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return dialogInkaroProgram();
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 15.0),
                                    primary: Colors.blue[700]),
                                child: Text(
                                  "+ Tambah Inkaro Program",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13.sp),
                                ),
                              )),
                        ]),
                      )
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
                            fontSize: 13.sp),
                      ),
                      // subtitle: Text('Trailing expansion arrow icon'),
                      children: <Widget>[
                        Card(
                          color: Colors.white,
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.sp, vertical: 10.sp),
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
                                              fontSize: 10.sp),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Inkaro',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10.sp),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Hapus',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10.sp),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  listInkaroDetailManual.length > 0
                                      ? SingleChildScrollView(
                                          physics: ScrollPhysics(),
                                          child: ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                                  listInkaroDetailManual.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 1.sp,
                                                      bottom: 1.sp,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            listInkaroDetailManual[
                                                                    index]
                                                                .descSubcategory,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    11.sp),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            convertToIdr(
                                                                int.parse(listInkaroDetailManual[
                                                                        index]
                                                                    .inkaroValue),
                                                                0),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    11.sp),
                                                            textAlign:
                                                                TextAlign.end,
                                                          ),
                                                        ),
                                                        Expanded(
                                                            flex: 2,
                                                            child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left: 10
                                                                            .sp),
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child:
                                                                    TextButton(
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Colors.red[
                                                                            600],
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await handleVerifUpdateInkaroItem(
                                                                        context,
                                                                        widget
                                                                            .customerList,
                                                                        widget
                                                                            .positionCustomer,
                                                                        widget
                                                                            .listInkaroHeader,
                                                                        widget
                                                                            .positionInkaro,
                                                                        inkaroRegSelected,
                                                                        inkaroProgSelected,
                                                                        inkaroManualSelected,
                                                                        refreshListAfterTambahData,
                                                                        listInkaroDetailManual,
                                                                        index,
                                                                        "delete");
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .white,
                                                                    size:
                                                                        15.0.sp,
                                                                  ),
                                                                ))),
                                                      ],
                                                    ));
                                              }))
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
                                                    fontSize: isHorizontal
                                                        ? 24.sp
                                                        : 14.sp,
                                                    fontFamily: 'Montserrat',
                                                  ))))
                                ],
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Row(children: [
                            Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await getOptionInkaroManual();
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return dialogInkaroManual(
                                              itemInkaroManual);
                                        });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 15.0),
                                      primary: Colors.blue[700]),
                                  child: Text(
                                    "+ Tambah Inkaro Manual",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13.sp),
                                  ),
                                )),
                          ]),
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget dialogCoba() {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: Container(
          height: MediaQuery.of(context).size.height - 400,
          width: MediaQuery.of(context).size.width - 400,
          child: Text("test"),
        ),
      );
    });
  }

  Widget dialogInkaroReguler() {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(
          'Pilih Inkaro Reguler',
          textAlign: TextAlign.center,
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(left: 7.0, right: 7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await getSelectedInkaroReguler();
                      await handleVerifUpdateInkaroItem(
                          context,
                          widget.customerList,
                          widget.positionCustomer,
                          widget.listInkaroHeader,
                          widget.positionInkaro,
                          inkaroRegSelected,
                          inkaroProgSelected,
                          inkaroManualSelected,
                          refreshListAfterTambahData,
                          listInkaroDetailReguler,
                          0,
                          "add");
                    },
                    child: Text(
                      "Tambahkan",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ],
            ),
          )
        ],
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder(
                  future: getOptionInkaroReguler(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<InkaroReguler>> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        return snapshot.hasData
                            ? widgetListInkaroReguler()
                            : Center(
                                child: Text('Data tidak ditemukan'),
                              );
                    }
                  }),
            ],
          ),
        ),
      );
    });
  }

  Widget widgetListInkaroReguler() {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        children: [
          itemInkaroReguler.length > 0
              ? Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )),
                  margin: EdgeInsets.only(bottom: 10.h),
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: checkAllInkaroReguler,
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pilih Semua",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),
                    onChanged: (bool? val) {
                      setState(() {
                        checkAllInkaroReguler = val!;
                        for (var loopUpdateCheckedReguler = 0;
                            loopUpdateCheckedReguler < itemInkaroReguler.length;
                            loopUpdateCheckedReguler++) {
                          itemInkaroReguler[loopUpdateCheckedReguler]
                              .ischecked = val;
                        }
                      });
                    },
                  ),
                )
              : SizedBox(),
          itemInkaroReguler.length > 0
              ? Container(
                  // width: double.minPositive.w,
                  width: MediaQuery.of(context).size.width / 1,
                  height: 300.h,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemInkaroReguler.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              )),
                          margin: EdgeInsets.only(bottom: 10.h),
                          child: CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: itemInkaroReguler[index].ischecked,
                            title: Padding(
                              padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemInkaroReguler[index].descKategori,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.sp,
                                  ),
                                  Text(
                                    "Inkaro : " +
                                        convertToIdr(
                                            int.parse(itemInkaroReguler[index]
                                                .inkaroValue),
                                            0),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12.sp,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            onChanged: (bool? val) {
                              setState(() {
                                itemInkaroReguler[index].ischecked = val!;
                              });
                            },
                          ));
                    },
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(top: 20.sp),
                  child: Text("Data Kosong"),
                ),
        ],
      );
    });
  }

  Widget dialogInkaroProgram() {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(
          'Pilih Inkaro Program',
          textAlign: TextAlign.center,
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(left: 7.0, right: 7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await getSelectedInkaroProgram();
                      await handleVerifUpdateInkaroItem(
                          context,
                          widget.customerList,
                          widget.positionCustomer,
                          widget.listInkaroHeader,
                          widget.positionInkaro,
                          inkaroRegSelected,
                          inkaroProgSelected,
                          inkaroManualSelected,
                          refreshListAfterTambahData,
                          listInkaroDetailReguler,
                          0,
                          "add");
                    },
                    child: Text(
                      "Tambahkan",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ],
            ),
          )
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Switch(
                  value: isSwitchedHouseBrandProgram,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedHouseBrandProgram = value;
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
                Text(
                  "House Brand",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    fontFamily: 'Montserrat',
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10.r),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white70,
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(5.r)),
                child: DropdownButton(
                  underline: SizedBox(),
                  isExpanded: true,
                  value: _choosenFilterSubcatProg,
                  style: TextStyle(
                    color: Colors.black54,
                    fontFamily: 'Segoe Ui',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _dataFilterSubcat.map((e) {
                    return DropdownMenuItem(
                      value: e.idKategori,
                      child: Padding(
                          padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
                          child: Text(e.descKategori,
                              style: TextStyle(color: Colors.black54))),
                    );
                  }).toList(),
                  hint: Padding(
                      padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
                      child: Text(
                        "Filter Kategori",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe Ui'),
                      )),
                  onChanged: (String? value) {
                    setState(() {
                      _choosenFilterSubcatProg = value!;
                      getOptionInkaroProgram();
                      checkAllInkaroProgram = false;
                    });
                  },
                ),
              ),
            ),
            FutureBuilder(
                future: getOptionInkaroProgram(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<InkaroProgram>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      return snapshot.hasData
                          ? widgetListInkaroProgram()
                          : Center(
                              child: Text('Data tidak ditemukan'),
                            );
                  }
                })
          ],
        ),
      );
    });
  }

  Widget widgetListInkaroProgram() {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        children: [
          itemInkaroProgram.length > 0
              ? Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )),
                  margin: EdgeInsets.only(bottom: 10.h),
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: checkAllInkaroProgram,
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pilih Semua",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),
                    onChanged: (bool? val) {
                      setState(() {
                        checkAllInkaroProgram = val!;
                        for (var loopUpdateCheckedProgram = 0;
                            loopUpdateCheckedProgram < itemInkaroProgram.length;
                            loopUpdateCheckedProgram++) {
                          itemInkaroProgram[loopUpdateCheckedProgram]
                              .ischecked = val;
                        }
                      });
                    },
                  ),
                )
              : SizedBox(),
          itemInkaroProgram.length > 0
              ? Container(
                  // width: double.minPositive.w,
                  width: MediaQuery.of(context).size.width / 1,
                  height: 300.h,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemInkaroProgram.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              )),
                          margin: EdgeInsets.only(bottom: 10.h),
                          child: CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: itemInkaroProgram[index].ischecked,
                            title: Padding(
                              padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemInkaroProgram[index].descSubcategory,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.sp,
                                  ),
                                  Text(
                                    "Inkaro : " +
                                        convertToIdr(
                                            int.parse(itemInkaroProgram[index]
                                                .inkaroValue),
                                            0),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12.sp,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            onChanged: (bool? val) {
                              setState(() {
                                itemInkaroProgram[index].ischecked = val!;
                              });
                            },
                          ));
                    },
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(top: 20.sp),
                  child: Text("Data Kosong"),
                ),
        ],
      );
    });
  }

  Widget dialogInkaroManual(List<InkaroManual> item) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: Text(
          'Pilih Inkaro Manual',
          textAlign: TextAlign.center,
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(bottom: 5.sp, top: 5.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: checkSetAllValueManual,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Set Semua Inkaro yang Dipilih Menjadi : ",
                        style: TextStyle(color: Colors.black, fontSize: 12.sp),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(
                        height: 5.sp,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.sp),
                        child: TextFormField(
                          enabled: checkSetAllValueManual,
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 5.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            hintStyle: TextStyle(
                              fontFamily: 'Segoe Ui',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          initialValue: ThousandsSeparatorInputFormatter()
                              .formatEditUpdate(TextEditingValue.empty,
                                  TextEditingValue(text: "0"))
                              .text,
                          onChanged: (value) {
                            allValueManual = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  onChanged: (bool? val) {
                    setState(() {
                      checkAllInkaroManual = false;
                      checkSetAllValueManual = val!;
                    });
                  },
                ),
                ElevatedButton(
                    onPressed: () async {
                      await getSelectedInkaroManual();
                      await handleVerifUpdateInkaroItem(
                          context,
                          widget.customerList,
                          widget.positionCustomer,
                          widget.listInkaroHeader,
                          widget.positionInkaro,
                          inkaroRegSelected,
                          inkaroProgSelected,
                          inkaroManualSelected,
                          refreshListAfterTambahData,
                          listInkaroDetailReguler,
                          0,
                          "add");
                    },
                    child: Text(
                      "Tambahkan",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ],
            ),
          )
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Switch(
                  value: isSwitchedHouseBrandManual,
                  onChanged: (value) {
                    setState(() {
                      isSwitchedHouseBrandManual = value;
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
                Text(
                  "House Brand",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    fontFamily: 'Montserrat',
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 5.sp),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white70,
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(5.r)),
                child: DropdownButton(
                  underline: SizedBox(),
                  isExpanded: true,
                  value: _choosenFilterSubcatManual,
                  style: TextStyle(
                    color: Colors.black54,
                    fontFamily: 'Segoe Ui',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _dataFilterSubcat.map((e) {
                    return DropdownMenuItem(
                      value: e.idKategori,
                      child: Padding(
                          padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
                          child: Text(e.descKategori,
                              style: TextStyle(color: Colors.black54))),
                    );
                  }).toList(),
                  hint: Padding(
                      padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
                      child: Text(
                        "Filter Kategori",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe Ui'),
                      )),
                  onChanged: (String? value) {
                    setState(() {
                      _choosenFilterSubcatManual = value!;
                      getOptionInkaroManual();
                      checkAllInkaroManual = false;
                    });
                  },
                ),
              ),
            ),
            FutureBuilder(
                future: getOptionInkaroManual(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<InkaroManual>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      return snapshot.hasData
                          ? widgetListInkaroManual()
                          : Center(
                              child: Text('Data tidak ditemukan'),
                            );
                  }
                })
          ],
        ),
      );
    });
  }

  Widget widgetListInkaroManual() {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        children: [
          itemInkaroManual.length > 0
              ? Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )),
                  margin: EdgeInsets.only(bottom: 10.h),
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: checkAllInkaroManual,
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pilih Semua",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),
                    onChanged: (bool? val) {
                      setState(() {
                        checkAllInkaroManual = val!;
                        for (var loopUpdateCheckedManual = 0;
                            loopUpdateCheckedManual < itemInkaroManual.length;
                            loopUpdateCheckedManual++) {
                          itemInkaroManual[loopUpdateCheckedManual].ischecked =
                              val;
                        }
                      });
                    },
                  ),
                )
              : SizedBox(),
          itemInkaroManual.length > 0
              ? Container(
                  // width: double.minPositive.w,
                  width: MediaQuery.of(context).size.width / 1,
                  height: 300.h,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemInkaroManual.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              )),
                          margin: EdgeInsets.only(bottom: 10.h),
                          child: CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: itemInkaroManual[index].ischecked,
                            title: Padding(
                              padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemInkaroManual[index].descSubcategory,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Text(
                                    "Inkaro Program : " +
                                        convertToIdr(
                                            int.parse(itemInkaroManual[index]
                                                .inkaroProgram),
                                            0),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  TextFormField(
                                    enabled: checkSetAllValueManual
                                        ? false
                                        : itemInkaroManual[index].ischecked,
                                    inputFormatters: [
                                      ThousandsSeparatorInputFormatter()
                                    ],
                                    keyboardType: TextInputType.number,
                                    maxLength: 10,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10.r,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      hintStyle: TextStyle(
                                        fontFamily: 'Segoe Ui',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                    initialValue: checkSetAllValueManual
                                        ? ''
                                        : ThousandsSeparatorInputFormatter()
                                            .formatEditUpdate(
                                                TextEditingValue.empty,
                                                TextEditingValue(
                                                    text:
                                                        itemInkaroManual[index]
                                                            .inkaroValue
                                                            .toString()))
                                            .text,
                                    onChanged: (value) {
                                      setState(() {
                                        itemInkaroManual[index].inkaroValue =
                                            value.replaceAll(".", "");
                                      });
                                    },
                                    onSaved: (value) {
                                      setState(() {
                                        itemInkaroManual[index].inkaroValue =
                                            value!.replaceAll(".", "");
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            onChanged: (bool? val) {
                              setState(() {
                                itemInkaroManual[index].ischecked = val!;
                              });
                            },
                          ));
                    },
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(top: 20.sp),
                  child: Text("Data Kosong"),
                ),
        ],
      );
    });
  }
}
