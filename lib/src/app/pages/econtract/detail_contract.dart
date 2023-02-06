import 'dart:async';
import 'dart:convert';
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
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/dialogImage.dart';
import 'package:sample/src/domain/entities/actcontract.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/discount.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class DetailContract extends StatefulWidget {
  Contract item;
  String div;
  String ttd;
  String username;
  bool isMonitoring;
  bool? isContract = false;
  bool? isAdminRenewal = false;
  bool? isHasDisc = false;
  bool? isNewCust = false;

  DetailContract(
    this.item,
    this.div,
    this.ttd,
    this.username,
    this.isMonitoring, {
    this.isContract,
    this.isAdminRenewal,
    this.isHasDisc,
    this.isNewCust,
  });

  @override
  _DetailContractState createState() => _DetailContractState();
}

class _DetailContractState extends State<DetailContract> {
  String? id = '';
  String? role = '';
  String? divisi = '';
  String opticName = '';
  late String tokenAdmin, tokenSales;
  bool _isLoading = true;
  bool _isLoadingTitle = true;
  List<Discount> discList = List.empty(growable: true);
  List<ActContract> itemActiveContract = List.empty(growable: true);
  TextEditingController textReason = new TextEditingController();
  String reasonVal = '';
  bool _isReason = false;
  Customer? cust;

  late bool _permissionReady;
  late String _localPath;
  final ReceivePort _port = ReceivePort();

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      divisi = preferences.getString("divisi");

      _permissionReady = false;
      _retryRequestPermission();

