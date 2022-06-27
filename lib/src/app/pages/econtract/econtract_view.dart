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
import 'package:sample/src/domain/entities/actcontract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:sample/src/domain/entities/product.dart';
import 'package:sample/src/domain/entities/stbcustomer.dart';
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
  List<ActContract> itemActiveContract = List.empty(growable: true);
  List<Product> itemProduct = List.empty(growable: true);
  List<StbCustomer> itemStbCust = List.empty(growable: true);
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
  bool _isContractActive = false;
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
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  getActiveContract(String input) async {
    itemActiveContract.clear();
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/parentCheck?id_customer=$input';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          this._isContractActive = true;
          var rest = data['data'];
          print(rest);
          itemActiveContract = rest
              .map<ActContract>((json) => ActContract.fromJson(json))
              .toList();
          print('List Size : ${itemActiveContract.length}');
        } else {
          this._isContractActive = false;
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      this._isContractActive = false;
    } on SocketException catch (e) {
      print('Socket Error : $e');
      this._isContractActive = false;
    } on Error catch (e) {
      print('General Error : $e');
    }

    print('Is disabled : $_isContractActive');
  }

  void handleContractActive({bool isHorizontal, BuildContext context,}) {
    _isContractActive
        ? Navigator.pop(context)
        : handleStatus(
            context,
            'Optik tidak memiliki kontrak active',
            false,
            isHorizontal: isHorizontal,
          );
  }

  Future<List<StbCustomer>> getSearchParent(String input) async {
    List<StbCustomer> list;
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/customers/oldCustIsActive?bill_name=$input';
    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest
              .map<StbCustomer>((json) => StbCustomer.fromJson(json))
              .toList();
          itemStbCust = rest
              .map<StbCustomer>((json) => StbCustomer.fromJson(json))
              .toList();
          print("List Size: ${list.length}");
          print("Product Size: ${itemStbCust.length}");
        }

        return list;
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
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
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
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

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          ttdPertama = data['data'][0]['ttd'];
          print(ttdPertama);
        }

        getItemProdDiv();
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
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

    try {
      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        list = rest.map<Proddiv>((json) => Proddiv.fromJson(json)).toList();
        print("List Size: ${list.length}");
      }

      return list;
    } on FormatException catch (e) {
      print('Format Error : $e');
    }
  }

  checkInput(Function stop, {bool isHorizontal}) async {
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
            'has_parent': _isContractActive ? '1' : '0',
            'id_contract_parent':
                _isContractActive ? itemActiveContract[0].idContract : '',
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

            _isContractActive
                ? print('Ini child')
                : _isRegularDisc
                    ? simpanDiskon(
                        idCustomer,
                        isHorizontal: isHorizontal,
                      )
                    : multipleInputDiskon(
                        isHorizontal: isHorizontal,
                      );
          }

          if (mounted) {
            handleStatus(
              context,
              capitalize(msg),
              sts,
              isHorizontal: isHorizontal,
            );
          }

          setState(() {});
        } on FormatException catch (e) {
          print('Format Error : $e');
          if (mounted) {
            handleStatus(
              context,
              e.toString(),
              false,
              isHorizontal: isHorizontal,
            );
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
          handleSocket(context);
        }
      } on Error catch (e) {
        print('General Error : $e');
        if (mounted) {
          handleStatus(
            context,
            e.toString(),
            false,
            isHorizontal: isHorizontal,
          );
        }
      }

      stop();
    } else {
      handleStatus(
        context,
        'Harap lengkapi data terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
      );
      stop();
    }
  }

  multipleInputDiskon({bool isHorizontal}) async {
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
          postMultiDiv(
            idCustomer,
            item.proddiv.proddiv,
            item.proddiv.diskon,
            item.proddiv.alias,
            isHorizontal: isHorizontal,
          );
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
            item.product.diskon,
            isHorizontal: isHorizontal,
          );
        }
      }
    } else {
      print("Form is Not Valid");
    }
  }

  postMultiDiv(String idCust, String proddiv, String diskon, String alias,
      {bool isHorizontal}) async {
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
          handleStatus(
            context,
            e.toString(),
            false,
            isHorizontal: isHorizontal,
          );
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
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : $e');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
        );
      }
    }
  }

  postMultiItem(String idCust, String categoryId, String prodDiv,
      String prodCat, String prodDesc, String disc,
      {bool isHorizontal}) async {
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
          handleStatus(
            context,
            e.toString(),
            false,
            isHorizontal: isHorizontal,
          );
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
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : $e');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
        );
      }
    }
  }

  simpanDiskon(String idCust, {bool isHorizontal}) async {
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
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : $e');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childEcontract(isHorizontal: true);
      }

      return childEcontract(isHorizontal: false);
    });
  }

  Widget childEcontract({bool isHorizontal}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Perjanjian Kerjasama Pembelian',
          style: TextStyle(
            color: Colors.black54,
            fontSize: isHorizontal ? 28.sp : 18.sp,
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
            size: isHorizontal ? 28.sp : 18.r,
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
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      // username,
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
                      // capitalize(role),
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
                      namaKedua = widget.customerList[widget.position].nama,
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
                      telpKedua = widget.customerList[widget.position].noTlp,
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
                      faxKedua =
                          widget.customerList[widget.position].fax.isEmpty
                              ? '-'
                              : widget.customerList[widget.position].fax,
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
                      alamatKedua = widget.customerList[widget.position].alamat,
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
                height: isHorizontal ? 35.h : 20.h,
              ),
              Container(
                child: Text(
                  'Target Pembelian yang disepakati / bulan : ',
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
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
                height: isHorizontal ? 35.h : 20.h,
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                          borderRadius: BorderRadius.circular(5.r),
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
                            '-',
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                            '-',
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                            '-',
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                            '-',
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
              areaFrameContract(
                isHorizontal: isHorizontal,
              ),
              _isFrameContract || _isChildContract
                  ? SizedBox(
                      width: 5.w,
                    )
                  : areaLensaContract(
                      isHorizontal: isHorizontal,
                    ),
              _isFrameContract || _isChildContract
                  ? SizedBox(
                      width: 5.w,
                    )
                  : _isRegularDisc
                      ? SizedBox(
                          height: 5.h,
                        )
                      : areaMultiFormDiv(isHorizontal: isHorizontal),
              _isFrameContract || _isChildContract
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
                        _isNetworkConnected
                            ? checkInput(
                                stopLoading,
                                isHorizontal: isHorizontal,
                              )
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

  Widget selectParent({bool isHorizontal}) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: Text('Pilih Optik Parent'),
        content: Container(
          height: MediaQuery.of(context).size.height / 1.5,
          child: Column(
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
                          ? getSearchParent(search)
                          : getSearchParent(''),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            return snapshot.data != null
                                ? listParentWidget(itemStbCust)
                                : Center(
                                    child: Text('Data tidak ditemukan'),
                                  );
                        }
                      }),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red.shade700,
                      ),
                      onPressed: () {
                        this._isChildContract = false;
                        itemStbCust.clear();
                        itemActiveContract.clear();
                        Navigator.pop(context);
                      },
                      child: Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () => handleContractActive(
                        isHorizontal: isHorizontal,
                        context: context,
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                      ),
                      child: Text("Pilih"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget customProduct({bool isHor}) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text('Pilih Item'),
        content: Container(
          width: MediaQuery.of(context).size.width / 1,
          height: MediaQuery.of(context).size.height / 1.5,
          child: Column(
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
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  getSelectedItem();
                  Navigator.pop(context);
                },
                child: Text("Submit"),
              ),
            ],
          ),
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

  Widget listParentWidget(List<StbCustomer> item) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
          width: double.minPositive.w,
          height: 350.h,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: item.length,
            itemBuilder: (BuildContext context, int index) {
              String _key = item[index].customerBillName;
              return CheckboxListTile(
                value: item[index].ischecked,
                title: Text(_key),
                onChanged: (bool val) {
                  setState(() {
                    item[index].ischecked = val;
                    item[index].ischecked
                        ? getActiveContract(item[index].customerBillNumber)
                        : print('Disable');
                    // getActiveContract(item[index].customerBillNumber);
                  });
                },
              );
            },
          ));
    });
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
        !_isChildContract
            ? Row(
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
              )
            : SizedBox(
                height: 5.w,
              ),
        !_isFrameContract
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isHorizontal ? 13.r : 8.r,
                        vertical: isHorizontal ? 5.r : 2.r,
                      ),
                      child: Text(
                        'Kontrak Sebagai Child',
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
                      value: this._isChildContract,
                      onChanged: (bool value) {
                        setState(() {
                          this._isChildContract = value;
                          formDisc.clear();
                          formProduct.clear();
                          tmpDiv.clear();
                          tmpProduct.clear();
                          itemActiveContract.clear();
                          _isChildContract
                              ? showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return selectParent(
                                      isHorizontal: isHorizontal,
                                    );
                                  }).then((_) => setState(() {}))
                              : itemStbCust.clear();
                        });
                      },
                    ), //C
                  ),
                ],
              )
            : SizedBox(
                width: 5.w,
              ),
        itemActiveContract.isNotEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 17.r,
                  vertical: 10.r,
                ),
                child: Card(
                  elevation: 2,
                  child: Container(
                    height: isHorizontal ? 115.h : 65.h,
                    padding: EdgeInsets.symmetric(
                      horizontal: isHorizontal ? 25.r : 15.r,
                      vertical: isHorizontal ? 20.r : 10.r,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                itemActiveContract[0].customerBillName,
                                style: TextStyle(
                                  fontSize: isHorizontal ? 24.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Kontrak tahun ${itemActiveContract[0].startContract.substring(0, 4)}',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 24.sp : 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Segoe ui',
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/images/success.png',
                          width: isHorizontal ? 45.r : 25.r,
                          height: isHorizontal ? 45.r : 25.r,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox(
                width: 5.w,
              ),
        SizedBox(
          height: 10.h,
        ),
      ],
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

  Widget areaMultiFormDiv({bool isHorizontal}) {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      constraints: BoxConstraints(
                        maxHeight: isHorizontal ? 50.r : 30.r,
                        maxWidth: isHorizontal ? 50.r : 30.r,
                      ),
                      icon: const Icon(Icons.add),
                      iconSize: isHorizontal ? 25.r : 15.r,
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
                  ],
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      constraints: BoxConstraints(
                        maxHeight: isHorizontal ? 50.r : 30.r,
                        maxWidth: isHorizontal ? 50.r : 30.r,
                      ),
                      icon: const Icon(Icons.add),
                      iconSize: isHorizontal ? 25.r : 15.r,
                      color: Colors.white,
                      onPressed: () {
                        _isNetworkConnected
                            ? showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return customProduct(isHor: isHorizontal);
                                })
                            : handleConnection(context);
                      },
                    ),
                  ],
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
