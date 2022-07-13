import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/actcontract.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/discount.dart';
import 'package:http/http.dart' as http;

class DetailContract extends StatefulWidget {
  Contract item;
  String div;
  String ttd;
  String username;
  bool isMonitoring;
  bool isContract = false;
  bool isAdminRenewal = false;
  bool isHasDisc = false;

  DetailContract(
    this.item,
    this.div,
    this.ttd,
    this.username,
    this.isMonitoring, {
    this.isContract,
    this.isAdminRenewal,
    this.isHasDisc,
  });

  @override
  _DetailContractState createState() => _DetailContractState();
}

class _DetailContractState extends State<DetailContract> {
  bool _isLoading = true;
  bool _isLoadingTitle = true;
  List<Discount> discList = List.empty(growable: true);
  List<Customer> custList = List.empty(growable: true);
  List<ActContract> itemActiveContract = List.empty(growable: true);
  TextEditingController textReason = new TextEditingController();
  String reasonVal;
  bool _isReason = false;

  getDisc(dynamic idContract) async {
    const timeout = 15;
    var url =
        '$API_URL/discount/getByIdContract?id_contract=$idContract';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
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
    var url =
        '$API_URL/customers?id=$idCust';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          custList =
              rest.map<Customer>((json) => Customer.fromJson(json)).toList();
          print("List Size: ${custList.length}");
        }

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
    getDisc(widget.item.hasParent.contains('1')
        ? widget.item.idContractParent
        : widget.item.idContract);
    getCustomer(widget.item.idCustomer);
    widget.item.idContract != null
        ? getActiveContract(widget.item.idParent)
        : print('Bukan child');
  }

  getActiveContract(dynamic input) async {
    itemActiveContract.clear();
    const timeout = 15;
    var url =
        '$API_URL/contract/parentCheck?id_customer=$input';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          // this._isContractActive = true;
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
      {bool isHorizontal}) async {
    const timeout = 15;
    List<Discount> list;
    var url =
        '$API_URL/discount/getByIdContract?id_contract=$idContract';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
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

        return list;
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
        );
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  approveContract(bool isAr, String idCust, String username,
      {bool isHorizontal}) async {
    const timeout = 15;
    var url = !isAr
        ? '$API_URL/approval/approveContractSM'
        : '$API_URL/approval/approveContractAM';

    try {
      var response = await http
          .post(
            url,
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

        widget.isAdminRenewal
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
              );
      } on FormatException catch (e) {
        print('Format Error : $e');
        if (mounted) {
          handleStatus(
            context,
            e.toString(),
            false,
            isHorizontal: isHorizontal,
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
        );
      }
    }
  }

  approveCustomer(bool isAr, String idCust, String ttd, String username,
      {bool isHorizontal}) async {
    const timeout = 15;
    var url = !isAr
        ? '$API_URL/approval/approveSM'
        : '$API_URL/approval/approveAM';

    try {
      var response = await http
          .post(
            url,
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

      approveContract(
        isAr,
        idCust,
        username,
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
        );
      }
    }
  }

  rejectContract(bool isAr, String idCust, String username, String reason,
      {bool isHorizontal}) async {
    const timeout = 15;
    var url = !isAr
        ? '$API_URL/approval/rejectContractSM'
        : '$API_URL/approval/rejectContractAM';

    try {
      var response = await http
          .post(
            url,
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

        widget.isAdminRenewal
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
              );
      } on FormatException catch (e) {
        print('Format Error : $e');
        if (mounted) {
          handleStatus(
            context,
            e.toString(),
            false,
            isHorizontal: isHorizontal,
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
        );
      }
    }
  }

  rejectCustomer(
      bool isAr, String idCust, String ttd, String username, String reason,
      {bool isHorizontal}) async {
    const timeout = 15;
    var url = !isAr
        ? '$API_URL/approval/rejectSM'
        : '$API_URL/approval/rejectAM';

    try {
      var response = await http
          .post(
            url,
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
        );
      }
    }
  }

  approveOldCustomer({bool isHorizontal}) {
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

  approveNewCustomer({bool isHorizontal}) {
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
  }

  rejectOldCustomer({bool isHorizontal}) {
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

  rejectNewCustomer({bool isHorizontal}) {
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

  checkEntry({bool isHorizontal}) {
    textReason.text.isEmpty ? _isReason = true : _isReason = false;

    if (!_isReason) {
      widget.isContract
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
      );
    }
  }

  handleRejection(BuildContext context, Function stop, {bool isHorizontal}) {
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

  Widget masterChild({bool isHor}) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity.w,
              height: isHor ? 350.h : 230.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 30.r),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.isAdminRenewal
                            ? Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => AdminScreen()))
                            : Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: isHor ? 25.r : 15.r,
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
                      vertical: widget.item.customerShipName != null
                          ? widget.item.customerShipName.length > 32
                              ? 3.r
                              : 15.r
                          : 15.r,
                    ),
                    child: Center(
                      child: _isLoadingTitle
                          ? Center(
                              child: Text(
                                'Processing ...',
                                style: TextStyle(
                                  fontSize: isHor ? 26.sp : 16.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            )
                          : Text(
                              // 'Perjanjian Kerjasama Pembelian',
                              widget.item.customerShipName != null
                                  ? 'KONTRAK ${widget.item.customerShipName}'
                                  : 'KONTRAK ${custList[0].namaUsaha}',
                              style: TextStyle(
                                fontSize: isHor ? 35.sp : 20.sp,
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
              height: isHor ? 30.h : 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isHor ? 30.r : 20.r),
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
                      widget.item.typeContract != null
                          ? 'KONTRAK ${widget.item.typeContract}'
                          : 'KONTRAK LENSA',
                      style: TextStyle(
                        fontSize: isHor ? 22.sp : 12.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: isHor ? 25.h : 15.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: isHor ? 1 : 1,
                        child: Text(
                          'Berlaku tanggal',
                          style: TextStyle(
                            fontSize: isHor ? 26.sp : 16.sp,
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
                            fontSize: isHor ? 26.sp : 16.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: isHor ? TextAlign.end : TextAlign.end,
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
                            convertDateWithMonth(widget.item.startContract),
                            style: TextStyle(
                              fontSize: isHor ? 26.sp : 16.sp,
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
                              fontSize: isHor ? 26.sp : 16.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                            // textAlign: isHor ? TextAlign.center : TextAlign.end,
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
                      fontSize: isHor ? 26.sp : 16.sp,
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
                                        fontSize: isHor ? 24.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Jabatan',
                                      style: TextStyle(
                                        fontSize: isHor ? 24.sp : 14.sp,
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
                                        fontSize: isHor ? 24.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.item.jabatanPertama,
                                      style: TextStyle(
                                        fontSize: isHor ? 24.sp : 14.sp,
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
                                        fontSize: isHor ? 24.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'No Fax',
                                      style: TextStyle(
                                        fontSize: isHor ? 24.sp : 14.sp,
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
                                        fontSize: isHor ? 24.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '021-4610151-52',
                                      style: TextStyle(
                                        fontSize: isHor ? 24.sp : 14.sp,
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
                                  fontSize: isHor ? 24.sp : 14.sp,
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
                                  fontSize: isHor ? 24.sp : 14.sp,
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
                    height: isHor ? 35.h : 25.h,
                  ),
                  Text(
                    'Pihak Kedua',
                    style: TextStyle(
                      fontSize: isHor ? 26.sp : 16.sp,
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
                                        fontSize: isHor ? 24.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Jabatan',
                                      style: TextStyle(
                                        fontSize: isHor ? 24.sp : 14.sp,
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
                                        fontSize: isHor ? 24.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Owner',
                                      style: TextStyle(
                                        fontSize: isHor ? 24.sp : 14.sp,
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
                                        fontSize: isHor ? 24.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'No Fax',
                                      style: TextStyle(
                                        fontSize: isHor ? 24.sp : 14.sp,
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
                                        fontSize: isHor ? 24.sp : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.item.faxKedua == null
                                          ? '-'
                                          : widget.item.faxKedua,
                                      style: TextStyle(
                                        fontSize: isHor ? 24.sp : 14.sp,
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
                                  fontSize: isHor ? 24.sp : 14.sp,
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
                                  fontSize: isHor ? 24.sp : 14.sp,
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
                    height: isHor ? 15.h : 10.h,
                  ),
                  Text(
                    'Target Pembelian yang disepakati',
                    style: TextStyle(
                      fontSize: isHor ? 26.sp : 16.sp,
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
                            fontSize: isHor ? 24.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Lensa Leinz',
                          style: TextStyle(
                            fontSize: isHor ? 24.sp : 14.sp,
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
                              fontSize: isHor ? 24.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          convertToIdr(int.parse(widget.item.tpLeinz), 0),
                          style: TextStyle(
                            fontSize: isHor ? 24.sp : 14.sp,
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
                            fontSize: isHor ? 24.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Lensa Moe',
                          style: TextStyle(
                            fontSize: isHor ? 24.sp : 14.sp,
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
                          convertToIdr(int.parse(widget.item.tpOriental), 0),
                          style: TextStyle(
                              fontSize: isHor ? 24.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          convertToIdr(int.parse(widget.item.tpMoe), 0),
                          style: TextStyle(
                            fontSize: isHor ? 24.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: isHor ? 35.h : 25.h,
                  ),
                  Text(
                    'Jangka waktu pembayaran',
                    style: TextStyle(
                      fontSize: isHor ? 26.sp : 16.sp,
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
                            fontSize: isHor ? 24.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Lensa Leinz',
                          style: TextStyle(
                            fontSize: isHor ? 24.sp : 14.sp,
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
                              fontSize: isHor ? 24.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.item.pembLeinz,
                          style: TextStyle(
                            fontSize: isHor ? 24.sp : 14.sp,
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
                            fontSize: isHor ? 24.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Lensa Moe',
                          style: TextStyle(
                            fontSize: isHor ? 24.sp : 14.sp,
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
                              fontSize: isHor ? 24.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.item.pembMoe,
                          style: TextStyle(
                            fontSize: isHor ? 24.sp : 14.sp,
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
                  widget.item.typeContract != null
                      ? widget.item.typeContract.contains('FRAME')
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
                                      fontSize: isHor ? 26.sp : 16.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5.r,
                                    ),
                                  ),
                                  SizedBox(
                                    height: isHor ? 15.h : 10.h,
                                  ),
                                  Text(
                                    'Diskon khusus pada kontrak frame disesuakan dengan surat pesanan (SP) .',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: isHor ? 23.sp : 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            )
                          : areaDiskon(
                              widget.item,
                              isHorizontal: isHor,
                            )
                      : SizedBox(
                          height: 10.w,
                        ),
                  SizedBox(
                    height: 30.h,
                  ),
                  widget.isMonitoring
                      ? Center(
                          child: ArgonButton(
                            height: isHor ? 60.h : 40.h,
                            width: isHor ? 100.w : 150.w,
                            borderRadius: 30.0.r,
                            color: Colors.blue[700],
                            child: Text(
                              "Unduh Kontrak",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isHor ? 24.sp : 14.sp,
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
                                  donwloadContract(
                                      widget.item.idCustomer, stopLoading());
                                });
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

  Widget areaDiskon(Contract item, {bool isHorizontal}) {
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
                    fontSize: isHorizontal ? 26.sp : 16.sp,
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
                                  fontSize: isHorizontal ? 24.sp : 14.sp,
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
                                  fontSize: isHorizontal ? 24.sp : 14.sp,
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
                            fontSize: isHorizontal ? 24.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Diskon',
                          style: TextStyle(
                            fontSize: isHorizontal ? 24.sp : 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  )
                : widget.isHasDisc
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Deskripsi produk',
                              style: TextStyle(
                                fontSize: isHorizontal ? 24.sp : 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Diskon',
                              style: TextStyle(
                                fontSize: isHorizontal ? 24.sp : 14.sp,
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
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return snapshot.data != null
                        ? listDiscWidget(
                            snapshot.data,
                            snapshot.data.length,
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
                                  fontSize: isHorizontal ? 26.sp : 16.sp,
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

  Widget listDiscWidget(List<Discount> item, int len, {bool isHorizontal}) {
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
                    item[position].prodDesc != null
                        ? item[position].prodDesc
                        : '-',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item[position].discount != null
                        ? '${item[position].discount} %'
                        : '-',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
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

  Widget handleAction({bool isHorizontal}) {
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
                  widget.isContract
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
}
