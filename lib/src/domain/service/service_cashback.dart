import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/cashback_attachment.dart';
import 'package:sample/src/domain/entities/cashback_header.dart';
import 'package:sample/src/domain/entities/cashback_identitas.dart';
import 'package:sample/src/domain/entities/cashback_line.dart';
import 'package:sample/src/domain/entities/cashback_rekening.dart';
import 'package:sample/src/domain/entities/cashback_resheader.dart';
import 'package:sample/src/domain/entities/manager_token.dart';
import 'package:sample/src/domain/entities/master_bank.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:sample/src/domain/entities/product.dart';

class ServiceCashback {
  Future<CashbackResHeader> getCashbackHeader(
    bool mounted,
    BuildContext context, {
    int idSales = 0,
    int idManager = 0,
    int status = 0,
    String search = '',
    String shipNumber = '',
    int limit = 4,
    int offset = 0,
  }) async {
    late CashbackResHeader cashbackResHeader;
    late var url;
    if (shipNumber != '') {
      url = "$API_URL/cashback?ship_number=$shipNumber&limit=$limit";
    } else {
      if (idSales == 0) {
        url =
            "$API_URL/cashback?id_sales_manager=$idManager&approval_status=$status&search=$search&limit=$limit&offset=$offset";
      } else {
        url =
            "$API_URL/cashback?id_sales=$idSales&approval_status=$status&search=$search&limit=$limit&offset=$offset";
      }
    }

    print('Cashback url : $url');

    try {
      var response = await http.get(Uri.parse(url));
      print('Cashback code : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        print(data);
        // final bool status = data['status'];
        int count = data['count'] ?? 0;

        if (count > 0) {
          cashbackResHeader = new CashbackResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              cashback: data['data']
                  .map<CashbackHeader>((json) => CashbackHeader.fromJson(json))
                  .toList());
        } else {
          cashbackResHeader = new CashbackResHeader(
              status: data['status'],
              message: data['message'],
              count: 0,
              total: 0,
              cashback: []);
        }
      } on FormatException catch (e) {
        print('Format Error : ${e.message}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : ${e.message}');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : ${e.message}');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return cashbackResHeader;
  }

  Future<CashbackResHeader> getCashbackManager(
    bool mounted,
    BuildContext context, {
    int status = 0,
    String search = '',
    int limit = 4,
    int offset = 0,
  }) async {
    late CashbackResHeader cashbackResHeader;
    late var url;
    url = "$API_URL/cashback/manager?approval_status=$status&search=$search&limit=$limit&offset=$offset";

    // print('Cashback url : $url');

    try {
      var response = await http.get(Uri.parse(url));
      print('Cashback code : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        print(data);
        // final bool status = data['status'];
        int count = data['count'] ?? 0;

        if (count > 0) {
          cashbackResHeader = new CashbackResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              cashback: data['data']
                  .map<CashbackHeader>((json) => CashbackHeader.fromJson(json))
                  .toList());
        } else {
          cashbackResHeader = new CashbackResHeader(
              status: data['status'],
              message: data['message'],
              count: 0,
              total: 0,
              cashback: []);
        }
      } on FormatException catch (e) {
        print('Format Error : ${e.message}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : ${e.message}');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : ${e.message}');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return cashbackResHeader;
  }

  Future<CashbackResHeader> getCashbackDashboard(
    bool mounted,
    BuildContext context, {
    int idManager = 0,
    int idGeneral = 0,
    int status = 0,
  }) async {
    late CashbackResHeader list;
    var url =
        '$API_URL/cashback/dashboard?id_sales_manager=$idManager&id_general_manager=$idGeneral&approval_status=$status';

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('Pos Material Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          list = new CashbackResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              cashback: data['data']
                  .map<CashbackHeader>(
                      (json) => CashbackHeader.fromJson(json))
                  .toList());
        } else {
          list = new CashbackResHeader(
            status: data['status'],
            message: data['message'],
            count: 0,
            total: 0,
            cashback: [],
          );
        }
      } on FormatException catch (e) {
        print('Format Exception : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return list;
  }

  Future<List<CashbackRekening>> getRekening(
    BuildContext context, {
    bool isMounted = false,
    String idRekening = '',
    String noAccount = '',
    String search = '',
  }) async {
    List<CashbackRekening> cashbackRekening = List.empty(growable: true);
    var url =
        '$API_URL/cashback/rekening?id_rekening=$idRekening&id_optic=$noAccount&search=$search';

    try { 
      var response = await http.get(Uri.parse(url));

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          cashbackRekening = data['data']
              .map<CashbackRekening>((json) => CashbackRekening.fromJson(json))
              .toList();
        } else {
          cashbackRekening = [];
        }
      } on FormatException catch (e) {
        print('Format Error : ${e.message}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : ${e.message}');
      if (isMounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : ${e.message}');
      if (isMounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
    }

    return cashbackRekening;
  }

  Future<List<ListMasterBank>> getMasterBank(
    BuildContext context, {
    bool isMounted = false,
  }) async {
    List<ListMasterBank> masterBank = List.empty(growable: true);
    var url = '$API_URL/cashback/listBank';

    try {
      var response = await http.get(Uri.parse(url));

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          masterBank = data['data']
              .map<ListMasterBank>((json) => ListMasterBank.fromJson(json))
              .toList();
        } else {
          masterBank = [];
        }
      } on FormatException catch (e) {
        print('Format Error : ${e.message}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : ${e.message}');
      if (isMounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : ${e.message}');
      if (isMounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
    }

    return masterBank;
  }

  Future<List<Proddiv>> getProddivCashbackCustom(
    BuildContext context, {
    bool isMounted = false,
    String inputProddiv = '',
  }) async {
    List<Proddiv> prodDiv = List.empty(growable: true);
    var url = '$API_URL/product/getProDivCustom?prod_div=$inputProddiv';

    try {
      var response = await http.get(Uri.parse(url));

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          prodDiv = data['data']
              .map<Proddiv>((json) => Proddiv.fromJson(json))
              .toList();
        } else {
          prodDiv = [];
        }
      } on FormatException catch (e) {
        print('Format Error : ${e.message}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : ${e.message}');
      if (isMounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : ${e.message}');
      if (isMounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
    }

    return prodDiv;
  }

  Future<List<CashbackLine>> getCashbackLine(
    BuildContext context, {
    bool isMounted = false,
    String cashbackId = '',
  }) async {
    List<CashbackLine> line = List.empty(growable: true);
    var url = '$API_URL/cashback/line?id_cashback=$cashbackId';

    try {
      var response = await http.get(Uri.parse(url));

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          line = data['data']
              .map<CashbackLine>((json) => CashbackLine.fromJson(json))
              .toList();
        } else {
          line = [];
        }
      } on FormatException catch (e) {
        print('Format Error : ${e.message}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : ${e.message}');
      if (isMounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : ${e.message}');
      if (isMounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
    }

    return line;
  }

  Future<List<Proddiv>> getProddivCashback(
    BuildContext context, {
    bool isMounted = false,
  }) async {
    List<Proddiv> prodDiv = List.empty(growable: true);
    var url = '$API_URL/product/getProDiv';

    try {
      var response = await http.get(Uri.parse(url));

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          prodDiv = data['data']
              .map<Proddiv>((json) => Proddiv.fromJson(json))
              .toList();
        } else {
          prodDiv = [];
        }
      } on FormatException catch (e) {
        print('Format Error : ${e.message}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : ${e.message}');
      if (isMounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : ${e.message}');
      if (isMounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
    }

    return prodDiv;
  }

  Future<List<Product>> getProductCashback(
    BuildContext context, {
    bool isMounted = false,
  }) async {
    List<Product> product = List.empty(growable: true);
    var url = '$API_URL/product';

    try {
      var response = await http.get(Uri.parse(url));

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          product = data['data']
              .map<Product>((json) => Product.fromJson(json))
              .toList();
        } else {
          product = [];
        }
      } on FormatException catch (e) {
        print('Format Error : ${e.message}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : ${e.message}');
      if (isMounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : ${e.message}');
      if (isMounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
    }

    return product;
  }

  Future<CashbackIdentitas?> getIdentitas(
    BuildContext context, {
    bool isMounted = false,
    String noAccount = '',
  }) async {
    CashbackIdentitas? identitas;
    var url = '$API_URL/cashback/ktpnpwp?id_optic=$noAccount';

    try {
      var response = await http.get(Uri.parse(url));

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          identitas = new CashbackIdentitas(
              nama: data['data']['nama'],
              noKtp: data['data']['no_identitas'],
              noNpwp: data['data']['no_npwp']);
        } else {
          identitas = new CashbackIdentitas(nama: '', noKtp: '', noNpwp: '');
        }
      } on FormatException catch (e) {
        print('Format Error : ${e.message}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : ${e.message}');
      if (isMounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : ${e.message}');
      if (isMounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
    }

    return identitas;
  }

  Future<CashbackAttachment> getAttachment(
    BuildContext context, {
    bool isMounted = false,
    String idCashback = '',
  }) async {
    late CashbackAttachment attachment;
    var url = '$API_URL/cashback/attachment?id_cashback=$idCashback';

    try {
      var response = await http.get(Uri.parse(url));

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          attachment = new CashbackAttachment(
            attachmentSign: data['data']['attachment_sign'],
            attachmentOther: data['data']['attachment_other'],
          );
        } else {
          attachment =
              new CashbackAttachment(attachmentOther: '', attachmentSign: '');
        }
      } on FormatException catch (e) {
        print('Format Error : ${e.message}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : ${e.message}');
      if (isMounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : ${e.message}');
      if (isMounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
    }

    return attachment;
  }

  Future<ManagerToken> generateTokenSales({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required String idCashback,
  }) async {
    late ManagerToken managerToken;

    var url = '$API_URL/cashback/sales?id_cashback=$idCashback';

    try {
      var response = await http.get(Uri.parse(url));
      print('Get all optic : $response');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          var rest = data['data'];
          managerToken = new ManagerToken(
              id: rest['id'],
              name: rest['name'],
              username: rest['username'],
              divisi: rest['divisi'],
              role: rest['role'],
              token: rest['gentoken']);
        } else {
          managerToken = new ManagerToken(
              id: '', name: '', username: '', divisi: '', role: '', token: '');
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');

      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return managerToken;
  }

  Future<String> insertRekening({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required CashbackRekening item,
  }) async {
    var url = '$API_URL/cashback/insertRekening';
    String idRekening = '';

    try {
      var response = await http.post(Uri.parse(url), body: {
        'bank_id': item.idBank,
        'account_number': item.nomorRekening,
        'account_name': item.namaRekening,
        'bill_number': item.billNumber,
        'ship_number': item.shipNumber,
      });

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String id = res['id_cashback_rekening'];

        if (sts) {
          idRekening = id;
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
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
      print('General Error : ${e.stackTrace}');
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

    return idRekening;
  }

  Future<String> insertHeader({
    bool isHorizontal = false,
    bool mounted = false,
    required String tokenSm,
    required BuildContext context,
    required CashbackHeader header,
  }) async {
    var url = '$API_URL/cashback';
    String idCashback = '';

    try {
      var response = await http.post(Uri.parse(url), body: {
        'salesname': header.salesName,
        'ship_number': header.shipNumber,
        'optic_name': header.opticName,
        'optic_address': header.opticAddress,
        'optic_type': header.opticType,
        'start_periode': header.startPeriode,
        'end_periode': header.endPeriode,
        'data_name': header.dataNama,
        'data_nik': header.dataNik,
        'data_npwp': header.dataNpwp,
        'withdraw_duration': header.withdrawDuration,
        'withdraw_process': header.withdrawProcess,
        'id_cashback_rekening': header.idCashbackRekening,
        'cashback_type': header.cashbackType,
        'target_value': header.targetValue,
        'target_duration': header.targetDuration,
        'target_product': header.targetProduct,
        'cashback_value': header.cashbackValue,
        'cashback_percentage': header.cashbackPercentage,
        'payment_duration': header.paymentDuration,
        'created_by': header.createdBy,
        'attachment_sign': header.attachmentSign,
        'attachment_other': header.attachmentOther,
        'bill_number': header.billNumber,
      });

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String id = res['cashback_id'];

        if (sts) {
          idCashback = id;

          pushNotif(
            20,
            3,
            salesName: header.salesName,
            idUser: header.createdBy,
            rcptToken: tokenSm,
            opticName: header.opticName,
          );
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
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
      print('General Error : ${e.stackTrace}');
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

    return idCashback;
  }

  Future<String> updateHeader({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required CashbackHeader header,
    required String idCashback,
    required String tokenSm,
  }) async {
    var url = '$API_URL/cashback';
    try {
      var response = await http.put(Uri.parse(url), body: {
        'id_cashback' : idCashback,
        'salesname': header.salesName,
        'ship_number': header.shipNumber,
        'optic_name': header.opticName,
        'optic_address': header.opticAddress,
        'optic_type': header.opticType,
        'start_periode': header.startPeriode,
        'end_periode': header.endPeriode,
        'data_name': header.dataNama,
        'data_nik': header.dataNik,
        'data_npwp': header.dataNpwp,
        'withdraw_duration': header.withdrawDuration,
        'withdraw_process': header.withdrawProcess,
        'id_cashback_rekening': header.idCashbackRekening,
        'cashback_type': header.cashbackType,
        'target_value': header.targetValue,
        'target_duration': header.targetDuration,
        'target_product': header.targetProduct,
        'cashback_value': header.cashbackValue,
        'cashback_percentage': header.cashbackPercentage,
        'payment_duration': header.paymentDuration,
        'created_by': header.createdBy,
        'attachment_sign': header.attachmentSign,
        'attachment_other': header.attachmentOther,
        'bill_number': header.billNumber,
      });

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String id = res['cashback_id'];

        if (sts) {
          idCashback = id;

          pushNotif(
            20,
            3,
            salesName: header.salesName,
            idUser: header.createdBy,
            rcptToken: tokenSm,
            opticName: header.opticName,
          );
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
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
      print('General Error : ${e.stackTrace}');
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

    return idCashback;
  }

  Future<bool> insertLine({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required List<CashbackLine> line,
  }) async {
    var url = '$API_URL/cashback/insertLine';
    bool output = false;

    try {
      var body = json.encode(line);
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];

        if (sts) {
          output = true;
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
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
      print('General Error : ${e.stackTrace}');
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

    return output;
  }

  Future<bool> updateLine({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required List<CashbackLine> line,
  }) async {
    var url = '$API_URL/cashback/updateLine';
    bool output = false;

    try {
      var body = json.encode(line);
      var response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];

        if (sts) {
          output = true;
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
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
      print('General Error : ${e.stackTrace}');
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

    return output;
  }

  approveCashback({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required String idCashback,
    required String idSales,
    required String nameSales,
    required String tokenSales,
    required String opticName,
    required String managerName,
    String approverSm = '',
    String approverGm = '',
  }) async {
    var url = "$API_URL/cashback/approve";

    try {
      var response = await http.post(Uri.parse(url), body: {
        'id_cashback': idCashback,
        'approver_sm': approverSm,
        'approver_gm': approverGm,
      }).timeout(
        Duration(
          seconds: 10,
        ),
      );

      try {
        var res = jsonDecode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (sts) {
          handleStatus(
            context,
            msg,
            sts,
            isHorizontal: isHorizontal,
            isLogout: false,
            isNewCust: false,
          );

          if (approverSm != '')
          {
            pushNotif(20, 6, salesName: nameSales, opticName: opticName, idUser: '');
          }

          pushNotif(
              21,
              3,
              idUser: idSales,
              rcptToken: tokenSales,
              admName: managerName,
              opticName: opticName,
            );
        }
      } on FormatException catch (e) {
        print('Format error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: false,
          isLogout: false,
        );
      }
    }
  }

  rejectCashback({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required String idCashback,
    required String idSales,
    required String nameSales,
    required String tokenSales,
    required String opticName,
    required String managerName,
    String approverSm = '',
    String approverGm = '',
    String reasonSm = '',
    String reasonGm = '',
  }) async {
    var url = "$API_URL/cashback/reject";

    try {
      var response = await http.post(Uri.parse(url), body: {
        'id_cashback': idCashback,
        'approver_sm': approverSm,
        'approver_gm': approverGm,
        'reason_sm': reasonSm,
        'reason_gm': reasonGm,
      }).timeout(
        Duration(
          seconds: 10,
        ),
      );

      try {
        var res = jsonDecode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (sts) {
          handleStatus(
            context,
            msg,
            sts,
            isHorizontal: isHorizontal,
            isLogout: false,
            isNewCust: false,
          );

          pushNotif(
            22,
            3,
            idUser: idSales,
            rcptToken: tokenSales,
            admName: managerName,
            opticName: opticName,
          );
        }
      } on FormatException catch (e) {
        print('Format error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: false,
          isLogout: false,
        );
      }
    }
  }
}
