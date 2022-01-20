import 'dart:convert';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/econtract/multiform_disc.dart';
import 'package:sample/src/app/econtract/multiproduct_disc.dart';
import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class EcontractScreen extends StatefulWidget {
  final List<Customer> customerList;
  final int position;

  @override
  _EcontractScreenState createState() => _EcontractScreenState();

  EcontractScreen(this.customerList, this.position);
}

class _EcontractScreenState extends State<EcontractScreen> {
  String id = '';
  String role = '';
  String username = '';
  String idCustomer,
      namaKedua,
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
  TextEditingController textTanggalSt = new TextEditingController();
  TextEditingController textTanggalEd = new TextEditingController();
  bool _isValNikon = false;
  bool _isValLeinz = false;
  bool _isValOriental = false;
  bool _isValMoe = false;
  bool _isTanggalSt = false;
  bool _isTanggalEd = false;
  bool _isRegularDisc = false;
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
      getTtdSales(int.parse(id));

      ttdKedua = widget.customerList[widget.position].ttdCustomer;
      idCustomer = widget.customerList[widget.position].id;
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  getTtdSales(int input) async {
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

  Future<List<Proddiv>> getProdDiv() async {
    List<Proddiv> list;
    var url = 'http://timurrayalab.com/salesforce/server/api/product/getProDiv';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      list = rest.map<Proddiv>((json) => Proddiv.fromJson(json)).toList();
      print("List Size: ${list.length}");
    }

    return list;
  }

  checkInput(Function stop) async {
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

    textTanggalSt.text.isEmpty ? _isTanggalSt = true : _isTanggalSt = false;
    textTanggalEd.text.isEmpty ? _isTanggalEd = true : _isTanggalEd = false;
    textValNikon.text.isEmpty ? _isValNikon = true : _isValNikon = false;
    textValLeinz.text.isEmpty ? _isValLeinz = true : _isValLeinz = false;
    textValOriental.text.isEmpty
        ? _isValOriental = true
        : _isValOriental = false;
    textValMoe.text.isEmpty ? _isValMoe = true : _isValMoe = false;

    if (!_isTanggalSt &&
        !_isTanggalEd &&
        !_isValNikon &&
        !_isValLeinz &&
        !_isValOriental &&
        !_isValMoe) {
      var url = 'http://timurrayalab.com/salesforce/server/api/contract/upload';
      var response = await http.post(
        url,
        body: {
          'id_customer': idCustomer,
          'nama_pertama': username,
          'jabatan_pertama': role,
          'nama_kedua': namaKedua,
          'jabatan_kedua': jabatanKedua,
          'alamat_kedua': alamatKedua,
          'telp_kedua': telpKedua,
          'fax_kedua': faxKedua,
          'tp_nikon': textValNikon.text.replaceAll('.', ''),
          'tp_leinz': textValLeinz.text.replaceAll('.', ''),
          'tp_oriental': textValOriental.text.replaceAll('.', ''),
          'tp_moe': textValMoe.text.replaceAll('.', ''),
          'pembayaran_nikon': _chosenNikon,
          'pembayaran_leinz': _chosenLeinz,
          'pembayaran_oriental': _chosenOriental,
          'pembayaran_moe': _chosenMoe,
          'start_contract': textTanggalSt.text,
          'end_contract': textTanggalEd.text,
          'ttd_pertama': ttdPertama,
          'ttd_kedua': ttdKedua,
          'created_by': id,
        },
      );

      print('ttd 1 : $ttdPertama');
      print('ttd 2 : $ttdKedua');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'];

      if (sts) {
        textTanggalSt.clear();
        textTanggalEd.clear();
        textValLeinz.clear();
        textValMoe.clear();
        textValNikon.clear();
        textValOriental.clear();

        simpanDiskon(idCustomer);
      }

      handleStatus(context, capitalize(msg), sts);
      stop();
      setState(() {});
    } else {
      stop();
    }
  }

  simpanDiskon(String idCust) async {
    var url =
        'http://timurrayalab.com/salesforce/server/api/discount/defaultDiskon';
    var response = await http.post(
      url,
      body: {
        'id_customer': idCust,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Perjanjian Kerjasama Pembelian',
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
          onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => CustomerScreen(int.parse(id)))),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black54,
            size: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  namaKedua = widget.customerList[widget.position].nama,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  telpKedua = widget.customerList[widget.position].noTlp,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  faxKedua = widget.customerList[widget.position].fax.isEmpty
                      ? '-'
                      : widget.customerList[widget.position].fax,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    alamatKedua = widget.customerList[widget.position].alamat,
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
                  errorText: _isValNikon ? 'Data wajib diisi' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
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
                  errorText: _isValLeinz ? 'Data wajib diisi' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
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
                  errorText: _isValOriental ? 'Data wajib diisi' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
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
                  errorText: _isValMoe ? 'Data wajib diisi' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5)),
                    margin: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      value: _chosenNikon,
                      style: TextStyle(color: Colors.black54),
                      items: [
                        'Cash & Carry',
                        'Transfer',
                        'Deposit',
                        'Bulanan',
                      ].map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child:
                              Text(e, style: TextStyle(color: Colors.black54)),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5)),
                    margin: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      value: _chosenLeinz,
                      style: TextStyle(color: Colors.black54),
                      items: [
                        'Cash & Carry',
                        'Transfer',
                        'Deposit',
                        'Bulanan',
                      ].map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child:
                              Text(e, style: TextStyle(color: Colors.black54)),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5)),
                    margin: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      value: _chosenOriental,
                      style: TextStyle(color: Colors.black54),
                      items: [
                        'Cash & Carry',
                        'Transfer',
                        'Deposit',
                        'Bulanan',
                      ].map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child:
                              Text(e, style: TextStyle(color: Colors.black54)),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5)),
                    margin: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      value: _chosenMoe,
                      style: TextStyle(color: Colors.black54),
                      items: [
                        'Cash & Carry',
                        'Transfer',
                        'Deposit',
                        'Bulanan',
                      ].map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child:
                              Text(e, style: TextStyle(color: Colors.black54)),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
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
                  hintText: 'Tanggal Mulai',
                  labelText: 'Tanggal Mulai',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  errorText: _isTanggalSt ? 'Data wajib diisi' : null,
                ),
                controller: textTanggalSt,
                format: format,
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(nextYear));
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              child: DateTimeField(
                decoration: InputDecoration(
                  hintText: 'Tanggal Berakhir',
                  labelText: 'Tanggal Berakhir',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  errorText: _isTanggalEd ? 'Data wajib diisi' : null,
                ),
                controller: textTanggalEd,
                format: format,
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(nextYear));
                },
              ),
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
                'Kontrak Diskon Reguler : ',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 200,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    child: Text(
                      'All Lensa Reguler',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 2,
                  ),
                  child: Checkbox(
                    value: this._isRegularDisc,
                    onChanged: (bool value) {
                      setState(() {
                        this._isRegularDisc = value;
                      });
                    },
                  ), //C
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            _isRegularDisc
                ? SizedBox(
                    height: 5,
                  )
                : MultiFormDisc(),
            MultiProductDisc(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              alignment: Alignment.centerRight,
              child: ArgonButton(
                height: 40,
                width: 100,
                borderRadius: 30.0,
                color: Colors.blue[700],
                child: Text(
                  "Simpan",
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
                    setState(() {
                      startLoading();
                      waitingLoad();
                      checkInput(stopLoading);
                    });
                  }
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
