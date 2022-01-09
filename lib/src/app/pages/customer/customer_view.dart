import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
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
  String namaKedua,
      jabatanKedua,
      alamatKedua,
      telpKedua,
      faxKedua,
      ttdPertama,
      ttdKedua;
  String _chosenNikon, _chosenLeinz, _chosenOriental, _chosenMoe;
  final format = DateFormat("yyyy-MM-dd");
  TextEditingController textValNikon = new TextEditingController();
  TextEditingController textValLeinz = new TextEditingController();
  TextEditingController textValOriental = new TextEditingController();
  TextEditingController textValMoe = new TextEditingController();
  TextEditingController textTanggal = new TextEditingController();
  bool _isValNikon = false;
  bool _isValLeinz = false;
  bool _isValOriental = false;
  bool _isValMoe = false;
  bool _isTanggal = false;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");

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

  checkInput() async {
    if (_chosenNikon == null) {
      _chosenNikon = 'Cash & Carry';
    }

    if (_chosenLeinz == null) {
      _chosenLeinz = 'Cash & Carry';
    }

    if (_chosenOriental == null) {
      _chosenOriental = 'Cash & Carry';
    }

    if (_chosenMoe == null) {
      _chosenMoe = 'Cash & Carry';
    }

    textTanggal.text.isEmpty ? _isTanggal = true : _isTanggal = false;
    textValNikon.text.isEmpty ? _isValNikon = true : _isValNikon = false;
    textValLeinz.text.isEmpty ? _isValLeinz = true : _isValLeinz = false;
    textValOriental.text.isEmpty
        ? _isValOriental = true
        : _isValOriental = false;
    textValMoe.text.isEmpty ? _isValMoe = true : _isValMoe = false;

    if (!_isTanggal &&
        !_isValNikon &&
        !_isValLeinz &&
        !_isValOriental &&
        !_isValMoe) {
      var url = 'http://timurrayalab.com/salesforce/server/api/contract/upload';
      var response = await http.post(
        url,
        body: {
          'nama_pertama': username,
          'jabatan_pertama': role,
          'nama_kedua': namaKedua,
          'jabatan_kedua': jabatanKedua,
          'alamat_kedua': alamatKedua,
          'telp_kedua': telpKedua,
          'fax_kedua': faxKedua,
          'tp_nikon': textValNikon.text,
          'tp_leinz': textValLeinz.text,
          'tp_oriental': textValOriental.text,
          'tp_moe': textValMoe.text,
          'pembayaran_nikon': _chosenNikon,
          'pembayaran_leinz': _chosenLeinz,
          'pembayaran_oriental': _chosenOriental,
          'pembayaran_moe': _chosenMoe,
          'start_contract': textTanggal.text,
          // 'ttd_pertama': ttdPertama,
          'ttd_kedua': ttdKedua,
          'created_by': id,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'];

      handleStatus(context, capitalize(msg), sts);
    }
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
                        left: BorderSide(color: Colors.red[700], width: 5),
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
                              color: Colors.red[600],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              customer[position].namaArManager,
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
                    showModalBottomSheet(
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
                          ttdKedua = customer[position].ttdCustomer;

                          return StatefulBuilder(builder:
                              (BuildContext context, StateSetter modalState) {
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                      child: Text(
                                        'Perjanjian Kerjasama Pembelian',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Segoe ui',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Pihak Pertama',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Nama : ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        username,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Jabatan : ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        role,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Telp : ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 29,
                                      ),
                                      Text(
                                        '021-4610154',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Fax : ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 34,
                                      ),
                                      Text(
                                        '021-4610151-52',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Alamat : ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Jl. Rawa Kepiting No. 4 Kawasan Industri Pulogadung, Jakarta Timur',
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Pihak Kedua',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Nama : ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        namaKedua = customer[position].nama,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Jabatan : ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        jabatanKedua = 'Owner',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Telp : ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 29,
                                      ),
                                      Text(
                                        telpKedua = customer[position].noTlp,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Fax : ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 34,
                                      ),
                                      Text(
                                        faxKedua =
                                            customer[position].fax.isEmpty
                                                ? '-'
                                                : customer[position].fax,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Alamat : ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Expanded(
                                        child: Text(
                                          alamatKedua =
                                              customer[position].alamat,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Target Pembelian yang disepakati : ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Lensa Nikon',
                                        labelText: 'Lensa Nikon',
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 15,
                                        ),
                                        errorText: _isValNikon
                                            ? 'Data wajib diisi'
                                            : null,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      controller: textValNikon,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Lensa Leinz',
                                        labelText: 'Lensa Leinz',
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 15,
                                        ),
                                        errorText: _isValLeinz
                                            ? 'Data wajib diisi'
                                            : null,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      controller: textValLeinz,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Lensa Oriental',
                                        labelText: 'Lensa Oriental',
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 15,
                                        ),
                                        errorText: _isValOriental
                                            ? 'Data wajib diisi'
                                            : null,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      controller: textValOriental,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Lensa Moe',
                                        labelText: 'Lensa Moe',
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 15,
                                        ),
                                        errorText: _isValMoe
                                            ? 'Data wajib diisi'
                                            : null,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      controller: textValMoe,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Jangka waktu pembayaran : ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            'Lensa Nikon : ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.white70,
                                              border: Border.all(
                                                  color: Colors.black54),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: DropdownButton(
                                            underline: SizedBox(),
                                            isExpanded: true,
                                            value: _chosenNikon,
                                            style: TextStyle(
                                                color: Colors.black54),
                                            items: [
                                              'Cash & Carry',
                                              'Transfer',
                                              'Deposit',
                                              'Bulanan',
                                            ].map((e) {
                                              return DropdownMenuItem(
                                                value: e,
                                                child: Text(e,
                                                    style: TextStyle(
                                                        color: Colors.black54)),
                                              );
                                            }).toList(),
                                            onChanged: (String value) {
                                              modalState(() {
                                                _chosenNikon = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            'Lensa Leinz : ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.white70,
                                              border: Border.all(
                                                  color: Colors.black54),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: DropdownButton(
                                            underline: SizedBox(),
                                            isExpanded: true,
                                            value: _chosenLeinz,
                                            style: TextStyle(
                                                color: Colors.black54),
                                            items: [
                                              'Cash & Carry',
                                              'Transfer',
                                              'Deposit',
                                              'Bulanan',
                                            ].map((e) {
                                              return DropdownMenuItem(
                                                value: e,
                                                child: Text(e,
                                                    style: TextStyle(
                                                        color: Colors.black54)),
                                              );
                                            }).toList(),
                                            onChanged: (String value) {
                                              modalState(() {
                                                _chosenLeinz = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            'Lensa Oriental : ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.white70,
                                              border: Border.all(
                                                  color: Colors.black54),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: DropdownButton(
                                            underline: SizedBox(),
                                            isExpanded: true,
                                            value: _chosenOriental,
                                            style: TextStyle(
                                                color: Colors.black54),
                                            items: [
                                              'Cash & Carry',
                                              'Transfer',
                                              'Deposit',
                                              'Bulanan',
                                            ].map((e) {
                                              return DropdownMenuItem(
                                                value: e,
                                                child: Text(e,
                                                    style: TextStyle(
                                                        color: Colors.black54)),
                                              );
                                            }).toList(),
                                            onChanged: (String value) {
                                              modalState(() {
                                                _chosenOriental = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            'Lensa Moe : ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.white70,
                                              border: Border.all(
                                                  color: Colors.black54),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: DropdownButton(
                                            underline: SizedBox(),
                                            isExpanded: true,
                                            value: _chosenMoe,
                                            style: TextStyle(
                                                color: Colors.black54),
                                            items: [
                                              'Cash & Carry',
                                              'Transfer',
                                              'Deposit',
                                              'Bulanan',
                                            ].map((e) {
                                              return DropdownMenuItem(
                                                value: e,
                                                child: Text(e,
                                                    style: TextStyle(
                                                        color: Colors.black54)),
                                              );
                                            }).toList(),
                                            onChanged: (String value) {
                                              modalState(() {
                                                _chosenMoe = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Terhitung sejak tanggal : ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    child: DateTimeField(
                                      decoration: InputDecoration(
                                        hintText: 'Tanggal Berlaku',
                                        labelText: 'Tanggal Berlaku',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        errorText: _isTanggal
                                            ? 'Data wajib diisi'
                                            : null,
                                      ),
                                      controller: textTanggal,
                                      format: format,
                                      onShowPicker: (context, currentValue) {
                                        return showDatePicker(
                                            context: context,
                                            firstDate: DateTime(1900),
                                            initialDate:
                                                currentValue ?? DateTime.now(),
                                            lastDate: DateTime(2100));
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: StadiumBorder(),
                                        primary: Colors.blue[700],
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                      ),
                                      child: Text(
                                        'Simpan',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Segoe ui',
                                        ),
                                      ),
                                      onPressed: () {
                                        // Navigator.pop(context);
                                        modalState(() {
                                          checkInput();
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            );
                          });
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
    );
  }
}
