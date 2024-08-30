import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/utils/config.dart';
import '../../app/utils/custom.dart';
import '../entities/contract_promo.dart';

class ServicePromo {
  Future<List<ContractPromo>> getContractPromo({String keyword = ''}) async {
    const timeout = 15;
    List<ContractPromo> listPromo = List.empty(growable: true);
    var url = '$API_URL/contract/contractPromo?keyword=$keyword';

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
            listPromo = rest
                .map<ContractPromo>((json) => ContractPromo.fromJson(json))
                .toList();
            print("List Contract Promo: ${listPromo.length}");
        }
        else {
          listPromo = [];
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

    return listPromo;
  }

  Future<String> insertPromo({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required ContractPromo item,
  }) async {
    var url = '$API_URL/contract/contractPromo';
    String idPromo = '';

    try {
      var response = await http.post(Uri.parse(url), body: {
        'promo_name': item.promoName,
        'promo_description': item.promoDescription,
        'promo_until': item.promoUntil,
        'created_by': item.createdBy,
      });

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String id = res['data'];

        if (sts) {
          idPromo = id;
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

    return idPromo;
  }
}