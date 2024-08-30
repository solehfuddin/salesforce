import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sample/src/app/pages/activity/form_activity.dart';
import 'package:sample/src/app/pages/activity/form_frame.dart';
import 'package:sample/src/app/pages/econtract/form_product.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/thousandformatter.dart';
import 'package:sample/src/app/widgets/activityappbar.dart';
import 'package:sample/src/domain/entities/frame.dart';
import 'package:sample/src/domain/entities/jenisact.dart';
import 'package:sample/src/domain/entities/opticdaily.dart';
import 'package:sample/src/domain/entities/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_pickerr/time_pickerr.dart';

// ignore: must_be_immutable
class DetailActivity extends StatefulWidget {
  String? dateSelected = '';

  DetailActivity({this.dateSelected});

  @override
  State<DetailActivity> createState() => _DetailActivityState();
}

class _DetailActivityState extends State<DetailActivity> {
  TextEditingController controllerSpLensStock = new TextEditingController();
  TextEditingController controllerSpFrame = new TextEditingController();
  TextEditingController controllerNamaOptik = new TextEditingController();
  TextEditingController controllerFeedback = new TextEditingController();
  TextEditingController controllerJam = new TextEditingController();

  List<OpticDaily> itemOpticDay = List.empty(growable: true);
  List<FormItemActivity> formAct = List.empty(growable: true);
  List<FormItemActivity> fixedAct = List.empty(growable: true);
  List<String> tmpAct = List.empty(growable: true);
  List<Jenisact> itemJenisAct = List.empty(growable: true);

  List<String> tmpProductAct = List.empty(growable: true);
  List<FormItemProduct> formProductAct = List.empty(growable: true);
  List<FormItemProduct> fixedProductAct = List.empty(growable: true);
  List<Product> itemProductAct = List.empty(growable: true);

  List<String> tmpFrameAct = List.empty(growable: true);
  List<FormFrame> formFrameAct = List.empty(growable: true);
  List<FormFrame> fixedFrameAct = List.empty(growable: true);
  List<Frame> itemFrameAct = List.empty(growable: true);

  final format = DateFormat("HH:mm");
  String timeEntry = '';
  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';
  String tokenSm = '';
  String idSm = '';
  String mytoken = '';
  String opticname = "";
  String title = "Kunjungan Sales";
  String search = '';
  String searchSpLensa = '';
  String searchSpFrame = '';
  bool _isNamaOptik = false;
  bool _isJam = false;
  bool _isHorizontal = false;
  late DateTime selDateTime;
  String? selectedTime;

