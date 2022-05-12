import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/econtract/form_disc.dart';
import 'package:sample/src/app/pages/econtract/form_product.dart';
import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:sample/src/domain/entities/product.dart';
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
  final globalKey = GlobalKey();
  List<FormItemDisc> formDisc = List.empty(growable: true);
  List<FormItemProduct> formProduct = List.empty(growable: true);
  List<String> tmpDiv = List.empty(growable: true);
  List<String> tmpProduct = List.empty(growable: true);
  List<Proddiv> itemProdDiv = List.empty(growable: true);
  List<Product> itemProduct = List.empty(growable: true);
  Map<String, String> selectMapProddiv = {"": ""};
  Map<String, String> selectMapProduct = {"": ""};
  String search = '';
  String id = '';
  String role = '';
  String username = '';
  String name = '';
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
  bool _isTanggalSt = false;
  bool _isTanggalEd = false;
  bool _isRegularDisc = false;
  bool _isFrameContract = false;
  bool _isChildContract = false;
  bool _isNetworkConnected = true;
  var thisYear, nextYear;
  int formLen;

  callback(newVal) {
    setState(() {
      formLen = newVal;
    });
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");

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

  getItemProdDiv() async {
    var url = 'http://timurrayalab.com/salesforce/server/api/product/getProDiv';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      itemProdDiv =
          rest.map<Proddiv>((json) => Proddiv.fromJson(json)).toList();
      print("List Size: ${itemProdDiv.length}");
    }
  }

  Future<List<Product>> getSearchProduct(String input) async {
    List<Product> list;
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/product/search?search=$input';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        list = rest.map<Product>((json) => Product.fromJson(json)).toList();
        itemProduct =
            rest.map<Product>((json) => Product.fromJson(json)).toList();
        print("List Size: ${list.length}");
        print("Product Size: ${itemProduct.length}");
      }

      return list;
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  getSelectedItem() {
    selectMapProduct.clear();

    if (itemProduct != null) {
      itemProduct.forEach((item) {
        if (item.ischecked) {
          selectMapProduct[item.proddiv] = item.proddesc;
          Product itemProduct = Product(item.categoryid, item.proddiv,
              item.prodcat, item.proddesc, item.status);
          if (!tmpProduct.contains(item.proddesc)) {
            tmpProduct.add(item.proddesc);
            tmpProduct.forEach((element) {
              print(element);
            });

            setState(() {
              formProduct.add(FormItemProduct(
                index: formProduct.length,
                product: itemProduct,
              ));
            });
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getRole();
    // getSearchProduct('');
  }

  getTtdSales(int input) async {
    const timeout = 15;
    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        ttdPertama = data['data'][0]['ttd'];
        print(ttdPertama);
      }

      getItemProdDiv();
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
      _isNetworkConnected = false;
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
      _isNetworkConnected = false;
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
      _isNetworkConnected = false;
    }
  }

  getSelectedProddiv() {
    selectMapProddiv.clear();

    if (itemProdDiv != null) {
      itemProdDiv.forEach((item) {
        if (item.ischecked) {
          selectMapProddiv[item.proddiv] = item.alias;
          Proddiv itemProddiv = Proddiv(item.alias, item.proddiv, item.diskon);

          if (!tmpDiv.contains(item.proddiv)) {
            tmpDiv.add(item.proddiv);
            tmpDiv.forEach((element) {
              print(element);
            });

            setState(() {
              formDisc.add(FormItemDisc(
                index: formDisc.length,
                proddiv: itemProddiv,
              ));
            });
          }
        }
      });
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
      _chosenNikon = '-';
    }

    if (_chosenLeinz == null) {
      _chosenLeinz = '-';
    }

    if (_chosenOriental == null) {
      _chosenOriental = '-';
    }

    if (_chosenMoe == null) {
      _chosenMoe = '-';
    }

    textTanggalSt.text.isEmpty ? _isTanggalSt = true : _isTanggalSt = false;
    textTanggalEd.text.isEmpty ? _isTanggalEd = true : _isTanggalEd = false;

    if (!_isTanggalSt && !_isTanggalEd) {
      var url = 'http://timurrayalab.com/salesforce/server/api/contract/upload';
      const timeout = 15;

      try {
        var response = await http.post(
          url,
          body: {
            'id_customer': idCustomer,
            'nama_pertama': name,
            'jabatan_pertama': role,
            'nama_kedua': namaKedua,
            'jabatan_kedua': jabatanKedua,
            'alamat_kedua': alamatKedua,
            'telp_kedua': telpKedua,
            'fax_kedua': faxKedua,
            'tp_nikon': textValNikon.text.length > 0
                ? textValNikon.text.replaceAll('.', '')
                : '0',
            'tp_leinz': textValLeinz.text.length > 0
                ? textValLeinz.text.replaceAll('.', '')
                : '0',
            'tp_oriental': textValOriental.text.length > 0
                ? textValOriental.text.replaceAll('.', '')
                : '0',
            'tp_moe': textValMoe.text.length > 0
                ? textValMoe.text.replaceAll('.', '')
                : '0',
            'pembayaran_nikon': _chosenNikon,
            'pembayaran_leinz': _chosenLeinz,
            'pembayaran_oriental': _chosenOriental,
            'pembayaran_moe': _chosenMoe,
            'start_contract': textTanggalSt.text,
            'end_contract': textTanggalEd.text,
            'type_contract': _isFrameContract ? 'FRAME' : 'LENSA',
            'ttd_pertama': ttdPertama,
            'ttd_kedua': ttdKedua,
            'created_by': id,
          },
        ).timeout(Duration(seconds: timeout));

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

          _isRegularDisc ? simpanDiskon(idCustomer) : multipleInputDiskon();
        }

        handleStatus(context, capitalize(msg), sts);
        setState(() {});
      } on TimeoutException catch (e) {
        print('Timeout Error : $e');
        handleTimeout(context);
      } on SocketException catch (e) {
        print('Socket Error : $e');
        handleSocket(context);
      } on Error catch (e) {
        print('General Error : $e');
        handleStatus(context, e.toString(), false);
      }

      stop();
    } else {
      handleStatus(context, 'Harap lengkapi data terlebih dahulu', false);
      stop();
    }
  }

  multipleInputDiskon() async {
    bool allValid = true;

    formDisc
        .forEach((element) => allValid = (allValid && element.isValidated()));

    if (allValid) {
      for (int i = 0; i < formDisc.length; i++) {
        FormItemDisc item = formDisc[i];
        if (item.proddiv.ischecked) {
          debugPrint("Proddiv: ${item.proddiv.proddiv}");
          debugPrint("Alias: ${item.proddiv.alias}");
          debugPrint("Diskon: ${item.proddiv.diskon}");
          debugPrint("Is Checked : ${item.proddiv.ischecked}");
          postMultiDiv(idCustomer, item.proddiv.proddiv, item.proddiv.diskon,
              item.proddiv.alias);
        }
      }
    } else {
      print("Form is Not Valid");
    }

    formProduct
        .forEach((element) => allValid = (allValid && element.isValidated()));

    if (allValid) {
      for (int i = 0; i < formProduct.length; i++) {
        FormItemProduct item = formProduct[i];
        if (item.product.ischecked) {
          debugPrint("Category Id: ${item.product.categoryid}");
          debugPrint("Proddiv: ${item.product.proddiv}");
          debugPrint("Prodcat: ${item.product.prodcat}");
          debugPrint("Proddesc: ${item.product.proddesc}");
          debugPrint("Diskon: ${item.product.diskon}");

          postMultiItem(
              idCustomer,
              item.product.categoryid,
              item.product.proddiv,
              item.product.prodcat,
              item.product.proddesc,
              item.product.diskon);
        }
      }
    } else {
      print("Form is Not Valid");
    }
  }

  postMultiDiv(
      String idCust, String proddiv, String diskon, String alias) async {
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/discount/divCustomDiscount';

    try {
      var response = await http.post(
        url,
        body: {
          'id_customer': idCust,
          'prod_div[]': proddiv,
          'discount[]': diskon,
          'prodcat_description[]': alias,
        },
      ).timeout(Duration(seconds: timeout));

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'];

      if (sts) {
        print(msg);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  postMultiItem(String idCust, String categoryId, String prodDiv,
      String prodCat, String prodDesc, String disc) async {
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/discount/customDiscount';

    try {
      var response = await http.post(
        url,
        body: {
          'id_customer': idCust,
          'category_id[]': categoryId,
          'prod_div[]': prodDiv,
          'prodcat[]': prodCat,
          'prodcat_description[]': prodDesc,
          'discount[]': disc,
        },
      ).timeout(Duration(seconds: timeout));

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'];

      if (sts) {
        print(msg);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  simpanDiskon(String idCust) async {
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/discount/defaultDiscount';

    try {
      var response = await http.post(
        url,
        body: {
          'id_customer': idCust,
        },
      ).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }
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
            fontSize: 18.sp,
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
            size: 18.r,
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
                horizontal: 20.r,
                vertical: 8.r,
              ),
              child: Text(
                'Pihak Pertama',
                style: TextStyle(
                  fontSize: 16.sp,
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
                  width: 20.w,
                ),
                Text(
                  'Nama : ',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 15.w,
                ),
                Text(
                  // username,
                  name,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  'Jabatan : ',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 2.w,
                ),
                Text(
                  // capitalize(role),
                  role,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  'Telp : ',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 29.w,
                ),
                Text(
                  '021-4610154',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  'Fax : ',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 34.w,
                ),
                Text(
                  '021-4610151-52',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  'Alamat : ',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 7.w,
                ),
                Expanded(
                  child: Text(
                    'Jl. Rawa Kepiting No. 4 Kawasan Industri Pulogadung, Jakarta Timur',
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 8.r,
              ),
              child: Text(
                'Pihak Kedua',
                style: TextStyle(
                  fontSize: 16.sp,
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
                  width: 20.w,
                ),
                Text(
                  'Nama : ',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 15.w,
                ),
                Text(
                  namaKedua = widget.customerList[widget.position].nama,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  'Jabatan : ',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 2.w,
                ),
                Text(
                  jabatanKedua = 'Owner',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  'Telp : ',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 29.w,
                ),
                Text(
                  telpKedua = widget.customerList[widget.position].noTlp,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  'Fax : ',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 34.w,
                ),
                Text(
                  faxKedua = widget.customerList[widget.position].fax.isEmpty
                      ? '-'
                      : widget.customerList[widget.position].fax,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  'Alamat : ',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 7.w,
                ),
                Expanded(
                  child: Text(
                    alamatKedua = widget.customerList[widget.position].alamat,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 8.r,
              ),
              child: Text(
                'Target Pembelian yang disepakati / bulan : ',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 5.r,
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Lensa Nikon',
                  labelText: 'Lensa Nikon',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 3.r,
                    horizontal: 15.r,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                controller: textValNikon,
                maxLength: 15,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 5.r,
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Lensa Leinz',
                  labelText: 'Lensa Leinz',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 3.r,
                    horizontal: 15.r,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                controller: textValLeinz,
                maxLength: 15,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 5.r,
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Lensa Oriental',
                  labelText: 'Lensa Oriental',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 3.r,
                    horizontal: 15.r,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                controller: textValOriental,
                maxLength: 15,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 5.r,
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Lensa Moe',
                  labelText: 'Lensa Moe',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 3.r,
                    horizontal: 15.r,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                controller: textValMoe,
                maxLength: 15,
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 8.r,
              ),
              child: Text(
                'Jangka waktu pembayaran / bulan : ',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 150.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.r,
                      vertical: 5.r,
                    ),
                    child: Text(
                      'Lensa Nikon : ',
                      style: TextStyle(
                        fontSize: 14.sp,
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
                      horizontal: 20.r,
                      vertical: 5.r,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5.r)),
                    margin: EdgeInsets.symmetric(
                      horizontal: 20.r,
                    ),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      value: _chosenNikon,
                      style: TextStyle(color: Colors.black54),
                      items: [
                        '-',
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
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 150.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.r,
                      vertical: 5.r,
                    ),
                    child: Text(
                      'Lensa Leinz : ',
                      style: TextStyle(
                        fontSize: 14.sp,
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
                      horizontal: 20.r,
                      vertical: 5.r,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5.r)),
                    margin: EdgeInsets.symmetric(
                      horizontal: 20.r,
                    ),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      value: _chosenLeinz,
                      style: TextStyle(color: Colors.black54),
                      items: [
                        '-',
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
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 150.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.r,
                      vertical: 5.r,
                    ),
                    child: Text(
                      'Lensa Oriental : ',
                      style: TextStyle(
                        fontSize: 14.sp,
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
                      horizontal: 20.r,
                      vertical: 5.r,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5.r)),
                    margin: EdgeInsets.symmetric(
                      horizontal: 20.r,
                    ),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      value: _chosenOriental,
                      style: TextStyle(color: Colors.black54),
                      items: [
                        '-',
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
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 150.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.r,
                      vertical: 5.r,
                    ),
                    child: Text(
                      'Lensa Moe : ',
                      style: TextStyle(
                        fontSize: 14.sp,
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
                      horizontal: 20.r,
                      vertical: 5.r,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(5.r)),
                    margin: EdgeInsets.symmetric(
                      horizontal: 20.r,
                    ),
                    child: DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      value: _chosenMoe,
                      style: TextStyle(color: Colors.black54),
                      items: [
                        '-',
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
              height: 20.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 8.r,
              ),
              child: Text(
                'Terhitung sejak tanggal : ',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 5.r,
              ),
              child: DateTimeField(
                decoration: InputDecoration(
                  hintText: 'Tanggal Mulai',
                  labelText: 'Tanggal Mulai',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  errorText: _isTanggalSt ? 'Data wajib diisi' : null,
                ),
                maxLength: 10,
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
                horizontal: 20.r,
                vertical: 5.r,
              ),
              child: DateTimeField(
                decoration: InputDecoration(
                  hintText: 'Tanggal Berakhir',
                  labelText: 'Tanggal Berakhir',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  errorText: _isTanggalEd ? 'Data wajib diisi' : null,
                ),
                maxLength: 10,
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
            areaFrameContract(),
            _isFrameContract || _isChildContract
                ? SizedBox(
                    width: 5.w,
                  )
                : areaLensaContract(),
            _isFrameContract || _isChildContract
                ? SizedBox(
                    width: 5.w,
                  )
                : _isRegularDisc
                    ? SizedBox(
                        height: 5.h,
                      )
                    : areaMultiFormDiv(),
            _isFrameContract || _isChildContract
                ? SizedBox(
                    width: 5.w,
                  )
                : _isRegularDisc
                    ? SizedBox(
                        height: 5.h,
                      )
                    : areaMultiFormProduct(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 5.r,
              ),
              alignment: Alignment.centerRight,
              child: ArgonButton(
                height: 40.h,
                width: 100.w,
                borderRadius: 30.0.r,
                color: Colors.blue[700],
                child: Text(
                  "Simpan",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700),
                ),
                loader: Container(
                  padding: EdgeInsets.all(8.r),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                onTap: (startLoading, stopLoading, btnState) {
                  if (btnState == ButtonState.Idle) {
                    setState(() {
                      startLoading();
                      waitingLoad();
                      _isNetworkConnected
                          ? checkInput(stopLoading)
                          : handleConnection(context);
                    });
                  }
                },
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget dialogProddiv(List<Proddiv> item) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text('Pilih ProdDiv'),
        actions: [
          ElevatedButton(
              onPressed: () {
                getSelectedProddiv();
                Navigator.pop(context);
              },
              child: Text("Submit")),
        ],
        content: Container(
          width: double.minPositive.w,
          height: 300.h,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: item.length,
            itemBuilder: (BuildContext context, int index) {
              String _key = item[index].alias;
              return CheckboxListTile(
                value: item[index].ischecked,
                title: Text(_key),
                onChanged: (bool val) {
                  setState(() {
                    item[index].ischecked = val;
                  });
                },
              );
            },
          ),
        ),
      );
    });
  }

  Widget customProduct() {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text('Pilih Item'),
        actions: [
          ElevatedButton(
              onPressed: () {
                getSelectedItem();
                Navigator.pop(context);
              },
              child: Text("Submit")),
        ],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 350.w,
              padding: EdgeInsets.symmetric(
                horizontal: 5.r,
                vertical: 10.r,
              ),
              color: Colors.white,
              height: 80.h,
              child: TextField(
                textInputAction: TextInputAction.search,
                autocorrect: true,
                decoration: InputDecoration(
                  hintText: 'Pencarian data ...',
                  prefixIcon: Icon(Icons.search),
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white70,
                  contentPadding: EdgeInsets.symmetric(vertical: 3.r),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
                    borderSide: BorderSide(color: Colors.grey, width: 2.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0.r)),
                    borderSide: BorderSide(color: Colors.blue, width: 2.r),
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
                height: 100.h,
                child: FutureBuilder(
                    future: search.isNotEmpty
                        ? getSearchProduct(search)
                        : getSearchProduct(''),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default:
                          return snapshot.data != null
                              ? listItemWidget(itemProduct)
                              : Center(
                                  child: Text('Data tidak ditemukan'),
                                );
                      }
                    }),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget listItemWidget(List<Product> item) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
          width: double.minPositive.w,
          height: 350.h,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: item.length,
            itemBuilder: (BuildContext context, int index) {
              String _key = item[index].proddesc;
              return CheckboxListTile(
                value: item[index].ischecked,
                title: Text(_key),
                onChanged: (bool val) {
                  setState(() {
                    item[index].ischecked = val;
                  });
                },
              );
            },
          ));
    });
  }

  Widget areaFrameContract() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.h,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.r,
            vertical: 8.r,
          ),
          child: Text(
            'Tipe Kontrak : ',
            style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600),
          ),
        ),
        !_isChildContract
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 200.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.r,
                        vertical: 2.r,
                      ),
                      child: Text(
                        'Kontrak Frame (Sesuai SP)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.r,
                      vertical: 2.r,
                    ),
                    child: Checkbox(
                      value: this._isFrameContract,
                      onChanged: (bool value) {
                        setState(() {
                          this._isFrameContract = value;
                          formDisc.clear();
                          formProduct.clear();
                          tmpDiv.clear();
                          tmpProduct.clear();
                        });
                      },
                    ), //C
                  ),
                ],
              )
            : SizedBox(
                height: 5.w,
              ),
        !_isFrameContract
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 200.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.r,
                        vertical: 2.r,
                      ),
                      child: Text(
                        'Kontrak Sebagai Child',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.r,
                      vertical: 2.r,
                    ),
                    child: Checkbox(
                      value: this._isChildContract,
                      onChanged: (bool value) {
                        setState(() {
                          this._isChildContract = value;
                          formDisc.clear();
                          formProduct.clear();
                          tmpDiv.clear();
                          tmpProduct.clear();
                        });
                      },
                    ), //C
                  ),
                ],
              )
            : SizedBox(
                width: 5.w,
              ),
      ],
    );
  }

  Widget areaLensaContract() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.h,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.r,
            vertical: 8.r,
          ),
          child: Text(
            'Kontrak Diskon Reguler : ',
            style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 200.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 2.r,
                ),
                child: Text(
                  'All Lensa Reguler',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 2.r,
              ),
              child: Checkbox(
                value: this._isRegularDisc,
                onChanged: (bool value) {
                  setState(() {
                    this._isRegularDisc = value;
                    formDisc.clear();
                    formProduct.clear();
                    tmpDiv.clear();
                    tmpProduct.clear();
                  });
                },
              ), //C
            ),
          ],
        ),
      ],
    );
  }

  Widget areaMultiFormDiv() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 8.r,
              ),
              child: Text(
                'Kontrak Diskon Divisi : ',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
              ),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.lightBlue,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  constraints: BoxConstraints(
                    maxHeight: 28.r,
                    maxWidth: 28.r,
                  ),
                  icon: const Icon(Icons.add),
                  iconSize: 13.r,
                  color: Colors.white,
                  onPressed: () {
                    itemProdDiv.length < 1
                        ? handleConnection(context)
                        : showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return dialogProddiv(itemProdDiv);
                            });
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 180.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Text(
                  'Produk',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 90.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Text(
                  'Regular',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 80.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Text(
                  'Diskon',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
          height: 150.w,
          child: formDisc.isNotEmpty
              ? ListView.builder(
                  itemCount: formDisc.length,
                  itemBuilder: (_, index) {
                    return formDisc[index];
                  },
                )
              : Center(
                  child: Text('Tambahkan item prod div'),
                ),
        ),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }

  Widget areaMultiFormProduct() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
                vertical: 8.r,
              ),
              child: Text(
                'Kontrak Diskon Khusus : ',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.r,
              ),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.lightBlue,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  constraints: BoxConstraints(
                    maxHeight: 28.r,
                    maxWidth: 28.r,
                  ),
                  icon: const Icon(Icons.add),
                  iconSize: 13.r,
                  color: Colors.white,
                  onPressed: () {
                    _isNetworkConnected
                        ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return customProduct();
                            })
                        : handleConnection(context);
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 180.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Text(
                  'Produk',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 90.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Text(
                  'Regular',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 80.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Text(
                  'Diskon',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
          height: 150.h,
          child: formProduct.isNotEmpty
              ? ListView.builder(
                  itemCount: formProduct.length,
                  itemBuilder: (_, index) {
                    return formProduct[index];
                  },
                )
              : Center(
                  child: Text('Tambahkan item'),
                ),
        ),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }
}
