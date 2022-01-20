import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sample/src/app/econtract/form_disc.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:http/http.dart' as http;

class MultiFormDisc extends StatefulWidget {
  @override
  _MultiFormDiscState createState() => _MultiFormDiscState();
}

class _MultiFormDiscState extends State<MultiFormDisc> {
  List<Proddiv> proddivs = List.empty(growable: true);
  List<Proddiv> itemProdDiv;
  Map<String, String> selectMapProddiv = {"": ""};

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

  getSelectedProddiv() {
    selectMapProddiv.clear();
    proddivs.clear();

    itemProdDiv.forEach((item) {
      if (item.ischecked) {
        selectMapProddiv[item.proddiv] = item.alias;
        setState(() {
          proddivs.add(Proddiv(item.alias, item.proddiv));
        });
      }
    });
    print(selectMapProddiv);
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
          child: proddivs.length <= 0
              ? Center(
                  child: Text('Tambahkan item prod div'),
                )
              : ListView.builder(
                  itemCount: proddivs.length,
                  itemBuilder: (_, index) => FormItemDisc(
                    proddiv: proddivs[index],
                  ),
                ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
