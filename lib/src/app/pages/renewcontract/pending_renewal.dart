import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PendingRenewal extends StatefulWidget {
  @override
  State<PendingRenewal> createState() => _PendingRenewalState();
}

class _PendingRenewalState extends State<PendingRenewal> {
  String search = '';
  String id = '';
  String role = '';
  String username = '';
  String divisi = '';
  String ttdPertama;

  Future<void> _refreshData() async {
    setState(() {
      divisi == "AR" ? getPendingData(true) : getPendingData(false);
    });
  }

  @override
  initState() {
    super.initState();
    getRole();
  }

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

  Future<List<Contract>> getPendingBySearch(String input, bool isAr) async {
    List<Contract> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/findOldCustContract';
    var response = await http.post(
      url,
      body: !isAr
          ? {
              'search': input,
              'approval_sm': '0',
            }
          : {
              'search': input,
              'approval_am': '0',
            },
    );

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

  Future<List<Contract>> getPendingData(bool isAr) async {
    List<Contract> list;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/contract/pendingContractOldCustSM'
        : 'http://timurrayalab.com/salesforce/server/api/contract/pendingContractOldCustAM';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      ? getPendingBySearch(
                          search, divisi == "AR" ? true : false)
                      : divisi == "AR"
                          ? getPendingData(true)
                          : getPendingData(false),
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

  Widget listViewWidget(List<Contract> item, int len) {
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
                  margin: EdgeInsets.only(
                    bottom: 10,
                  ),
                  padding: EdgeInsets.all(15),
                  height: 80,
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
                        width: 35,
                        height: 35,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          item[position].customerShipName != null
                              ? item[position].customerShipName
                              : '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            convertDateWithMonth(item[position].dateAdded),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Segoe ui',
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'PENDING',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  item[position].idCustomer != null
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailContract(
                              item[position],
                              divisi,
                              ttdPertama,
                              username,
                              false,
                              isContract: true,
                              isAdminRenewal: false,
                            ),
                          ),
                        )
                      : handleStatus(
                          context, 'Id customer tidak ditemukan', false);
                },
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}
