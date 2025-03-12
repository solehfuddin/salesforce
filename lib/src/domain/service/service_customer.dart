import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sample/src/domain/entities/change_customer.dart';
import 'package:sample/src/domain/entities/change_rescustomer.dart';

import '../../app/utils/config.dart';
import '../../app/utils/custom.dart';

class ServiceCustomer {
  Future<ChangeResCustomer> getChangeCustomer(
    bool mounted,
    BuildContext context, {
    bool isArManager = false,
    String idOptic = "",
    int idSales = 0,
    int idManager = 0,
    int status = 0,
    String search = '',
    int limit = 4,
    int offset = 0,
  }) async {
    late ChangeResCustomer changeResCustomer;
    late var url;
    if (idSales == 0) {
      if (idOptic != '') {
        url = "$API_URL/customers/changeCustomer?id=$idOptic";
      }
      else {
        if (isArManager) {
          url =
              "$API_URL/customers/changeCustomer?id_sales=&id_salesmanager=&is_armanager=1&approval_status=$status&search=$search&limit=$limit&offset=$offset";
        } else {
          url =
              "$API_URL/customers/changeCustomer?id_sales=&id_salesmanager=$idManager&approval_status=$status&search=$search&limit=$limit&offset=$offset";
        }
      }
    }
    else {
        url =
            "$API_URL/customers/changeCustomer?id_sales=$idSales&approval_status=$status&search=$search&limit=$limit&offset=$offset";
    }

    print('Cashback url : $url');

    try {
      var response = await http.get(Uri.parse(url));
      print('Cashback code : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        print(data);
        int count = data['count'] ?? 0;

        if (count > 0) {
          changeResCustomer = new ChangeResCustomer(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              customer: data['data']
                  .map<ChangeCustomer>(
                      (json) => ChangeCustomer.fromJson(json))
                  .toList());
        } else {
          changeResCustomer = new ChangeResCustomer(
              status: data['status'],
              message: data['message'],
              count: 0,
              total: 0,
              customer: []);
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

    return changeResCustomer;
  }
}
