import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/manager_token.dart';
import 'package:sample/src/domain/entities/marketingexpense_attachment.dart';
import 'package:sample/src/domain/entities/marketingexpense_header.dart';
import 'package:sample/src/domain/entities/marketingexpense_line.dart';
import 'package:sample/src/domain/entities/marketingexpense_paramapprove.dart';
import 'package:sample/src/domain/entities/marketingexpense_resheader.dart';
import 'package:sample/src/domain/entities/trainer.dart';

class ServiceMarketingExpense {
  Future<MarketingExpenseResHeader> getHeader(
    bool mounted,
    BuildContext context, {
    int idSales = 0,
    int idManager = 0,
    int status = 0,
    int limit = 4,
    int offset = 0,
    String search = '',
  }) async {
    late MarketingExpenseResHeader list;
    late var url;
    if (idSales == 0) {
      url =
          '$API_URL/marketingexpense?id_sales_manager=$idManager&approval_status=$status&search=$search&limit=$limit&offset=$offset';
    } else {
      url =
          '$API_URL/marketingexpense?id_sales=$idSales&search=$search&limit=$limit&offset=$offset';
    }

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('Pos Material Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          list = new MarketingExpenseResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              list: data['data']
                  .map<MarketingExpenseHeader>(
                      (json) => MarketingExpenseHeader.fromJson(json))
                  .toList());
        } else {
          list = new MarketingExpenseResHeader(
            status: data['status'],
            message: data['message'],
            count: 0,
            total: 0,
            list: [],
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

  Future<MarketingExpenseResHeader> getHeaderManager(
    bool mounted,
    BuildContext context, {
    int status = 0,
    int limit = 4,
    int offset = 0,
    String search = '',
  }) async {
    late MarketingExpenseResHeader list;
    var url =
        '$API_URL/marketingexpense/manager?approval_status=$status&search=$search&limit=$limit&offset=$offset';

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('ME Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          list = new MarketingExpenseResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              list: data['data']
                  .map<MarketingExpenseHeader>(
                      (json) => MarketingExpenseHeader.fromJson(json))
                  .toList());
        } else {
          list = new MarketingExpenseResHeader(
            status: data['status'],
            message: data['message'],
            count: 0,
            total: 0,
            list: [],
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

  Future<MarketingExpenseResHeader> getMEDashboard(
    bool mounted,
    BuildContext context, {
    int idManager = 0,
    int idGeneral = 0,
    int status = 0,
  }) async {
    late MarketingExpenseResHeader list;
    var url =
        '$API_URL/marketingexpense/dashboard?id_sales_manager=$idManager&id_gm_manager=$idGeneral&approval_status=$status';

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('Pos Material Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          list = new MarketingExpenseResHeader(
            status: data['status'],
            message: data['message'],
            count: data['count'],
            total: data['total'],
            list: [],
          );
        } else {
          list = new MarketingExpenseResHeader(
            status: data['status'],
            message: data['message'],
            count: 0,
            total: 0,
            list: [],
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

  Future<List<Trainer>> getTrainer(
    bool mounted,
    BuildContext context,
  ) async {
    List<Trainer> list = List.empty(growable: true);
    late var url;
    url = '$API_URL/users/trainer';

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('Pos Material Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          list = data['data']
              .map<Trainer>((json) => Trainer.fromJson(json))
              .toList();
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

  Future<String> insertME({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required MarketingExpenseHeader item,
    required salesname,
    required opticname,
    required idSm,
    required tokenSm,
  }) async {
    String idMarketingExpense = '';
    var url = '$API_URL/marketingexpense';
    const timeout = 15;

    print("""
    'sales_name': $salesname,
        'no_account': ${item.shipNumber},
        'nama_usaha': ${item.opticName},
        'alamat_usaha': ${item.opticAddress},
        'optic_type': ${item.opticType},
        'data_name' : ${item.dataName},
        'data_nik' : ${item.dataNik},
        'data_npwp' : ${item.dataNpwp},
        'is_sp_satuan' : ${item.isSpSatuan},
        'sp_number' : ${item.spNumber},
        'is_sp_percent' : ${item.isSpPercent},
        'sp_start_period' : ${item.spStartPeriode},
        'sp_end_period' : ${item.spEndPeriode},
        'total_value' : ${item.totalValue},
        'total_percent' : ${item.totalPercent},
        'payment_mechanism' : ${item.paymentMechanism},
        'payment_date' : ${item.paymentDate},
        'id_rekening' : ${item.idRekening},
        'notes': ${item.notes},
        'is_training': ${item.isTraining},
        'training_mekanisme': ${item.trainingMekanisme},
        'training_materi': ${item.trainingMateri},
        'training_date': ${item.trainingDate},
        'training_time': ${item.trainingTime},
        'training_duration': ${item.trainingDuration},
        'created_by': ${item.createdBy},
    """);

    try {
      var response = await http.post(Uri.parse(url), body: {
        'sales_name': salesname,
        'no_account': item.shipNumber,
        'nama_usaha': item.opticName,
        'alamat_usaha': item.opticAddress,
        'optic_type': item.opticType,
        'data_name' : item.dataName,
        'data_nik' : item.dataNik,
        'data_npwp' : item.dataNpwp,
        'is_sp_satuan' : item.isSpSatuan,
        'sp_number' : item.spNumber,
        'is_sp_percent' : item.isSpPercent,
        'sp_start_period' : item.spStartPeriode,
        'sp_end_period' : item.spEndPeriode,
        'total_value' : item.totalValue,
        'total_percent' : item.totalPercent,
        'payment_mechanism' : item.paymentMechanism,
        'payment_date' : item.paymentDate,
        'id_rekening' : item.idRekening,
        'notes': item.notes,
        'is_training': item.isTraining,
        'training_mekanisme': item.trainingMekanisme,
        'training_materi': item.trainingMateri,
        'training_date': item.trainingDate,
        'training_time': item.trainingTime,
        'training_duration': item.trainingDuration,
        'created_by': item.createdBy,
      }).timeout(Duration(seconds: timeout));

      print('Response status : ${response.statusCode}');
      print('Response body : ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];

        if (sts) {
          idMarketingExpense = res['marketing_expense_id'];

          pushNotif(
            23,
            3,
            salesName: salesname,
            idUser: idSm,
            rcptToken: tokenSm,
            opticName: opticname,
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

    return idMarketingExpense;
  }

  Future<bool> insertLine({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required List<MarketingExpenseLine> line,
  }) async {
    var url = '$API_URL/marketingexpense/insertLine';
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

    // stop();
    return output;
  }

  insertAttachment({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required MarketingExpenseAttachment attachment,
  }) async {
    var url = '$API_URL/marketingexpense/insertAttachment';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id_marketing_expense': attachment.id,
          'attachment': attachment.attachment,
        },
      );

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];

        if (sts) {
          print('Upload image success');
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
  }

  Future<List<MarketingExpenseLine>> getLine(
    BuildContext context,
    bool mounted, {
    String idMe = '',
  }) async {
    List<MarketingExpenseLine> itemList = List.empty(growable: true);
    var url = '$API_URL/marketingexpense/getLine?id_marketing_expense=$idMe';

    try {
      var response = await http.get(Uri.parse(url));
      print('ME line : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          var rest = data['data'];
          itemList = rest
              .map<MarketingExpenseLine>(
                  (json) => MarketingExpenseLine.fromJson(json))
              .toList();
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

    return itemList;
  }

  Future<List<MarketingExpenseAttachment>> getAttachment(
    BuildContext context,
    bool mounted, {
    String idMe = '',
  }) async {
    List<MarketingExpenseAttachment> itemList = List.empty(growable: true);
    var url =
        '$API_URL/marketingexpense/getAttachment?id_marketing_expense=$idMe';

    try {
      var response = await http.get(Uri.parse(url));
      print('ME attachment : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          var rest = data['data'];
          itemList = rest
              .map<MarketingExpenseAttachment>(
                  (json) => MarketingExpenseAttachment.fromJson(json))
              .toList();
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

    return itemList;
  }

  Future<ManagerToken> generateTokenSales({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required String idMe,
  }) async {
    late ManagerToken managerToken;

    var url = '$API_URL/marketingexpense/sales?id_me=$idMe';

    try {
      var response = await http.get(Uri.parse(url));

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

  approveME({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required MarketingExpenseParamApprove param,
  }) async {
    var url = "$API_URL/marketingexpense/approve";

    try {
      var response = await http.post(Uri.parse(url), body: {
        'id_marketing_expense': param.idMe,
        'approver_sm': param.approverSm,
        'approver_gm': param.approverGm,
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

          if (param.approverSm != '') {
            pushNotif(23, 6,
                salesName: param.nameSales,
                opticName: param.opticName,
                idUser: '');
          }

          pushNotif(
            24,
            3,
            idUser: param.idSales,
            rcptToken: param.tokenSales,
            admName: param.managerName,
            opticName: param.opticName,
          );
        } else {
          handleStatus(
            context,
            msg,
            false,
            isHorizontal: false,
            isLogout: false,
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

  rejectME({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required MarketingExpenseParamApprove param,
  }) async {
    var url = "$API_URL/marketingexpense/reject";

    try {
      var response = await http.post(Uri.parse(url), body: {
        'id_marketing_expense': param.idMe,
        'approver_sm': param.approverSm,
        'approver_gm': param.approverGm,
        'reason_sm': param.reasonSm,
        'reason_gm': param.reasonGm,
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
            25,
            3,
            idUser: param.idSales,
            rcptToken: param.tokenSales,
            admName: param.managerName,
            opticName: param.opticName,
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
