import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/econtract/form_disc.dart';
import 'package:sample/src/app/pages/econtract/form_product.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/discount.dart';
import 'package:sample/src/domain/entities/oldcustomer.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:sample/src/domain/entities/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ChangeContract extends StatefulWidget {
  final OldCustomer oldCustomer;
  final List<Contract> actContract;
  dynamic keyword;
  ChangeContract(this.oldCustomer, this.actContract, {this.keyword});

  @override
  State<ChangeContract> createState() => _ChangeContractState();
}

class _ChangeContractState extends State<ChangeContract> {
  final globalKey = GlobalKey();
  List<FormItemDisc> formDisc = List.empty(growable: true);
  List<FormItemProduct> formProduct = List.empty(growable: true);
  List<String> tmpDiv = List.empty(growable: true);
  List<String> tmpProduct = List.empty(growable: true);
  List<Proddiv> itemProdDiv;
  List<Product> itemProduct;
  Map<String, String> selectMapProddiv = {"": ""};
  Map<String, String> selectMapProduct = {"": ""};
  String search = '';
  String id = '';
  String role = '';
  String username = '';
  String name = '';
  String ttdKedua = '';
  String idCustomer, jabatanKedua, ttdPertama;
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
  bool _isConnected = false;
  bool _isFrameContract = false;
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
      idCustomer = widget.oldCustomer.customerShipNumber;
    });
  }

  getTtdSales(int input) async {
    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';

    if (_isConnected) {
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          ttdPertama = data['data'][0]['ttd'];
          print(ttdPertama);
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(context, e.toString(), false);
      }
    }
  }

  Future<List<Discount>> getDiscountData(dynamic idCust) async {
    List<Discount> list;
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/discount/getByIdCustomer?id_customer=$idCust';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest.map<Discount>((json) => Discount.fromJson(json)).toList();
          print("List Size: ${list.length}");
        }

        return list;
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(context, e.toString(), false);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getRole();
    getItemProdDiv();
  }

  getItemProdDiv() async {
    const timeout = 15;
    var url = 'http://timurrayalab.com/salesforce/server/api/product/getProDiv';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          itemProdDiv =
              rest.map<Proddiv>((json) => Proddiv.fromJson(json)).toList();
          print("List Size: ${itemProdDiv.length}");
        }

        _isConnected = true;
        getSearchProduct('');
        getTtdSales(int.parse(id));
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(context, e.toString(), false);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
      _isConnected = false;
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleConnection(context);
      _isConnected = false;
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
      _isConnected = false;
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

      try {
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
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(context, e.toString(), false);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
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
    var url =
        'http://timurrayalab.com/salesforce/server/api/discount/divCustomDiscount';
    var response = await http.post(
      url,
      body: {
        'id_customer': idCust,
        'prod_div[]': proddiv,
        'discount[]': diskon,
        'prodcat_description[]': alias,
      },
    );

    try {
      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'];

      if (sts) {
        print(msg);
      }
    } on FormatException catch (e) {
      print('Format Error : $e');
      if (mounted) {
        handleStatus(context, e.toString(), false);
      }
    }
  }

  postMultiItem(String idCust, String categoryId, String prodDiv,
      String prodCat, String prodDesc, String disc) async {
    var url =
        'http://timurrayalab.com/salesforce/server/api/discount/customDiscount';
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
    );

    try {
      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'];

      if (sts) {
        print(msg);
      }
    } on FormatException catch (e) {
      print('Format Error : $e');
      if (mounted) {
        handleStatus(context, e.toString(), false);
      }
    }
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

    if (!_isTanggalSt && !_isTanggalEd) {
      const timeout = 15;
      var url = 'http://timurrayalab.com/salesforce/server/api/contract/upload';

      try {
        var response = await http.post(
          url,
          body: {
            'id_customer': idCustomer,
            'nama_pertama': name,
            'jabatan_pertama': role,
            'nama_kedua': widget.oldCustomer.contactPerson,
            'jabatan_kedua': jabatanKedua,
            'alamat_kedua': widget.oldCustomer.address2,
            'telp_kedua': widget.oldCustomer.phone,
            'fax_kedua': '-',
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
            'no_account': idCustomer,
            'ttd_pertama': ttdPertama,
            'ttd_kedua': ttdKedua,
            'created_by': id,
            'has_parent': '0',
          },
        ).timeout(Duration(seconds: timeout));

        print('ttd 1 : $ttdPertama');
        print('ttd 2 : $ttdKedua');
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        try {
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

          handleStatusChangeContract(
            widget.oldCustomer,
            context,
            capitalize(msg),
            sts,
            keyword: widget.keyword,
          );
          stop();
          setState(() {});
        } on FormatException catch (e) {
          print('Format Error : $e');
          if (mounted) {
            handleStatus(context, e.toString(), false);
          }
        }
      } on TimeoutException catch (e) {
        print('Timeout Error : $e');
        if (mounted) {
          handleTimeout(context);
        }
      } on SocketException catch (e) {
        print('Socket Error : $e');
        if (mounted) {
          handleConnection(context);
        }
      } on Error catch (e) {
        print('General Error : $e');
        if (mounted) {
          handleStatus(context, e.toString(), false);
        }
      }
    } else {
      stop();
    }
  }

  simpanDiskon(String idCust) async {
    var url =
        'http://timurrayalab.com/salesforce/server/api/discount/defaultDiscount';
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
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childChangeContract(isHorizontal: true);
      }

      return childChangeContract(isHorizontal: false);
    });
  }

  Widget childChangeContract({bool isHorizontal}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Perubahan Kontrak',
          style: TextStyle(
            fontSize: isHorizontal ? 28.sp : 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: isHorizontal ? 28.sp : 18.r,
            color: Colors.black54,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 40.r : 25.r,
            vertical: isHorizontal ? 15.r : 5.r,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Text(
                  'Pihak Pertama',
                  style: TextStyle(
                    fontSize: isHorizontal ? 26.sp : 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 10.r : 5.r,
                    ),
                    width: isHorizontal
                        ? MediaQuery.of(context).size.width / 8.2
                        : MediaQuery.of(context).size.width / 5.2,
                    child: Text(
                      'Nama : ',
                      style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 10.r : 5.r,
                    ),
                    width: isHorizontal
                        ? MediaQuery.of(context).size.width / 8.2
                        : MediaQuery.of(context).size.width / 5.2,
                    child: Text(
                      'Jabatan : ',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      role,
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 10.r : 5.r,
                    ),
                    width: isHorizontal
                        ? MediaQuery.of(context).size.width / 8.2
                        : MediaQuery.of(context).size.width / 5.2,
                    child: Text(
                      'Telp : ',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '021-4610154',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 10.r : 5.r,
                    ),
                    width: isHorizontal
                        ? MediaQuery.of(context).size.width / 8.2
                        : MediaQuery.of(context).size.width / 5.2,
                    child: Text(
                      'Fax : ',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '021-4610151-52',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 10.r : 5.r,
                    ),
                    width: isHorizontal
                        ? MediaQuery.of(context).size.width / 8.2
                        : MediaQuery.of(context).size.width / 5.2,
                    child: Text(
                      'Alamat : ',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Jl. Rawa Kepiting No. 4 Kawasan Industri Pulogadung, Jakarta Timur',
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 20.h : 10.h,
              ),
              Container(
                child: Text(
                  'Pihak Kedua',
                  style: TextStyle(
                    fontSize: isHorizontal ? 26.sp : 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 10.r : 5.r,
                    ),
                    width: isHorizontal
                        ? MediaQuery.of(context).size.width / 8.2
                        : MediaQuery.of(context).size.width / 5.2,
                    child: Text(
                      'Nama : ',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.oldCustomer.contactPerson.trim(),
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 10.r : 5.r,
                    ),
                    width: isHorizontal
                        ? MediaQuery.of(context).size.width / 8.2
                        : MediaQuery.of(context).size.width / 5.2,
                    child: Text(
                      'Jabatan : ',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      jabatanKedua = 'Owner',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 10.r : 5.r,
                    ),
                    width: isHorizontal
                        ? MediaQuery.of(context).size.width / 8.2
                        : MediaQuery.of(context).size.width / 5.2,
                    child: Text(
                      'Telp : ',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.oldCustomer.phone,
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 10.r : 5.r,
                    ),
                    width: isHorizontal
                        ? MediaQuery.of(context).size.width / 8.2
                        : MediaQuery.of(context).size.width / 5.2,
                    child: Text(
                      'Fax : ',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '-',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: isHorizontal ? 10.r : 5.r,
                    ),
                    width: isHorizontal
                        ? MediaQuery.of(context).size.width / 8.2
                        : MediaQuery.of(context).size.width / 5.2,
                    child: Text(
                      'Alamat : ',
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.oldCustomer.address2,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 25.h : 10.h,
              ),
              widget.actContract.isNotEmpty
                  ? areaTarget(
                      isHorizontal: isHorizontal,
                    )
                  : SizedBox(
                      width: 0.w,
                    ),
              Container(
                child: Text(
                  'Target Pembelian yang disepakati / bulan : ',
                  style: TextStyle(
                      fontSize: isHorizontal ? 26.sp : 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
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
                    errorText: _isValNikon ? 'Data wajib diisi' : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  controller: textValNikon,
                  maxLength: 15,
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Segoe Ui',
                  ),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
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
                    errorText: _isValLeinz ? 'Data wajib diisi' : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  controller: textValLeinz,
                  maxLength: 15,
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Segoe Ui',
                  ),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
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
                    errorText: _isValOriental ? 'Data wajib diisi' : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  controller: textValOriental,
                  maxLength: 15,
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Segoe Ui',
                  ),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
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
                    errorText: _isValMoe ? 'Data wajib diisi' : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  controller: textValMoe,
                  maxLength: 15,
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Segoe Ui',
                  ),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 30.h : 15.h,
              ),
              widget.actContract.isNotEmpty
                  ? areaJangkaWaktu(
                      isHorizontal: isHorizontal,
                    )
                  : SizedBox(
                      width: 0.w,
                    ),
              SizedBox(
                height: 15.h,
              ),
              Container(
                child: Text(
                  'Jangka waktu pembayaran / bulan : ',
                  style: TextStyle(
                    fontSize: isHorizontal ? 26.sp : 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: isHorizontal
                          ? MediaQuery.of(context).size.width / 5.5
                          : MediaQuery.of(context).size.width / 3.2,
                      child: Text(
                        'Lensa Nikon : ',
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.h : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(5.r)),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: isHorizontal ? 20.r : 10.r,
                          ),
                          child: DropdownButton(
                            underline: SizedBox(),
                            isExpanded: true,
                            value: _chosenNikon,
                            style: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Segoe Ui',
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                            items: [
                              'Cash & Carry',
                              'Transfer',
                              'Deposit',
                              'Bulanan',
                            ].map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: TextStyle(color: Colors.black54)),
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
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: isHorizontal
                          ? MediaQuery.of(context).size.width / 5.5
                          : MediaQuery.of(context).size.width / 3.2,
                      child: Text(
                        'Lensa Leinz : ',
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.h : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(5.r)),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: isHorizontal ? 20.r : 10.r,
                          ),
                          child: DropdownButton(
                            underline: SizedBox(),
                            isExpanded: true,
                            value: _chosenLeinz,
                            style: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Segoe Ui',
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                            items: [
                              'Cash & Carry',
                              'Transfer',
                              'Deposit',
                              'Bulanan',
                            ].map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: TextStyle(color: Colors.black54)),
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
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: isHorizontal
                          ? MediaQuery.of(context).size.width / 5.5
                          : MediaQuery.of(context).size.width / 3.2,
                      child: Text(
                        'Lensa Oriental : ',
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.h : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(5.r)),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: isHorizontal ? 20.r : 10.r,
                          ),
                          child: DropdownButton(
                            underline: SizedBox(),
                            isExpanded: true,
                            value: _chosenOriental,
                            style: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Segoe Ui',
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                            items: [
                              'Cash & Carry',
                              'Transfer',
                              'Deposit',
                              'Bulanan',
                            ].map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: TextStyle(color: Colors.black54)),
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
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: isHorizontal
                          ? MediaQuery.of(context).size.width / 5.5
                          : MediaQuery.of(context).size.width / 3.2,
                      child: Text(
                        'Lensa Moe : ',
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.h : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(5.r)),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: isHorizontal ? 20.r : 10.r,
                          ),
                          child: DropdownButton(
                            underline: SizedBox(),
                            isExpanded: true,
                            value: _chosenMoe,
                            style: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Segoe Ui',
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                            items: [
                              'Cash & Carry',
                              'Transfer',
                              'Deposit',
                              'Bulanan',
                            ].map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: TextStyle(color: Colors.black54)),
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
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: isHorizontal ? 35.h : 20.h,
              ),
              Container(
                child: Text(
                  'Terhitung sejak tanggal : ',
                  style: TextStyle(
                      fontSize: isHorizontal ? 26.sp : 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
                  vertical: isHorizontal ? 18.r : 8.r,
                ),
                child: DateTimeField(
                  decoration: InputDecoration(
                    hintText: 'Tanggal Mulai',
                    labelText: 'Tanggal Mulai',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    errorText: _isTanggalSt ? 'Data wajib diisi' : null,
                    hintStyle: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe Ui',
                    ),
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
                  horizontal: isHorizontal ? 10.r : 5.r,
                  vertical: isHorizontal ? 18.r : 8.r,
                ),
                child: DateTimeField(
                  decoration: InputDecoration(
                    hintText: 'Tanggal Berakhir',
                    labelText: 'Tanggal Berakhir',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    errorText: _isTanggalEd ? 'Data wajib diisi' : null,
                    hintStyle: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe Ui',
                    ),
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
              SizedBox(
                height: 20.h,
              ),
              widget.actContract.isNotEmpty
                  ? areaDiskon(
                      widget.actContract[0],
                      isHorizontal: isHorizontal,
                    )
                  : SizedBox(
                      width: 0.w,
                    ),
              areaFrameContract(
                isHorizontal: isHorizontal,
              ),
              _isFrameContract
                  ? SizedBox(
                      width: 5.w,
                    )
                  : areaLensaContract(
                      isHorizontal: isHorizontal,
                    ),
              _isFrameContract
                  ? SizedBox(
                      width: 5.w,
                    )
                  : _isRegularDisc
                      ? SizedBox(
                          height: 5.h,
                        )
                      : areaMultiFormDiv(
                          isHorizontal: isHorizontal,
                        ),
              _isFrameContract
                  ? SizedBox(
                      width: 5.w,
                    )
                  : _isRegularDisc
                      ? SizedBox(
                          height: 5.h,
                        )
                      : areaMultiFormProduct(
                          isHorizontal: isHorizontal,
                        ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
                  vertical: isHorizontal ? 10.r : 5.r,
                ),
                alignment: Alignment.centerRight,
                child: ArgonButton(
                  height: isHorizontal ? 60.h : 40.h,
                  width: isHorizontal ? 80.w : 100.w,
                  borderRadius: isHorizontal ? 60.r : 30.r,
                  color: Colors.blue[700],
                  child: Text(
                    "Simpan",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: isHorizontal ? 24.sp : 14.sp,
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
                        checkInput(stopLoading);
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
      ),
    );
  }

  Widget areaLensaContract({bool isHorizontal}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.h,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 10.r : 5.r,
            vertical: isHorizontal ? 18.r : 8.r,
          ),
          child: Text(
            'Kontrak Diskon Reguler : ',
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: isHorizontal ? 26.sp : 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 13.r : 8.r,
                  vertical: isHorizontal ? 5.r : 2.r,
                ),
                child: Text(
                  'All Lensa Reguler',
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 13.r : 8.r,
                vertical: isHorizontal ? 5.r : 2.r,
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

  Widget areaFrameContract({bool isHorizontal}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.h,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 10.r : 5.r,
            vertical: isHorizontal ? 18.r : 8.r,
          ),
          child: Text(
            'Tipe Kontrak : ',
            style: TextStyle(
                fontSize: isHorizontal ? 26.sp : 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 13.r : 8.r,
                  vertical: isHorizontal ? 5.r : 2.r,
                ),
                child: Text(
                  'Kontrak Frame (Sesuai SP)',
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 13.r : 8.r,
                vertical: isHorizontal ? 5.r : 2.r,
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
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.h,
        ),
      ],
    );
  }

  Widget areaTarget({bool isHorizontal}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 5.r : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Pembelian sebelumnya :',
            style: TextStyle(
              fontSize: isHorizontal ? 26.sp : 16.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 18.h : 8.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 10.r : 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Lensa Nikon',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lensa Leinz',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: isHorizontal ? 10.h : 5.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 10.r : 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.actContract.isNotEmpty
                        ? convertToIdr(
                            int.parse(widget.actContract[0].tpNikon), 0)
                        : 'Rp 0',
                    style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.actContract.isNotEmpty
                        ? convertToIdr(
                            int.parse(widget.actContract[0].tpLeinz), 0)
                        : 'Rp 0',
                    style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 10.r : 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Lensa Oriental',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lensa Moe',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: isHorizontal ? 10.h : 5.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 10.r : 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.actContract.isNotEmpty
                        ? convertToIdr(
                            int.parse(widget.actContract[0].tpOriental), 0)
                        : 'Rp 0',
                    style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.actContract.isNotEmpty
                        ? convertToIdr(
                            int.parse(widget.actContract[0].tpMoe), 0)
                        : 'Rp 0',
                    style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: isHorizontal ? 30.h : 15.h,
          ),
        ],
      ),
    );
  }

  Widget areaJangkaWaktu({bool isHorizontal}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 5.r : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jangka waktu pembayaran sebelumnya :',
            style: TextStyle(
              fontSize: isHorizontal ? 26.sp : 16.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 10.r : 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Lensa Nikon',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lensa Leinz',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: isHorizontal ? 10.h : 5.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 10.r : 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.actContract[0].pembNikon,
                    style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.actContract[0].pembLeinz,
                    style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 10.r : 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Lensa Oriental',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lensa Moe',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 10.r : 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.actContract[0].pembOriental,
                    style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.actContract[0].pembMoe,
                    style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
        ],
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
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  getSelectedItem();
                  Navigator.pop(context);
                },
                child: Text("Submit")),
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

  Widget areaDiskon(Contract item, {bool isHorizontal}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 5.r : 0.r,
            vertical: isHorizontal ? 10.r : 5.r,
          ),
          child: Text(
            'Kontrak Diskon Sebelumnya : ',
            style: TextStyle(
                fontSize: isHorizontal ? 26.sp : 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: isHorizontal ? 10.h : 5.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 10.r : 5.r,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Deskripsi produk',
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Diskon',
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.maxFinite.w,
          height: isHorizontal ? 300.h : 150.h,
          child: FutureBuilder(
              future: getDiscountData(item.idCustomer),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return snapshot.data != null
                        ? listDiscWidget(
                            snapshot.data,
                            snapshot.data.length,
                            isHorizontal: isHorizontal,
                          )
                        : Column(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/not_found.png',
                                  width: isHorizontal ? 135.w : 120.w,
                                  height: isHorizontal ? 135.h : 120.h,
                                ),
                              ),
                              Text(
                                'Item Discount tidak ditemukan',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 28.sp : 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          );
                }
              }),
        ),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }

  Widget listDiscWidget(List<Discount> item, int len, {bool isHorizontal}) {
    return ListView.builder(
        itemCount: len,
        padding: EdgeInsets.symmetric(
          horizontal: isHorizontal ? 10.r : 5.r,
          vertical: isHorizontal ? 18.r : 8.r,
        ),
        itemBuilder: (context, position) {
          return SizedBox(
            height: isHorizontal ? 50.h : 30.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item[position].prodDesc != null
                        ? item[position].prodDesc
                        : '-',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item[position].discount != null
                        ? '${item[position].discount} %'
                        : '-',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget areaMultiFormDiv({bool isHorizontal}) {
    return Column(
      children: [
        SizedBox(
          height: 20.r,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 10.r : 5.r,
                vertical: isHorizontal ? 18.r : 8.r,
              ),
              child: Text(
                'Kontrak Diskon Divisi : ',
                style: TextStyle(
                    fontSize: isHorizontal ? 26.sp : 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 35.r : 20.r,
              ),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.lightBlue,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  constraints: BoxConstraints(
                    maxHeight: isHorizontal ? 50.r : 30.r,
                    maxWidth: isHorizontal ? 50.r : 30.r,
                  ),
                  icon: const Icon(Icons.add),
                  iconSize: isHorizontal ? 25.r : 15.r,
                  color: Colors.white,
                  onPressed: () {
                    showDialog(
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
            Expanded(
              flex: isHorizontal ? 4 : 3,
              child: Padding(
                padding: EdgeInsets.only(
                  left: isHorizontal ? 10.r : 5.r,
                  top: 2.r,
                  bottom: 2.r,
                ),
                child: Text(
                  'Produk',
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                  child: Text(
                'Regular',
                style: TextStyle(
                  fontSize: isHorizontal ? 24.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              )),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Diskon',
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
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
          height: isHorizontal ? 300.h : 150.h,
          child: formDisc.isNotEmpty
              ? ListView.builder(
                  itemCount: formDisc.length,
                  itemBuilder: (_, index) {
                    return formDisc[index];
                  },
                )
              : Center(
                  child: Text(
                    'Tambahkan item prod div',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }

  Widget areaMultiFormProduct({bool isHorizontal}) {
    return Column(
      children: [
        SizedBox(
          height: 20.r,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 10.r : 5.r,
                vertical: isHorizontal ? 18.r : 8.r,
              ),
              child: Text(
                'Kontrak Diskon Khusus : ',
                style: TextStyle(
                    fontSize: isHorizontal ? 26.sp : 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 35.r : 20.r,
              ),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.lightBlue,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  constraints: BoxConstraints(
                    maxHeight: isHorizontal ? 50.r : 30.r,
                    maxWidth: isHorizontal ? 50.r : 30.r,
                  ),
                  icon: const Icon(Icons.add),
                  iconSize: isHorizontal ? 25.r : 15.r,
                  color: Colors.white,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return customProduct();
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
            Expanded(
              flex: isHorizontal ? 4 : 3,
              child: Padding(
                padding: EdgeInsets.only(
                  left: isHorizontal ? 10.r : 5.r,
                  top: 2.r,
                  bottom: 2.r,
                ),
                child: Text(
                  'Produk',
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                  child: Text(
                'Regular',
                style: TextStyle(
                  fontSize: isHorizontal ? 24.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              )),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Diskon',
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
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
          height: isHorizontal ? 300.h : 150.h,
          child: formProduct.isNotEmpty
              ? ListView.builder(
                  itemCount: formProduct.length,
                  itemBuilder: (_, index) {
                    return formProduct[index];
                  },
                )
              : Center(
                  child: Text(
                    'Tambahkan item',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }
}
