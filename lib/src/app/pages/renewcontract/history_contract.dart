import 'dart:convert';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/renewcontract/change_contract.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/oldcustomer.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryContract extends StatefulWidget {
  OldCustomer item;
  dynamic keyword;
  bool isAdmin = false;

  HistoryContract(this.item, {this.keyword, this.isAdmin});

  @override
  State<HistoryContract> createState() => _HistoryContractState();
}

class _HistoryContractState extends State<HistoryContract> {
  String id = '';
  String role = '';
  String username = '';
  String search = '';
  String divisi = '';
  String ttdPertama;
  List<Contract> activeContract = List.empty(growable: true);

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");

      getTtd(int.parse(id));
      print("Search Contract : $role");
      print("Keyword : ${widget.keyword}");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
    getContractActive();
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

  getContractActive() async {
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/getActiveContractById?id=${widget.item.customerShipNumber}';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      activeContract =
          rest.map<Contract>((json) => Contract.fromJson(json)).toList();
    }
  }

  Future<List<Contract>> getHistoryContract(String input) async {
    List<Contract> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract?id_customer=$input';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      list = rest.map<Contract>((json) => Contract.fromJson(json)).toList();
      print("List Size: ${list.length}");
    }

    return list;
  }

  Future<void> _refreshData() async {
    setState(() {
      getHistoryContract(widget.item.customerShipNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 280,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 190),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 15,
                                ),
                                style: ButtonStyle(
                                  shape:
                                      MaterialStateProperty.all(CircleBorder()),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(8)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/history_contract.png'),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                      Container(
                        height: 230,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.customerShipName,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                fontFamily: 'Montserrat',
                              ),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.black12,
                                  width: 1.8,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            'Penanggung Jawab',
                                            style: TextStyle(
                                              fontFamily: 'Segoe ui',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            widget.item.contactPerson.trim(),
                                            style: TextStyle(
                                              fontFamily: 'Segoe ui',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 1.8,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            'Nomor Akun',
                                            style: TextStyle(
                                              fontFamily: 'Segoe ui',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            widget.item.customerShipNumber,
                                            style: TextStyle(
                                              fontFamily: 'Segoe ui',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 1.8,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            'Status Akun',
                                            style: TextStyle(
                                              fontFamily: 'Segoe ui',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          margin: EdgeInsets.only(left: 7),
                                          decoration: BoxDecoration(
                                            color: widget.item.status == "A"
                                                ? Colors.orange[100]
                                                : Colors.red[100],
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            widget.item.status == 'A'
                                                ? 'AKTIF'
                                                : 'TIDAK AKTIF',
                                            style: TextStyle(
                                              fontFamily: 'Segoe ui',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: widget.item.status == 'A'
                                                  ? Colors.orange[800]
                                                  : Colors.red[800],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.isAdmin
                                ? SizedBox(
                                    width: 5,
                                  )
                                : Container(
                                    alignment: Alignment.centerRight,
                                    child: ArgonButton(
                                      height: 30,
                                      width: 100,
                                      borderRadius: 30.0,
                                      color: Colors.blue[600],
                                      child: Text(
                                        "Ubah kontrak",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      loader: Container(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onTap: (startLoading, stopLoading,
                                          btnState) {
                                        if (btnState == ButtonState.Idle) {
                                          startLoading();
                                          waitingLoad();
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChangeContract(
                                                        widget.item,
                                                        activeContract,
                                                        keyword: widget.keyword,
                                                      )));
                                          stopLoading();
                                        }
                                      },
                                    ),
                                  ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Riwayat Kontrak',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FutureBuilder(
                                future: getHistoryContract(
                                    widget.item.customerShipNumber),
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Center(
                                          child: CircularProgressIndicator());
                                    default:
                                      return snapshot.data != null
                                          ? listViewWidget(snapshot.data,
                                              snapshot.data.length)
                                          : Column(
                                              children: [
                                                Center(
                                                  child: Image.asset(
                                                    'assets/images/not_found.png',
                                                    width: 150,
                                                    height: 150,
                                                  ),
                                                ),
                                                Text(
                                                  'Data tidak ditemukan',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.red[600],
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                ),
                                              ],
                                            );
                                  }
                                }),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listViewWidget(List<Contract> item, int len) {
    return RefreshIndicator(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: len,
        shrinkWrap: true,
        itemBuilder: (context, position) {
          return InkWell(
            child: Container(
              margin: EdgeInsets.only(
                bottom: 5,
              ),
              padding: EdgeInsets.all(15),
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                border: Border.all(
                  color: Colors.black26,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/e_contract_new.png',
                    filterQuality: FilterQuality.medium,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Kontrak tahun ${item[position].startContract.substring(0, 4)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Segoe ui',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        convertDateWithMonth(item[position].startContract),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Segoe ui',
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        item[position].status,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Segoe ui',
                          color: item[position].status == "ACTIVE"
                              ? Colors.green.shade700
                              : item[position].status == "INACTIVE" ||
                                      item[position].status == "REJECTED"
                                  ? Colors.red.shade800
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () {
              item[position].status.contains('PENDING') ||
                      item[position].status.contains('pending') ||
                      item[position].status.contains('REJECTED') ||
                      item[position].status.contains('rejected')
                  ? formWaitingContract(context, item, position)
                  : item[position].idCustomer != null
                      ? getCustomerContractNew(
                          context: context,
                          idCust: item[position].idCustomer,
                          divisi: divisi,
                          username: username,
                          ttdPertama: ttdPertama,
                          isSales: true,
                          isContract: false,
                        )
                      : handleStatus(
                          context, 'Id customer tidak ditemukan', false);
            },
          );
        },
      ),
      onRefresh: _refreshData,
    );
  }
}
