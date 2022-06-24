import 'dart:convert';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/econtract/form_product.dart';
import 'package:sample/src/domain/entities/product.dart';
import 'package:http/http.dart' as http;

class MultiProductDisc extends StatefulWidget {
  @override
  _MultiProductDiscState createState() => _MultiProductDiscState();
}

class _MultiProductDiscState extends State<MultiProductDisc> {
  List<Product> itemProduct;
  List<FormItemProduct> formProduct = List.empty(growable: true);
  List<String> tmpProduct = List.empty(growable: true);
  Map<String, String> selectMapProduct = {"": ""};
  String search = '';

  Future<List<Product>> getSearchProduct(String input) async {
    List<Product> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/product/search?search=$input';
    var response = await http.get(url);
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
  }

  getSelectedItem() {
    selectMapProduct.clear();

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

  onSaveMultiProduct(Function stop) {
    bool allValid = true;

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
        }
      }
    } else {
      print("Form is Not Valid");
    }

    stop();
  }

  @override
  void initState() {
    super.initState();
    getSearchProduct('');
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
                  });
                },
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 100,
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
          ));
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
                'Kontrak Diskon Khusus : ',
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
                          // return customProduct(itemProduct);
                          return customProduct();
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
                onSaveMultiProduct(stopLoading);
              });
            }
          },
        ),
      ],
    );
  }
}
