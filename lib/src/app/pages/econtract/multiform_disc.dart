import 'dart:convert';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/econtract/form_disc.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:http/http.dart' as http;

class MultiFormDisc extends StatefulWidget {
  MultiFormDisc({Key key, this.myCallback}) : super(key: key);
  Function(int) myCallback;
  final state = _MultiFormDiscState();

  @override
  _MultiFormDiscState createState() {
    return state;
  }
}

class _MultiFormDiscState extends State<MultiFormDisc> {
  List<FormItemDisc> formDisc = List.empty(growable: true);
  List<Proddiv> itemProdDiv;
  List<String> tmpDiv = List.empty(growable: true);
  Map<String, String> selectMapProddiv = {"": ""};

  getItemProdDiv() async {
    var url = 'http://timurrayalab.com/salesforce/server/api/product/getProDiv';
    var response = await http.get(url);
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
      handleStatus(context, e.toString(), false);
    }
  }

  getSelectedProddiv() {
    setState(() {
      selectMapProddiv.clear();

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
    });
  }

  onSaveMultiForm(Function stop) {
    bool allValid = true;

    formDisc
        .forEach((element) => allValid = (allValid && element.isValidated()));

    if (allValid) {
      widget.myCallback(formDisc.length);

      for (int i = 0; i < formDisc.length; i++) {
        FormItemDisc item = formDisc[i];
        if (item.proddiv.ischecked) {
          debugPrint("Proddiv: ${item.proddiv.proddiv}");
          debugPrint("Alias: ${item.proddiv.alias}");
          debugPrint("Diskon: ${item.proddiv.diskon}");
          // postMulti(item.proddiv.proddiv, item.proddiv.diskon);
        }
      }
    } else {
      print("Form is Not Valid");
    }

    print("Test submit form");
    stop();
  }

  postMulti(String proddiv, String diskon) async {
    var url =
        'http://timurrayalab.com/salesforce/server/api/discount/divCustomDiscount';
    var response = await http.post(
      url,
      body: {
        'id_customer': '9999',
        'prod_div[]': proddiv,
        'discount[]': diskon,
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

  @override
  void initState() {
    super.initState();
    getItemProdDiv();
  }

  Widget customProddiv(List<Proddiv> item) {
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
          width: double.minPositive,
          height: 300,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              child: Text(
                'Kontrak Diskon Divisi : ',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.lightBlue,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  constraints: BoxConstraints(
                    maxHeight: 28,
                    maxWidth: 28,
                  ),
                  icon: const Icon(Icons.add),
                  iconSize: 13,
                  color: Colors.white,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return customProddiv(itemProdDiv);
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
              width: 200,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Text(
                  'Produk',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Text(
                  'Regular',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Text(
                  'Diskon',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 150,
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
          height: 20,
        ),
        ArgonButton(
          height: 40,
          width: 100,
          borderRadius: 30.0,
          color: Colors.blue[700],
          child: Text(
            "Simpan",
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
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
                onSaveMultiForm(stopLoading);
              });
            }
          },
        ),
      ],
    );
  }
}
