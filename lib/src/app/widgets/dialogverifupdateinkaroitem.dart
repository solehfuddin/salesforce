import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/inkaro/detail_inkaro.dart';
import 'package:sample/src/app/pages/inkaro/edit_header_inkaro.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/customer_inkaro.dart';
import 'package:sample/src/domain/entities/inkaro_manual.dart';
import 'package:sample/src/domain/entities/inkaro_program.dart';
import 'package:sample/src/domain/entities/inkaro_reguler.dart';
import 'package:sample/src/domain/entities/list_inkaro_detail.dart';
import 'package:sample/src/domain/entities/list_inkaro_header.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DialogVerifUpdateInkaroItem extends StatefulWidget {
  final List<ListInkaroHeader> inkaroHeaderList;
  final int positionInkaroHeader;
  final List<ListCustomerInkaro> customerList;
  final int positionCustomer;
  List<InkaroReguler> inkaroRegSelected;
  List<InkaroProgram> inkaroProgSelected;
  List<InkaroManual> inkaroManualSelected;
  List<ListInkaroDetail> inkaroDetailUpdate;
  int positionDetail;
  String typeUpdate;

  final void Function(List<ListInkaroDetail>) inkaroDetail;

  @override
  State<DialogVerifUpdateInkaroItem> createState() =>
      _DialogVerifUpdateInkaroItemState();

  DialogVerifUpdateInkaroItem(
      this.inkaroHeaderList,
      this.positionInkaroHeader,
      this.customerList,
      this.positionCustomer,
      this.inkaroRegSelected,
      this.inkaroProgSelected,
      this.inkaroManualSelected,
      this.inkaroDetail,
      this.inkaroDetailUpdate,
      this.positionDetail,
      this.typeUpdate);
}

