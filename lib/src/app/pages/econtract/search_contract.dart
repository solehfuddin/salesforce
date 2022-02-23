import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/monitoring.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchContract extends StatefulWidget {
  @override
  _SearchContractState createState() => _SearchContractState();
}

class _SearchContractState extends State<SearchContract> {
  String id = '';
  String role = '';
  String username = '';
  String search = '';
  String divisi = '';
  String ttdPertama;
  Contract itemContract;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");

      getTtd(int.parse(id));
      print("Search Contract : $role");
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

  Future<List<Monitoring>> getMonitoringBySearch(String input) async {
    List<Monitoring> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/search?search=$input';
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
    setState((){});
  }

  Future<void> _refreshData() async{
    setState(() {
      search.isNotEmpty
                      ? getMonitoringBySearch(search)
                      : getMonitoringData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'List Monitoring Contract',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18,
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
            size: 18,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            color: Colors.white,
            height: 80,
            child: TextField(
              textInputAction: TextInputAction.search,
              autocorrect: true,
              decoration: InputDecoration(
                hintText: 'Pencarian data ...',
                prefixIcon: Icon(Icons.search),
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white70,
                contentPadding: EdgeInsets.symmetric(vertical: 3),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  search = value;
                });
              },
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 100,
              child: FutureBuilder(
                  future: search.isNotEmpty
                      ? getMonitoringBySearch(search)
                      : getMonitoringData(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        return snapshot.data != null
                            ? listViewWidget(
                                snapshot.data, snapshot.data.length)
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
          ),
        ],
      ),
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
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 15,
            ),
            shrinkWrap: true,
            itemBuilder: (context, position) {
              return InkWell(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 7,),
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
                                // 'Active',
                                capitalize(
                                        item[position].status.toLowerCase()),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Segoe Ui',
                                  fontWeight: FontWeight.w600,
                                  color: item[position].status == "ACTIVE" ?  Colors.orange[800] : Colors.red[600],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sisa Kontrak',
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
                                // convertDateIndo(item[position].endDateContract),
                                getEndDays(input: item[position].endDateContract),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Segoe Ui',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
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
                  item[position].idCustomer != null ?
                  getCustomerContract(int.parse(item[position].idCustomer))
                  : handleStatus(context, 'Id customer tidak ditemukan', false) ;
                },
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}