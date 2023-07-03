import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/econtract/form_disc.dart';
import 'package:sample/src/app/pages/econtract/form_product.dart';
import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/actcontract.dart';
import 'package:sample/src/domain/entities/contract.dart';
// import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/customer_noimage.dart';
import 'package:sample/src/domain/entities/discount.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:sample/src/domain/entities/product.dart';
import 'package:sample/src/domain/entities/stbcustomer.dart';
import 'package:sample/src/domain/entities/tipe_kontrak.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class EcontractScreen extends StatefulWidget {
  final List<CustomerNoImage> customerList;
  final int position;
  bool? isRevisi = false;
  bool? isAdmin = false;

  @override
  _EcontractScreenState createState() => _EcontractScreenState();

  EcontractScreen(this.customerList, this.position,
      {this.isRevisi, this.isAdmin});
}

class _EcontractScreenState extends State<EcontractScreen> {
  final globalKey = GlobalKey();
  List<FormItemDisc> formDisc = List.empty(growable: true);
  List<FormItemDisc> defaultDisc = List.empty(growable: true);
  List<FormItemDisc> fixedDisc = List.empty(growable: true);
  List<FormItemProduct> formProduct = List.empty(growable: true);
  List<FormItemProduct> fixedProduct = List.empty(growable: true);
  List<String> tmpDiv = List.empty(growable: true);
  List<String> tmpDivInput = List.empty(growable: true);
  List<String> tmpProduct = List.empty(growable: true);
  List<Proddiv> itemProdDiv = List.empty(growable: true);
  List<TipeKontrak> itemTipeKontrak = List.empty(growable: true);
  List<ActContract> itemActiveContract = List.empty(growable: true);
  List<Product> itemProduct = List.empty(growable: true);
  List<StbCustomer> itemStbCust = List.empty(growable: true);
  List<Contract> dtContract = List.empty(growable: true);
  List<Discount> dtDisc = List.empty(growable: true);
  List<Discount> dtCustomDisc = List.empty(growable: true);
  List<TipeKontrak> _listFuture = List.empty(growable: true);
  List<TipeKontrak> _listFutureTmp = List.empty(growable: true);
  var _now = new DateTime.now();
  var _formatter = new DateFormat('yyyy-MM-dd');
  bool _isLoading = true;
  String search = '';
  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';
  String tokenSm = '';
  String idSm = '';
  String mytoken = '';
  String idCustomer = '';
  String namaKedua = '';
  String jabatanKedua = '';
  String alamatKedua = '';
  String telpKedua = '';
  String faxKedua = '';
  String ttdPertama = '';
  String ttdKedua = '';
  // String _chosenNikon = '-';
  // String _durasiNikon = '7 HARI';
  // String _chosenNikonSt = '-';
  // String _durasiNikonSt = '7 HARI';
  String _chosenLeinz = '-';
  String _durasiLeinz = '7 HARI';
  String _chosenLeinzSt = '-';
  String _durasiLeinzSt = '7 HARI';
  String _chosenOriental = '-';
  String _durasiOriental = '7 HARI';
  String _chosenOrientalSt = '-';
  String _durasiOrientalSt = '7 HARI';
  String _chosenMoe = '-';
  String _durasiMoe = '';
  bool _isEmpty = false;
  final format = DateFormat("dd MMM yyyy");
  // TextEditingController textValNikon = new TextEditingController();
  TextEditingController textValLeinz = new TextEditingController();
  TextEditingController textValOriental = new TextEditingController();
  TextEditingController textValMoe = new TextEditingController();
  TextEditingController textCatatan = new TextEditingController();
  bool _isFrameContract = false;
  bool _isPartaiContract = false;
  bool _isPrestigeContract = false;
  bool _isCashbackWithDiscContract = false;
  bool _isChildContract = false;
  bool _isCashbackContrack = false;
  bool _isContractActive = false;
  var thisYear, nextYear;
  int formLen = 0;

  callback(newVal) {
    setState(() {
      formLen = newVal;
    });
  }

