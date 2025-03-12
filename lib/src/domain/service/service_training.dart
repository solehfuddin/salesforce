import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:sample/src/domain/entities/agenda_training.dart';

import '../../app/utils/config.dart';
import '../../app/utils/custom.dart';
import '../entities/training_attachment.dart';
import '../entities/training_header.dart';
import '../entities/training_paramapprove.dart';
import '../entities/training_resheader.dart';

class ServiceTraining {
  Future<String> insertHeader({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required TrainingHeader item,
    required salesname,
    required opticname,
    required idSm,
    required tokenSm,
  }) async {
    String idTraining = '';
    var url = '$API_URL/training';
    const timeout = 15;

    try {
      var response = await http.post(Uri.parse(url), body: {
        'sales_name': salesname,
        'no_account': item.shipNumber,
        'nama_usaha': item.opticName,
        'alamat_usaha': item.opticAddress,
        'optic_type': item.opticType,
        'trainer_id' : item.trainerId,
        'trainer_name' : item.trainerName,
        'training_date' : item.scheduleDate,
        'training_time' : item.scheduleStartTime?.trim(),
        'training_duration' : item.duration,
        'training_mechanism' : item.mechanism,
        'training_materi' : item.agenda,
        'notes' : item.notes,
        'created_by': item.createdBy,
      }).timeout(Duration(seconds: timeout));

      print('Response status : ${response.statusCode}');
      print('Response body : ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];

        if (sts) {
          idTraining = res['training_id'];

          pushNotif(
            26,
            3,
            salesName: salesname,
            idUser: idSm,
            rcptToken: tokenSm,
            opticName: opticname,
          );
        }
        else {
          idTraining = "";
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

    return idTraining;
  }

  insertAttachment({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required TrainingAttachment attachment,
  }) async {
    var url = '$API_URL/training/insertAttachment';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id_training': attachment.id,
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

  Future<TrainingResHeader> getHeader(
    bool mounted,
    BuildContext context, {
    int idSales = 0,
    int idManager = 0,
    int status = 0,
    int limit = 4,
    int offset = 0,
    String search = '',
  }) async {
    late TrainingResHeader list;
    late var url;
    if (idSales == 0) {
      url =
          '$API_URL/training?id_sales_manager=$idManager&approval_status=$status&search=$search&limit=$limit&offset=$offset';
    } else {
      url =
          '$API_URL/training?id_sales=$idSales&search=$search&limit=$limit&offset=$offset';
    }

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('Training Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          list = new TrainingResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              list: data['data']
                  .map<TrainingHeader>(
                      (json) => TrainingHeader.fromJson(json))
                  .toList());
        } else {
          list = new TrainingResHeader(
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

  Future<TrainingResHeader> getHeaderManager(
    bool mounted,
    BuildContext context, {
    int status = 0,
    int limit = 4,
    int offset = 0,
    String search = '',
  }) async {
    late TrainingResHeader list;
    var url =
        '$API_URL/training/manager?approval_status=$status&search=$search&limit=$limit&offset=$offset';

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('Training Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        print('count : ${data['total']}');

        if (status) {
          list = new TrainingResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              list: data['data']
                  .map<TrainingHeader>(
                      (json) => TrainingHeader.fromJson(json))
                  .toList());
        } else {
          list = new TrainingResHeader(
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

  Future<TrainingResHeader> getHeaderTrainer(
    bool mounted,
    BuildContext context, {
    int limit = 4,
    int offset = 0,
    String idTrainer = '',
    String selectedDate = '',
    String status = '',
    String search = '',
  }) async {
    late TrainingResHeader list;
    var url = '$API_URL/training/trainer?id_trainer=$idTrainer&training_status=$status&search=$search&training_date=$selectedDate&limit=$limit&offset=$offset';

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('Training Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          list = new TrainingResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              list: data['data']
                  .map<TrainingHeader>(
                      (json) => TrainingHeader.fromJson(json))
                  .toList());
        } else {
          list = new TrainingResHeader(
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

  Future<TrainingResHeader> getRescheduleTraining(
    bool mounted,
    BuildContext context, {
    String idSales = '',
    String search = '',
  }) async {
    late TrainingResHeader list;
    var url = '$API_URL/training/trainingReschedule?id_sales=$idSales';

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('Training Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          list = new TrainingResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              list: data['data']
                  .map<TrainingHeader>(
                      (json) => TrainingHeader.fromJson(json))
                  .toList());
        } else {
          list = new TrainingResHeader(
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

  Future<List<AgendaTraining>> getSearchAgenda(BuildContext context, {String input = ''}) async {
    List<AgendaTraining> list = List.empty(growable: true);

    const timeout = 15;
    var url = '$API_URL/training/agenda?search=$input';
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
          list = rest
              .map<AgendaTraining>((json) => AgendaTraining.fromJson(json))
              .toList();

          print("List Size: ${list.length}");
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

  approveTraining({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required TrainingParamApprove param,
  }) async {
    var url = "$API_URL/training/approve";

    print("""
    Id Training : ${param.idTraining},
    Approver Sm : ${param.approverSm},
    Approver Bb : ${param.approverBm}
    """);

    try {
      var response = await http.post(Uri.parse(url), body: {
        'id_training': param.idTraining,
        'approver_sm': param.approverSm,
        'approver_bm': param.approverBm,
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
            pushNotif(27, 6,
                salesName: param.nameSales,
                opticName: param.opticName,
                idUser: '');
          }

          pushNotif(
            27,
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

  rejectTraining({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required TrainingParamApprove param,
  }) async {
    var url = "$API_URL/training/reject";

    try {
      var response = await http.post(Uri.parse(url), body: {
        'id_training': param.idTraining,
        'approver_sm': param.approverSm,
        'approver_bm': param.approverBm,
        'reason_sm': param.reasonSm,
        'reason_bm': param.reasonBm,
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
            28,
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