      IsolateNameServer.registerPortWithName(
        _port.sendPort,
        'downloader_contract',
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

      getAdmToken(int.parse(id!));

      if (double.tryParse(widget.item.createdBy) == null) {
        print('The input is not a numeric string');
      } else {
        print('Yes, it is a numeric string');
        getSalesToken(int.parse(widget.item.createdBy));
      }
    });
  }

  getAdmToken(int input) async {
    const timeout = 15;
    var url = '$API_URL/users?id=$input';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          tokenAdmin = data['data']['gentoken'];
          print('Token admin : $tokenAdmin');
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleConnectionAdmin(context);
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
        var data = json.decode(response.body);
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
    var url = '$PDFURL/contract_pdf/$idCust';

    await FlutterDownloader.enqueue(
      url: url,
      fileName: "Contract $custName.pdf",
      requiresStorageNotLow: true,
      savedDir: locatedFile,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  getDisc(dynamic idContract) async {
    const timeout = 15;
    var url = '$API_URL/discount/getByIdContract?id_contract=$idContract';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          discList =
              rest.map<Discount>((json) => Discount.fromJson(json)).toList();
          print("List Size: ${discList.length}");

          discList.length > 0
              ? widget.isHasDisc = true
              : widget.isHasDisc = false;
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
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  getCustomer(dynamic idCust) async {
    const timeout = 15;
    var url = '$API_URL/customers?id=$idCust&id_salesmanager=';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);

          cust = Customer.fromJson(rest);
          print("Customer Info : ${cust!.namaUsaha}");

          opticName = rest['nama_usaha'].toString().toUpperCase();
        } else {
          opticName = widget.item.customerShipName.toUpperCase();
        }

        print('optic name : $opticName');

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoadingTitle = false;
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

  @override
  initState() {
    super.initState();
    getRole();
    getDisc(widget.item.hasParent.contains('1')
        ? widget.item.idContractParent
        : widget.item.idContract);
    print('Id Customer : ${widget.item.idCustomer}');
    getCustomer(widget.item.idCustomer);
    widget.item.hasParent == '1'
        ? getActiveContract(widget.item.idParent)
        : print('Bukan child');
  }

  getActiveContract(dynamic input) async {
    itemActiveContract.clear();
    const timeout = 15;
    var url = '$API_URL/contract/parentCheck?id_customer=$input';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          itemActiveContract = rest
              .map<ActContract>((json) => ActContract.fromJson(json))
              .toList();
          print('List Size : ${itemActiveContract.length}');
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

  Future<List<Discount>> getDiscountData(dynamic idContract,
      {bool isHorizontal = false}) async {
    const timeout = 15;
    List<Discount> list = [];
    var url = '$API_URL/discount/getByIdContract?id_contract=$idContract';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest.map<Discount>((json) => Discount.fromJson(json)).toList();
          print("List Size: ${list.length}");
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }

    return list;
  }

  approveContract(bool isAr, String idCust, String username,
      {bool isHorizontal = false}) async {
    const timeout = 15;
    var url = !isAr
        ? '$API_URL/approval/approveContractSM'
        : '$API_URL/approval/approveContractAM';

    try {
      var response = await http
          .post(
            Uri.parse(url),
            body: !isAr
                ? {
                    'id_customer': idCust,
                    'approver_sm': username,
                  }
                : {
                    'id_customer': idCust,
                    'approver_am': username,
                  },
          )
          .timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        widget.isAdminRenewal!
            ? handleCustomStatus(
                context,
                capitalize(msg),
                sts,
                isHorizontal: isHorizontal,
              )
            : handleStatus(
                context,
                capitalize(msg),
                sts,
                isHorizontal: isHorizontal,
                isLogout: false,
              );

        //Approve Kontrak
        //Send to sales spesifik
        pushNotif(
          7,
          3,
          idUser: widget.item.createdBy,
          rcptToken: tokenSales,
          admName: username,
          opticName: opticName,
        );

        //Approve Kontrak
        //Send to me
        pushNotif(
          6,
          3,
          idUser: id,
          rcptToken: tokenAdmin,
          salesName: widget.item.namaPertama,
          opticName: opticName,
        );
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

  approveCustomer(bool isAr, String idCust, String ttd, String username,
      {bool isHorizontal = false}) async {
    const timeout = 15;
    var url =
        !isAr ? '$API_URL/approval/approveSM' : '$API_URL/approval/approveAM';

    try {
      var response = await http
          .post(
            Uri.parse(url),
            body: !isAr
                ? {
                    'id_customer': idCust,
                    'nama_sales_manager': username,
                  }
                : {
                    'id_customer': idCust,
                    'nama_ar_manager': username,
                  },
          )
          .timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        approveContract(
          isAr,
          idCust,
          username,
          isHorizontal: isHorizontal,
        );
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

  rejectContract(bool isAr, String idCust, String username, String reason,
      {bool isHorizontal = false}) async {
    const timeout = 15;
    var url = !isAr
        ? '$API_URL/approval/rejectContractSM'
        : '$API_URL/approval/rejectContractAM';

    try {
      var response = await http
          .post(
            Uri.parse(url),
            body: !isAr
                ? {
                    'id_customer': idCust,
                    'approver_sm': username,
                    'reason_sm': reason,
                  }
                : {
                    'id_customer': idCust,
                    'approver_am': username,
                    'reason_am': reason,
                  },
          )
          .timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Username : $username');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        widget.isAdminRenewal!
            ? handleCustomStatus(
                context,
                capitalize(msg),
                sts,
                isHorizontal: isHorizontal,
              )
            : handleStatus(
                context,
                capitalize(msg),
                sts,
                isHorizontal: isHorizontal,
                isLogout: false,
              );

        //REJECT KONTRAK
        //Send to sales spesifik
        pushNotif(
          9,
          3,
          idUser: widget.item.createdBy,
          rcptToken: tokenSales,
          admName: username,
          opticName: opticName,
        );

        //REJECT KONTRAK
        //Send to me
        pushNotif(
          8,
          3,
          idUser: id,
          rcptToken: tokenAdmin,
          salesName: widget.item.namaPertama,
          opticName: opticName,
        );
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

  rejectCustomer(
      bool isAr, String idCust, String ttd, String username, String reason,
      {bool isHorizontal = false}) async {
    const timeout = 15;
    var url =
        !isAr ? '$API_URL/approval/rejectSM' : '$API_URL/approval/rejectAM';

    try {
      var response = await http
          .post(
            Uri.parse(url),
            body: !isAr
                ? {
                    'id_customer': idCust,
                    'nama_sales_manager': username,
                  }
                : {
                    'id_customer': idCust,
                    'nama_ar_manager': username,
                  },
          )
          .timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      rejectContract(
        isAr,
        idCust,
        username,
        reason,
        isHorizontal: isHorizontal,
      );
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

  approveOldCustomer({bool isHorizontal = false}) {
    widget.div == "AR"
        ? approveContract(
            true,
            widget.item.idCustomer,
            widget.username,
            isHorizontal: isHorizontal,
          )
        : approveContract(
            false,
            widget.item.idCustomer,
            widget.username,
            isHorizontal: isHorizontal,
          );
  }

  approveNewCustomer({bool isHorizontal = false}) {
    widget.div == "AR"
        ? approveCustomer(
            true,
            widget.item.idCustomer,
            widget.ttd,
            widget.username,
            isHorizontal: isHorizontal,
          )
        : approveCustomer(
            false,
            widget.item.idCustomer,
            widget.ttd,
            widget.username,
            isHorizontal: isHorizontal,
          );

    widget.div == "AR"
        ? approveContract(
            true,
            widget.item.idCustomer,
            widget.username,
            isHorizontal: isHorizontal,
          )
        : approveContract(
            false,
            widget.item.idCustomer,
            widget.username,
            isHorizontal: isHorizontal,
          );
  }

  rejectOldCustomer({bool isHorizontal = false}) {
    widget.div == "AR"
        ? rejectContract(
            true,
            widget.item.idCustomer,
            widget.username,
            textReason.text.trim(),
            isHorizontal: isHorizontal,
          )
        : rejectContract(
            false,
            widget.item.idCustomer,
            widget.username,
            textReason.text.trim(),
            isHorizontal: isHorizontal,
          );
  }

  rejectNewCustomer({bool isHorizontal = false}) {
    widget.div == "AR"
        ? rejectCustomer(
            true,
            widget.item.idCustomer,
            widget.ttd,
            widget.username,
            textReason.text.trim(),
            isHorizontal: isHorizontal,
          )
        : rejectCustomer(
            false,
            widget.item.idCustomer,
            widget.ttd,
            widget.username,
            textReason.text.trim(),
            isHorizontal: isHorizontal,
          );
  }

  checkEntry({bool isHorizontal = false}) {
    textReason.text.isEmpty ? _isReason = true : _isReason = false;

    if (!_isReason) {
      widget.isContract!
          ? rejectOldCustomer(
              isHorizontal: isHorizontal,
            )
          : rejectNewCustomer(
              isHorizontal: isHorizontal,
            );
      Navigator.of(context, rootNavigator: true).pop();
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

  handleRejection(BuildContext context, Function stop,
      {bool isHorizontal = false}) {
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
            stop();
            checkEntry(
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
            stop();
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        widget.isAdminRenewal!
                            ? Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => AdminScreen()))
                            : Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: isHor ? 20.r : 15.r,
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(CircleBorder()),
                        padding: MaterialStateProperty.all(EdgeInsets.all(8.r)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.r,
                      vertical: opticName == "null"
                          ? 3.r
                          : opticName.length > 32
                              ? 3.r
                              : 15.r,
                    ),
                    child: Center(
                      child: _isLoadingTitle
                          ? Center(
                              child: Text(
                                'Processing ...',
                                style: TextStyle(
                                  fontSize: isHor ? 25.sp : 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            )
                          : Text(
                              'KONTRAK $opticName',
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
                  image: AssetImage('assets/images/sepakat.jpg'),
                  fit: isHor ? BoxFit.cover : BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            SizedBox(
              height: isHor ? 20.h : 15.h,
            ),
            _isLoadingTitle
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isHor ? 30.r : 20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isHor ? 10.r : 5.r,
                            horizontal: isHor ? 15.r : 10.r,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[600],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            widget.item.typeContract != 'LENSA' ||
                                    widget.item.typeContract == ''
                                ? 'KONTRAK ${widget.item.typeContract}'
                                : 'KONTRAK LENSA',
                            style: TextStyle(
                              fontSize: isHor ? 14.sp : 12.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: isHor ? 20.h : 15.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: isHor ? 1 : 1,
                              child: Text(
                                'Berlaku tanggal',
                                style: TextStyle(
                                  fontSize: isHor ? 18.sp : 16.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Hingga tanggal',
                                style: TextStyle(
                                  fontSize: isHor ? 18.sp : 16.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign:
                                    isHor ? TextAlign.end : TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: isHor ? 20.r : 10.r,
                                ),
                                child: Text(
                                  convertDateWithMonth(
                                      widget.item.startContract),
                                  style: TextStyle(
                                    fontSize: isHor ? 18.sp : 16.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: isHor ? 20.r : 10.r,
                                ),
                                child: Text(
                                  convertDateWithMonth(widget.item.endContract),
                                  style: TextStyle(
                                    fontSize: isHor ? 18.sp : 16.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHor ? 15.h : 8.h,
                        ),
                        Container(
                          height: isHor ? 3.h : 1.3.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                        ),
                        SizedBox(
                          height: isHor ? 15.h : 8.h,
                        ),
                        Text(
                          'Pihak Pertama',
                          style: TextStyle(
                            fontSize: isHor ? 18.sp : 16.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                        SizedBox(
                          height: isHor ? 15.h : 10.h,
                        ),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 5.w,
                              ),
                              VerticalDivider(
                                color: Colors.orange[500],
                                thickness: isHor ? 5 : 3.5,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Nama',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Jabatan',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.end,
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
                                        Expanded(
                                          child: Text(
                                            widget.item.namaPertama,
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            widget.item.jabatanPertama,
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'No Telp',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'No Fax',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.end,
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
                                        Expanded(
                                          child: Text(
                                            '021-4610154',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '021-4610151-52',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      'Alamat : ',
                                      style: TextStyle(
                                        fontSize: isHor ? 16.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    Text(
                                      'Jl. Rawa Kepiting No. 4 Kawasan Industri Pulogadung, Jakarta Timur',
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        fontSize: isHor ? 16.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: isHor ? 30.h : 25.h,
                        ),
                        Text(
                          'Pihak Kedua',
                          style: TextStyle(
                            fontSize: isHor ? 18.sp : 16.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                        SizedBox(
                          height: isHor ? 15.h : 10.h,
                        ),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 5.w,
                              ),
                              VerticalDivider(
                                color: Colors.green[600],
                                thickness: isHor ? 5 : 3.5,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Nama',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Jabatan',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.end,
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
                                        Expanded(
                                          child: Text(
                                            widget.item.namaKedua,
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Owner',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'No KTP',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'No NPWP',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.end,
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
                                        Expanded(
                                          child: Text(
                                            widget.isNewCust!
                                                ? cust?.noIdentitas ?? '-'
                                                : widget.item.ktpNpwp.isNotEmpty
                                                    ? widget.item.ktpNpwp
                                                    : '-',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            widget.isNewCust!
                                                ? cust?.noNpwp ?? '-'
                                                : '-',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'No Telp',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'No WA / Fax',
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.end,
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
                                        Expanded(
                                          child: Text(
                                            widget.item.telpKedua,
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            widget.item.faxKedua,
                                            style: TextStyle(
                                              fontSize: isHor ? 16.sp : 14.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Text(
                                      'Alamat : ',
                                      style: TextStyle(
                                        fontSize: isHor ? 16.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    Text(
                                      widget.item.alamatKedua,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        fontSize: isHor ? 16.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        widget.isNewCust!
                            ? areaOptik(isHor: isHor)
                            : SizedBox(
                                width: 5.w,
                              ),
                        SizedBox(
                          height: isHor ? 15.h : 8.h,
                        ),
                        Container(
                          height: isHor ? 3.h : 1.3.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                        ),
                        widget.isNewCust!
                            ? areaFoto(
                                isHor: isHor,
                              )
                            : SizedBox(
                                width: 5.w,
                              ),
                        SizedBox(
                          height: isHor ? 35.h : 20.h,
                        ),
                        Text(
                          'Target Pembelian yang disepakati',
                          style: TextStyle(
                            fontSize: isHor ? 18.sp : 16.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: isHor ? 15.h : 8.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Lensa Nikon',
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Lensa Leinz',
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                convertToIdr(int.parse(widget.item.tpNikon), 0),
                                style: TextStyle(
                                    fontSize: isHor ? 16.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                convertToIdr(int.parse(widget.item.tpLeinz), 0),
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Lensa Oriental',
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Lensa Moe',
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                convertToIdr(
                                    int.parse(widget.item.tpOriental), 0),
                                style: TextStyle(
                                    fontSize: isHor ? 16.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                convertToIdr(int.parse(widget.item.tpMoe), 0),
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHor ? 30.h : 25.h,
                        ),
                        Text(
                          'Jangka waktu pembayaran',
                          style: TextStyle(
                            fontSize: isHor ? 18.sp : 16.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: isHor ? 15.h : 8.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Lensa Nikon RX',
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Lensa Leinz RX',
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.pembNikon,
                                style: TextStyle(
                                    fontSize: isHor ? 16.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.item.pembLeinz,
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Lensa Nikon Stock',
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Lensa Leinz Stock',
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.pembNikonSt,
                                style: TextStyle(
                                    fontSize: isHor ? 16.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.item.pembLeinzSt,
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Lensa Oriental RX',
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Lensa Moe RX',
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.pembOriental,
                                style: TextStyle(
                                    fontSize: isHor ? 16.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.item.pembMoe,
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHor ? 15.h : 8.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Lensa Oriental Stock',
                                style: TextStyle(
                                  fontSize: isHor ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.pembOrientalSt,
                                style: TextStyle(
                                    fontSize: isHor ? 16.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHor ? 15.h : 8.h,
                        ),
                        Container(
                          height: isHor ? 3.h : 1.3.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        widget.item.typeContract != "CASHBACK"
                            ? areaDiskon(
                                widget.item,
                                isHorizontal: isHor,
                              )
                            : SizedBox(
                                width: 5.w,
                              ),
                        widget.item.typeContract == "CASHBACK"
                            ? Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Text(
                                      'KETERANGAN',
                                      style: TextStyle(
                                        fontFamily: 'Segoe Ui',
                                        fontSize: isHor ? 16.sp : 16.sp,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5.r,
                                      ),
                                    ),
                                    SizedBox(
                                      height: isHor ? 15.h : 10.h,
                                    ),
                                    Text(
                                      'Diskon tidak tersedia pada kontrak Cashback.',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: isHor ? 14.sp : 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.justify,
                                    )
                                  ],
                                ),
                              )
                            : SizedBox(
                                width: 5.w,
                              ),
                        widget.item.isFrame == "1" ||
                                widget.item.isPartai == "1"
                            ? Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Text(
                                      'KETERANGAN',
                                      style: TextStyle(
                                        fontFamily: 'Segoe Ui',
                                        fontSize: isHor ? 16.sp : 16.sp,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5.r,
                                      ),
                                    ),
                                    SizedBox(
                                      height: isHor ? 15.h : 10.h,
                                    ),
                                    widget.item.isFrame.contains('1')
                                        ? Text(
                                            'Diskon khusus pada kontrak frame disesuakan dengan surat pesanan (SP) .',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: isHor ? 14.sp : 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.justify,
                                          )
                                        : SizedBox(
                                            width: 10.h,
                                          ),
                                    SizedBox(
                                      height: isHor ? 15.h : 10.h,
                                    ),
                                    widget.item.isPartai.contains('1')
                                        ? Text(
                                            'Diskon khusus pada kontrak partai disesuakan dengan surat pesanan (SP) .',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: isHor ? 14.sp : 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.justify,
                                          )
                                        : SizedBox(
                                            width: 10.h,
                                          ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                width: 10.w,
                              ),
                        SizedBox(
                          height: 30.h,
                        ),
                        widget.isMonitoring
                            ? Center(
                                child: ArgonButton(
                                  height: isHor ? 50.h : 40.h,
                                  width: isHor ? 90.w : 150.w,
                                  borderRadius: 30.0.r,
                                  color: Colors.blue[700],
                                  child: Text(
                                    "Unduh Kontrak",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isHor ? 16.sp : 14.sp,
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
                                        donwloadContract(widget.item.idCustomer,
                                            opticName, _localPath);
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
                              )
                            : SizedBox(
                                height: 5.h,
                              ),
                        widget.isMonitoring
                            ? SizedBox(
                                height: 5.h,
                              )
                            : handleAction(
                                isHorizontal: isHor,
                              ),
                        SizedBox(
                          height: isHor ? 20.h : 10.h,
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget areaDiskon(Contract item, {bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 0.r,
                vertical: isHorizontal ? 10.r : 5.r,
              ),
              child: Text(
                'Kontrak Diskon',
                style: TextStyle(
                    fontSize: isHorizontal ? 18.sp : 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        itemActiveContract.isNotEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isHorizontal ? 6.r : 3.r,
                ),
                child: Card(
                  elevation: 2,
                  child: Container(
                    height: isHorizontal ? 80.w : 60.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.r,
                      vertical: 10.r,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                itemActiveContract[0].customerBillName,
                                style: TextStyle(
                                  fontSize: isHorizontal ? 16.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Kontrak tahun ${itemActiveContract[0].startContract.substring(0, 4)}',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 16.sp : 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Segoe ui',
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/images/success.png',
                          width: 25.r,
                          height: 25.r,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox(
                width: 5.w,
              ),
        SizedBox(
          height: 3.h,
        ),
        _isLoading
            ? Center(
                child: Text(
                  'Processing ...',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              )
            : widget.isHasDisc == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Deskripsi produk',
                          style: TextStyle(
                            fontSize: isHorizontal ? 16.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Diskon',
                          style: TextStyle(
                            fontSize: isHorizontal ? 16.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  )
                : widget.isHasDisc!
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Deskripsi produk',
                              style: TextStyle(
                                fontSize: isHorizontal ? 16.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Diskon',
                              style: TextStyle(
                                fontSize: isHorizontal ? 16.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        height: 3.h,
                      ),
        Container(
          width: double.maxFinite.w,
          height: 170.h,
          child: FutureBuilder(
              future: getDiscountData(
                widget.item.hasParent.contains('1')
                    ? widget.item.idContractParent
                    : widget.item.idContract,
                isHorizontal: isHorizontal,
              ),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Discount>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return snapshot.data != null
                        ? listDiscWidget(
                            snapshot.data!,
                            snapshot.data!.length,
                            isHorizontal: isHorizontal,
                          )
                        : Column(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/not_found.png',
                                  width: isHorizontal ? 130.w : 145.w,
                                  height: isHorizontal ? 130.w : 145.h,
                                ),
                              ),
                              Text(
                                'Item Discount tidak ditemukan',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 16.sp : 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                            ],
                          );
                }
              }),
        ),
      ],
    );
  }

  Widget listDiscWidget(List<Discount> item, int len,
      {bool isHorizontal = false}) {
    return ListView.builder(
        itemCount: len,
        padding: EdgeInsets.symmetric(
          horizontal: 0.r,
          vertical: 5.r,
        ),
        itemBuilder: (context, position) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: isHorizontal ? 8.r : 4.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item[position].prodDesc,
                    style: TextStyle(
                      fontSize: isHorizontal ? 16.sp : 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${item[position].discount} %',
                    style: TextStyle(
                      fontSize: isHorizontal ? 16.sp : 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        });
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
          child: ArgonButton(
            height: isHorizontal ? 60.h : 40.h,
            width: isHorizontal ? 80.w : 100.w,
            borderRadius: isHorizontal ? 60.r : 30.r,
            color: Colors.red[700],
            child: Text(
              "Reject",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 24.sp : 14.sp,
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
                setState(() {
                  startLoading();
                  waitingLoad();
                  handleRejection(
                    context,
                    stopLoading,
                    isHorizontal: isHorizontal,
                  );
                });
              }
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 30.r : 20.r,
            vertical: 5.r,
          ),
          alignment: Alignment.centerRight,
          child: ArgonButton(
            height: isHorizontal ? 60.h : 40.h,
            width: isHorizontal ? 80.w : 100.w,
            borderRadius: isHorizontal ? 60.r : 30.r,
            color: Colors.blue[600],
            child: Text(
              "Approve",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 24.sp : 14.sp,
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
                setState(() {
                  startLoading();
                  waitingLoad();
                  widget.isContract!
                      ? approveOldCustomer(
                          isHorizontal: isHorizontal,
                        )
                      : approveNewCustomer(
                          isHorizontal: isHorizontal,
                        );
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget areaOptik({bool isHor = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: isHor ? 35.h : 25.h,
        ),
        Text(
          'Informasi Optik',
          style: TextStyle(
            fontSize: isHor ? 18.sp : 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.blue[800],
          ),
        ),
        SizedBox(
          height: isHor ? 15.h : 10.h,
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: 5.w,
              ),
              VerticalDivider(
                color: Colors.blue[600],
                thickness: isHor ? 5 : 3.5,
              ),
              SizedBox(
                width: 10.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Nama Optik',
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Telp',
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            opticName,
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            cust?.tlpUsaha ?? '-',
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'No Fax',
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cust?.faxUsaha ?? '-',
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            cust?.emailUsaha ?? '-',
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Penanggung Jawab',
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Kredit Limit',
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cust?.namaPj ?? '',
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            cust?.kreditLimit ?? '0',
                            style: TextStyle(
                              fontSize: isHor ? 16.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      'Alamat Optik : ',
                      style: TextStyle(
                        fontSize: isHor ? 16.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Text(
                      cust?.alamatUsaha ?? '-',
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontSize: isHor ? 16.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget areaFoto({bool isHor = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: isHor ? 15.h : 10.h,
        ),
        Text(
          'Dokumen Pendukung',
          style: TextStyle(
            fontSize: isHor ? 18.sp : 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: isHor ? 15.h : 10.h,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * (isHor ? 1.2 : 0.93),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                cust?.uploadIdentitas != ''
                    ? InkWell(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            8.r,
                          ),
                          child: Image.memory(
                            base64Decode(cust!.uploadIdentitas),
                            width: isHor ? 95.w : 60.w,
                            height: isHor ? 110.h : 60.h,
                            fit: isHor ? BoxFit.cover : BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DialogImage(
                                'Foto KTP',
                                cust!.uploadIdentitas,
                              );
                            },
                          );
                        },
                      )
                    : InkWell(
                        child: Image.asset(
                          'assets/images/picture.png',
                          width: isHor ? 95.w : 60.w,
                          height: isHor ? 110.h : 60.h,
                        ),
                        onTap: () => showStyledToast(
                          child: Text('Foto ktp tidak ditemukan'),
                          context: context,
                          backgroundColor: Colors.red,
                          borderRadius: BorderRadius.circular(15.r),
                          duration: Duration(seconds: 2),
                        ),
                      ),
                cust?.gambarKartuNama != ''
                    ? InkWell(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            8.r,
                          ),
                          child: Image.memory(
                            base64Decode(cust!.gambarKartuNama),
                            width: isHor ? 95.w : 60.w,
                            height: isHor ? 110.h : 60.h,
                            fit: isHor ? BoxFit.cover : BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DialogImage(
                                'Foto Kartu Nama',
                                cust!.gambarKartuNama,
                              );
                            },
                          );
                        },
                      )
                    : InkWell(
                        child: Image.asset(
                          'assets/images/picture.png',
                          width: isHor ? 95.w : 60.w,
                          height: isHor ? 110.h : 60.h,
                        ),
                        onTap: () => showStyledToast(
                          child: Text('Foto kartu nama tidak ditemukan'),
                          context: context,
                          backgroundColor: Colors.red,
                          borderRadius: BorderRadius.circular(15.r),
                          duration: Duration(seconds: 2),
                        ),
                      ),
                cust?.gambarPendukung != ''
                    ? InkWell(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            8.r,
                          ),
                          child: Image.memory(
                            base64Decode(cust!.gambarPendukung),
                            width: isHor ? 95.w : 60.w,
                            height: isHor ? 110.h : 60.h,
                            fit: isHor ? BoxFit.cover : BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DialogImage(
                                'Foto Tampak Depan',
                                cust!.gambarPendukung,
                              );
                            },
                          );
                        },
                      )
                    : InkWell(
                        child: Image.asset(
                          'assets/images/picture.png',
                          width: isHor ? 95.w : 60.w,
                          height: isHor ? 110.h : 60.h,
                        ),
                        onTap: () => showStyledToast(
                          child: Text('Foto tampak depan tidak ditemukan'),
                          context: context,
                          backgroundColor: Colors.red,
                          borderRadius: BorderRadius.circular(15.r),
                          duration: Duration(seconds: 2),
                        ),
                      ),
                cust?.uploadDokumen != ''
                    ? InkWell(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            8.r,
                          ),
                          child: Image.memory(
                            base64Decode(cust!.uploadDokumen),
                            width: isHor ? 95.w : 60.w,
                            height: isHor ? 110.h : 60.h,
                            fit: isHor ? BoxFit.cover : BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DialogImage(
                                'Foto SIUP / NPWP',
                                cust!.uploadDokumen,
                              );
                            },
                          );
                        },
                      )
                    : InkWell(
                        child: Image.asset(
                          'assets/images/picture.png',
                          width: isHor ? 95.w : 60.w,
                          height: isHor ? 110.h : 60.h,
                        ),
                        onTap: () => showStyledToast(
                          child: Text('Foto siup/npwp tidak ditemukan'),
                          context: context,
                          backgroundColor: Colors.red,
                          borderRadius: BorderRadius.circular(15.r),
                          duration: Duration(seconds: 2),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