  @override
  initState() {
    super.initState();
    getJenisAct();
    getRole();

    selDateTime = DateTime.now();
    selectedTime =
        "${selDateTime.hour < 10 ? '0' : ''}${selDateTime.hour}${selDateTime.minute < 10 ? ':0' : ':'}${selDateTime.minute}";
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");

      print('ID user : $id');
      getTtdSales(int.parse(id!));
    });
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
          mytoken = data['data']['gentoken'];
          int areaId = data['data']['area'] != null
              ? int.parse(data['data']['area'])
              : 29;
          getTokenSM(areaId);
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

  Future<List<OpticDaily>> getSearchOptic(String input) async {
    List<OpticDaily> list = List.empty(growable: true);

    const timeout = 15;
    var url = '$API_URL/customers/findCust?created_by=$id&search=$input';
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
              .map<OpticDaily>((json) => OpticDaily.fromJson(json))
              .toList();
          itemOpticDay = rest
              .map<OpticDaily>((json) => OpticDaily.fromJson(json))
              .toList();

          print("List Size: ${list.length}");
          print("Product Size: ${itemOpticDay.length}");
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

  Future<List<Product>> getSPLensa(String input) async {
    List<Product> list = List.empty(growable: true);
    const timeout = 15;
    var url = '$API_URL/product/searchStockLens?search=$input';

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
          print("List Size: ${list.length}");
          itemProductAct =
              rest.map<Product>((json) => Product.fromJson(json)).toList();

          print("Product Size: ${itemProductAct.length}");

          for (int j = 0; j < itemProductAct.length; j++) {
            for (int i = 0; i < tmpProductAct.length; i++) {
              if (itemProductAct[j].proddesc == tmpProductAct[i]) {
                itemProductAct[j].ischecked = true;
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

  Future<List<Frame>> getSPFrame(String input) async {
    List<Frame> list = List.empty(growable: true);
    const timeout = 15;
    var url = '$API_URL/product/getFrames';

    try {
      var response = await http.post(Uri.parse(url), body: {
        'nama_brand': input,
      }).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);
          list = rest.map<Frame>((json) => Frame.fromJson(json)).toList();
          print("List Size: ${list.length}");
          itemFrameAct =
              rest.map<Frame>((json) => Frame.fromJson(json)).toList();

          print("Frame Size: ${itemFrameAct.length}");

          for (int j = 0; j < itemFrameAct.length; j++) {
            for (int i = 0; i < tmpFrameAct.length; i++) {
              if (itemFrameAct[j].frameName == tmpFrameAct[i]) {
                itemFrameAct[j].ischecked = true;
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

  getJenisAct() async {
    const timeout = 15;
    var url = '$API_URL/sales_activity/jenisActivity';

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
          itemJenisAct =
              rest.map<Jenisact>((json) => Jenisact.fromJson(json)).toList();
          print("List Size: ${itemJenisAct.length}");
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

  getSelectedJenisact() {
    if (itemJenisAct.length > 0) {
      for (int i = 0; i < itemJenisAct.length; i++) {
        if (itemJenisAct[i].ischecked) {
          Jenisact act = Jenisact(itemJenisAct[i].description);

          if (!tmpAct.contains(itemJenisAct[i].description)) {
            tmpAct.add(itemJenisAct[i].description);
            tmpAct.forEach((element) {
              print(element);
            });

            setState(() {
              formAct.add(FormItemActivity(
                index: formAct.length,
                jenisact: act,
              ));
            });
          }
        } else {
          if (tmpAct.contains(itemJenisAct[i].description)) {
            tmpAct.remove(itemJenisAct[i].description);
            tmpAct.forEach((element) {
              print(element);
            });

            setState(() {
              if (formAct.length > 0) {
                formAct.removeWhere((element) =>
                    element.jenisact!.description ==
                    itemJenisAct[i].description);
              }
            });
          }
        }
      }
    }
  }

  getSelectedSpLensa() {
    if (itemProductAct.length > 0) {
      for (int i = 0; i < itemProductAct.length; i++) {
        if (itemProductAct[i].ischecked) {
          if (!tmpProductAct.contains(itemProductAct[i].proddesc)) {
            tmpProductAct.add(itemProductAct[i].proddesc);
            tmpProductAct.forEach((element) {
              print(element);
            });

            setState(() {
              formProductAct.add(FormItemProduct(
                index: formProductAct.length,
                product: itemProductAct[i],
                itemLength: 4,
              ));
            });
          }
        } else {
          if (tmpProductAct.contains(itemProductAct[i].proddesc)) {
            tmpProductAct.remove(itemProductAct[i].proddesc);
            tmpProductAct.forEach((element) {
              print(element);
            });

            setState(() {
              if (formProductAct.length > 0) {
                formProductAct.removeWhere((element) =>
                    element.product!.proddesc == itemProductAct[i].proddesc);
              }
            });
          }
        }
      }
    }
  }

  getSelectedSpFrame() {
    if (itemFrameAct.length > 0) {
      for (int i = 0; i < itemFrameAct.length; i++) {
        if (itemFrameAct[i].ischecked) {
          if (!tmpFrameAct.contains(itemFrameAct[i].frameName)) {
            tmpFrameAct.add(itemFrameAct[i].frameName!);
            tmpFrameAct.forEach((element) {
              print(element);
            });

            setState(() {
              formFrameAct.add(FormFrame(
                index: formProductAct.length,
                frame: itemFrameAct[i],
                itemLength: 3,
              ));
            });
          }
        } else {
          if (tmpFrameAct.contains(itemFrameAct[i].frameName)) {
            tmpFrameAct.remove(itemFrameAct[i].frameName);
            tmpFrameAct.forEach((element) {
              print(element);
            });

            setState(() {
              if (formFrameAct.length > 0) {
                formFrameAct.removeWhere((element) =>
                    element.frame!.frameName == itemFrameAct[i].frameName);
              }
            });
          }
        }
      }
    }
  }

  onButtonPressed() async {
    await Future.delayed(const Duration(milliseconds: 1500),
        () => checkInput(isHorizontal: _isHorizontal));

    return () {};
  }

  checkInput({bool isHorizontal = false}) async {
    List<String> outputOther = List.empty(growable: true);
    var valSpFrame, valSpLensaStock;
    valSpFrame =
        controllerSpFrame.text.length > 0 ? '${controllerSpFrame.text}' : '0';
    valSpLensaStock = controllerSpLensStock.text.length > 0
        ? '${controllerSpLensStock.text}'
        : '0';

    controllerNamaOptik.text.isEmpty
        ? _isNamaOptik = true
        : _isNamaOptik = false;
    controllerJam.text.isEmpty ? _isJam = true : _isJam = false;

    setState(() {
      if (formAct.length > 0) {
        for (int i = 0; i < formAct.length; i++) {
          if (formAct[i].jenisact!.ischecked) {
            if (!tmpAct.contains(formAct[i].jenisact!.description)) {
              tmpAct.add(formAct[i].jenisact!.description);
              fixedAct.add(formAct[i]);
            } else {
              fixedAct.removeWhere((element) =>
                  element.jenisact!.description ==
                  formAct[i].jenisact!.description);
              fixedAct.add(formAct[i]);
            }
          } else {
            fixedAct.removeWhere((element) =>
                element.jenisact!.description ==
                formAct[i].jenisact!.description);
          }
        }
      }

      if (formProductAct.length > 0) {
        for (int i = 0; i < formProductAct.length; i++) {
          if (formProductAct[i].product!.ischecked) {
            if (!tmpProductAct.contains(formProductAct[i].product!.proddesc)) {
              tmpProductAct.add(formProductAct[i].product!.proddesc);
              fixedProductAct.add(formProductAct[i]);
            } else {
              fixedProductAct.removeWhere((element) =>
                  element.product!.proddesc ==
                  formProductAct[i].product!.proddesc);
              fixedProductAct.add(formProductAct[i]);
            }
          } else {
            fixedProductAct.removeWhere((element) =>
                element.product!.proddesc ==
                formProductAct[i].product!.proddesc);
          }
        }
      }

      if (formFrameAct.length > 0) {
        for (int i = 0; i < formFrameAct.length; i++) {
          if (formFrameAct[i].frame!.ischecked) {
            if (!tmpFrameAct.contains(formFrameAct[i].frame!.frameName)) {
              tmpFrameAct.add(formFrameAct[i].frame!.frameName!);
              fixedFrameAct.add(formFrameAct[i]);
            } else {
              fixedFrameAct.removeWhere((element) =>
                  element.frame!.frameName == formFrameAct[i].frame!.frameName);
              fixedFrameAct.add(formFrameAct[i]);
            }
          } else {
            fixedFrameAct.removeWhere((element) =>
                element.frame!.frameName == formFrameAct[i].frame!.frameName);
          }
        }
      }
    });

    fixedAct.forEach((e) => outputOther.add(e.jenisact!.description));
    timeEntry = '${widget.dateSelected} ${controllerJam.text}';

    print('Total Data Lainnya =  ${fixedAct.length}');
    fixedAct.forEach((element) {
      print(element.jenisact!.description);
      print(element.jenisact!.ischecked);
    });

    print('Total Data Product =  ${fixedProductAct.length}');
    fixedProductAct.forEach((element) {
      print(element.product!.proddesc);
      print(element.product!.diskon);
      print(element.product!.ischecked);
    });

    print('Total Data Frame =  ${fixedFrameAct.length}');
    fixedFrameAct.forEach((element) {
      print(element.frame!.frameName);
      print(element.frame!.qty);
      print(element.frame!.ischecked);
    });

    print('sales_id : $id');
    print('agenda : $title');
    print('optik : ${controllerNamaOptik.text}');
    print('feedback : ${controllerFeedback.text}');
    print('Waktu kunjungan : $timeEntry');
    print('spFrame: ${valSpFrame.replaceAll('.', '')}');
    print('spLensaStock: ${valSpLensaStock.replaceAll('.', '')}');
    print('other : ${outputOther.join(";")}');

    if (!_isNamaOptik && !_isJam) {
      simpanData(
        isHorizontal: isHorizontal,
        spFrame: valSpFrame.replaceAll('.', ''),
        spLensStock: valSpLensaStock.replaceAll('.', ''),
        other: outputOther.join(";"),
        feedback: controllerFeedback.text.trim(),
        timeEntry: timeEntry,
      );
    } else {
      handleStatus(
        context,
        'Harap lengkapi data terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    }
  }

  simpanData({
    bool isHorizontal = false,
    dynamic spFrame,
    dynamic spLensStock,
    dynamic other,
    dynamic feedback,
    dynamic timeEntry,
  }) async {
    // EKSEKUSI INPUT KE DB
    var url = '$API_URL/sales_activity';
    const timeout = 15;

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'sales_id': id,
          'agenda': title,
          'optik': controllerNamaOptik.text,
          'spFrame': spFrame,
          'spLensaStock': spLensStock,
          'other': other,
          'feedback': feedback,
          'time_start': timeEntry,
        },
      ).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (sts) {
          multipleInputSP(
            isHorizontal: isHorizontal,
          );

          //Send to Sales Manager
          pushNotif(
            10,
            3,
            salesName: name,
            idUser: idSm,
            rcptToken: tokenSm,
            opticName: controllerNamaOptik.text,
          );
        }

        if (mounted) {
          handleBack(
            context,
            capitalize(msg),
            "Aktivitas",
            sts,
            isHorizontal: isHorizontal,
            isLogout: false,
            isAdmin: false,
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

  multipleInputSP({bool isHorizontal = false}) async {
    if (fixedProductAct.length > 0) {
      for (int i = 0; i < fixedProductAct.length; i++) {
        FormItemProduct item = fixedProductAct[i];
        if (item.product!.ischecked) {
          debugPrint("Category Id: ${item.product!.categoryid}");
          debugPrint("Proddiv: ${item.product!.proddiv}");
          debugPrint("Prodcat: ${item.product!.prodcat}");
          debugPrint("Proddesc: ${item.product!.proddesc}");
          debugPrint("Diskon: ${item.product!.diskon}");

          postMultiSp(
            id!,
            item.product!.proddesc,
            item.product!.diskon,
            'L',
            isHorizontal: isHorizontal,
          );
        }
      }
    } else {
      print("Form is Not Valid");
    }

    if (fixedFrameAct.length > 0) {
      for (int i = 0; i < fixedFrameAct.length; i++) {
        FormFrame item = fixedFrameAct[i];
        if (item.frame!.ischecked) {
          debugPrint("Id: ${item.frame!.frameid}");
          debugPrint("Frame Name: ${item.frame!.frameName}");
          debugPrint("Status: ${item.frame!.status}");

          postMultiSp(
            id!,
            item.frame!.frameName!,
            item.frame!.qty!,
            'F',
            isHorizontal: isHorizontal,
          );
        }
      }
    } else {
      print("Form is Not Valid");
    }
  }

  postMultiSp(String idCust, String prodName, String qty, String jenisSp,
      {bool isHorizontal = false}) async {
    const timeout = 15;
    var url = '$API_URL/sales_activity/simpanSp';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'sales_id': idCust,
          'product_name[]': prodName,
          'qty[]': qty,
          'type[]': jenisSp,
        },
      ).timeout(Duration(seconds: timeout));

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];
        print(res);
        print(sts);
        print(msg);
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
        _isHorizontal = true;
        return detailActivity(isHorizontal: true);
      }

      _isHorizontal = false;
      return detailActivity(isHorizontal: false);
    });
  }

  Widget detailActivity({bool isHorizontal = false}) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: ActivityAppbar(
        isHorizontal: isHorizontal,
        onTitleChange: (t) {
          this.title = t;

          print(title);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 25.r : 15.r,
                vertical: isHorizontal ? 15.h : 10.r,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: isHorizontal ? 10.h : 5.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nama Optik',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Waktu Kunjungan',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: isHorizontal ? 15.h : 10.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'Nama Optik',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 2.h,
                              horizontal: 10.w,
                            ),
                            errorText:
                                _isNamaOptik ? 'Optik belum diisi' : null,
                            suffixIcon: IconButton(
                              onPressed: () {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return dialogOptic(
                                        isHorizontal: isHorizontal,
                                      );
                                    });
                              },
                              icon: Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 30.r,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: isHorizontal ? 24.sp : 14.sp,
                            fontFamily: 'Segoe Ui',
                          ),
                          maxLength: 50,
                          controller: controllerNamaOptik,
                        ),
                      ),
                      SizedBox(
                        width: 15.w,
                      ),
                      Expanded(
                        child: TextFormField(
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: selectedTime,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 2.h,
                              horizontal: 10.w,
                            ),
                            errorText: _isJam ? 'Belum diisi' : null,
                            suffixIcon: IconButton(
                              padding: EdgeInsets.only(
                                right: 0.r,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomHourPicker(
                                      elevation: 2,
                                      onPositivePressed: (context, time) {
                                        setState(() {
                                          selectedTime =
                                              "${time.hour < 10 ? '0' : ''}${time.hour}${time.minute < 10 ? ':0' : ':'}${time.minute}";
                                          controllerJam.text = selectedTime!;
                                        });

                                        Navigator.pop(context);
                                      },
                                      onNegativePressed: (context) {
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 30.r,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: isHorizontal ? 24.sp : 14.sp,
                            fontFamily: 'Segoe Ui',
                          ),
                          maxLength: 5,
                          controller: controllerJam,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomHourPicker(
                                  elevation: 2,
                                  onPositivePressed: (context, time) {
                                    setState(() {
                                      selectedTime =
                                          "${time.hour < 10 ? '0' : ''}${time.hour}${time.minute < 10 ? ':0' : ':'}${time.minute}";
                                      controllerJam.text = selectedTime!;
                                    });

                                    Navigator.pop(context);
                                  },
                                  onNegativePressed: (context) {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: isHorizontal ? 20.h : 15.h,
                  ),
                  Container(
                    height: isHorizontal ? 3.h : 1.3.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 20.h : 10.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sp Lensa Stok',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Sp Frame',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: isHorizontal ? 15.h : 10.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            hintStyle: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Segoe Ui',
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 2.h,
                              horizontal: 10.w,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: isHorizontal ? 24.sp : 14.sp,
                            fontFamily: 'Segoe Ui',
                          ),
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                          controller: controllerSpLensStock,
                          maxLength: 14,
                        ),
                      ),
                      SizedBox(
                        width: 15.w,
                      ),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 2.h,
                              horizontal: 10.w,
                            ),
                            hintStyle: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Segoe Ui',
                            ),
                          ),
                          style: TextStyle(
                            fontSize: isHorizontal ? 24.sp : 14.sp,
                            fontFamily: 'Segoe Ui',
                          ),
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                          controller: controllerSpFrame,
                          maxLength: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: isHorizontal ? 20.h : 10.h,
                  ),
                  areaSpLensa(
                    isHorizontal: isHorizontal,
                  ),
                  SizedBox(
                    height: isHorizontal ? 20.h : 10.h,
                  ),
                  areaSpFrame(
                    isHorizontal: isHorizontal,
                  ),
                  Container(
                    height: isHorizontal ? 3.h : 1.3.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 20.h : 15.h,
                  ),
                  areaLainnya(
                    isHorizontal: isHorizontal,
                  ),
                  SizedBox(
                    height: isHorizontal ? 20.h : 15.h,
                  ),
                  Text(
                    'Feedback Kunjungan',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 15.h : 10.h,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 150,
                    controller: controllerFeedback,
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe Ui',
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 20.h : 15.h,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isHorizontal ? 10.r : 5.r,
                      vertical: isHorizontal ? 10.r : 5.r,
                    ),
                    alignment: Alignment.centerRight,
                    child: EasyButton(
                      idleStateWidget: Text(
                        "Simpan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isHorizontal ? 24.sp : 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      loadingStateWidget: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                      useEqualLoadingStateWidgetDimension: true,
                      useWidthAnimation: true,
                      height: isHorizontal ? 60.h : 40.h,
                      width: isHorizontal ? 80.w : 100.w,
                      borderRadius: isHorizontal ? 60.r : 30.r,
                      buttonColor: Colors.blue.shade600,
                      elevation: 2.0,
                      contentGap: 6.0,
                      onPressed: onButtonPressed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dialogOptic({bool isHorizontal = false}) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: Center(
          child: Text('Pilih Optik'),
        ),
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
                          ? getSearchOptic(search)
                          : getSearchOptic(''),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            return snapshot.data != null
                                ? listParentWidget(itemOpticDay)
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
                        backgroundColor: Colors.red.shade700,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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

  Widget listParentWidget(List<OpticDaily> item) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
          width: double.minPositive.w,
          height: 350.h,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: item.length,
            itemBuilder: (BuildContext context, int index) {
              String _key = item[index].namaUsaha;
              return InkWell(
                onTap: () {
                  setState(() {
                    item.forEach((element) {
                      element.ischecked = false;
                    });
                    item[index].ischecked = true;
                    controllerNamaOptik.text = item[index].namaUsaha;
                  });
                },
                child: ListTile(
                  title: Text(_key),
                  trailing: Visibility(
                    visible: item[index].ischecked,
                    child: Icon(
                      Icons.check,
                      color: Colors.green.shade600,
                      size: 22.r,
                    ),
                    replacement: SizedBox(
                      width: 5.w,
                    ),
                  ),
                ),
              );
            },
          ));
    });
  }

  Widget dialogJenisact(List<Jenisact> item) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text('Pilih Aktivitas'),
        actions: [
          ElevatedButton(
              onPressed: () {
                getSelectedJenisact();
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
              String _key = item[index].description;
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

  Widget areaLainnya({bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lainnya : ',
              style: TextStyle(
                color: Colors.black87,
                fontSize: isHorizontal ? 24.sp : 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            Ink(
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
                      maxHeight: isHorizontal ? 59.r : 39.r,
                      maxWidth: isHorizontal ? 59.r : 39.r,
                    ),
                    icon: const Icon(Icons.add),
                    iconSize: isHorizontal ? 30.r : 17.r,
                    color: Colors.white,
                    onPressed: () {
                      itemJenisAct.length < 1
                          ? handleConnection(context)
                          : showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return dialogJenisact(itemJenisAct);
                              });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.symmetric(
            vertical: 5.r,
          ),
          height: isHorizontal ? 300.h : 150.h,
          child: formAct.isNotEmpty
              ? ListView.builder(
                  itemCount: formAct.length,
                  itemBuilder: (_, index) {
                    return formAct[index];
                  },
                )
              : Center(
                  child: Text(
                    'Tambahkan item lainnya',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget areaSpLensa({bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SP Lensa : ',
              style: TextStyle(
                color: Colors.black87,
                fontSize: isHorizontal ? 24.sp : 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            Ink(
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
                      maxHeight: isHorizontal ? 59.r : 39.r,
                      maxWidth: isHorizontal ? 59.r : 39.r,
                    ),
                    icon: const Icon(Icons.add),
                    iconSize: isHorizontal ? 30.r : 17.r,
                    color: Colors.white,
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return dialogSpLensa(isHorizontal: isHorizontal);
                          });
                    },
                  ),
                ],
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
                  'Nama Lensa',
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
                'Tandai',
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
                  'Qty',
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
          margin: EdgeInsets.symmetric(
            vertical: 5.r,
          ),
          height: isHorizontal ? 300.h : 150.h,
          child: formProductAct.isNotEmpty
              ? ListView.builder(
                  itemCount: formProductAct.length,
                  itemBuilder: (_, index) {
                    return formProductAct[index];
                  },
                )
              : Center(
                  child: Text(
                    'Tambahkan item lainnya',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget dialogSpLensa({bool isHorizontal = false}) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Center(
          child: Text('Pilih Lensa Stok'),
        ),
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
                      searchSpLensa = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder(
                    future: searchSpLensa.isNotEmpty
                        ? getSPLensa(searchSpLensa)
                        : getSPLensa(''),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default:
                          return snapshot.data != null
                              ? listSpLensa(itemProductAct)
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
                  getSelectedSpLensa();
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

  Widget listSpLensa(List<Product> item) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
          width: double.minPositive.w,
          height: 350.h,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: item.length,
            itemBuilder: (BuildContext context, int index) {
              String _key = item[index].proddesc.toUpperCase();
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

  Widget areaSpFrame({bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SP Frame : ',
              style: TextStyle(
                color: Colors.black87,
                fontSize: isHorizontal ? 24.sp : 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            Ink(
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
                      maxHeight: isHorizontal ? 59.r : 39.r,
                      maxWidth: isHorizontal ? 59.r : 39.r,
                    ),
                    icon: const Icon(Icons.add),
                    iconSize: isHorizontal ? 30.r : 17.r,
                    color: Colors.white,
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return dialogSpFrame(isHorizontal: isHorizontal);
                          });
                    },
                  ),
                ],
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
                  'Nama Frame',
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
                'Tandai',
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
                  'Qty',
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
          margin: EdgeInsets.symmetric(
            vertical: 5.r,
          ),
          height: isHorizontal ? 300.h : 150.h,
          child: formFrameAct.isNotEmpty
              ? ListView.builder(
                  itemCount: formFrameAct.length,
                  itemBuilder: (_, index) {
                    return formFrameAct[index];
                  },
                )
              : Center(
                  child: Text(
                    'Tambahkan item lainnya',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget dialogSpFrame({bool isHorizontal = false}) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Center(
          child: Text('Pilih Frame'),
        ),
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
                      searchSpFrame = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder(
                    future: searchSpFrame.isNotEmpty
                        ? getSPFrame(searchSpFrame)
                        : getSPFrame(''),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default:
                          return snapshot.data != null
                              ? listSpFrame(itemFrameAct)
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
                  getSelectedSpFrame();
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

  Widget listSpFrame(List<Frame> item) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
          width: double.minPositive.w,
          height: 350.h,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: item.length,
            itemBuilder: (BuildContext context, int index) {
              String _key = item[index].frameName!;
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
}
