import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sample/src/app/pages/econtract/econtract_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerScreen extends StatefulWidget {
  final int idOuter;
  @override
  _CustomerScreenState createState() => _CustomerScreenState();

  CustomerScreen(this.idOuter);
}

class _CustomerScreenState extends State<CustomerScreen> {
  String id = '';
  String role = '';
  String username = '';
  String search = '';
  var thisYear, nextYear;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");

      var formatter = new DateFormat('yyyy');
      thisYear = formatter.format(DateTime.now());
      nextYear = int.parse(thisYear) + 1;

      print('This Year : $thisYear');
      print('Next Year : $nextYear');

      print("Dashboard : $role");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  Future<List<Customer>> getCustomerById(int input) async {
    List<Customer> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/customers/getBySales?created_by=$input';
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

    return list;
  }

  Future<List<Customer>> getCustomerBySeach(String input) async {
    List<Customer> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/customers/search?search=$input';
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

    return list;
  }

  Future<void> _refreshData() async {
    setState(() {
      search.isNotEmpty
                      ? getCustomerBySeach(search)
                      : getCustomerById(widget.idOuter);
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
                      ? getCustomerBySeach(search)
                      : getCustomerById(widget.idOuter),
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
                          left: BorderSide(
                              color: customer[position].status == "Pending"
                                  ? Colors.grey[600]
                                  : customer[position].status == "Accepted"
                                      ? Colors.blue[600]
                                      : Colors.red[600],
                              width: 5),
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
                                color: customer[position].status == "Pending"
                                    ? Colors.grey[600]
                                    : customer[position].status == "Accepted"
                                        ? Colors.blue[600]
                                        : Colors.red[600],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                customer[position].status,
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
                      customer[position].econtract == "0"
                          ? Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EcontractScreen(customer, position)))
                          : formWaiting(customer, position);
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

  formWaiting(List<Customer> customer, int position) {
    return showModalBottomSheet(
      elevation: 2,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    customer[position].namaUsaha,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: customer[position].status == "Pending"
                          ? Colors.grey[600]
                          : customer[position].status == "Accepted"
                              ? Colors.blue[600]
                              : Colors.red[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      customer[position].status,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'Pengajuan e-kontrak berhasil',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.green[600],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Diajukan tgl : ${convertDateIndo(customer[position].dateAdded)}',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Divider(
                color: Colors.black54,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Detail Status',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    width: 50,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'SM',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Sales Manager',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        customer[position].ttdSalesManager == "0"
                            ? 'Menunggu Persetujuan Sales Manager'
                            : customer[position].ttdSalesManager == "1"
                                ? 'Disetujui oleh Sales Manager ${convertDateIndo(customer[position].dateSM)}'
                                : 'Ditolak oleh Sales Manager ${convertDateIndo(customer[position].dateSM)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    width: 50,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'AM',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AR Manager',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        customer[position].ttdArManager == "0"
                            ? 'Menunggu Persetujuan AR Manager'
                            : customer[position].ttdArManager == "1"
                                ? 'Disetujui oleh AR Manager ${convertDateIndo(customer[position].dateAM)}'
                                : 'Ditolak oleh AR Manager ${convertDateIndo(customer[position].dateAM)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    primary: Colors.blue[700],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Segoe ui',
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      },
    );
  }
}