  setRegularDisc() {
    List<Proddiv> regProddiv = [
      Proddiv("ALL LEINZ RX", "TRLX", "10"),
      // Proddiv("ALL NIKON RX", "TRNX", "10"),
      Proddiv("ALL ORIENTAL RX", "TRTX", "10"),
      Proddiv("ALL MOE STOCK", "TRML", "15"),
      // Proddiv("ALL NIKON STOCK", "TRNL", "15"),
      Proddiv("ALL LEINZ STOCK", "TROL", "15"),
      Proddiv("ALL ORIENTAL STOCK", "TRTL", "15"),
    ];

    regProddiv.forEach((element) {
      defaultDisc.add(FormItemDisc(
        proddiv: element,
      ));
    });
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _listFuture = await getTipeKontrak();
    _listFutureTmp = await getTipeKontrak();

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
      getTtdSales(int.parse(id!));
      getItemProdDiv();

      setRegularDisc();

      ttdKedua = widget.customerList[widget.position].ttdCustomer;
      idCustomer = widget.customerList[widget.position].id;

      print("Ttd Kedua : $ttdKedua");

      if (!widget.isRevisi!) {
        var strsplit;
        bool isKredit = false;
        String tmpJenis = widget.customerList[widget.position].sistemPembayaran;

        if (tmpJenis.contains("-")) {
          strsplit = tmpJenis.split("-");
          isKredit = true;
        }

        // _chosenNikon = isKredit ? strsplit[0] : tmpJenis;
        // _durasiNikon = isKredit ? strsplit[1] : '7 HARI';
        // _chosenNikonSt = isKredit ? strsplit[0] : tmpJenis;
        // _durasiNikonSt = isKredit ? strsplit[1] : '7 HARI';
        _chosenLeinz = isKredit ? strsplit[0] : tmpJenis;
        _durasiLeinz = isKredit ? strsplit[1] : '7 HARI';
        _chosenLeinzSt = isKredit ? strsplit[0] : tmpJenis;
        _durasiLeinzSt = isKredit ? strsplit[1] : '7 HARI';
        _chosenOriental = isKredit ? strsplit[0] : tmpJenis;
        _durasiOriental = isKredit ? strsplit[1] : '7 HARI';
        _chosenOrientalSt = isKredit ? strsplit[0] : tmpJenis;
        _durasiOrientalSt = isKredit ? strsplit[1] : '7 HARI';
        _chosenMoe = isKredit ? strsplit[0] : tmpJenis;
        _durasiMoe = isKredit ? strsplit[1] : '7 HARI';
      }
    });
  }

  getDataContract(var idUser) async {
    _isLoading = true;
    const timeout = 15;
    var url = '$API_URL/contract?id_customer=$idUser';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          dtContract =
              rest.map<Contract>((json) => Contract.fromJson(json)).toList();
          print("List Size: ${dtContract.length}");

          var catat = dtContract[0].catatan;
          textCatatan.text = catat.replaceAll("KONTRAK KHUSUS LEINZ PRESTIGE (JAPAN) - BELI 3 GRATIS 1", "");

          handleTargetEdit(dtContract);
          handleJangkaWaktuEdit(dtContract);
          handleTipeKontrakEdit(dtContract);
          handleDivDiscEdit(dtContract[0].idCustomer);
          getActiveContract(dtContract[0].idParent);
        }

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
          });
        });
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

  handleTargetEdit(List<Contract> _contract) {
    NumberFormat myFormat = NumberFormat.decimalPattern('id');
    dynamic leinzVal = getSatuan(_contract[0].tpLeinz);
    // dynamic nikonVal = getSatuan(_contract[0].tpNikon);
    dynamic moeVal = getSatuan(_contract[0].tpMoe);
    dynamic orientalVal = getSatuan(_contract[0].tpOriental);

    print('Target Leinz Revisi : $leinzVal');
    textValLeinz.text = myFormat.format(leinzVal);
    // textValNikon.text = myFormat.format(nikonVal);
    textValMoe.text = myFormat.format(moeVal);
    textValOriental.text = myFormat.format(orientalVal);
  }

  dynamic getSatuan(String input) {
    if (input != '') {
      int a = int.parse(input);
      return (a / 1000000);
    } else {
      return 0;
    }
  }

  bool handleIsKreditEdit(String input) {
    if (input != '') {
      if (input.contains("-")) {
        return true;
      }
    }
    return false;
  }

  String handleChosenEdit(String input, bool isKredit) {
    return isKredit ? input.split("-")[0] : input;
  }

  String handleDurasiEdit(String input, bool isKredit) {
    return isKredit ? input.split("-")[1] : '7 HARI';
  }

  handleJangkaWaktuEdit(List<Contract> _contract) {
    // bool isKreditNikon = handleIsKreditEdit(_contract[0].pembNikon);
    // bool isKreditNikonSt = handleIsKreditEdit(_contract[0].pembNikonSt);
    bool isKreditLeinz = handleIsKreditEdit(_contract[0].pembLeinz);
    bool isKreditLeinzSt = handleIsKreditEdit(_contract[0].pembLeinzSt);
    bool isKreditOriental = handleIsKreditEdit(_contract[0].pembOriental);
    bool isKreditOrientalSt = handleIsKreditEdit(_contract[0].pembOrientalSt);
    bool isKreditMoe = handleIsKreditEdit(_contract[0].pembMoe);

    // _chosenNikon = handleChosenEdit(_contract[0].pembNikon, isKreditNikon);
    // _durasiNikon = handleDurasiEdit(_contract[0].pembNikon, isKreditNikon);
    // _chosenNikonSt =
    //     handleChosenEdit(_contract[0].pembNikonSt, isKreditNikonSt);
    // _durasiNikonSt =
    //     handleDurasiEdit(_contract[0].pembNikonSt, isKreditNikonSt);
    _chosenLeinz = handleChosenEdit(_contract[0].pembLeinz, isKreditLeinz);
    _durasiLeinz = handleDurasiEdit(_contract[0].pembLeinz, isKreditLeinz);
    _chosenLeinzSt =
        handleChosenEdit(_contract[0].pembLeinzSt, isKreditLeinzSt);
    _durasiLeinzSt =
        handleDurasiEdit(_contract[0].pembLeinzSt, isKreditLeinzSt);
    _chosenOriental =
        handleChosenEdit(_contract[0].pembOriental, isKreditOriental);
    _durasiOriental =
        handleDurasiEdit(_contract[0].pembOriental, isKreditOriental);
    _chosenOrientalSt =
        handleChosenEdit(_contract[0].pembOrientalSt, isKreditOrientalSt);
    _durasiOrientalSt =
        handleDurasiEdit(_contract[0].pembOrientalSt, isKreditOrientalSt);
    _chosenMoe = handleChosenEdit(_contract[0].pembMoe, isKreditMoe);
    _durasiMoe = handleDurasiEdit(_contract[0].pembMoe, isKreditMoe);
  }

  handleTipeKontrakEdit(List<Contract> _contract) {
    _contract[0].isFrame == "1"
        ? _isFrameContract = true
        : _isFrameContract = false;
    _contract[0].typeContract == "CASHBACK"
        ? _isCashbackContrack = true
        : _isCashbackContrack = false;
    _contract[0].typeContract == "CASHBACK DENGAN DISKON"
        ? _isCashbackWithDiscContract = true
        : _isCashbackWithDiscContract = false;
    _contract[0].catatan.contains("KONTRAK KHUSUS LEINZ PRESTIGE (JAPAN) - BELI 3 GRATIS 1")
        ? _isPrestigeContract = true
        : _isPrestigeContract = false;
    _contract[0].isPartai == "1"
        ? _isPartaiContract = true
        : _isPartaiContract = false;
    _contract[0].hasParent == '1'
        ? _isChildContract = true
        : _isChildContract = false;
  }

  handleDivDiscEdit(String idUser) async {
    const timeout = 15;
    var url = '$API_URL/discount/getByIdCustomer?id_customer=$idUser';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          dtCustomDisc =
              rest.map<Discount>((json) => Discount.fromJson(json)).toList();
          print("List Size: ${dtCustomDisc.length}");

          setState(() {
            //handle ceklist divisi
            for (int j = 0; j < itemProdDiv.length; j++) {
              print('Proddiv : ${itemProdDiv[j].alias}');
              for (int i = 0; i < dtCustomDisc.length; i++) {
                if (itemProdDiv[j].alias == dtCustomDisc[i].prodDesc) {
                  setState(() {
                    itemProdDiv[j].ischecked = true;
                  });
                }
              }
            }

            for (int i = 0; i < dtCustomDisc.length; i++) {
              if (dtCustomDisc[i].categoryId.isEmpty &&
                  dtCustomDisc[i].prodCat.isEmpty) {
                setState(() {
                  formDisc.add(FormItemDisc(
                    index: dtCustomDisc[i].idDiscount,
                    proddiv: Proddiv(
                      dtCustomDisc[i].prodDesc,
                      dtCustomDisc[i].prodDiv,
                      dtCustomDisc[i].discount,
                    ),
                  ));

                  tmpDiv.add(dtCustomDisc[i].prodDesc);
                });
              }

              if (dtCustomDisc[i].categoryId.isNotEmpty &&
                  dtCustomDisc[i].prodCat.isNotEmpty) {
                setState(() {
                  formProduct.add(FormItemProduct(
                    index: dtCustomDisc[i].idDiscount,
                    product: Product(
                      dtCustomDisc[i].categoryId,
                      dtCustomDisc[i].prodDiv,
                      dtCustomDisc[i].prodCat,
                      dtCustomDisc[i].prodDesc,
                      dtCustomDisc[i].discount,
                      dtCustomDisc[i].status,
                    ),
                    itemLength: 2,
                  ));

                  tmpProduct.add(dtCustomDisc[i].prodDesc);
                });
              }
            }
          });
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

  getItemProdDiv() async {
    const timeout = 15;
    var url = '$API_URL/product/getProDiv';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
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

  Future<List<TipeKontrak>> getTipeKontrak() async {
    const timeout = 15;
    List<TipeKontrak> list = List.empty(growable: true);
    var url = '$API_URL/contract/tipe_kontrak';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print("Tipe kontrak : $rest");
          list = rest
              .map<TipeKontrak>((json) => TipeKontrak.fromJson(json))
              .toList();
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

    return list;
  }

  getActiveContract(String input) async {
    itemActiveContract.clear();
    const timeout = 15;
    var url = '$API_URL/contract/parentCheck?id_customer=$input';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
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

  void handleContractActive({
    bool isHorizontal = false,
    BuildContext? context,
  }) {
    _isContractActive
        ? Navigator.pop(context!)
        : handleStatus(
            context!,
            'Optik tidak memiliki kontrak active',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
  }

  Future<List<StbCustomer>> getSearchParent(String input) async {
    List<StbCustomer> list = List.empty(growable: true);
    const timeout = 15;
    var url = '$API_URL/customers/oldCustIsActive?bill_name=$input';
    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      if (response.statusCode == 400) {
        _isEmpty = true;
      }

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

          _isEmpty = false;
        }
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

    return list;
  }

  Future<List<Product>> getSearchProduct(String input) async {
    List<Product> list = List.empty(growable: true);
    const timeout = 15;
    var url = input == ''
        ? '$API_URL/product'
        : '$API_URL/product/search?search=$input';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
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

          //CEK LIST KONTRAK BARU
          for (int j = 0; j < itemProduct.length; j++) {
            for (int i = 0; i < tmpProduct.length; i++) {
              if (itemProduct[j].proddesc == tmpProduct[i]) {
                itemProduct[j].ischecked = true;
              }
            }
          }

          //CEK LIST REVISI
          if (widget.isRevisi!) {
            for (int j = 0; j < itemProduct.length; j++) {
              for (int i = 0; i < tmpProduct.length; i++) {
                if (itemProduct[j].proddesc == tmpProduct[i]) {
                  itemProduct[j].ischecked = true;
                }
              }
            }
          }
        }
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

    return list;
  }

  getSelectedItem() {
    if (itemProduct.isNotEmpty) {
      for (int i = 0; i < itemProduct.length; i++) {
        if (itemProduct[i].ischecked) {
          if (!tmpProduct.contains(itemProduct[i].proddesc)) {
            tmpProduct.add(itemProduct[i].proddesc);
            tmpProduct.forEach((element) {
              print(element);
            });

            setState(() {
              formProduct.add(FormItemProduct(
                index: formProduct.length,
                product: itemProduct[i],
                itemLength: 2,
              ));
            });
          }
        } else {
          if (tmpProduct.contains(itemProduct[i].proddesc)) {
            tmpProduct.remove(itemProduct[i].proddesc);
            tmpProduct.forEach((element) {
              print(element);
            });

            setState(() {
              if (formProduct.length > 0) {
                formProduct.removeWhere((item) =>
                    item.product!.proddesc == itemProduct[i].proddesc);
              }
            });
          }
        }
      }
    }

    if (widget.isRevisi!) {
      for (int i = 0; i < itemProduct.length; i++) {
        if (itemProduct[i].ischecked) {
          if (!tmpProduct.contains(itemProduct[i].proddesc)) {
            tmpProduct.add(itemProduct[i].proddesc);
            tmpProduct.forEach((element) {
              print(element);
            });

            setState(() {
              formProduct.add(FormItemProduct(
                index: formProduct.length,
                product: itemProduct[i],
                itemLength: 2,
              ));
            });
          }
        } else {
          if (tmpProduct.contains(itemProduct[i].proddesc)) {
            tmpProduct.remove(itemProduct[i].proddesc);
            tmpProduct.forEach((element) {
              print(element);
            });

            setState(() {
              if (formProduct.length > 0) {
                formProduct.removeWhere((item) =>
                    item.product!.proddesc == itemProduct[i].proddesc);
                dtCustomDisc.removeWhere(
                    (item) => item.prodDesc == itemProduct[i].proddesc);
              }
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getRole();
    if (widget.isRevisi!) {
      getDataContract(widget.customerList[widget.position].id);
    }
  }

  getTtdSales(int input) async {
    const timeout = 15;
    var url = '$API_URL/users?id=$input';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          ttdPertama = data['data']['ttd'];
          mytoken = data['data']['gentoken'];
          int areaId = data['data']['area'] != null
              ? int.parse(data['data']['area'])
              : 29;
          getTokenSM(areaId);
          print('TTD Pertama : $ttdPertama');
          print('Mytoken : $mytoken');
          print('AREA ID : $areaId');
        }
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

  getTokenSM(int smID) async {
    const timeout = 15;
    var url = '$API_URL/users?id=$smID';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          idSm = data['data']['id'];
          tokenSm = data['data']['gentoken'];
          print('Id SM : $idSm');
          print('Token SM : $tokenSm');
        }
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

  getSelectedProddiv() {
    if (itemProdDiv.isNotEmpty) {
      for (int i = 0; i < itemProdDiv.length; i++) {
        if (itemProdDiv[i].ischecked) {
          Proddiv prodiv = Proddiv(itemProdDiv[i].alias, itemProdDiv[i].proddiv,
              itemProdDiv[i].diskon);

          if (!tmpDiv.contains(itemProdDiv[i].alias)) {
            tmpDiv.add(itemProdDiv[i].alias);
            tmpDiv.forEach((element) {
              print(element);
            });

            setState(() {
              formDisc.add(FormItemDisc(
                index: formDisc.length,
                proddiv: prodiv,
              ));
            });
          }
        } else {
          if (tmpDiv.contains(itemProdDiv[i].alias)) {
            tmpDiv.remove(itemProdDiv[i].alias);
            tmpDiv.forEach((element) {
              print(element);
            });

            setState(() {
              if (formDisc.length > 0) {
                formDisc.removeWhere((element) =>
                    element.proddiv!.alias == itemProdDiv[i].alias);
              }
            });
          }
        }
      }
    }

    if (widget.isRevisi!) {
      for (int i = 0; i < itemProdDiv.length; i++) {
        if (itemProdDiv[i].ischecked) {
          Proddiv prodiv = Proddiv(itemProdDiv[i].alias, itemProdDiv[i].proddiv,
              itemProdDiv[i].diskon);

          if (!tmpDiv.contains(itemProdDiv[i].alias)) {
            tmpDiv.add(itemProdDiv[i].alias);
            tmpDiv.forEach((element) {
              print(element);
            });

            setState(() {
              formDisc.add(FormItemDisc(
                index: formDisc.length,
                proddiv: prodiv,
              ));
            });
          }
        } else {
          if (tmpDiv.contains(itemProdDiv[i].alias)) {
            tmpDiv.remove(itemProdDiv[i].alias);
            tmpDiv.forEach((element) {
              print(element);
            });

            setState(() {
              if (formDisc.length > 0) {
                formDisc.removeWhere((element) =>
                    element.proddiv!.alias == itemProdDiv[i].alias);
              }
            });
          }
        }
      }
    }
  }

  updateDiskon({
    bool isHorizontal = false,
    dynamic idContract,
  }) async {
    const timeout = 15;
    var url = '$API_URL/discount/delete/$idContract';

    try {
      var response = await http
          .delete(
            Uri.parse(url),
          )
          .timeout(Duration(seconds: timeout));

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        // final String msg = res['message'];

        if (_isContractActive) {
          print('Ini child');
          print('Status = $sts');
        } else if (_isCashbackContrack) {
          print('Ini Cashback');
        } else {
          multipleInputDiskon(
            isHorizontal: isHorizontal,
          );
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
        if (mounted) {
          handleStatus(
            context,
            e.toString(),
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
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
          isLogout: false,
        );
      }
    }
  }

  checkUpdate(Function stop, {bool isHorizontal = false}) async {
    fixedDisc.clear();
    tmpDivInput.clear();
    fixedProduct.clear();
    tmpProduct.clear();

    print('Run update');
    var outNikon,
        outNikonSt,
        outLeinz,
        outLeinzSt,
        outOriental,
        outOrientalSt,
        outMoe,
        startContract;
    var valNikon, valLeinz, valOriental, valMoe;

    startContract = _formatter.format(_now);

    // if (_chosenNikon == "KREDIT") {
    //   outNikon = _chosenNikon + '-' + _durasiNikon;
    // } else {
    //   outNikon = _chosenNikon;
    // }

    // if (_chosenNikonSt == "KREDIT") {
    //   outNikonSt = _chosenNikonSt + '-' + _durasiNikonSt;
    // } else {
    //   outNikonSt = _chosenNikonSt;
    // }

    if (_chosenLeinz == "KREDIT") {
      outLeinz = _chosenLeinz + '-' + _durasiLeinz;
    } else {
      outLeinz = _chosenLeinz;
    }

    if (_chosenLeinzSt == "KREDIT") {
      outLeinzSt = _chosenLeinzSt + '-' + _durasiLeinzSt;
    } else {
      outLeinzSt = _chosenLeinzSt;
    }

    if (_chosenOriental == "KREDIT") {
      outOriental = _chosenOriental + '-' + _durasiOriental;
    } else {
      outOriental = _chosenOriental;
    }

    if (_chosenOrientalSt == "KREDIT") {
      outOrientalSt = _chosenOrientalSt + '-' + _durasiOrientalSt;
    } else {
      outOrientalSt = _chosenOrientalSt;
    }

    if (_chosenMoe == "KREDIT") {
      outMoe = _chosenMoe + '-' + _durasiMoe;
    } else {
      outMoe = _chosenMoe;
    }

    // valNikon =
    //     textValNikon.text.length > 0 ? '${textValNikon.text}.000.000' : '0';
    valLeinz =
        textValLeinz.text.length > 0 ? '${textValLeinz.text}.000.000' : '0';
    valOriental = textValOriental.text.length > 0
        ? '${textValOriental.text}.000.000'
        : '0';
    valMoe = textValMoe.text.length > 0 ? '${textValMoe.text}.000.000' : '0';

    print('Id_Kontrak : ${dtContract[0].idContract}');
    print('ID CUSTOMER : ${dtContract[0].idCustomer}');
    print('nama_kedua : $namaKedua');
    print('tp_nikon: ${valNikon.replaceAll('.', '')}');
    print('tp_leinz: ${valLeinz.replaceAll('.', '')}');
    print('tp_oriental: ${valOriental.replaceAll('.', '')}');
    print('tp_moe: ${valMoe.replaceAll('.', '')}');
    print('pembayaran_nikon : $outNikon');
    print('pembayaran_leinz : $outLeinz');
    print('pembayaran_oriental : $outOriental');
    print('pembayaran_moe : $outMoe');
    print('pembayaran_nikon_st : $outNikonSt');
    print('pembayaran_leinz_St : $outLeinzSt');
    print('pembayaran_oriental_st : $outOrientalSt');
    print('type_contract : ${_isCashbackContrack ? 'CASHBACK' : _isCashbackWithDiscContract ? 'CASHBACK DENGAN DISKON' : 'LENSA'}');
    print('is_frame : $_isFrameContract');
    print('is_partai : $_isPartaiContract');
    print('updated_by : $id');
    print('has_parent : ${_isContractActive ? '1' : '0'}');
    print(
        'id_parent : ${_isContractActive ? itemActiveContract[0].idCustomer : ''}');
    print(
        'id_contract_parent : ${_isContractActive ? itemActiveContract[0].idContract : ''}');

    if (_isCashbackContrack) {
      print('Cashback');
    } else if (_isChildContract) {
      print('Child');
    } else {
      setState(() {
        if (defaultDisc.length > 0) {
          defaultDisc.forEach((element) {
            element.proddiv!.ischecked = true;
          });
          fixedDisc.addAll(defaultDisc);
          for (int i = 0; i < defaultDisc.length; i++) {
            tmpDivInput.add(defaultDisc[i].proddiv!.alias);
          }
        }

        if (formDisc.length > 0) {
          for (int i = 0; i < formDisc.length; i++) {
            if (formDisc[i].proddiv!.ischecked) {
              if (!tmpDivInput.contains(formDisc[i].proddiv!.alias)) {
                tmpDivInput.add(formDisc[i].proddiv!.alias);
                fixedDisc.add(formDisc[i]);
              } else {
                fixedDisc.removeWhere((element) =>
                    element.proddiv!.alias == formDisc[i].proddiv!.alias);
                fixedDisc.add(formDisc[i]);
              }
            } else {
              fixedDisc.removeWhere((element) =>
                  element.proddiv!.alias == formDisc[i].proddiv!.alias);
            }
          }
        }

        if (formProduct.length > 0) {
          for (int i = 0; i < formProduct.length; i++) {
            if (formProduct[i].product!.ischecked) {
              if (!tmpProduct.contains(formProduct[i].product!.proddesc)) {
                tmpProduct.add(formProduct[i].product!.proddesc);
                fixedProduct.add(formProduct[i]);
              } else {
                fixedProduct.removeWhere((element) =>
                    element.product!.proddesc ==
                    formProduct[i].product!.proddesc);
                fixedProduct.add(formProduct[i]);
              }
            } else {
              fixedProduct.removeWhere((element) =>
                  element.product!.proddesc ==
                  formProduct[i].product!.proddesc);
            }
          }
        }
      });

      print('Total Data Diskon =  ${fixedDisc.length}');
      fixedDisc.forEach((element) {
        print(element.proddiv!.alias);
        print(element.proddiv!.diskon);
        print(element.proddiv!.ischecked);
      });

      print('Total Data Product =  ${fixedProduct.length}');
      fixedProduct.forEach((element) {
        print(element.product!.proddesc);
        print(element.product!.diskon);
        print(element.product!.ischecked);
      });
    }

    stop();

    // EKSEKUSI UPDATE DB
    var url = '$API_URL/contract/${dtContract[0].idContract}';
    const timeout = 15;

    try {
      var response = await http.put(
        Uri.parse(url),
        body: {
          'nama_kedua': namaKedua,
          'tp_nikon': valNikon.replaceAll('.', ''),
          'tp_leinz': valLeinz.replaceAll('.', ''),
          'tp_oriental': valOriental.replaceAll('.', ''),
          'tp_moe': valMoe.replaceAll('.', ''),
          'pembayaran_nikon': outNikon,
          'pembayaran_leinz': outLeinz,
          'pembayaran_oriental': outOriental,
          'pembayaran_moe': outMoe,
          'pembayaran_nikon_stock': outNikonSt,
          'pembayaran_leinz_stock': outLeinzSt,
          'pembayaran_oriental_stock': outOrientalSt,
          'start_contract': startContract,
          'type_contract': _isCashbackContrack ? 'CASHBACK' : _isCashbackWithDiscContract ? 'CASHBACK DENGAN DISKON' : 'LENSA',
          'is_frame': _isFrameContract ? '1' : '0',
          'is_partai': _isPartaiContract ? '1' : '0',
          'catatan': "${textCatatan.text} ${_isPrestigeContract ? 'Kontrak Khusus Leinz Prestige (Japan) - Beli 3 gratis 1' : ''}",
          'updated_by': id,
          'has_parent': _isContractActive ? '1' : '0',
          'id_parent':
              _isContractActive ? itemActiveContract[0].idCustomer : '',
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
          textValLeinz.clear();
          textValMoe.clear();
          // textValNikon.clear();
          textValOriental.clear();

          print('RUN UPDATE DISKON : ${dtContract[0].idContract}');

          updateDiskon(
            isHorizontal: isHorizontal,
            idContract: dtContract[0].idContract,
          );

          if (dtContract[0].approvalSm == "2") {
            //NOTIF KE SALES MANAGER
            //Send to me
            pushNotif(
              2,
              3,
              idUser: id,
              rcptToken: mytoken,
              opticName: widget.customerList[widget.position].namaUsaha,
            );

            //Send to Sales Manager
            pushNotif(
              3,
              3,
              salesName: name,
              idUser: idSm,
              rcptToken: tokenSm,
              opticName: widget.customerList[widget.position].namaUsaha,
            );
          } else {
            //NOTIF KE AR MANAGER
            //Send to me
            pushNotif(
              2,
              3,
              idUser: id,
              rcptToken: mytoken,
              opticName: widget.customerList[widget.position].namaUsaha,
            );

            //Send to all AR
            pushNotif(
              3,
              4,
              salesName: name,
              opticName: widget.customerList[widget.position].namaUsaha,
              idUser: '',
            );
          }
        }
        if (mounted) {
          handleStatus(
            context,
            capitalize(msg),
            sts,
            isHorizontal: isHorizontal,
            isLogout: false,
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
            isLogout: false,
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
          isLogout: false,
        );
      }
    }
  }

  checkInput(Function stop, {bool isHorizontal = false}) async {
    fixedDisc.clear();
    fixedProduct.clear();
    tmpDivInput.clear();
    tmpProduct.clear();

    // var outNikon,
    //     outNikonSt,
    var outLeinz,
        outLeinzSt,
        outOriental,
        outOrientalSt,
        outMoe,
        startContract;
    // var valNikon;
    var valLeinz, valOriental, valMoe;

    // if (_chosenNikon == "KREDIT") {
    //   outNikon = _chosenNikon + '-' + _durasiNikon;
    // } else {
    //   outNikon = _chosenNikon;
    // }

    // if (_chosenNikonSt == "KREDIT") {
    //   outNikonSt = _chosenNikonSt + '-' + _durasiNikonSt;
    // } else {
    //   outNikonSt = _chosenNikonSt;
    // }

    if (_chosenLeinz == "KREDIT") {
      outLeinz = _chosenLeinz + '-' + _durasiLeinz;
    } else {
      outLeinz = _chosenLeinz;
    }

    if (_chosenLeinzSt == "KREDIT") {
      outLeinzSt = _chosenLeinzSt + '-' + _durasiLeinzSt;
    } else {
      outLeinzSt = _chosenLeinzSt;
    }

    if (_chosenOriental == "KREDIT") {
      outOriental = _chosenOriental + '-' + _durasiOriental;
    } else {
      outOriental = _chosenOriental;
    }

    if (_chosenOrientalSt == "KREDIT") {
      outOrientalSt = _chosenOrientalSt + '-' + _durasiOrientalSt;
    } else {
      outOrientalSt = _chosenOrientalSt;
    }

    if (_chosenMoe == "KREDIT") {
      outMoe = _chosenMoe + '-' + _durasiMoe;
    } else {
      outMoe = _chosenMoe;
    }

    startContract = _formatter.format(_now);
    // valNikon =
    //     textValNikon.text.length > 0 ? '${textValNikon.text}.000.000' : '0';
    valLeinz =
        textValLeinz.text.length > 0 ? '${textValLeinz.text}.000.000' : '0';
    valOriental = textValOriental.text.length > 0
        ? '${textValOriental.text}.000.000'
        : '0';
    valMoe = textValMoe.text.length > 0 ? '${textValMoe.text}.000.000' : '0';

    print('id_customer: $idCustomer');
    print('nama_pertama : $name');
    print('jabatan_pertama: $role');
    print('nama_kedua : $namaKedua');
    // print('tp_nikon: ${valNikon.replaceAll('.', '')}');
    print('tp_leinz: ${valLeinz.replaceAll('.', '')}');
    print('tp_oriental: ${valOriental.replaceAll('.', '')}');
    print('tp_moe: ${valMoe.replaceAll('.', '')}');
    // print('pembayaran_nikon : $outNikon');
    print('pembayaran_leinz : $outLeinz');
    print('pembayaran_oriental : $outOriental');
    print('pembayaran_moe : $outMoe');
    // print('pembayaran_nikon_stock : $outNikonSt');
    print('pembayaran_leinz_stock : $outLeinzSt');
    print('pembayaran_oriental_stock : $outOrientalSt');
    print('start_contract : $startContract');
    print('type_contract : ${_isCashbackContrack ? 'CASHBACK' : _isCashbackWithDiscContract ? 'CASHBACK DENGAN DISKON' : 'LENSA'}');
    print('is_frame : ${_isFrameContract ? '1' : '0'}');
    print('is_partai : ${_isPartaiContract ? '1' : '0'}');
    print('ttd_pertama : $ttdPertama');
    print('ttd_kedua : $ttdKedua');
    print('catatan : ${textCatatan.text} ${_isPrestigeContract ? 'Kontrak Khusus Leinz Prestige (Japan) - Beli 3 gratis 1' : ''}');
    print('created_by : $id');
    print('has_parent : ${_isContractActive ? '1' : '0'}');
    print(
        'id_parent : ${_isContractActive ? itemActiveContract[0].idCustomer : ''}');
    print(
        'id_contract_parent : ${_isContractActive ? itemActiveContract[0].idContract : ''}');

    stop();

    if (_isCashbackContrack) {
      print('Cashback');
    } else if (_isChildContract) {
      print('Child');
    } else {
      setState(() {
        if (defaultDisc.length > 0) {
          defaultDisc.forEach((element) {
            element.proddiv!.ischecked = true;
          });
          fixedDisc.addAll(defaultDisc);
          for (int i = 0; i < defaultDisc.length; i++) {
            tmpDivInput.add(defaultDisc[i].proddiv!.alias);
          }
        }

        if (formDisc.length > 0) {
          for (int i = 0; i < formDisc.length; i++) {
            if (formDisc[i].proddiv!.ischecked) {
              if (!tmpDivInput.contains(formDisc[i].proddiv!.alias)) {
                tmpDivInput.add(formDisc[i].proddiv!.alias);
                fixedDisc.add(formDisc[i]);
              } else {
                fixedDisc.removeWhere((element) =>
                    element.proddiv!.alias == formDisc[i].proddiv!.alias);
                fixedDisc.add(formDisc[i]);
              }
            } else {
              fixedDisc.removeWhere((element) =>
                  element.proddiv!.alias == formDisc[i].proddiv!.alias);
            }
          }
        }

        if (formProduct.length > 0) {
          for (int i = 0; i < formProduct.length; i++) {
            if (formProduct[i].product!.ischecked) {
              if (!tmpProduct.contains(formProduct[i].product!.proddesc)) {
                tmpProduct.add(formProduct[i].product!.proddesc);
                fixedProduct.add(formProduct[i]);
              } else {
                fixedProduct.removeWhere((element) =>
                    element.product!.proddesc ==
                    formProduct[i].product!.proddesc);
                fixedProduct.add(formProduct[i]);
              }
            } else {
              fixedProduct.removeWhere((element) =>
                  element.product!.proddesc ==
                  formProduct[i].product!.proddesc);
            }
          }
        }
      });

      print('Total Data Diskon =  ${fixedDisc.length}');
      fixedDisc.forEach((element) {
        print(element.proddiv!.alias);
        print(element.proddiv!.diskon);
        print(element.proddiv!.ischecked);
      });

      print('Total Data Product =  ${fixedProduct.length}');
      fixedProduct.forEach((element) {
        print(element.product!.proddesc);
        print(element.product!.diskon);
        print(element.product!.ischecked);
      });
    }

    // EKSEKUSI INPUT KE DB
    var url = '$API_URL/contract/upload';
    const timeout = 15;

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id_customer': idCustomer,
          'nama_pertama': name,
          'jabatan_pertama': role,
          'nama_kedua': namaKedua,
          'jabatan_kedua': jabatanKedua,
          'alamat_kedua': alamatKedua,
          'telp_kedua': telpKedua,
          'fax_kedua': faxKedua,
          // 'tp_nikon': valNikon.replaceAll('.', ''),
          'tp_leinz': valLeinz.replaceAll('.', ''),
          'tp_oriental': valOriental.replaceAll('.', ''),
          'tp_moe': valMoe.replaceAll('.', ''),
          // 'pembayaran_nikon': outNikon,
          'pembayaran_leinz': outLeinz,
          'pembayaran_oriental': outOriental,
          'pembayaran_moe': outMoe,
          // 'pembayaran_nikon_stock': outNikonSt,
          'pembayaran_leinz_stock': outLeinzSt,
          'pembayaran_oriental_stock': outOrientalSt,
          'start_contract': startContract,
          'type_contract': _isCashbackContrack ? 'CASHBACK' : _isCashbackWithDiscContract ? 'CASHBACK DENGAN DISKON' : 'LENSA',
          'is_frame': _isFrameContract ? '1' : '0',
          'is_partai': _isPartaiContract ? '1' : '0',
          'catatan': "${textCatatan.text} ${_isPrestigeContract ? 'Kontrak Khusus Leinz Prestige (Japan) - Beli 3 gratis 1' : ''}",
          'ttd_pertama': ttdPertama,
          'ttd_kedua': ttdKedua,
          'created_by': id,
          'has_parent': _isContractActive ? '1' : '0',
          'id_parent':
              _isContractActive ? itemActiveContract[0].idCustomer : '',
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
          textValLeinz.clear();
          textValMoe.clear();
          // textValNikon.clear();
          textValOriental.clear();

          if (_isContractActive) {
            print('Ini child');
          } else if (_isCashbackContrack) {
            print('Ini Cashback');
          } else {
            multipleInputDiskon(
              isHorizontal: isHorizontal,
            );
          }

          //Send to me
          pushNotif(
            0,
            3,
            idUser: id,
            rcptToken: mytoken,
            opticName: widget.customerList[widget.position].namaUsaha,
          );

          //Send to Sales Manager
          pushNotif(
            1,
            3,
            salesName: name,
            idUser: idSm,
            rcptToken: tokenSm,
            opticName: widget.customerList[widget.position].namaUsaha,
          );
        }

        if (mounted) {
          handleStatus(
            context,
            capitalize(msg),
            sts,
            isHorizontal: isHorizontal,
            isLogout: false,
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
            isLogout: false,
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
          isLogout: false,
        );
      }
    }
  }

  multipleInputDiskon({bool isHorizontal = false}) async {
    if (fixedDisc.length > 0) {
      for (int i = 0; i < fixedDisc.length; i++) {
        FormItemDisc item = fixedDisc[i];
        if (item.proddiv!.ischecked) {
          debugPrint("Proddiv: ${item.proddiv!.proddiv}");
          debugPrint("Alias: ${item.proddiv!.alias}");
          debugPrint("Diskon: ${item.proddiv!.diskon}");
          debugPrint("Is Checked : ${item.proddiv!.ischecked}");

          print(
              'Id Cust : $idCustomer \n Ischecked : ${item.proddiv!.ischecked} Proddiv : ${item.proddiv!.proddiv} \n Diskon : ${item.proddiv!.diskon} \n Alias : ${item.proddiv!.alias}');

          postMultiDiv(
            idCustomer,
            item.proddiv!.proddiv,
            item.proddiv!.diskon,
            item.proddiv!.alias,
            isHorizontal: isHorizontal,
          );
        }
      }
    } else {
      print("Form is Not Valid");
    }

    if (fixedProduct.length > 0) {
      for (int i = 0; i < fixedProduct.length; i++) {
        FormItemProduct item = fixedProduct[i];
        if (item.product!.ischecked) {
          debugPrint("Category Id: ${item.product!.categoryid}");
          debugPrint("Proddiv: ${item.product!.proddiv}");
          debugPrint("Prodcat: ${item.product!.prodcat}");
          debugPrint("Proddesc: ${item.product!.proddesc}");
          debugPrint("Diskon: ${item.product!.diskon}");

          postMultiItem(
            idCustomer,
            item.product!.categoryid,
            item.product!.proddiv,
            item.product!.prodcat,
            item.product!.proddesc,
            item.product!.diskon,
            isHorizontal: isHorizontal,
          );
        }
      }
    } else {
      print("Form is Not Valid");
    }
  }

  postMultiDiv(String idCust, String proddiv, String diskon, String alias,
      {bool isHorizontal = false}) async {
    const timeout = 15;
    var url = '$API_URL/discount/divCustomDiscount';

    try {
      var response = await http.post(
        Uri.parse(url),
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
            isLogout: false,
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
          isLogout: false,
        );
      }
    }
  }

  postMultiItem(
    String idCust,
    String categoryId,
    String prodDiv,
    String prodCat,
    String prodDesc,
    String disc, {
    bool isHorizontal = false,
  }) async {
    const timeout = 15;
    var url = '$API_URL/discount/customDiscount';

    try {
      var response = await http.post(
        Uri.parse(url),
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
            isLogout: false,
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
          isLogout: false,
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

  Widget childEcontract({bool isHorizontal = false}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Perjanjian Kontrak Kerjasama',
          style: TextStyle(
            color: Colors.black54,
            fontSize: isHorizontal ? 20.sp : 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.0,
        centerTitle: isHorizontal ? true : false,
        leading: IconButton(
          onPressed: () {
            if (widget.isAdmin!) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AdminScreen(),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => CustomerScreen(
                    int.parse(id!),
                  ),
                ),
              );
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black54,
            size: isHorizontal ? 20.sp : 18.r,
          ),
        ),
      ),
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 25.r : 20.r,
                vertical: widget.isRevisi!
                    ? isHorizontal
                        ? 85.r
                        : 65.r
                    : isHorizontal
                        ? 85.r
                        : 70.r,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Text(
                      'Pihak Pertama',
                      style: TextStyle(
                        fontSize: isHorizontal ? 19.sp : 15.sp,
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
                            ? MediaQuery.of(context).size.width / 5.5
                            : MediaQuery.of(context).size.width / 5.2,
                        child: Text(
                          'Nama : ',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          name!,
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                            ? MediaQuery.of(context).size.width / 5.5
                            : MediaQuery.of(context).size.width / 5.2,
                        child: Text(
                          'Jabatan : ',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          role!,
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                            ? MediaQuery.of(context).size.width / 5.5
                            : MediaQuery.of(context).size.width / 5.2,
                        child: Text(
                          'Telp : ',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '021-4610154',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                            ? MediaQuery.of(context).size.width / 5.5
                            : MediaQuery.of(context).size.width / 5.2,
                        child: Text(
                          'Fax : ',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '021-4610151-52',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                            ? MediaQuery.of(context).size.width / 5.5
                            : MediaQuery.of(context).size.width / 5.2,
                        child: Text(
                          'Alamat : ',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Jl. Rawa Kepiting No. 4 Kawasan Industri Pulogadung, Jakarta Timur',
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                        fontSize: isHorizontal ? 19.sp : 15.sp,
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
                            ? MediaQuery.of(context).size.width / 5.5
                            : MediaQuery.of(context).size.width / 5.2,
                        child: Text(
                          'Nama : ',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          namaKedua = widget.customerList[widget.position].nama,
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                            ? MediaQuery.of(context).size.width / 5.5
                            : MediaQuery.of(context).size.width / 5.2,
                        child: Text(
                          'Jabatan : ',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          jabatanKedua = 'Owner',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                            ? MediaQuery.of(context).size.width / 5.5
                            : MediaQuery.of(context).size.width / 5.2,
                        child: Text(
                          'Telp : ',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          telpKedua =
                              widget.customerList[widget.position].noTlp,
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                            ? MediaQuery.of(context).size.width / 5.5
                            : MediaQuery.of(context).size.width / 5.2,
                        child: Text(
                          'Fax : ',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                            ? MediaQuery.of(context).size.width / 5.5
                            : MediaQuery.of(context).size.width / 5.2,
                        child: Text(
                          'Alamat : ',
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          alamatKedua =
                              widget.customerList[widget.position].alamat,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
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
                      'Target pembelian / bulan (satuan juta) : ',
                      style: TextStyle(
                        fontSize: isHorizontal ? 19.sp : 15.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: isHorizontal ? 18.h : 8.h,
                  // ),
                  // Container(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: isHorizontal ? 10.r : 5.r,
                  //   ),
                  //   child: TextFormField(
                  //     keyboardType: TextInputType.number,
                  //     decoration: InputDecoration(
                  //       hintText: 'Lensa Nikon',
                  //       labelText: 'Lensa Nikon',
                  //       contentPadding: EdgeInsets.symmetric(
                  //         vertical: 3.r,
                  //         horizontal: 15.r,
                  //       ),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(5.r),
                  //       ),
                  //     ),
                  //     inputFormatters: [ThousandsSeparatorInputFormatter()],
                  //     controller: textValNikon,
                  //     maxLength: 5,
                  //     style: TextStyle(
                  //       fontSize: isHorizontal ? 18.sp : 14.sp,
                  //       fontFamily: 'Segoe Ui',
                  //     ),
                  //   ),
                  // ),
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
                      maxLength: 5,
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 14.sp,
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
                      maxLength: 5,
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 14.sp,
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
                      maxLength: 5,
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 14.sp,
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
                        fontSize: isHorizontal ? 19.sp : 15.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 18.h : 8.h,
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: isHorizontal ? 10.r : 5.r,
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: [
                  //       Container(
                  //         width: isHorizontal
                  //             ? MediaQuery.of(context).size.width / 3.5
                  //             : MediaQuery.of(context).size.width / 3.2,
                  //         child: Text(
                  //           'Lensa Nikon RX : ',
                  //           style: TextStyle(
                  //             fontSize: isHorizontal ? 18.h : 14.sp,
                  //             fontFamily: 'Montserrat',
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //       ),
                  //       Expanded(
                  //         child: Container(
                  //           padding: EdgeInsets.symmetric(horizontal: 10.r),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white70,
                  //             border: Border.all(color: Colors.black54),
                  //             borderRadius: BorderRadius.circular(5.r),
                  //           ),
                  //           child: DropdownButton(
                  //             underline: SizedBox(),
                  //             isExpanded: true,
                  //             value: _chosenNikon,
                  //             style: TextStyle(
                  //               fontSize: isHorizontal ? 18.sp : 14.sp,
                  //               fontFamily: 'Segoe Ui',
                  //               color: Colors.black54,
                  //               fontWeight: FontWeight.w600,
                  //             ),
                  //             items: [
                  //               '-',
                  //               'COD',
                  //               'TRANSFER',
                  //               'DEPOSIT',
                  //               'KREDIT',
                  //             ].map((e) {
                  //               return DropdownMenuItem(
                  //                 value: e,
                  //                 child: Text(e,
                  //                     style: TextStyle(color: Colors.black54)),
                  //               );
                  //             }).toList(),
                  //             onChanged: (String? value) {
                  //               setState(() {
                  //                 _chosenNikon = value!;
                  //               });
                  //             },
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: isHorizontal ? 18.h : 8.h,
                  // ),
                  // _chosenNikon == "KREDIT"
                  //     ? durasiNikon(
                  //         isHorizontal: isHorizontal,
                  //       )
                  //     : SizedBox(
                  //         width: 20.w,
                  //       ),
                  // SizedBox(
                  //   height: isHorizontal ? 18.h : 8.h,
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: isHorizontal ? 10.r : 5.r,
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: [
                  //       Container(
                  //         width: isHorizontal
                  //             ? MediaQuery.of(context).size.width / 3.5
                  //             : MediaQuery.of(context).size.width / 3.2,
                  //         child: Text(
                  //           'Lensa Nikon Stock : ',
                  //           style: TextStyle(
                  //             fontSize: isHorizontal ? 18.h : 14.sp,
                  //             fontFamily: 'Montserrat',
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //       ),
                  //       Expanded(
                  //         child: Container(
                  //           padding: EdgeInsets.symmetric(horizontal: 10.r),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white70,
                  //             border: Border.all(color: Colors.black54),
                  //             borderRadius: BorderRadius.circular(5.r),
                  //           ),
                  //           child: DropdownButton(
                  //             underline: SizedBox(),
                  //             isExpanded: true,
                  //             value: _chosenNikonSt,
                  //             style: TextStyle(
                  //               fontSize: isHorizontal ? 18.sp : 14.sp,
                  //               fontFamily: 'Segoe Ui',
                  //               color: Colors.black54,
                  //               fontWeight: FontWeight.w600,
                  //             ),
                  //             items: [
                  //               '-',
                  //               'COD',
                  //               'TRANSFER',
                  //               'DEPOSIT',
                  //               'KREDIT',
                  //             ].map((e) {
                  //               return DropdownMenuItem(
                  //                 value: e,
                  //                 child: Text(e,
                  //                     style: TextStyle(color: Colors.black54)),
                  //               );
                  //             }).toList(),
                  //             onChanged: (String? value) {
                  //               setState(() {
                  //                 _chosenNikonSt = value!;
                  //               });
                  //             },
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: isHorizontal ? 18.h : 8.h,
                  // ),
                  // _chosenNikonSt == "KREDIT"
                  //     ? durasiNikonSt(
                  //         isHorizontal: isHorizontal,
                  //       )
                  //     : SizedBox(
                  //         width: 20.w,
                  //       ),
                  // SizedBox(
                  //   height: isHorizontal ? 18.h : 8.h,
                  // ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isHorizontal ? 10.r : 5.r,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: isHorizontal
                              ? MediaQuery.of(context).size.width / 3.5
                              : MediaQuery.of(context).size.width / 3.2,
                          child: Text(
                            'Lensa Leinz RX : ',
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.h : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.r),
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(5.r)),
                            child: DropdownButton(
                              underline: SizedBox(),
                              isExpanded: true,
                              value: _chosenLeinz,
                              style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Segoe Ui',
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              items: [
                                '-',
                                'COD',
                                'TRANSFER',
                                'DEPOSIT',
                                'KREDIT',
                              ].map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: TextStyle(color: Colors.black54)),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _chosenLeinz = value!;
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
                  _chosenLeinz == "KREDIT"
                      ? durasiLeinz(
                          isHorizontal: isHorizontal,
                        )
                      : SizedBox(
                          width: 20.w,
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
                              ? MediaQuery.of(context).size.width / 3.5
                              : MediaQuery.of(context).size.width / 3.2,
                          child: Text(
                            'Lensa Leinz Stock : ',
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.h : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.r),
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(5.r)),
                            child: DropdownButton(
                              underline: SizedBox(),
                              isExpanded: true,
                              value: _chosenLeinzSt,
                              style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Segoe Ui',
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              items: [
                                '-',
                                'COD',
                                'TRANSFER',
                                'DEPOSIT',
                                'KREDIT',
                              ].map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: TextStyle(color: Colors.black54)),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _chosenLeinzSt = value!;
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
                  _chosenLeinzSt == "KREDIT"
                      ? durasiLeinzSt(
                          isHorizontal: isHorizontal,
                        )
                      : SizedBox(
                          width: 20.w,
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
                              ? MediaQuery.of(context).size.width / 3.5
                              : MediaQuery.of(context).size.width / 3.2,
                          child: Text(
                            'Lensa Oriental RX : ',
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.h : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.r),
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(5.r)),
                            child: DropdownButton(
                              underline: SizedBox(),
                              isExpanded: true,
                              value: _chosenOriental,
                              style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Segoe Ui',
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              items: [
                                '-',
                                'COD',
                                'TRANSFER',
                                'DEPOSIT',
                                'KREDIT',
                              ].map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: TextStyle(color: Colors.black54)),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _chosenOriental = value!;
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
                  _chosenOriental == "KREDIT"
                      ? durasiOriental(
                          isHorizontal: isHorizontal,
                        )
                      : SizedBox(
                          width: 20.w,
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
                              ? MediaQuery.of(context).size.width / 3.5
                              : MediaQuery.of(context).size.width / 3.2,
                          child: Text(
                            'Lensa Oriental Stock : ',
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.h : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.r),
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(5.r)),
                            child: DropdownButton(
                              underline: SizedBox(),
                              isExpanded: true,
                              value: _chosenOrientalSt,
                              style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Segoe Ui',
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              items: [
                                '-',
                                'COD',
                                'TRANSFER',
                                'DEPOSIT',
                                'KREDIT',
                              ].map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: TextStyle(color: Colors.black54)),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _chosenOrientalSt = value!;
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
                  _chosenOrientalSt == "KREDIT"
                      ? durasiOrientalSt(
                          isHorizontal: isHorizontal,
                        )
                      : SizedBox(
                          width: 20.w,
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
                              ? MediaQuery.of(context).size.width / 3.5
                              : MediaQuery.of(context).size.width / 3.2,
                          child: Text(
                            'Lensa Moe : ',
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.h : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.r),
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(5.r)),
                            child: DropdownButton(
                              underline: SizedBox(),
                              isExpanded: true,
                              value: _chosenMoe,
                              style: TextStyle(
                                fontSize: isHorizontal ? 18.sp : 14.sp,
                                fontFamily: 'Segoe Ui',
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              items: [
                                '-',
                                'COD',
                                'TRANSFER',
                                'DEPOSIT',
                                'KREDIT',
                              ].map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: TextStyle(color: Colors.black54)),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _chosenMoe = value!;
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
                  _chosenMoe == "KREDIT"
                      ? durasiMoe(
                          isHorizontal: isHorizontal,
                        )
                      : SizedBox(
                          width: 20.w,
                        ),
                  SizedBox(
                    height: isHorizontal ? 35.h : 20.h,
                  ),
                  Text(
                    'Catatan',
                    style: TextStyle(
                      fontSize: isHorizontal ? 19.sp : 12.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 18.h : 8.h,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Isi Catatan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 4,
                    maxLength: 100,
                    controller: textCatatan,
                    style: TextStyle(
                      fontSize: isHorizontal ? 18.sp : 14.sp,
                      fontFamily: 'Segoe Ui',
                    ),
                  ),
                  areaFrameContract(
                    isHorizontal: isHorizontal,
                  ),
                  !_isChildContract
                      ? !_isCashbackContrack
                          ? areaMultiFormDiv(
                              isHorizontal: isHorizontal,
                            )
                          : SizedBox(
                              width: 5.w,
                            )
                      : SizedBox(
                          width: 5.w,
                        ),
                  !_isChildContract
                      ? !_isCashbackContrack
                          ? areaMultiFormProduct(
                              isHorizontal: isHorizontal,
                            )
                          : SizedBox(
                              width: 5.w,
                            )
                      : SizedBox(
                          width: 5.w,
                        ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isHorizontal ? 10.r : 5.r,
                      vertical: isHorizontal ? 10.r : 5.r,
                    ),
                    alignment: Alignment.centerRight,
                    child: ArgonButton(
                      height: isHorizontal ? 45.h : 35.h,
                      width: isHorizontal
                          ? widget.isRevisi!
                              ? 80.w
                              : 70.w
                          : 90.w,
                      borderRadius: isHorizontal ? 60.r : 30.r,
                      color: widget.isRevisi!
                          ? Colors.orange[700]
                          : Colors.blue[700],
                      child: Text(
                        widget.isRevisi! ? "Perbarui" : "Simpan",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: isHorizontal ? 18.sp : 14.sp,
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
                            widget.isRevisi!
                                ? checkUpdate(stopLoading,
                                    isHorizontal: isHorizontal)
                                : checkInput(
                                    stopLoading,
                                    isHorizontal: isHorizontal,
                                  );
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          widget.isRevisi!
              ? _isLoading
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: CircularProgressIndicator(),
                    )
                  : Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                              offset: Offset(5.0, 5.0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            dtContract[0].reasonSm != ''
                                ? dtContract[0].reasonSm.isNotEmpty
                                    ? Text(
                                        'INFO SM : ${dtContract[0].reasonSm}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Segoe ui',
                                          fontSize:
                                              isHorizontal ? 24.sp : 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.justify,
                                      )
                                    : SizedBox(
                                        width: 5,
                                      )
                                : SizedBox(
                                    width: 5,
                                  ),
                            dtContract[0].reasonAm != ''
                                ? dtContract[0].reasonAm.isNotEmpty
                                    ? Text(
                                        'INFO AR : ${dtContract[0].reasonAm}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Segoe ui',
                                          fontSize:
                                              isHorizontal ? 24.sp : 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.justify,
                                      )
                                    : SizedBox(
                                        width: 5,
                                      )
                                : SizedBox(
                                    width: 5,
                                  ),
                          ],
                        ),
                      ),
                    )
              : Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade700,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                          offset: Offset(5.0, 5.0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Kontrak yang berakhir ditanggal 31 Desember akan otomatis diperpanjang ke tahun berikutnya',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 18.sp : 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
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
                onChanged: (bool? val) {
                  setState(() {
                    item[index].ischecked = val!;
                  });
                },
              );
            },
          ),
        ),
      );
    });
  }

  // Widget durasiNikon({bool isHorizontal = false}) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: isHorizontal ? 10.r : 5.r,
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: isHorizontal
  //               ? MediaQuery.of(context).size.width / 3.5
  //               : MediaQuery.of(context).size.width / 3.2,
  //           child: Text(
  //             'Durasi : ',
  //             style: TextStyle(
  //               fontSize: isHorizontal ? 18.h : 14.sp,
  //               fontFamily: 'Montserrat',
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 10.r),
  //             decoration: BoxDecoration(
  //               color: Colors.white70,
  //               border: Border.all(color: Colors.black54),
  //               borderRadius: BorderRadius.circular(5.r),
  //             ),
  //             child: DropdownButton(
  //               underline: SizedBox(),
  //               isExpanded: true,
  //               value: _durasiNikon,
  //               style: TextStyle(
  //                 fontSize: isHorizontal ? 18.sp : 14.sp,
  //                 fontFamily: 'Segoe Ui',
  //                 color: Colors.black54,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //               items: [
  //                 '7 HARI',
  //                 '14 HARI',
  //                 '30 HARI',
  //                 '45 HARI',
  //               ].map((e) {
  //                 return DropdownMenuItem(
  //                   value: e,
  //                   child: Text(e, style: TextStyle(color: Colors.black54)),
  //                 );
  //               }).toList(),
  //               onChanged: (String? value) {
  //                 setState(() {
  //                   _durasiNikon = value!;
  //                 });
  //               },
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget durasiNikonSt({bool isHorizontal = false}) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: isHorizontal ? 10.r : 5.r,
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: isHorizontal
  //               ? MediaQuery.of(context).size.width / 3.5
  //               : MediaQuery.of(context).size.width / 3.2,
  //           child: Text(
  //             'Durasi : ',
  //             style: TextStyle(
  //               fontSize: isHorizontal ? 18.h : 14.sp,
  //               fontFamily: 'Montserrat',
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 10.r),
  //             decoration: BoxDecoration(
  //               color: Colors.white70,
  //               border: Border.all(color: Colors.black54),
  //               borderRadius: BorderRadius.circular(5.r),
  //             ),
  //             child: DropdownButton(
  //               underline: SizedBox(),
  //               isExpanded: true,
  //               value: _durasiNikonSt,
  //               style: TextStyle(
  //                 fontSize: isHorizontal ? 18.sp : 14.sp,
  //                 fontFamily: 'Segoe Ui',
  //                 color: Colors.black54,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //               items: [
  //                 '7 HARI',
  //                 '14 HARI',
  //                 '30 HARI',
  //                 '45 HARI',
  //               ].map((e) {
  //                 return DropdownMenuItem(
  //                   value: e,
  //                   child: Text(e, style: TextStyle(color: Colors.black54)),
  //                 );
  //               }).toList(),
  //               onChanged: (String? value) {
  //                 setState(() {
  //                   _durasiNikonSt = value!;
  //                 });
  //               },
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget durasiMoe({bool isHorizontal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 10.r : 5.r,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isHorizontal
                ? MediaQuery.of(context).size.width / 3.5
                : MediaQuery.of(context).size.width / 3.2,
            child: Text(
              'Durasi : ',
              style: TextStyle(
                fontSize: isHorizontal ? 18.h : 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.r),
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: DropdownButton(
                underline: SizedBox(),
                isExpanded: true,
                value: _durasiMoe,
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 14.sp,
                  fontFamily: 'Segoe Ui',
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  '7 HARI',
                  '14 HARI',
                  '30 HARI',
                  '45 HARI',
                ].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e, style: TextStyle(color: Colors.black54)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _durasiMoe = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget durasiLeinz({bool isHorizontal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 10.r : 5.r,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isHorizontal
                ? MediaQuery.of(context).size.width / 3.5
                : MediaQuery.of(context).size.width / 3.2,
            child: Text(
              'Durasi : ',
              style: TextStyle(
                fontSize: isHorizontal ? 18.h : 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.r),
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: DropdownButton(
                underline: SizedBox(),
                isExpanded: true,
                value: _durasiLeinz,
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 14.sp,
                  fontFamily: 'Segoe Ui',
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  '7 HARI',
                  '14 HARI',
                  '30 HARI',
                  '45 HARI',
                ].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e, style: TextStyle(color: Colors.black54)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _durasiLeinz = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget durasiLeinzSt({bool isHorizontal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 10.r : 5.r,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isHorizontal
                ? MediaQuery.of(context).size.width / 3.5
                : MediaQuery.of(context).size.width / 3.2,
            child: Text(
              'Durasi : ',
              style: TextStyle(
                fontSize: isHorizontal ? 18.h : 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.r),
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: DropdownButton(
                underline: SizedBox(),
                isExpanded: true,
                value: _durasiLeinzSt,
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 14.sp,
                  fontFamily: 'Segoe Ui',
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  '7 HARI',
                  '14 HARI',
                  '30 HARI',
                  '45 HARI',
                ].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e, style: TextStyle(color: Colors.black54)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _durasiLeinzSt = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget durasiOriental({bool isHorizontal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 10.r : 5.r,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isHorizontal
                ? MediaQuery.of(context).size.width / 3.5
                : MediaQuery.of(context).size.width / 3.2,
            child: Text(
              'Durasi : ',
              style: TextStyle(
                fontSize: isHorizontal ? 18.h : 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.r),
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: DropdownButton(
                underline: SizedBox(),
                isExpanded: true,
                value: _durasiOriental,
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 14.sp,
                  fontFamily: 'Segoe Ui',
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  '7 HARI',
                  '14 HARI',
                  '30 HARI',
                  '45 HARI',
                ].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e, style: TextStyle(color: Colors.black54)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _durasiOriental = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget durasiOrientalSt({bool isHorizontal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 10.r : 5.r,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isHorizontal
                ? MediaQuery.of(context).size.width / 3.5
                : MediaQuery.of(context).size.width / 3.2,
            child: Text(
              'Durasi : ',
              style: TextStyle(
                fontSize: isHorizontal ? 18.h : 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.r),
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: DropdownButton(
                underline: SizedBox(),
                isExpanded: true,
                value: _durasiOrientalSt,
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 14.sp,
                  fontFamily: 'Segoe Ui',
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  '7 HARI',
                  '14 HARI',
                  '30 HARI',
                  '45 HARI',
                ].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e, style: TextStyle(color: Colors.black54)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _durasiOrientalSt = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget selectParent({bool isHorizontal = false}) {
  //   return StatefulBuilder(builder: (context, setState) {
  //     return AlertDialog(
  //       scrollable: true,
  //       title: Text('Pilih Optik Parent'),
  //       content: Container(
  //         height: MediaQuery.of(context).size.height / 1.5,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             Container(
  //               width: 350.w,
  //               padding: EdgeInsets.symmetric(
  //                 horizontal: 5.r,
  //                 vertical: 10.r,
  //               ),
  //               color: Colors.white,
  //               height: 80.h,
  //               child: TextField(
  //                 textInputAction: TextInputAction.search,
  //                 autocorrect: true,
  //                 decoration: InputDecoration(
  //                   hintText: 'Pencarian data ...',
  //                   prefixIcon: Icon(Icons.search),
  //                   hintStyle: TextStyle(color: Colors.grey),
  //                   filled: true,
  //                   fillColor: Colors.white70,
  //                   contentPadding: EdgeInsets.symmetric(vertical: 3.r),
  //                   enabledBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
  //                     borderSide: BorderSide(color: Colors.grey, width: 2.r),
  //                   ),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.all(Radius.circular(10.0.r)),
  //                     borderSide: BorderSide(color: Colors.blue, width: 2.r),
  //                   ),
  //                 ),
  //                 onSubmitted: (value) {
  //                   setState(() {
  //                     search = value;
  //                   });
  //                 },
  //               ),
  //             ),
  //             Expanded(
  //               child: SizedBox(
  //                 height: 100.h,
  //                 child: FutureBuilder(
  //                     future: search.isNotEmpty
  //                         ? getSearchParent(search)
  //                         : getSearchParent(''),
  //                     builder: (BuildContext context,
  //                         AsyncSnapshot<List<StbCustomer>> snapshot) {
  //                       switch (snapshot.connectionState) {
  //                         case ConnectionState.waiting:
  //                           return Center(child: CircularProgressIndicator());
  //                         default:
  //                           return snapshot.hasData
  //                               ? listParentWidget(itemStbCust)
  //                               : Center(
  //                                   child: Text('Data tidak ditemukan'),
  //                                 );
  //                       }
  //                     }),
  //               ),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.symmetric(
  //                 horizontal: 20.r,
  //                 vertical: 5.r,
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       primary: Colors.red.shade700,
  //                     ),
  //                     onPressed: () {
  //                       setState(() {
  //                         _listFutureTmp.where((element) => element.flag == "CHILD" ? !element.ischecked : element.ischecked);
  //                       });

  //                       this._isChildContract = false;
  //                       itemStbCust.clear();
  //                       itemActiveContract.clear();
  //                       Navigator.pop(context);
  //                     },
  //                     child: Text("Batal"),
  //                   ),
  //                   ElevatedButton(
  //                     onPressed: () => handleContractActive(
  //                       isHorizontal: isHorizontal,
  //                       context: context,
  //                     ),
  //                     style: ElevatedButton.styleFrom(
  //                       primary: Colors.blue,
  //                     ),
  //                     child: Text("Pilih"),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   });
  // }

  Widget selectParent({bool isHorizontal = false}) {
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
                      builder: (BuildContext context,
                          AsyncSnapshot<List<StbCustomer>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            return snapshot.hasData
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

  Widget customProduct({bool isHor = false}) {
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

  Widget tipeKontrakWidget(
    List<TipeKontrak> item, {
    bool isHorizontal = false,
  }) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        child: ListView.builder(
            itemCount: item.length,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isHorizontal ? 10.r : 8.r,
                        vertical: isHorizontal ? 5.r : 2.r,
                      ),
                      child: Text(
                        item[index].deskripsi!,
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isHorizontal ? 10.r : 8.r,
                      vertical: isHorizontal ? 5.r : 2.r,
                    ),
                    child: Checkbox(
                      value: item[index].ischecked,
                      onChanged: (bool? value) {
                        setState(
                          () {
                            item[index].ischecked = value!;
                            handleTipeKontrak(
                              item[index],
                              isHorizontal: isHorizontal,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
      );
    });
  }

  void handleTipeKontrak(TipeKontrak item, {bool isHorizontal = false}) {
    if (item.flag == "CHILD") {
      formDisc.clear();
      formProduct.clear();
      tmpDiv.clear();
      tmpProduct.clear();
      itemActiveContract.clear();
      this._isContractActive = false;
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return selectParent(
              isHorizontal: isHorizontal,
            );
          }).then((_) => setState(() {}));
    } else if (item.flag == "CASHBACK") {
      if (item.ischecked) {
        setState(() {
          print('Remove : ${item.ischecked}');
          _listFutureTmp.removeWhere((element) => element.flag != "CASHBACK");
        });
      } else {
        setState(() {
          print('Restore : ${item.ischecked}');
          _listFutureTmp = _listFuture;
        });
      }
    }
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
                onChanged: (bool? val) {
                  setState(() {
                    item[index].ischecked = val!;
                  });
                },
              );
            },
          ));
    });
  }

  Widget listParentWidget(List<StbCustomer> item) {
    return StatefulBuilder(builder: (context, setState) {
      return _isEmpty
          ? Center(
              child: Text("Masukkan pencarian lain"),
            )
          : Container(
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
                    onChanged: (bool? val) {
                      setState(() {
                        item[index].ischecked = val!;
                        item[index].ischecked
                            ? getActiveContract(item[index].customerBillNumber)
                            : print('Disable');
                      });
                    },
                  );
                },
              ));
    });
  }

  // Widget areaFrameContract({bool isHorizontal = false}) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       SizedBox(
  //         height: 10.h,
  //       ),
  //       Container(
  //         padding: EdgeInsets.symmetric(
  //           vertical: isHorizontal ? 18.r : 8.r,
  //         ),
  //         child: Text(
  //           'Tipe Kontrak : ',
  //           style: TextStyle(
  //             fontSize: isHorizontal ? 19.sp : 15.sp,
  //             fontFamily: 'Montserrat',
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ),
  //       SizedBox(
  //         height: 290.h,
  //         child: tipeKontrakWidget(
  //           _listFutureTmp,
  //           isHorizontal: isHorizontal,
  //         ),
  //       ),
  //       // SizedBox(
  //       //   height: 290.h,
  //       //   child: FutureBuilder(
  //       //       future: _listFutureTmp,
  //       //       builder: (BuildContext context,
  //       //           AsyncSnapshot<List<TipeKontrak>> snapshot) {
  //       //         switch (snapshot.connectionState) {
  //       //           case ConnectionState.waiting:
  //       //             return Center(child: CircularProgressIndicator());
  //       //           default:
  //       //             return snapshot.data != null
  //       //                 ? tipeKontrakWidget(
  //       //                     snapshot.data!,
  //       //                     isHorizontal: isHorizontal,
  //       //                   )
  //       //                 : Center(
  //       //                     child: Text('Data tidak ditemukan'),
  //       //                   );
  //       //         }
  //       //       }),
  //       // ),
  //     ],
  //   );
  // }

  Widget areaFrameContract({bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.h,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: isHorizontal ? 18.r : 8.r,
          ),
          child: Text(
            'Tipe Kontrak : ',
            style: TextStyle(
                fontSize: isHorizontal ? 19.sp : 15.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600),
          ),
        ),
        !_isChildContract
            ? !_isCashbackContrack
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isHorizontal ? 10.r : 8.r,
                                vertical: isHorizontal ? 5.r : 2.r,
                              ),
                              child: Text(
                                'Kontrak Frame (Sesuai SP)',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 18.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isHorizontal ? 10.r : 8.r,
                              vertical: isHorizontal ? 5.r : 2.r,
                            ),
                            child: Checkbox(
                              value: this._isFrameContract,
                              onChanged: (bool? value) {
                                setState(
                                  () {
                                    this._isFrameContract = value!;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isHorizontal ? 10.r : 8.r,
                                vertical: isHorizontal ? 5.r : 2.r,
                              ),
                              child: Text(
                                'Kontrak Partai (Sesuai SP)',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 18.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isHorizontal ? 10.r : 8.r,
                              vertical: isHorizontal ? 5.r : 2.r,
                            ),
                            child: Checkbox(
                              value: this._isPartaiContract,
                              onChanged: (bool? value) {
                                setState(
                                  () {
                                    this._isPartaiContract = value!;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isHorizontal ? 10.r : 8.r,
                                vertical: isHorizontal ? 5.r : 2.r,
                              ),
                              child: Text(
                                'Kontrak Khusus Leinz Prestige (Japan) - Beli 3 Gratis 1',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 18.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isHorizontal ? 10.r : 8.r,
                              vertical: isHorizontal ? 5.r : 2.r,
                            ),
                            child: Checkbox(
                              value: this._isPrestigeContract,
                              onChanged: (bool? value) {
                                setState(
                                  () {
                                    this._isPrestigeContract = value!;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isHorizontal ? 10.r : 8.r,
                                vertical: isHorizontal ? 5.r : 2.r,
                              ),
                              child: Text(
                                'Kontrak Cashback (Dengan Diskon)',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 18.sp : 14.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isHorizontal ? 10.r : 8.r,
                              vertical: isHorizontal ? 5.r : 2.r,
                            ),
                            child: Checkbox(
                              value: this._isCashbackWithDiscContract,
                              onChanged: (bool? value) {
                                setState(
                                  () {
                                    this._isCashbackWithDiscContract = value!;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : SizedBox(
                    height: 5.w,
                  )
            : SizedBox(
                height: 5.w,
              ),
        !_isChildContract
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isHorizontal ? 10.r : 8.r,
                        vertical: isHorizontal ? 5.r : 2.r,
                      ),
                      child: Text(
                        'Kontrak Cashback (Tanpa Diskon)',
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isHorizontal ? 10.r : 8.r,
                      vertical: isHorizontal ? 5.r : 2.r,
                    ),
                    child: Checkbox(
                      value: this._isCashbackContrack,
                      onChanged: (bool? value) {
                        setState(() {
                          this._isCashbackContrack = value!;
                          formDisc.clear();
                          formProduct.clear();
                          tmpDiv.clear();
                          tmpProduct.clear();
                          itemActiveContract.clear();
                        });
                      },
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: 5.w,
              ),
        !_isCashbackContrack
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isHorizontal ? 10.r : 8.r,
                        vertical: isHorizontal ? 5.r : 2.r,
                      ),
                      child: Text(
                        'Kontrak Sebagai Child',
                        style: TextStyle(
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isHorizontal ? 10.r : 8.r,
                      vertical: isHorizontal ? 5.r : 2.r,
                    ),
                    child: Checkbox(
                      value: this._isChildContract,
                      onChanged: (bool? value) {
                        setState(() {
                          this._isChildContract = value!;
                          formDisc.clear();
                          formProduct.clear();
                          tmpDiv.clear();
                          tmpProduct.clear();
                          itemActiveContract.clear();
                          this._isContractActive = false;
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
                    ),
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

  Widget areaMultiFormDiv({bool isHorizontal = false}) {
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
                // horizontal: isHorizontal ? 10.r : 5.r,
                vertical: isHorizontal ? 18.r : 8.r,
              ),
              child: Text(
                'Kontrak Diskon Divisi : ',
                style: TextStyle(
                    fontSize: isHorizontal ? 19.sp : 15.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 15.r : 20.r,
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
                        maxHeight: isHorizontal ? 40.r : 30.r,
                        maxWidth: isHorizontal ? 40.r : 30.r,
                      ),
                      icon: const Icon(Icons.add),
                      iconSize: isHorizontal ? 20.r : 15.r,
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
                  left: isHorizontal ? 5.r : 5.r,
                  top: 2.r,
                  bottom: 2.r,
                ),
                child: Text(
                  'Produk',
                  style: TextStyle(
                    fontSize: isHorizontal ? 18.sp : 14.sp,
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
                'Tandai',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 14.sp,
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
                    fontSize: isHorizontal ? 18.sp : 14.sp,
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
          height: isHorizontal ? 160.h : 150.h,
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

  Widget areaMultiFormProduct({bool isHorizontal = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                // horizontal: isHorizontal ? 10.r : 5.r,
                vertical: isHorizontal ? 18.r : 8.r,
              ),
              child: Text(
                'Kontrak Diskon Khusus : ',
                style: TextStyle(
                    fontSize: isHorizontal ? 18.sp : 15.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 15.r : 20.r,
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
                        maxHeight: isHorizontal ? 40.r : 30.r,
                        maxWidth: isHorizontal ? 40.r : 30.r,
                      ),
                      icon: const Icon(Icons.add),
                      iconSize: isHorizontal ? 20.r : 15.r,
                      color: Colors.white,
                      onPressed: () {
                        // _isNetworkConnected
                        // ?
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return customProduct(isHor: isHorizontal);
                            });
                        // : handleConnection(context);
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
                  left: isHorizontal ? 5.r : 5.r,
                  top: 2.r,
                  bottom: 2.r,
                ),
                child: Text(
                  'Produk',
                  style: TextStyle(
                    fontSize: isHorizontal ? 18.sp : 14.sp,
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
                'Tandai',
                style: TextStyle(
                  fontSize: isHorizontal ? 18.sp : 14.sp,
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
                    fontSize: isHorizontal ? 18.sp : 14.sp,
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
          height: isHorizontal ? 160.h : 150.h,
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