class _DialogVerifUpdateInkaroItemState
    extends State<DialogVerifUpdateInkaroItem> {
  String? id = '';
  bool? statusCreate = false;
  List<ListInkaroDetail> listInkaroDetailReguler = List.empty(growable: true);
  List<ListInkaroDetail> listInkaroDetailProgram = List.empty(growable: true);
  List<ListInkaroDetail> listInkaroDetailManual = List.empty(growable: true);
  List<ListInkaroDetail> listInkaroDetailTotal = List.empty(growable: true);

  String? descCatItemDeleted = "",
      descSubCatItemDeleted = "",
      typeInkaroDeleted = "";

  deleteData({bool isHorizontal = false}) async {
    const timeout = 15;
    var url = '$API_URL/inkaro/deleteInkaroItembyContract/';

    try {
      statusCreate = false;
      var response = await http.post(Uri.parse(url), body: {
        'id_contract': widget
            .inkaroHeaderList[widget.positionInkaroHeader].inkaroContractId,
        'updated_by': id,
        'id_inkaro_contract_detail': widget
            .inkaroDetailUpdate[widget.positionDetail].inkaroContractDetailId
      }, headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      var res = json.decode(response.body);
      final bool sts = res['status'];
      statusCreate = res['status'];
      final String msg = res['message'].toString();

      if (sts) {
        Navigator.of(context, rootNavigator: true)..pop('dialog');
        await getListInkaro();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return dialogStatusDeleteItemInkaro(sts);
            });
      } else {
        Navigator.of(context, rootNavigator: true)..pop('dialog');
        await getListInkaro();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return dialogStatusDeleteItemInkaro(sts);
            });
      }
    } on FormatException catch (e) {
      if (mounted) {
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

  simpanData({bool isHorizontal = false}) async {
    const timeout = 15;
    var url = '$API_URL/inkaro/addInkaroItembyContract/';

    // Merge Selected Inkaro Reguler, Program dan Manual
    List<Object> finalListInkaro = List.empty(growable: true);
    // Merge Inkaro Reguler
    for (int loopReg = 0;
        loopReg < widget.inkaroRegSelected.length;
        loopReg++) {
      finalListInkaro.add({
        'CATEGORY_ID': widget.inkaroRegSelected[loopReg].idKategori,
        'type_inkaro': 'reguler',
      });
    }

    // Merge Inkaro Program
    for (int loopProg = 0;
        loopProg < widget.inkaroProgSelected.length;
        loopProg++) {
      finalListInkaro.add({
        'CATEGORY_ID': widget.inkaroProgSelected[loopProg].idCategory,
        'SUBCATEGORY_ID': widget.inkaroProgSelected[loopProg].idSubcategory,
        'type_inkaro': 'program',
      });
    }
    // Merge Inkaro Manual
    for (int loopManual = 0;
        loopManual < widget.inkaroManualSelected.length;
        loopManual++) {
      finalListInkaro.add({
        'SUBCATEGORY_ID': widget.inkaroManualSelected[loopManual].idSubcategory,
        'type_inkaro': 'manual',
        'inkaro_value': widget.inkaroManualSelected[loopManual].inkaroValue
      });
    }

    try {
      statusCreate = false;
      var response = await http.post(Uri.parse(url), body: {
        'id_contract': widget
            .inkaroHeaderList[widget.positionInkaroHeader].inkaroContractId,
        'updated_by': id,
        'detail_inkaro': json.encode(finalListInkaro)
      }, headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      var res = json.decode(response.body);

      final bool sts = res['status'];
      statusCreate = res['status'];
      final String msg = res['message'].toString();

      if (sts) {
        await getListInkaro();
        Navigator.of(context, rootNavigator: true)
          ..pop('dialog')
          ..pop('dialog');

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return dialogStatusAddItemInkaro(sts, 'Tambah Inkaro Berhasil');
            });
      } else {
        await getListInkaro();
        Navigator.of(context, rootNavigator: true)
          ..pop('dialog')
          ..pop('dialog');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return dialogStatusAddItemInkaro(sts, res['message'].toString());
            });
      }
    } on FormatException catch (e) {
      if (mounted) {
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

  getListInkaro() async {
    const timeout = 15;
    var url =
        '$API_URL/inkaro/getInkaroDetail?id_inkaro_header=${widget.inkaroHeaderList[widget.positionInkaroHeader].inkaroContractId}&sort=DESC_CATEGORY,DESC_SUBCATEGORY:ASC';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        "api-key-trl": API_KEY
      }).timeout(Duration(seconds: timeout));

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];
        if (sts) {
          var rest = data['data'];
          setState(() {
            listInkaroDetailReguler = rest['reguler']
                .map<ListInkaroDetail>(
                    (json) => ListInkaroDetail.fromJson(json))
                .toList();
            listInkaroDetailProgram = rest['program']
                .map<ListInkaroDetail>(
                    (json) => ListInkaroDetail.fromJson(json))
                .toList();
            listInkaroDetailManual = rest['manual']
                .map<ListInkaroDetail>(
                    (json) => ListInkaroDetail.fromJson(json))
                .toList();

            listInkaroDetailTotal = [
              ...listInkaroDetailReguler,
              ...listInkaroDetailProgram,
              ...listInkaroDetailManual
            ];
            widget.inkaroDetail(listInkaroDetailTotal);
          });
        }

        print('get inkaro list item');
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

  @override
  void initState() {
    super.initState();
    getRole();
    descCatItemDeleted =
        widget.inkaroDetailUpdate.length > 0 
        ?  widget.inkaroDetailUpdate[widget.positionDetail].descKategori
        : '';
    descSubCatItemDeleted =
         widget.inkaroDetailUpdate.length > 0 
        ? widget.inkaroDetailUpdate[widget.positionDetail].descSubcategory
        : '';
    typeInkaroDeleted =
        widget.inkaroDetailUpdate.length > 0 
        ? widget.inkaroDetailUpdate[widget.positionDetail].typeInkaro
        : '';
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childDialogVerifEditHeaderInkaro(isHorizontal: true);
      }

      return childDialogVerifEditHeaderInkaro(isHorizontal: false);
    });
  }

  Widget childDialogVerifEditHeaderInkaro({bool isHorizontal = false}) {
    return AlertDialog(
      title: Center(
        child: Text(
          "Apakah Anda Yakin Ingin Mengubah Data Kontrak Inkaro ?",
          style: TextStyle(
            fontSize: isHorizontal ? 20.sp : 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: Container(
        padding: EdgeInsets.only(
          top: 10.r,
        ),
        height: 200.h,
        child: Column(
          children: [
            (widget.typeUpdate == 'delete'
                ? Center(
                    child: Text(
                      'Inkaro ' +
                          (typeInkaroDeleted == "reguler"
                              ? descCatItemDeleted! + " akan dihapus"
                              : descSubCatItemDeleted! + " akan dihapus"),
                      style: TextStyle(
                        fontSize: isHorizontal ? 16.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SizedBox(
                    height: 0.h,
                  )),
            SizedBox(
              height: 10.h,
            ),
            Center(
              child: Text(
                'Jika Data Kontrak Mengalami Perubahan, maka status kontrak inkaro akan kembali menjadi "PENDING" dan perlu melalui proses approval Sales Manager',
                style: TextStyle(
                  fontSize: isHorizontal ? 16.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: isHorizontal ? 10.h : 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      primary: Colors.indigo[600],
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.r, vertical: 10.r),
                    ),
                    child: Text(
                      'Iya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isHorizontal ? 18.sp : 14.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Segoe ui',
                      ),
                    ),
                    onPressed: () async {
                      if (widget.typeUpdate == 'add') {
                        await simpanData();
                      } else if (widget.typeUpdate == 'delete') {
                        await deleteData();
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: isHorizontal ? 10.h : 20.h,
                ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      primary: Colors.orange[800],
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.r, vertical: 10.r),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isHorizontal ? 18.sp : 14.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Segoe ui',
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)..pop();
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget dialogStatusAddItemInkaro(statusAddItem, String message) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Column(children: [
          Center(
            child: Image.asset(
              statusAddItem
                  ? 'assets/images/success.png'
                  : 'assets/images/failure.png',
              width: 65.r,
              height: 65.r,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            statusAddItem ? "Tambah Inkaro Berhasil" : message,
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ]),
        actions: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      primary: Colors.indigo[600],
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.r, vertical: 10.r),
                    ),
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Segoe ui',
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true)..pop('dialog');
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      );
    });
  }

  Widget dialogStatusDeleteItemInkaro(statusAddItem) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Column(children: [
          Center(
            child: Image.asset(
              statusAddItem
                  ? 'assets/images/success.png'
                  : 'assets/images/failure.png',
              width: 65.r,
              height: 65.r,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            statusAddItem ? "Hapus Inkaro Berhasil" : "Hapus Inkaro Gagal",
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ]),
        actions: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      primary: Colors.indigo[600],
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.r, vertical: 10.r),
                    ),
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Segoe ui',
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true)..pop('dialog');
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      );
    });
  }
}
