import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/cashback/cashback_form.dart';
import 'package:sample/src/app/pages/econtract/form_disc.dart';
import 'package:sample/src/app/pages/econtract/form_product.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/domain/entities/actcontract.dart';
import 'package:sample/src/domain/entities/cashback_rekening.dart';
import 'package:sample/src/domain/entities/cashback_resheader.dart';
import 'package:sample/src/domain/entities/contract.dart';
// import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/customer_noimage.dart';
import 'package:sample/src/domain/entities/discount.dart';
import 'package:sample/src/domain/entities/oldcustomer.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:sample/src/domain/entities/product.dart';
import 'package:sample/src/domain/entities/stbcustomer.dart';
import 'package:sample/src/domain/service/service_cashback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:signature/signature.dart';

// ignore: must_be_immutable
class ChangeContract extends StatefulWidget {
  final OldCustomer? oldCustomer;
  final CustomerNoImage? customer;
  final List<Contract> actContract;
  dynamic keyword;
  bool? isNewCust = false;

  ChangeContract(
    this.actContract, {
    this.oldCustomer,
    this.customer,
    this.keyword,
    this.isNewCust,
  });

  @override
  State<ChangeContract> createState() => _ChangeContractState();
}

class _ChangeContractState extends State<ChangeContract> {
  final globalKey = GlobalKey();
  ServiceCashback serviceCashback = new ServiceCashback();
  CashbackResHeader? otherHeader;
  List<FormItemDisc> formDisc = List.empty(growable: true);
  List<FormItemDisc> defaultDisc = List.empty(growable: true);
  List<FormItemDisc> fixedDisc = List.empty(growable: true);
  List<FormItemProduct> formProduct = List.empty(growable: true);
  List<FormItemProduct> fixedProduct = List.empty(growable: true);
  List<String> tmpDiv = List.empty(growable: true);
  List<String> tmpDivInput = List.empty(growable: true);
  List<String> tmpProduct = List.empty(growable: true);
  late List<Proddiv> itemProdDiv;
  List<ActContract> itemActiveContract = List.empty(growable: true);
  List<StbCustomer> itemStbCust = List.empty(growable: true);
  List<CashbackRekening> listRekening = List.empty(growable: true);
  late List<Product> itemProduct;
  List<Proddiv> listTargetProddiv = List.empty(growable: true);
  List<Proddiv> listProductProddiv = List.empty(growable: true);
  List<Product> listProductKhusus = List.empty(growable: true);
  Map<String, String> selectMapProddiv = {"": ""};
  Map<String, String> selectMapProduct = {"": ""};
  String search = '';
  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';
  String? ttdKedua = '';
  String? token = '';
  String? tokenSm = '';
  String? idSm = '';
  String? idCustomer, jabatanKedua, ttdPertama, attachmentSign, attachmentOther;
  // String? _chosenNikon,
  //     _durasiNikon,
  //     _chosenNikonSt,
  //     _durasiNikonSt,
  //     _chosenOriental,
  //     _durasiOriental,
  //    _chosenMoe,
  //     _durasiMoe
  String? _chosenLeinz,
      _durasiLeinz,
      _chosenLeinzSt,
      _durasiLeinzSt,
      _chosenOrientalSt,
      _durasiOrientalSt;
  final format = DateFormat("yyyy-MM-dd");
  // TextEditingController textValNikon = new TextEditingController();
  TextEditingController textValLeinz = new TextEditingController();
  TextEditingController textValLeinzSt = new TextEditingController();
  // TextEditingController textValOriental = new TextEditingController();'
  TextEditingController textValOrientalSt = new TextEditingController();
  // TextEditingController textValMoe = new TextEditingController();
  TextEditingController textTanggalSt = new TextEditingController();
  TextEditingController textTanggalEd = new TextEditingController();
  TextEditingController textCatatan = new TextEditingController();
  TextEditingController textOngkir = new TextEditingController();
  var _now = new DateTime.now();
  var _formatter = new DateFormat('yyyy-MM-dd');
  // bool _isValNikon = false;
  bool _isValLeinz = false;
  bool _isValOriental = false;
  bool _isValMoe = false;
  bool _isConnected = false;
  bool _isFrameContract = false;
  bool _isPartaiContract = false;
  bool _isOngkirContract = false;
  bool _isFixedOngkir = false;
  bool _isFacetContract = false;
  bool _isPrestigeContract = false;
  bool _isCashbackWithDiscContract = false;
  bool _isChildContract = false;
  bool _isCashbackContrack = false;
  bool _isContractActive = false;
  bool isCashbackExpired = true;
  var thisYear, nextYear;
  int formLen = 0;

  final SignatureController _signController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  callback(newVal) {
    setState(() {
      formLen = newVal;
    });
  }

