import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:http/http.dart' as http;

class WaitingApprovalScreen extends StatefulWidget {
  @override
  _WaitingApprovalScreenState createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen> {
  String id = '';
  String role = '';
  String username = '';
  String divisi = '';
  String ttdPertama;
  String tpNikon, tpLeinz, tpOriental, tpMoe;
  String pembNikon, pembLeinz, pembOriental, pembMoe;
  String tglKontrak;
  Contract itemContract;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");

      getTtd(int.parse(id));

      print("Dashboard : $role");
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

  @override
  void initState() {
    super.initState();
    getRole();
  }

  Future<List<Customer>> getCustomerData(bool isAr) async {
    List<Customer> list;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/customers/approvalSM?ttd_sales_manager=0'
        : 'http://timurrayalab.com/salesforce/server/api/customers/approvalAM?ttd_ar_manager=0';

    try {
      var response = await http.get(url);

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        list = rest.map<Customer>((json) => Customer.fromJson(json)).toList();
        print("List Size: ${list.length}");
      }
    } catch (e) {
      print(e.toString());
    }
    return list;
  }

  getCustomerContract(dynamic idCust, bool isContract) async {
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
      openDialog(isContract);
    }
  }

  openDialog(bool isContract) async {
    await formContract(itemContract, divisi, isContract);
    setState(() {});
  }

  Future<void> _refreshData() async {
    setState(() {
      divisi == "AR" ? getCustomerData(true) : getCustomerData(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'List Customer Baru',
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
          onPressed: () {
            if (role == 'admin') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminScreen()));
            } else if (role == 'sales') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            }
          },
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
          Expanded(
            child: SizedBox(
              height: 100,
              child: FutureBuilder(
                  future: divisi == "AR"
                      ? getCustomerData(true)
                      : getCustomerData(false),
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

  Widget listViewWidget(List<Customer> customer, int len) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 8,
            ),
            itemBuilder: (context, position) {
              return Card(
                elevation: 2,
                child: ClipPath(
                  child: InkWell(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey[600], width: 5),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  customer[position].namaUsaha,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tgl entry : ',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 40,
                                    ),
                                    Text(
                                      'Pemilik : ',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      convertDateIndo(
                                          customer[position].dateAdded),
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Text(
                                      customer[position].nama,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                customer[position].namaSalesman.length > 0
                                    ? capitalize(
                                        customer[position].namaSalesman)
                                    : 'Admin',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Segoe ui',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        getCustomerContract(customer[position].id, false);
                      });
                    },
                  ),
                  clipper: ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }

  formContract(Contract item, String div, bool isContract) {
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
          return DetailContract(
            item,
            div,
            ttdPertama,
            username,
            false,
            isContract: isContract,
            isAdminRenewal: false,
          );
        });
  }
}
