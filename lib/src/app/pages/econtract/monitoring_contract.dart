import 'dart:convert';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/pages/econtract/search_contract.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/monitoring.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MonitoringContract extends StatefulWidget {
  double heightLayout;

  MonitoringContract(this.heightLayout);

  @override
  _MonitoringContractState createState() => _MonitoringContractState();
}

class _MonitoringContractState extends State<MonitoringContract> {
  Contract itemContract;
  String id = '';
  String role = '';
  String username = '';
  String divisi = '';
  String ttdPertama;
  int countList = 0;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");

      getTtd(int.parse(id));
      print("Dashboard : $role");
      print('Layout Size Monitoring : ${widget.heightLayout}');
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  getTtd(int input) async {
    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      ttdPertama = data['data'][0]['ttd'];
      print(ttdPertama);
    }
  }

  Future<List<Monitoring>> getMonitoringData() async {
    await Future.delayed(Duration(seconds: 1));

    List<Monitoring> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/monitoring';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      list = rest.map<Monitoring>((json) => Monitoring.fromJson(json)).toList();
      print("List Size: ${list.length}");
    }

    return list;
  }

  Future<List<Monitoring>> getMonitoringSales() async {
    await Future.delayed(Duration(seconds: 1));

    List<Monitoring> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/salesMonitoring?id=$id';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      list = rest.map<Monitoring>((json) => Monitoring.fromJson(json)).toList();
      print("List Size: ${list.length}");
    }

    return list;
  }

  getCustomerContract(int idCust) async {
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

      openDialog();
    }
  }

  openDialog() async {
    await formContract(itemContract, divisi);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        SizedBox(
          height: widget.heightLayout,
          child: FutureBuilder(
              future: role == "admin"
                  ? getMonitoringData()
                  : getMonitoringSales(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return snapshot.data != null
                        ? listViewWidget(snapshot.data, snapshot.data.length)
                        : Column(
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
                              )
                            ],
                          );
                }
              }),
        ),
        SizedBox(
          height: 10,
        ),
        Center(
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
        ),
      ],
    );
  }

  formContract(Contract item, String div) {
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

  Widget listViewWidget(List<Monitoring> item, int len) {
    return Container(
      child: ListView.builder(
          itemCount: len,
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 15,
          ),
          itemBuilder: (context, position) {
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
                      item[position].namaUsaha,
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
                              'Active',
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
                              convertDateIndo(item[position].endDateContract),
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
                setState(() {
                  getCustomerContract(int.parse(item[position].idCustomer));
                });
              },
            );
          }),
    );
  }
}
