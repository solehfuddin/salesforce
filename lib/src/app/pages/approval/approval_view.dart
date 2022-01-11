import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:http/http.dart' as http;

class ApprovedScreen extends StatefulWidget {
  @override
  _ApprovedScreenState createState() => _ApprovedScreenState();
}

class _ApprovedScreenState extends State<ApprovedScreen> {
  Future<List<Customer>> getCustomerData(bool isAr) async {
    List<Customer> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/customers/approved';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Approved Customer',
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
          Expanded(
            child: SizedBox(
              height: 100,
              child: FutureBuilder(
                  future: getCustomerData(false),
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
    return Container(
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
                              color: Colors.teal[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              customer[position].namaSalesman.length > 0
                                  ? capitalize(customer[position].namaSalesman)
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
                  onTap: () {},
                ),
                clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
