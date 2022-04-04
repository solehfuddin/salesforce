import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/renewcontract/history_contract.dart';
import 'package:sample/src/domain/entities/oldcustomer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RenewalContract extends StatefulWidget {
  dynamic keyword;
  bool isAdmin = false;

  RenewalContract({this.keyword, this.isAdmin});

  @override
  State<RenewalContract> createState() => _RenewalContractState();
}

class _RenewalContractState extends State<RenewalContract> {
  String id = '';
  String role = '';
  String username = '';
  String search = '';
  String divisi = '';
  String ttdPertama;
  int _count = 10;
  List<OldCustomer> oldCustomerList = List.empty(growable: true);
  TextEditingController txtSearch = TextEditingController();

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
    getAllOldCustomer();

    txtSearch.text = widget.keyword;
    search = widget.keyword;
    print("Keyword : ${widget.keyword}");
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

  getAllOldCustomer() async {
    var url =
        'http://timurrayalab.com/salesforce/server/api/customers/oldCustomer?limit=100&offset=0';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      oldCustomerList =
          rest.map<OldCustomer>((json) => OldCustomer.fromJson(json)).toList();
      print("List Size: ${oldCustomerList.length}");
    }
  }

  Future<List<OldCustomer>> getOldCustomerByIdLimit(int count) async {
    return Future.delayed(Duration(seconds: 3), () => getData(oldCustomerList));
  }

  List<OldCustomer> getData(List<OldCustomer> item) {
    List<OldCustomer> local = List.empty(growable: true);

    for (int i = 0; i < item.length; i++) {
      if (i < _count) {
        local.add(item[i]);
      }
    }

    print('Lokal size : ${local.length}');
    return local.toList();
  }

  Future<List<OldCustomer>> getOldCustomerBySearch(String input) async {
    setState(() {});

    List<OldCustomer> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/customers/searchOldCust?limit=100&offset=0&search=$input';
    
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      list =
          rest.map<OldCustomer>((json) => OldCustomer.fromJson(json)).toList();
      print("List Size: ${list.length}");
    }

    return list;
  }

  Future<void> _refreshData() async {
    setState(() {
      _count = 10;
      search.isNotEmpty
          ? getOldCustomerBySearch(search)
          : getOldCustomerByIdLimit(_count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'List Customer Lama',
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
              size: 18,
              color: Colors.black54,
            )),
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
              controller: txtSearch,
              decoration: InputDecoration(
                hintText:'Pencarian data..',
                prefixIcon: Icon(Icons.search),
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white70,
                contentPadding: EdgeInsets.symmetric(vertical: 3),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  txtSearch.text = value;
                  search = txtSearch.text;
                });
              },
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 100,
              child: FutureBuilder(
                future: txtSearch.text.isNotEmpty
                    ? getOldCustomerBySearch(search)
                    : getOldCustomerByIdLimit(_count),
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  final controller = ScrollController();
                  controller.addListener(() {
                    final pos =
                        controller.offset / controller.position.maxScrollExtent;
                    if (pos >= 0.8) {
                      if (snapshot.data.length == _count &&
                          _count < oldCustomerList.length) {
                        setState(() {
                          _count += 10;
                        });
                      }
                    }
                  });
                  if (data == null) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (oldCustomerList.length < 1) {
                      return Column(
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
                    } else {
                      return listViewWidget(
                          snapshot.data, snapshot.data.length, controller);
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listViewWidget(
      List<OldCustomer> item, int len, ScrollController controller) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            controller: controller,
            itemCount: len,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            shrinkWrap: true,
            itemBuilder: (context, position) {
              return InkWell(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 7,
                  ),
                  padding: EdgeInsets.all(15),
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black26,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              item[position].customerShipName,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Segoe Ui',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            item[position].customerShipNumber,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Segoe Ui',
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: item[position].status == "A"
                                  ? Colors.orange[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              item[position].status == 'A'
                                  ? 'AKTIF'
                                  : 'TIDAK AKTIF',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Segoe ui',
                                fontWeight: FontWeight.bold,
                                color: item[position].status == "A"
                                    ? Colors.orange[800]
                                    : Colors.red[800],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.pin_drop_sharp,
                                      color: Colors.blue[800],
                                      size: 14,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: item[position].city,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Segoe ui',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.attach_file,
                                    color: Colors.grey[600],
                                    size: 19,
                                  ),
                                ),
                                TextSpan(
                                  text: item[position].totalContract,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  item[position].contactPerson,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Image.asset(
                                  'assets/images/avatar_user.png',
                                  width: 28,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryContract(
                                item[position],
                                keyword: txtSearch.text,
                                isAdmin: false,
                              ))).then((_) {
                                setState(() {
                                  _refreshData();
                                });
                              });
                },
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}
