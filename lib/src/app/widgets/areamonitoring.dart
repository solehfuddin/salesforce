import 'dart:convert';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/pages/econtract/search_contract.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/monitoring.dart';
import 'package:http/http.dart' as http;

Contract itemContract;

getCustomerContract(int idCust, BuildContext context, String ttdPertama,
    String username, String divisi) async {
  var url =
      'http://timurrayalab.com/salesforce/server/api/contract?id_customer=$idCust';
  var response = await http.get(url);

  print('Response status: ${response.statusCode}');

  var data = json.decode(response.body);
  final bool sts = data['status'];

  if (sts) {
    var rest = data['data'];
    print(rest);
    itemContract = Contract.fromJson(rest[0]);

    openDialog(context, ttdPertama, username, divisi);
  }
}

openDialog(BuildContext context, String ttdPertama, String username,
    String divisi) async {
  await formContract(context, ttdPertama, username, itemContract, divisi);
}

SliverToBoxAdapter areaLoading() {
  return SliverToBoxAdapter(
    child: Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
        SizedBox(
          height: 10,
        ),
        Center(
          child: Text(
            'Processing ...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    ),
  );
}

SliverPadding areaHeaderMonitoring() {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 0,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Monitoring Contract',
              style: TextStyle(
                fontSize: 23,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ]),
    ),
  );
}

SliverPadding areaMonitoring(List<Monitoring> item, BuildContext context,
    String ttdPertama, String username, String divisi) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return itemMonitoring(
              item, index, context, ttdPertama, username, divisi);
        },
        childCount: item.length,
      ),
    ),
  );
}

SliverPadding areaMonitoringNotFound(BuildContext context) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 0,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        children: [
          Center(
            child: Image.asset(
              'assets/images/not_found.png',
              width: 300,
              height: 300,
            ),
          ),
          Text(
            'Data tidak ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Center(
            child: ArgonButton(
              height: 40,
              width: 130,
              borderRadius: 30.0,
              color: Colors.blue[600],
              child: Text(
                "Search Contract",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
              loader: Container(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              onTap: (startLoading, stopLoading, btnState) {
                if (btnState == ButtonState.Idle) {
                  startLoading();
                  waitingLoad();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchContract(),
                    ),
                  );
                  stopLoading();
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

SliverPadding areaButtonMonitoring(BuildContext context, bool isShow) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 10,
    ),
    sliver: SliverToBoxAdapter(
      child: isShow
          ? Center(
              child: ArgonButton(
                height: 40,
                width: 130,
                borderRadius: 30.0,
                color: Colors.blue[600],
                child: Text(
                  "More Data",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                loader: Container(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                onTap: (startLoading, stopLoading, btnState) {
                  if (btnState == ButtonState.Idle) {
                    startLoading();
                    waitingLoad();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchContract(),
                      ),
                    );
                    stopLoading();
                  }
                },
              ),
            )
          : SizedBox(
              height: 5,
            ),
    ),
  );
}

Widget itemMonitoring(List<Monitoring> item, int index, BuildContext context,
    String ttdPertama, String username, String divisi) {
  return InkWell(
    child: Container(
      margin: EdgeInsets.symmetric(
        vertical: 7,
      ),
      padding: EdgeInsets.all(
        15,
      ),
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black26,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item[index].namaUsaha,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Segoe Ui',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    capitalize(item[index].status.toLowerCase()),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'End Contract',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    convertDateIndo(item[index].endDateContract),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
    onTap: () {
      getCustomerContract(int.parse(item[index].idCustomer), context,
          ttdPertama, username, divisi);
    },
  );
}

formContract(BuildContext context, String ttdPertama, String username,
    Contract item, String div) {
  return showModalBottomSheet(
      elevation: 2,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      builder: (context) {
        return DetailContract(item, div, ttdPertama, username, true);
      });
}