  setRegularDisc() {
    List<Proddiv> regProddiv = [
      Proddiv("ALL LEINZ RX", "TRLX", "10"),
      //Proddiv("ALL NIKON RX", "TRNX", "10"),
      // Proddiv("ALL ORIENTAL RX", "TRTX", "10"),
      // Proddiv("ALL MOE STOCK", "TRML", "15"),
      //Proddiv("ALL NIKON STOCK", "TRNL", "15"),
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
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");

      var formatter = new DateFormat('yyyy');
      thisYear = formatter.format(DateTime.now());
      nextYear = int.parse(thisYear) + 1;
      setRegularDisc();

      print('This Year : $thisYear');
      print('Next Year : $nextYear');

      print("Dashboard : $role");
      idCustomer = widget.isNewCust!
          ? widget.customer!.id
          : widget.oldCustomer!.customerShipNumber;

      getRekening();
    });
  }

  getTtdSales(int input) async {
    var url = '$API_URL/users?id=$input';

    if (_isConnected) {
      var response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          ttdPertama = data['data']['ttd'];
          token = data['data']['gentoken'];
          int areaId = data['data']['area'] != null
              ? int.parse(data['data']['area'])
              : 29;
          getTokenSM(areaId);
          print(ttdPertama);
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
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

  void getRekening() {
    serviceCashback
        .getRekening(
          context,
          isMounted: mounted,
          noAccount: widget.isNewCust!
              ? widget.customer?.noAccount ?? ''
              : widget.oldCustomer?.customerShipNumber ?? '',
        )
        .then((value) => listRekening.addAll(value));
  }

  Future<List<Discount>> getDiscountData(dynamic idCust,
      {bool isHorizontal = false}) async {
    List<Discount> list = List.empty(growable: true);
    const timeout = 15;
    var url = '$API_URL/discount/getByIdCustomer?id_customer=$idCust';

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
          list = rest.map<Discount>((json) => Discount.fromJson(json)).toList();
          print("List Size: ${list.length}");
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
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

  Future<List<StbCustomer>> getSearchParent(String input) async {
    List<StbCustomer> list = List.empty(growable: true);
    const timeout = 15;
    var url = '$API_URL/customers/oldCustIsActive?bill_name=$input';

    print("Change contract :  $url");

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
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

  @override
  void initState() {
    super.initState();
    getRole();
    getItemProdDiv();
    _signController.addListener(() => print('Value changed'));

    serviceCashback
        .getCashbackHeader(
      mounted,
      context,
      shipNumber: widget.isNewCust!
          ? widget.customer!.noAccount.isNotEmpty
              ? widget.customer?.noAccount ?? ''
              : widget.customer?.id ?? ''
          : widget.oldCustomer?.customerShipNumber ?? '',
      limit: 1,
    )
        .then((value) {
      otherHeader = value;

      if (value.status) {
        getTargetProddiv(value.cashback[0].targetProduct!);
        getProductLine(value.cashback[0].id!);
        getAttachment(value.cashback[0].id!);
      }

      setState(() {
        if (value.status) {
          isCashbackExpired = getActiveCashback(value.cashback[0].endPeriode);
        }
      });
    });

    if (widget.actContract.length > 0) {
      widget.actContract[0].isFrame == "1"
          ? _isFrameContract = true
          : _isFrameContract = false;
      widget.actContract[0].isPartai == "1"
          ? _isPartaiContract = true
          : _isPartaiContract = false;
      widget.actContract[0].isOngkir == "1"
          ? _isOngkirContract = true
          : widget.actContract[0].isOngkir == "2"
              ? _isFixedOngkir = true
              : _isOngkirContract = false;
      textOngkir.value = TextEditingValue(
        text: convertThousand(int.parse(widget.actContract[0].ongkir), 0),
      );
      widget.actContract[0].isFacet == "1"
          ? _isFacetContract = true
          : _isFacetContract = false;
      widget.actContract[0].catatan.contains(
              "KONTRAK KHUSUS LEINZ PRESTIGE (JAPAN) - BELI 3 GRATIS 1")
          ? _isPrestigeContract = true
          : _isPrestigeContract = false;
    }
  }

  void getTargetProddiv(String proddiv) {
    listTargetProddiv.clear();
    serviceCashback
        .getProddivCashbackCustom(context,
            isMounted: mounted, inputProddiv: proddiv)
        .then((value) {
      listTargetProddiv.addAll(value);
    });
  }

  void getProductLine(String cashbackId) {
    listProductProddiv.clear();
    listProductKhusus.clear();

    serviceCashback
        .getCashbackLine(context, isMounted: mounted, cashbackId: cashbackId)
        .then((value) {
      value.forEach((element) {
        if (element.categoryId!.isEmpty) {
          listProductProddiv.add(Proddiv(
            element.prodCatDescription ?? '',
            element.prodDiv ?? '',
            element.cashback ?? '',
          ));
        } else {
          listProductKhusus.add(Product(
            element.categoryId ?? '',
            element.prodDiv ?? '',
            element.prodCat ?? '',
            element.prodCatDescription ?? '',
            element.cashback ?? '',
            element.status ?? '',
          ));
        }
      });
    });
  }

  void getAttachment(String cashbackId) {
    serviceCashback
        .getAttachment(context, isMounted: mounted, idCashback: cashbackId)
        .then((value) {
      attachmentSign = value.attachmentSign ?? '';
      attachmentOther = value.attachmentOther ?? '';
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      serviceCashback
          .getCashbackHeader(
        mounted,
        context,
        shipNumber: widget.isNewCust!
            ? widget.customer!.noAccount.isNotEmpty
                ? widget.customer?.noAccount ?? ''
                : widget.customer?.id ?? ''
            : widget.oldCustomer?.customerShipNumber ?? '',
        limit: 1,
      )
          .then((value) {
        otherHeader = value;

        if (value.status) {
          getTargetProddiv(value.cashback[0].targetProduct!);
          getProductLine(value.cashback[0].id!);
          getAttachment(value.cashback[0].id!);
        }

        setState(() {
          if (value.status) {
            isCashbackExpired = getActiveCashback(value.cashback[0].endPeriode);
          }
        });
      });
    });
  }

  void handleCashback() {
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      if (isCashbackExpired) {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => CashbackForm(
                  isUpdateForm: false,
                  listRekening: listRekening,
                  listTargetProddiv: [],
                  listProductProddiv: [],
                  listProductKhusus: [],
                  constructOpticName: widget.isNewCust!
                      ? widget.customer?.namaUsaha ?? ''
                      : widget.oldCustomer?.customerShipName ?? '',
                  constructOpticAddress: widget.isNewCust!
                      ? widget.customer?.alamatUsaha ?? ''
                      : widget.oldCustomer?.address2 ?? '',
                  constructShipNumber: widget.isNewCust!
                      ? widget.customer!.noAccount.isNotEmpty
                          ? widget.customer?.noAccount ?? ''
                          : widget.customer?.id ?? ''
                      : widget.oldCustomer?.customerShipNumber ?? '',
                  constructBillNumber: widget.isNewCust!
                      ? widget.customer?.noAccount ?? ''
                      : widget.oldCustomer?.customerBillNumber ?? '',
                  constructTypeAccount: widget.isNewCust! ? 'NEW' : 'OLD',
                  constructOwnerName: widget.isNewCust!
                      ? widget.customer?.nama ?? ''
                      : widget.oldCustomer?.contactPerson ?? '',
                  constructOwnerNik: widget.isNewCust!
                      ? widget.customer?.noIdentitas ?? ''
                      : '',
                  constructOwnerNpwp:
                      widget.isNewCust! ? widget.customer?.noNpwp ?? '' : '',
                ),
              ),
            )
            .then((value) => setState(() {
                  _refreshData();
                }));
      } else {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => CashbackForm(
                  isUpdateForm: true,
                  listRekening: listRekening,
                  listTargetProddiv: listTargetProddiv,
                  listProductProddiv: listProductProddiv,
                  listProductKhusus: listProductKhusus,
                  constructIdCashback: otherHeader!.cashback[0].id ?? '',
                  constructOpticName: widget.isNewCust!
                      ? widget.customer?.namaUsaha ?? ''
                      : widget.oldCustomer?.customerShipName ?? '',
                  constructOpticAddress: widget.isNewCust!
                      ? widget.customer?.alamatUsaha ?? ''
                      : widget.oldCustomer?.address2 ?? '',
                  constructShipNumber: widget.isNewCust!
                      ? widget.customer!.noAccount.isNotEmpty
                          ? widget.customer?.noAccount ?? ''
                          : widget.customer?.id ?? ''
                      : widget.oldCustomer?.customerShipNumber ?? '',
                  constructBillNumber: widget.isNewCust!
                      ? widget.customer?.noAccount ?? ''
                      : widget.oldCustomer?.customerBillNumber ?? '',
                  constructTypeAccount: widget.isNewCust! ? 'NEW' : 'OLD',
                  constructOwnerName: widget.isNewCust!
                      ? widget.customer?.nama ?? ''
                      : widget.oldCustomer?.contactPerson ?? '',
                  constructOwnerNik: widget.isNewCust!
                      ? widget.customer?.noIdentitas ?? ''
                      : otherHeader?.cashback[0].dataNik ?? '',
                  constructOwnerNpwp: widget.isNewCust!
                      ? widget.customer?.noNpwp ?? ''
                      : otherHeader?.cashback[0].dataNpwp ?? '',
                  constructIdCashbackRekening:
                      otherHeader!.cashback[0].idCashbackRekening!,
                  constructStartDate: otherHeader!.cashback[0].startPeriode!,
                  constructEndDate: otherHeader!.cashback[0].endPeriode!,
                  constructWithdrawProcess:
                      otherHeader!.cashback[0].withdrawProcess!,
                  constructWithdrawDuration:
                      otherHeader!.cashback[0].withdrawDuration!,
                  constructPaymentDuration:
                      otherHeader!.cashback[0].paymentDuration!,
                  constructTypeCashback: otherHeader!.cashback[0].cashbackType!,
                  constructTargetValue:
                      int.parse(otherHeader!.cashback[0].targetValue!),
                  constructCashbackValue:
                      int.parse(otherHeader!.cashback[0].cashbackValue!),
                  constructCashbackPercent: double.parse(
                      otherHeader!.cashback[0].cashbackPercentage!),
                  constructTargetProduct:
                      otherHeader!.cashback[0].targetProduct!,
                  constructAttachmentSign: attachmentSign ?? '',
                  constructAttachmentOther: attachmentOther ?? '',
                ),
              ),
            )
            .then((value) => setState(() {
                  _refreshData();
                }));
      }
    });
  }

  bool getActiveCashback(String? endPeriode) {
    bool output = true;
    DateTime nowDate = DateTime.now();
    DateTime endDate = DateTime.parse(endPeriode!);
    Duration duration = nowDate.difference(endDate);

    if (duration.inDays <= 0) {
      print('Tanggal masih aktif');
      output = false;
    } else {
      print('Tanggal kadaluarsa');
      output = true;
    }

    return output;
  }

  getItemProdDiv() async {
    // const timeout = 15;
    var url = '$API_URL/product/getProDiv';

    try {
      var response = await http.get(Uri.parse(url));
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
        getTtdSales(int.parse(id!));
      } on FormatException catch (e) {
        print('Format Error : $e');
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
      _isConnected = false;
    }
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

          for (int j = 0; j < itemProduct.length; j++) {
            for (int i = 0; i < tmpProduct.length; i++) {
              if (itemProduct[j].proddesc == tmpProduct[i]) {
                itemProduct[j].ischecked = true;
              }
            }
          }
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

    print('Change Active contract : $url');

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
            idCustomer!,
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
            idCustomer!,
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

    //Send to me
    pushNotif(
      4,
      3,
      idUser: id,
      rcptToken: token,
      opticName: widget.isNewCust!
          ? widget.customer!.namaUsaha
          : widget.oldCustomer!.customerShipName,
    );

    //Send to Sales Manager
    pushNotif(
      1,
      3,
      salesName: name,
      idUser: idSm,
      rcptToken: tokenSm,
      opticName: widget.isNewCust!
          ? widget.customer!.namaUsaha
          : widget.oldCustomer!.customerShipName,
    );

    widget.isNewCust!
        ? print('opticName : ${widget.customer!.namaUsaha}')
        : print('opticName : ${widget.oldCustomer!.customerShipName}');
  }

  postMultiDiv(String idCust, String proddiv, String diskon, String alias,
      {bool isHorizontal = false}) async {
    var url = '$API_URL/discount/divCustomDiscount';
    var response = await http.post(
      Uri.parse(url),
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

  postMultiItem(String idCust, String categoryId, String prodDiv,
      String prodCat, String prodDesc, String disc,
      {bool isHorizontal = false}) async {
    var url = '$API_URL/discount/customDiscount';
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

  checkInput(Function stop, {bool isHorizontal = false}) async {
    fixedDisc.clear();
    fixedProduct.clear();
    tmpDivInput.clear();
    tmpProduct.clear();

    // var outNikon,
    //     outNikonSt,
    //     outOriental,
    //     outMoe,
    var outLeinz, outLeinzSt, outOrientalSt, startContract;
    // var valNikon,
    //     valOriental,
    //     valMoe
    var valLeinz, valLeinzSt, valOrientalSt;

    startContract = _formatter.format(_now);

    // if (_chosenNikon == null) {
    //   outNikon = '-';
    // } else if (_chosenNikon == "KREDIT") {
    //   outNikon = "$_chosenNikon - $_durasiNikon";
    // } else {
    //   outNikon = _chosenNikon;
    // }

    // if (_chosenNikonSt == null) {
    //   outNikonSt = '-';
    // } else if (_chosenNikonSt == "KREDIT") {
    //   outNikonSt = "$_chosenNikonSt - $_durasiNikonSt";
    // } else {
    //   outNikonSt = _chosenNikonSt;
    // }

    if (_chosenLeinz == null) {
      outLeinz = '-';
    } else if (_chosenLeinz == "KREDIT") {
      outLeinz = "$_chosenLeinz - $_durasiLeinz";
    } else {
      outLeinz = _chosenLeinz;
    }

    if (_chosenLeinzSt == null) {
      outLeinzSt = '-';
    } else if (_chosenLeinzSt == "KREDIT") {
      outLeinzSt = "$_chosenLeinzSt - $_durasiLeinzSt";
    } else {
      outLeinzSt = _chosenLeinzSt;
    }

    // if (_chosenOriental == null) {
    //   outOriental = '-';
    // } else if (_chosenOriental == "KREDIT") {
    //   outOriental = "$_chosenOriental - $_durasiOriental";
    // } else {
    //   outOriental = _chosenOriental;
    // }

    if (_chosenOrientalSt == null) {
      outOrientalSt = '-';
    } else if (_chosenOrientalSt == "KREDIT") {
      outOrientalSt = "$_chosenOrientalSt - $_durasiOrientalSt";
    } else {
      outOrientalSt = _chosenOrientalSt;
    }

    // if (_chosenMoe == null) {
    //   outMoe = '-';
    // } else if (_chosenMoe == "KREDIT") {
    //   outMoe = "$_chosenMoe - $_durasiMoe";
    // } else {
    //   outMoe = _chosenMoe;
    // }

    // valNikon =
    //     textValNikon.text.length > 0 ? '${textValNikon.text}.000.000' : '0';
    valLeinz =
        textValLeinz.text.length > 0 ? '${textValLeinz.text}.000.000' : '0';
    valLeinzSt =
        textValLeinzSt.text.length > 0 ? '${textValLeinzSt.text}.000.000' : '0';
    // valOriental = textValOriental.text.length > 0
    //     ? '${textValOriental.text}.000.000'
    //     : '0';
    valOrientalSt = textValOrientalSt.text.length > 0
        ? '${textValOrientalSt.text}.000.000'
        : '0';
    // valMoe = textValMoe.text.length > 0 ? '${textValMoe.text}.000.000' : '0';

    print('id_customer: $idCustomer');
    print('nama_pertama : $name');
    print('jabatan_pertama: $role');
    // print('tp_nikon: ${valNikon.replaceAll('.', '')}');
    print('tp_leinz: ${valLeinz.replaceAll('.', '')}');
    print('tp_leinz_st: ${valLeinzSt.replaceAll('.', '')}');
    // print('tp_oriental: ${valOriental.replaceAll('.', '')}');
    print('tp_oriental_st: ${valOrientalSt.replaceAll('.', '')}');
    // print('tp_moe: ${valMoe.replaceAll('.', '')}');
    // print('pembayaran_nikon : $outNikon');
    print('pembayaran_leinz : $outLeinz');
    // print('pembayaran_oriental : $outOriental');
    // print('pembayaran_moe : $outMoe');
    // print('pembayaran_nikon_stock : $outNikonSt');
    print('pembayaran_leinz_stock : $outLeinzSt');
    print('pembayaran_oriental_stock : $outOrientalSt');
    print('start_contract : $startContract');
    print(
        'type_contract : ${_isCashbackContrack ? 'CASHBACK' : _isCashbackWithDiscContract ? 'CASHBACK DENGAN DISKON' : 'LENSA'}');
    print('is_frame : ${_isFrameContract ? '1' : '0'}');
    print('is_partai : ${_isPartaiContract ? '1' : '0'}');
    print('is_ongkir : ${_isOngkirContract ? '1' : '0'}');
    print('is fixed ongkir : $_isFixedOngkir');
    print('is_facet : ${_isFacetContract ? '1' : '0'}');
    print('ttd_pertama : $ttdPertama');
    print('ttd_kedua : $ttdKedua');
    print(
        'catatan : ${textCatatan.text} ${_isPrestigeContract ? 'Kontrak Khusus Leinz Prestige (Japan) - Beli 3 gratis 1' : ''}');
    print('created_by : $id');
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
        //Ubah kontrak tidak perlu default diskon
        // if (defaultDisc.length > 0) {
        //   defaultDisc.forEach((element) {
        //     element.proddiv!.ischecked = true;
        //   });
        //   fixedDisc.addAll(defaultDisc);
        //   for (int i = 0; i < defaultDisc.length; i++) {
        //     tmpDivInput.add(defaultDisc[i].proddiv!.alias);
        //   }
        // }

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

    if (_signController.isEmpty) {
      handleStatus(
        context,
        'Silahkan isi tanda tangan dahulu',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    } else {
      var data = await _signController.toPngBytes();
      ttdKedua = base64Encode(data!);

      print('id_customer: $idCustomer');
      print('nama_pertama: $name');
      print('jabatan_pertama : $role');
      print(
          'nama_kedua: ${widget.isNewCust! ? widget.customer!.nama : widget.oldCustomer!.contactPerson}');
      print('jabatan_kedua: $jabatanKedua');
      print(
          'alamat_kedua: ${widget.isNewCust! ? widget.customer!.alamatUsaha : widget.oldCustomer!.address2}');
      print(
          'telp_kedua: ${widget.isNewCust! ? widget.customer!.noTlp : widget.oldCustomer!.phone}');
      print('fax_kedua: -');
      // print('tp_nikon: ${valNikon.replaceAll('.', '')}');
      print('tp_leinz: ${valLeinz.replaceAll('.', '')}');
      print('tp_leinz_st: ${valLeinzSt.replaceAll('.', '')}');
      // print('tp_oriental :  ${valOriental.replaceAll('.', '')}');
      print('tp_oriental_st :  ${valOrientalSt.replaceAll('.', '')}');
      // print('tp_moe: ${valMoe.replaceAll('.', '')}');
      // print('pembayaran_nikon: $outNikon');
      print('pembayaran_leinz: $outLeinz');
      // print('pembayaran_oriental: $outOriental');
      // print('pembayaran_moe: $outMoe');
      // print('pembayaran_nikon_stock: $outNikonSt');
      print('pembayaran_leinz_stock: $outLeinzSt');
      print('pembayaran_oriental_stock: $outOrientalSt');
      print('start_contract: $startContract');
      print(
          'type_contract: ${_isCashbackContrack ? 'CASHBACK' : _isCashbackWithDiscContract ? 'CASHBACK DENGAN DISKON' : 'LENSA'}');
      print('is_frame: ${_isFrameContract ? '1' : '0'}');
      print('is_partai: ${_isPartaiContract ? '1' : '0'}');
      print('is_ongkir : ${_isOngkirContract ? '1' : '0'}');
      print('is fixed ongkir : $_isFixedOngkir');
      print('is_facet : ${_isFacetContract ? '1' : '0'}');
      print(
          'catatan: ${textCatatan.text} ${_isPrestigeContract ? 'Kontrak Khusus Leinz Prestige (Japan) - Beli 3 gratis 1' : ''}');
      print('no_account: ');
      print('ttd_pertama: $ttdPertama');
      print('ttd_kedua: $ttdKedua');
      print('created_by: $id');
      print('has_parent: ${_isContractActive ? '1' : '0'}');
      print(
          'id_parent: ${_isContractActive ? itemActiveContract[0].idCustomer : ''}');
      print(
          'id_contract_parent: ${_isContractActive ? itemActiveContract[0].idContract : ''}');

      const timeout = 15;
      var url = '$API_URL/contract';

      try {
        var response = await http.post(
          Uri.parse(url),
          body: {
            'id_customer': idCustomer,
            'nama_pertama': name,
            'jabatan_pertama': role,
            'nama_kedua': widget.isNewCust!
                ? widget.customer!.nama
                : widget.oldCustomer!.contactPerson,
            'jabatan_kedua': jabatanKedua,
            'alamat_kedua': widget.isNewCust!
                ? widget.customer!.alamatUsaha
                : widget.oldCustomer!.address2,
            'telp_kedua': widget.isNewCust!
                ? widget.customer!.noTlp
                : widget.oldCustomer!.phone,
            'fax_kedua': '-',
            // 'tp_nikon': valNikon.replaceAll('.', ''),
            'tp_leinz': valLeinz.replaceAll('.', ''),
            'tp_leinz_stock': valLeinzSt.replaceAll('.', ''),
            // 'tp_oriental': valOriental.replaceAll('.', ''),
            'tp_oriental_stock': valOrientalSt.replaceAll('.', ''),
            // 'tp_moe': valMoe.replaceAll('.', ''),
            // 'pembayaran_nikon': outNikon,
            'pembayaran_leinz': outLeinz,
            // 'pembayaran_oriental': outOriental,
            // 'pembayaran_moe': outMoe,
            // 'pembayaran_nikon_stock': outNikonSt,
            'pembayaran_leinz_stock': outLeinzSt,
            'pembayaran_oriental_stock': outOrientalSt,
            'start_contract': startContract,
            'type_contract': _isCashbackContrack
                ? 'CASHBACK'
                : _isCashbackWithDiscContract
                    ? 'CASHBACK DENGAN DISKON'
                    : 'LENSA',
            'is_frame': _isFrameContract ? '1' : '0',
            'is_partai': _isPartaiContract ? '1' : '0',
            'is_ongkir': _isOngkirContract
                ? '1'
                : _isFixedOngkir
                    ? '2'
                    : '0',
            'ongkir': _isFixedOngkir ? textOngkir.text.replaceAll('.', '') : '',
            'is_facet': _isFacetContract ? '1' : '0',
            'catatan':
                "${textCatatan.text} ${_isPrestigeContract ? 'Kontrak Khusus Leinz Prestige (Japan) - Beli 3 gratis 1' : ''}",
            'no_account': itemActiveContract.length < 1
                ? idCustomer
                : itemActiveContract[0].noAccount,
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

        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];
        print(msg);

        if (!sts) {
          handleStatus(
            context,
            msg,
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }

        try {
          if (sts) {
            textValLeinz.clear();
            textValLeinzSt.clear();
            // textValMoe.clear();
            // textValNikon.clear();
            // textValOriental.clear();
            textValOrientalSt.clear();

            if (_isContractActive) {
              print('Ini child');
            } else if (_isCashbackContrack) {
              print('Ini Cashback');
            } else {
              multipleInputDiskon(
                isHorizontal: isHorizontal,
              );
            }
          }

          if (widget.isNewCust!) {
            handleStatusChangeContract(
              context,
              capitalize(msg),
              true,
              keyword: widget.keyword,
              isHorizontal: isHorizontal,
              isNewCust: widget.isNewCust!,
              customer: widget.customer,
            );
          } else {
            handleStatusChangeContract(
              context,
              capitalize(msg),
              true,
              keyword: widget.keyword,
              isHorizontal: isHorizontal,
              isNewCust: widget.isNewCust!,
              item: widget.oldCustomer!,
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
          handleConnection(context);
        }
      } on Error catch (e) {
        print('General Error : $e');
      }
    }

    stop();
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

  Widget childChangeContract({bool isHorizontal = false}) {
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
                      name!,
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
                      role!,
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
                      widget.isNewCust!
                          ? widget.customer!.nama
                          : widget.oldCustomer!.contactPerson.trim(),
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
                      widget.isNewCust!
                          ? widget.customer!.noTlp
                          : widget.oldCustomer!.phone,
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
                      widget.isNewCust!
                          ? widget.customer!.alamatUsaha
                          : widget.oldCustomer!.address2,
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
                  'Target Pembelian / bulan (satuan juta) : ',
                  style: TextStyle(
                      fontSize: isHorizontal ? 26.sp : 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
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
              //       errorText: _isValNikon ? 'Data wajib diisi' : null,
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(5.r),
              //       ),
              //     ),
              //     inputFormatters: [ThousandsSeparatorInputFormatter()],
              //     controller: textValNikon,
              //     maxLength: 5,
              //     style: TextStyle(
              //       fontSize: isHorizontal ? 24.sp : 14.sp,
              //       fontFamily: 'Segoe Ui',
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: isHorizontal ? 18.h : 8.h,
              // ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
                ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Lensa Leinz RX',
                    labelText: 'Lensa Leinz RX',
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
                  maxLength: 5,
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Segoe Ui',
                  ),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              // Container(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: isHorizontal ? 10.r : 5.r,
              //   ),
              //   child: TextFormField(
              //     keyboardType: TextInputType.number,
              //     decoration: InputDecoration(
              //       hintText: 'Lensa Oriental',
              //       labelText: 'Lensa Oriental',
              //       contentPadding: EdgeInsets.symmetric(
              //         vertical: 3.r,
              //         horizontal: 15.r,
              //       ),
              //       errorText: _isValOriental ? 'Data wajib diisi' : null,
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(5),
              //       ),
              //     ),
              //     inputFormatters: [ThousandsSeparatorInputFormatter()],
              //     controller: textValOriental,
              //     maxLength: 5,
              //     style: TextStyle(
              //       fontSize: isHorizontal ? 24.sp : 14.sp,
              //       fontFamily: 'Segoe Ui',
              //     ),
              //   ),
              // ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
                ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Lensa Leinz Stock',
                    labelText: 'Lensa Leinz Stock',
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
                  controller: textValLeinzSt,
                  maxLength: 5,
                  style: TextStyle(
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontFamily: 'Segoe Ui',
                  ),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 18.h : 8.h,
              ),
              // Container(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: isHorizontal ? 10.r : 5.r,
              //   ),
              //   child: TextFormField(
              //     keyboardType: TextInputType.number,
              //     decoration: InputDecoration(
              //       hintText: 'Lensa Moe',
              //       labelText: 'Lensa Moe',
              //       contentPadding: EdgeInsets.symmetric(
              //         vertical: 3.r,
              //         horizontal: 15.r,
              //       ),
              //       errorText: _isValMoe ? 'Data wajib diisi' : null,
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(5.r),
              //       ),
              //     ),
              //     inputFormatters: [ThousandsSeparatorInputFormatter()],
              //     controller: textValMoe,
              //     maxLength: 5,
              //     style: TextStyle(
              //       fontSize: isHorizontal ? 24.sp : 14.sp,
              //       fontFamily: 'Segoe Ui',
              //     ),
              //   ),
              // ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
                ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Lensa Oriental Stock',
                    labelText: 'Lensa Oriental Stock',
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
                  controller: textValOrientalSt,
                  maxLength: 5,
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
              /* Padding(
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
                        'Lensa Nikon RX : ',
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
              _chosenNikon == "KREDIT"
                  ? durasiNikon(
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
                          ? MediaQuery.of(context).size.width / 5.5
                          : MediaQuery.of(context).size.width / 3.2,
                      child: Text(
                        'Lensa Nikon Stock : ',
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.h : 14.sp,
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
                          value: _chosenNikonSt,
                          style: TextStyle(
                            fontSize: isHorizontal ? 24.sp : 14.sp,
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
                              _chosenNikonSt = value;
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
              _chosenNikonSt == "KREDIT"
                  ? durasiNikonSt(
                      isHorizontal: isHorizontal,
                    )
                  : SizedBox(
                      width: 20.w,
                    ),*/
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
                        'Lensa Leinz RX : ',
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
                          ? MediaQuery.of(context).size.width / 5.5
                          : MediaQuery.of(context).size.width / 3.2,
                      child: Text(
                        'Lensa Leinz Stock : ',
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.h : 14.sp,
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
                            fontSize: isHorizontal ? 24.sp : 14.sp,
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
                              _chosenLeinzSt = value;
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
              // SizedBox(
              //   height: isHorizontal ? 18.h : 8.h,
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: isHorizontal ? 10.r : 5.r,
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Container(
              //         width: isHorizontal
              //             ? MediaQuery.of(context).size.width / 5.5
              //             : MediaQuery.of(context).size.width / 3.2,
              //         child: Text(
              //           'Lensa Oriental RX : ',
              //           style: TextStyle(
              //             fontSize: isHorizontal ? 24.h : 14.sp,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //       ),
              //       Expanded(
              //         child: Container(
              //           decoration: BoxDecoration(
              //               color: Colors.white70,
              //               border: Border.all(color: Colors.black54),
              //               borderRadius: BorderRadius.circular(5.r)),
              //           child: Padding(
              //             padding: EdgeInsets.only(
              //               left: isHorizontal ? 20.r : 10.r,
              //             ),
              //             child: DropdownButton(
              //               underline: SizedBox(),
              //               isExpanded: true,
              //               value: _chosenOriental,
              //               style: TextStyle(
              //                 fontSize: isHorizontal ? 24.sp : 14.sp,
              //                 fontFamily: 'Segoe Ui',
              //                 color: Colors.black54,
              //                 fontWeight: FontWeight.w600,
              //               ),
              //               items: [
              //                 '-',
              //                 'COD',
              //                 'TRANSFER',
              //                 'DEPOSIT',
              //                 'KREDIT',
              //               ].map((e) {
              //                 return DropdownMenuItem(
              //                   value: e,
              //                   child: Text(e,
              //                       style: TextStyle(color: Colors.black54)),
              //                 );
              //               }).toList(),
              //               onChanged: (String? value) {
              //                 setState(() {
              //                   _chosenOriental = value;
              //                 });
              //               },
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(
              //   height: isHorizontal ? 18.h : 10.h,
              // ),
              // _chosenOriental == "KREDIT"
              //     ? durasiOriental(
              //         isHorizontal: isHorizontal,
              //       )
              //     : SizedBox(
              //         width: 20.w,
              //       ),
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
                        'Lensa Oriental Stock : ',
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.h : 14.sp,
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
                            fontSize: isHorizontal ? 24.sp : 14.sp,
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
                              _chosenOrientalSt = value;
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
              // SizedBox(
              //   height: isHorizontal ? 18.h : 8.h,
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: isHorizontal ? 10.r : 5.r,
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: [
              //       Container(
              //         width: isHorizontal
              //             ? MediaQuery.of(context).size.width / 5.5
              //             : MediaQuery.of(context).size.width / 3.2,
              //         child: Text(
              //           'Lensa Moe RX : ',
              //           style: TextStyle(
              //             fontSize: isHorizontal ? 24.h : 14.sp,
              //             fontFamily: 'Montserrat',
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //       ),
              //       Expanded(
              //         child: Container(
              //           decoration: BoxDecoration(
              //               color: Colors.white70,
              //               border: Border.all(color: Colors.black54),
              //               borderRadius: BorderRadius.circular(5.r)),
              //           child: Padding(
              //             padding: EdgeInsets.only(
              //               left: isHorizontal ? 20.r : 10.r,
              //             ),
              //             child: DropdownButton(
              //               underline: SizedBox(),
              //               isExpanded: true,
              //               value: _chosenMoe,
              //               style: TextStyle(
              //                 fontSize: isHorizontal ? 24.sp : 14.sp,
              //                 fontFamily: 'Segoe Ui',
              //                 color: Colors.black54,
              //                 fontWeight: FontWeight.w600,
              //               ),
              //               items: [
              //                 '-',
              //                 'COD',
              //                 'TRANSFER',
              //                 'DEPOSIT',
              //                 'KREDIT',
              //               ].map((e) {
              //                 return DropdownMenuItem(
              //                   value: e,
              //                   child: Text(e,
              //                       style: TextStyle(color: Colors.black54)),
              //                 );
              //               }).toList(),
              //               onChanged: (String? value) {
              //                 setState(() {
              //                   _chosenMoe = value;
              //                 });
              //               },
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(
              //   height: isHorizontal ? 18.h : 8.h,
              // ),
              // _chosenMoe == "KREDIT"
              //     ? durasiMoe(
              //         isHorizontal: isHorizontal,
              //       )
              //     : SizedBox(
              //         width: 20.w,
              //       ),
              SizedBox(
                height: isHorizontal ? 35.h : 20.h,
              ),
              Text(
                'Catatan',
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 12.sp,
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
                  fontSize: isHorizontal ? 24.sp : 14.sp,
                  fontFamily: 'Segoe Ui',
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
              areaSigned(
                isHorizontal: isHorizontal,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      primary: Colors.orange[800],
                      padding: EdgeInsets.symmetric(
                        horizontal: isHorizontal ? 40.r : 20.r,
                        vertical: isHorizontal ? 20.r : 10.r,
                      ),
                    ),
                    child: Text(
                      'Hapus Ttd',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Segoe ui',
                      ),
                    ),
                    onPressed: () {
                      _signController.clear();
                    },
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
                            checkInput(
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
              SizedBox(
                height: 10.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget areaFrameContract({bool isHorizontal = false}) {
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
            ? !_isCashbackContrack
                ? Column(
                    children: [
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
                              onChanged: (bool? value) {
                                setState(() {
                                  this._isFrameContract = value!;
                                });
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
                                horizontal: isHorizontal ? 13.r : 8.r,
                                vertical: isHorizontal ? 5.r : 2.r,
                              ),
                              child: Text(
                                'Kontrak Partai (Sesuai SP)',
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
                      Visibility(
                        visible: !_isFixedOngkir,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isHorizontal ? 10.r : 8.r,
                                  vertical: isHorizontal ? 5.r : 2.r,
                                ),
                                child: Text(
                                  'Kontrak Free Ongkir',
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
                                value: this._isOngkirContract,
                                onChanged: (bool? value) {
                                  setState(
                                    () {
                                      this._isOngkirContract = value!;
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        replacement: SizedBox(
                          width: 5.w,
                        ),
                      ),
                      Visibility(
                        visible: !_isOngkirContract,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isHorizontal ? 10.r : 8.r,
                                  vertical: isHorizontal ? 5.r : 2.r,
                                ),
                                child: Text(
                                  'Kontrak Fixed Ongkir',
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
                                value: this._isFixedOngkir,
                                onChanged: (bool? value) {
                                  setState(
                                    () {
                                      this._isFixedOngkir = value!;
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        replacement: SizedBox(
                          width: 5.w,
                        ),
                      ),
                      Visibility(
                        visible: _isFixedOngkir,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isHorizontal ? 10.r : 5.r,
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Masukkan ongkir',
                              labelText: 'Ongkos kirim (Fixed)',
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 3.r,
                                horizontal: 15.r,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                            ),
                            inputFormatters: [
                              ThousandsSeparatorInputFormatter()
                            ],
                            controller: textOngkir,
                            maxLength: 9,
                            style: TextStyle(
                              fontSize: isHorizontal ? 18.sp : 14.sp,
                              fontFamily: 'Segoe Ui',
                            ),
                          ),
                        ),
                        replacement: SizedBox(
                          width: 5.w,
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
                                'Kontrak Free Facet',
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
                              value: this._isFacetContract,
                              onChanged: (bool? value) {
                                setState(() {
                                  this._isFacetContract = value!;
                                });
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
                                    if (value) {
                                      handleCashback();
                                    }
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
                        horizontal: isHorizontal ? 13.r : 8.r,
                        vertical: isHorizontal ? 5.r : 2.r,
                      ),
                      child: Text(
                        'Kontrak Cashback (Tanpa Diskon)',
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
                      value: this._isCashbackContrack,
                      onChanged: (bool? value) {
                        setState(() {
                          this._isCashbackContrack = value!;
                          formDisc.clear();
                          formProduct.clear();
                          tmpDiv.clear();
                          tmpProduct.clear();
                          itemActiveContract.clear();

                          if (value) {
                            handleCashback();
                          }
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
                      onChanged: (bool? value) {
                        setState(() {
                          this._isChildContract = value!;
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

  Widget areaTarget({bool isHorizontal = false}) {
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
                    'Lensa Leinz RX',
                    style: TextStyle(
                      fontSize: isHorizontal ? 16.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lensa Leinz Stock',
                    style: TextStyle(
                      fontSize: isHorizontal ? 16.sp : 14.sp,
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
                            int.parse(widget.actContract[0].tpLeinz.isNotEmpty
                                ? widget.actContract[0].tpLeinz
                                : "0"),
                            0)
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
                            int.parse(widget.actContract[0].tpLeinzSt.isNotEmpty
                                ? widget.actContract[0].tpLeinzSt
                                : "0"),
                            0)
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
                    'Lensa Oriental Stock',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Expanded(
                //   child: Text(
                //     'Lensa Moe',
                //     style: TextStyle(
                //       fontSize: isHorizontal ? 24.sp : 14.sp,
                //       fontFamily: 'Montserrat',
                //       fontWeight: FontWeight.w500,
                //     ),
                //     textAlign: TextAlign.end,
                //   ),
                // ),
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
                            int.parse(
                                widget.actContract[0].tpOrientalSt.isNotEmpty
                                    ? widget.actContract[0].tpOrientalSt
                                    : "0"),
                            0)
                        : 'Rp 0',
                    style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ),
                // Expanded(
                //   child: Text(
                //     widget.actContract.isNotEmpty
                //         ? convertToIdr(
                //             int.parse(widget.actContract[0].tpMoe), 0)
                //         : 'Rp 0',
                //     style: TextStyle(
                //         fontSize: isHorizontal ? 24.sp : 14.sp,
                //         fontFamily: 'Montserrat',
                //         fontWeight: FontWeight.w600),
                //     textAlign: TextAlign.end,
                //   ),
                // ),
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

  Widget areaJangkaWaktu({bool isHorizontal = false}) {
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
                    'Lensa Leinz RX',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lensa Leinz Stock',
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
                    widget.actContract[0].pembLeinz,
                    style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.actContract[0].pembLeinzSt,
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
          // Padding(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: isHorizontal ? 10.r : 5.r,
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Expanded(
          //         child: Text(
          //           'Lensa Nikon Stock',
          //           style: TextStyle(
          //             fontSize: isHorizontal ? 24.sp : 14.sp,
          //             fontFamily: 'Montserrat',
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ),
          //       Expanded(
          //         child: Text(
          //           'Lensa Leinz Stock',
          //           style: TextStyle(
          //             fontSize: isHorizontal ? 24.sp : 14.sp,
          //             fontFamily: 'Montserrat',
          //             fontWeight: FontWeight.w500,
          //           ),
          //           textAlign: TextAlign.end,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   height: isHorizontal ? 10.h : 5.h,
          // ),
          // Padding(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: isHorizontal ? 10.r : 5.r,
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Expanded(
          //         child: Text(
          //           widget.actContract[0].pembNikonSt,
          //           style: TextStyle(
          //               fontSize: isHorizontal ? 24.sp : 14.sp,
          //               fontFamily: 'Montserrat',
          //               fontWeight: FontWeight.w600),
          //         ),
          //       ),
          //       Expanded(
          //         child: Text(
          //           widget.actContract[0].pembNikonSt,
          //           style: TextStyle(
          //               fontSize: isHorizontal ? 24.sp : 14.sp,
          //               fontFamily: 'Montserrat',
          //               fontWeight: FontWeight.w600),
          //           textAlign: TextAlign.end,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   height: isHorizontal ? 20.h : 10.h,
          // ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 10.r : 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Lensa Oriental Stock',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Expanded(
                //   child: Text(
                //     'Lensa Oriental RX',
                //     style: TextStyle(
                //       fontSize: isHorizontal ? 24.sp : 14.sp,
                //       fontFamily: 'Montserrat',
                //       fontWeight: FontWeight.w500,
                //     ),
                //     textAlign: TextAlign.end,
                //   ),
                // ),
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
                    widget.actContract[0].pembOrientalSt,
                    style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  ),
                ),
                // Expanded(
                //   child: Text(
                //     widget.actContract[0].pembOriental,
                //     style: TextStyle(
                //         fontSize: isHorizontal ? 24.sp : 14.sp,
                //         fontFamily: 'Montserrat',
                //         fontWeight: FontWeight.w600),
                //     textAlign: TextAlign.end,
                //   ),
                // ),
              ],
            ),
          ),
          // SizedBox(
          //   height: isHorizontal ? 20.h : 10.h,
          // ),
          // Padding(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: isHorizontal ? 10.r : 5.r,
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Expanded(
          //         child: Text(
          //           'Lensa Moe Rx',
          //           style: TextStyle(
          //             fontSize: isHorizontal ? 24.sp : 14.sp,
          //             fontFamily: 'Montserrat',
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   height: isHorizontal ? 10.h : 5.h,
          // ),
          // Padding(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: isHorizontal ? 10.r : 5.r,
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Expanded(
          //         child: Text(
          //           widget.actContract[0].pembMoe,
          //           style: TextStyle(
          //               fontSize: isHorizontal ? 24.sp : 14.sp,
          //               fontFamily: 'Montserrat',
          //               fontWeight: FontWeight.w600),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
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

  Widget areaDiskon(Contract item, {bool isHorizontal = false}) {
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
              future: getDiscountData(
                item.idCustomer,
                isHorizontal: isHorizontal,
              ),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Discount>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return snapshot.data != null
                        ? listDiscWidget(
                            snapshot.data!,
                            snapshot.data!.length,
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

  Widget listDiscWidget(List<Discount> item, int len,
      {bool isHorizontal = false}) {
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
                    item[position].prodDesc,
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item[position].discount,
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

  Widget areaMultiFormDiv({bool isHorizontal = false}) {
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

  Widget areaMultiFormProduct({bool isHorizontal = false}) {
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
  //               ? MediaQuery.of(context).size.width / 5.5
  //               : MediaQuery.of(context).size.width / 3.2,
  //           child: Text(
  //             'Durasi : ',
  //             style: TextStyle(
  //               fontSize: isHorizontal ? 24.h : 14.sp,
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
  //                 fontSize: isHorizontal ? 24.sp : 14.sp,
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
  //                   _durasiNikon = value;
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
  //               ? MediaQuery.of(context).size.width / 5.5
  //               : MediaQuery.of(context).size.width / 3.2,
  //           child: Text(
  //             'Durasi : ',
  //             style: TextStyle(
  //               fontSize: isHorizontal ? 24.h : 14.sp,
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
  //                 fontSize: isHorizontal ? 24.sp : 14.sp,
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
  //                   _durasiNikonSt = value;
  //                 });
  //               },
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget durasiMoe({bool isHorizontal = false}) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: isHorizontal ? 10.r : 5.r,
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: isHorizontal
  //               ? MediaQuery.of(context).size.width / 5.5
  //               : MediaQuery.of(context).size.width / 3.2,
  //           child: Text(
  //             'Durasi : ',
  //             style: TextStyle(
  //               fontSize: isHorizontal ? 24.h : 14.sp,
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
  //               value: _durasiMoe,
  //               style: TextStyle(
  //                 fontSize: isHorizontal ? 24.sp : 14.sp,
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
  //                   _durasiMoe = value;
  //                 });
  //               },
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                ? MediaQuery.of(context).size.width / 5.5
                : MediaQuery.of(context).size.width / 3.2,
            child: Text(
              'Durasi : ',
              style: TextStyle(
                fontSize: isHorizontal ? 24.h : 14.sp,
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
                  fontSize: isHorizontal ? 24.sp : 14.sp,
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
                    _durasiLeinz = value;
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
                ? MediaQuery.of(context).size.width / 5.5
                : MediaQuery.of(context).size.width / 3.2,
            child: Text(
              'Durasi : ',
              style: TextStyle(
                fontSize: isHorizontal ? 24.h : 14.sp,
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
                  fontSize: isHorizontal ? 24.sp : 14.sp,
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
                    _durasiLeinzSt = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget durasiOriental({bool isHorizontal = false}) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: isHorizontal ? 10.r : 5.r,
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: isHorizontal
  //               ? MediaQuery.of(context).size.width / 5.5
  //               : MediaQuery.of(context).size.width / 3.2,
  //           child: Text(
  //             'Durasi : ',
  //             style: TextStyle(
  //               fontSize: isHorizontal ? 24.h : 14.sp,
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
  //               value: _durasiOriental,
  //               style: TextStyle(
  //                 fontSize: isHorizontal ? 24.sp : 14.sp,
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
  //                   _durasiOriental = value;
  //                 });
  //               },
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                ? MediaQuery.of(context).size.width / 5.5
                : MediaQuery.of(context).size.width / 3.2,
            child: Text(
              'Durasi : ',
              style: TextStyle(
                fontSize: isHorizontal ? 24.h : 14.sp,
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
                  fontSize: isHorizontal ? 24.sp : 14.sp,
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
                    _durasiOrientalSt = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget areaSigned({bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 10.r : 5.r,
            vertical: isHorizontal ? 18.r : 8.r,
          ),
          child: Text(
            'Persetujuan Customer',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 26.sp : 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: isHorizontal ? 30.h : 5.h,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 10.r : 5.r,
          ),
          child: Signature(
            controller: _signController,
            height: isHorizontal ? 250.h : 150.h,
            backgroundColor: Colors.blueGrey.shade50,
          ),
        ),
        SizedBox(
          height: isHorizontal ? 30.h : 15.h,
        ),
      ],
    );
  }
}
