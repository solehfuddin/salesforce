import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sample/src/domain/entities/product.dart';
import 'package:http/http.dart' as http;

class MultiProductDisc extends StatefulWidget {
  @override
  _MultiProductDiscState createState() => _MultiProductDiscState();
}

class _MultiProductDiscState extends State<MultiProductDisc> {
  List<Product> itemProduct;
  String search = '';

  getSearchProduct(String input) async {
    var url = 'http://timurrayalab.com/salesforce/server/api/product/search?search=supertrans';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      itemProduct =
          rest.map<Product>((json) => Product.fromJson(json)).toList();
      print("List Size: ${itemProduct.length}");
    }
  }

  @override
  void initState() {
    super.initState();
    getSearchProduct('');
  }

  Widget customProduct(List<Product> item) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text('Pilih Item'),
        actions: [
          ElevatedButton(
              onPressed: () {
                // getSelectedProddiv();
                Navigator.pop(context);
              },
              child: Text("Submit")),
        ],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 350,
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              color: Colors.white,
              height: 80,
              child: TextField(
                textInputAction: TextInputAction.search,
                autocorrect: true,
                decoration: InputDecoration(
                  hintText: 'Pencarian data ...',
                  prefixIcon: Icon(Icons.search),
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white70,
                  contentPadding: EdgeInsets.symmetric(vertical: 3),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    search = value;
                    getSearchProduct(search);
                  });
                },
              ),
            ),
            Container(
              width: double.minPositive,
              height: 350,
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
              ),
            ),
          ],
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
                'Kontrak Diskon Item : ',
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
                          return customProduct(itemProduct);
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
        // Container(
        //   height: 150,
        //   child: proddivs.length <= 0
        //       ? Center(
        //           child: Text('Tambahkan item prod div'),
        //         )
        //       : ListView.builder(
        //           itemCount: proddivs.length,
        //           itemBuilder: (_, index) => FormItemDisc(
        //             proddiv: proddivs[index],
        //           ),
        //         ),
        // ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
