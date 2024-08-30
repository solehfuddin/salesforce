import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/news/detail_product_corner.dart';
import 'package:sample/src/app/pages/staff/staff_view.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/imagevalidation.dart';
import 'package:sample/src/domain/entities/category_corner.dart';
import 'package:sample/src/domain/entities/item_corner.dart';
import 'package:sample/src/domain/entities/subcategory_corner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCornerScreen extends StatefulWidget {
  const ProductCornerScreen({Key? key}) : super(key: key);

  @override
  State<ProductCornerScreen> createState() => _ProductCornerScreenState();
}

class _ProductCornerScreenState extends State<ProductCornerScreen> {
  Future<List<ItemCorner>>? _itemlistFuture;
  List<CategoryCorner> categoryList = List.empty(growable: true);
  List<ItemCorner> itemList = List.empty(growable: true);
  ImageValidation _validationImage = new ImageValidation();
  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';
  int _idCategory = 13;
  int _idSubcategory = 2;
  String _sortBy = "id_corner";
  bool isDataFound = true;
  List<bool> expanded = [false, false, false, false];

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();

    getCategory();
    _itemlistFuture = getItemCorner(
      _idCategory,
      _idSubcategory,
      _sortBy,
    );
  }

  Future<List<CategoryCorner>> getCategory() async {
    categoryList.clear();
    // setState(() {
    //   isDataFound = true;
    // });

    List<CategoryCorner> list = List.empty(growable: true);
    const timeout = 15;
    var url = '$API_URL/productcorner/listcategorywithsubcategory';

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
              .map<CategoryCorner>((json) => CategoryCorner.fromJson(json))
              .toList();
          print("List Size: ${list.length}");

          setState(() {
            categoryList.addAll(list);
          });
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

    // setState(() {
    //   isDataFound = false;
    // });

    return list;
  }

  Future<List<ItemCorner>> getItemCorner(
    int idCategory,
    int idSubcategory,
    String sortBy,
  ) async {
    itemList.clear();
    setState(() {
      isDataFound = true;
    });

    List<ItemCorner> list = List.empty(growable: true);
    const timeout = 15;
    var url =
        '$API_URL/productcorner?id_category=$idCategory&id_subcategory=$idSubcategory&sort=$sortBy';

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
              .map<ItemCorner>((json) => ItemCorner.fromJson(json))
              .toList();
          print("List Size: ${list.length}");

          for (int i = 0; i < list.length; i++) {
            list[i].isImageValid =
                await _validationImage.validateImage(list[i].imgCorner);
          }

          setState(() {
            itemList.addAll(list);
          });
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

    setState(() {
      isDataFound = false;
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return childWidget();
  }

  Widget childWidget() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Product Corner',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (role == 'ADMIN') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminScreen()));
            } else if (role == 'SALES') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            } else {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => StaffScreen()));
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: Colors.black54,
          ),
        ),
        actions: [
          InkWell(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Icon(
                Icons.more_horiz,
                size: 22.sp,
                color: Colors.black54,
              ),
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (
                    BuildContext context,
                    StateSetter stateSetter,
                  ) {
                    return Wrap(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            left: 15,
                            top: 15,
                          ),
                          child: Text(
                            'Pilih Kategori',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              color: Colors.black45,
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 300.h,
                          child: FutureBuilder(
                              future: getCategory(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<CategoryCorner>>
                                      snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasError) {
                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Center(
                                            child: Image.asset(
                                              'assets/images/not_found.png',
                                              width: 300.r,
                                              height: 300.r,
                                            ),
                                          ),
                                          Text(
                                            'Data tidak ditemukan',
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red[600],
                                              fontFamily: 'Montserrat',
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  } else {
                                    return listViewWidget(
                                      snapshot.data!,
                                      snapshot.data!.length,
                                      stateSetter,
                                      isHorizontal: false,
                                    );
                                  }
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              }),
                        ),
                      ],
                    );
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          isDataFound
              ? Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 5.r,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : itemList.length > 0
                  ? Expanded(
                      child: SizedBox(
                        height: 100.h,
                        child: FutureBuilder(
                            future: _itemlistFuture,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<ItemCorner>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasError) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Center(
                                          child: Image.asset(
                                            'assets/images/not_found.png',
                                            width: 300.r,
                                            height: 300.r,
                                          ),
                                        ),
                                        Text(
                                          'Data tidak ditemukan',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red[600],
                                            fontFamily: 'Montserrat',
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                } else {
                                  return itemViewWidget(
                                    snapshot.data!,
                                    snapshot.data!.length,
                                    isHorizontal: false,
                                  );
                                }
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                      ),
                    )
                  // ? Text(
                  //     categoryList[0].subcategoryList[0].slugSubcategory ?? '',
                  //   )
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/images/not_found.png',
                                width: 230.w,
                                height: 230.h,
                              ),
                            ),
                            Text(
                              'Data tidak ditemukan',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[600],
                                fontFamily: 'Montserrat',
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget itemViewWidget(List<ItemCorner> data, int len,
      {bool isHorizontal = false}) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 5,
      ),
      scrollDirection: Axis.vertical,
      itemCount: len,
      itemBuilder: (context, position) {
        return Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.grey,
            ),
          ),
          elevation: 0,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 15,
                ),
                child: Column(
                  children: [
                    Container(
                      child: Stack(
                        children: [
                          data[position].isImageValid
                              ? Center(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: 50,
                                    ),
                                    child: Image.network(
                                      data[position].imgCorner,
                                      width: 135.w,
                                      height: 135.h,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return Image.asset(
                                          'assets/images/not_found.png',
                                          width: 130.w,
                                          height: 130.h,
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: 50,
                                    ),
                                    child: Image.asset(
                                      'assets/images/not_found.png',
                                      width: 135.w,
                                      height: 135.h,
                                    ),
                                  ),
                                ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade400,
                              ),
                              margin: EdgeInsets.only(
                                top: 15,
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: 9,
                              ),
                              child: Text(
                                data[position].titleCategories ?? '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      data[position].titleCorner ?? "",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      color: Colors.grey.shade400,
                      height: 4,
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Html(
                  data: "${data[position].bodyCorner?.substring(0, 200)} ...",
                  style: {
                    'html': Style(
                      textAlign: TextAlign.justify,
                    ),
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailProductCorner(
                          data[position],
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Selengkapnya",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget listViewWidget(
      List<CategoryCorner> data, int len, StateSetter stateSetter,
      {bool isHorizontal = false}) {
    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 5,
      ),
      scrollDirection: Axis.vertical,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            // vertical: 15,
            horizontal: 5,
          ),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              stateSetter(() {
                expanded[index] = !isExpanded;
                print('Isexpanded $index : ${expanded[index]}');
              });
            },
            expandedHeaderPadding: EdgeInsets.symmetric(
              vertical: 0,
            ),
            animationDuration: Duration(milliseconds: 1500),
            children: buildPanelList(
              data,
              stateSetter,
            ),
          ),
        ),
      ],
    );
  }

  List<ExpansionPanel> buildPanelList(
    List<CategoryCorner> item,
    StateSetter stateSetter,
  ) {
    List<ExpansionPanel> children = List.empty(growable: true);
    for (int i = 0; i < item.length; i++) {
      children.add(
        ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text(
                item[i].titleCategory ?? "",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            );
          },
          isExpanded: expanded[i],
          body: item[i].subcategoryList.length > 0
              ? SizedBox(
                  height: 60,
                  child: widgetSubcategory(
                    item[i].subcategoryList,
                    item[i].subcategoryList.length,
                    item[i].idCategory,
                  ),
                )
              : Column(
                  children: [
                    Container(
                      width: double.maxFinite,
                      height: 45,
                      margin: EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red.shade700,
                          style: BorderStyle.solid,
                          width: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Subkategori tidak ditemukan",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
        ),
      );
    }
    return children;
  }

  Widget widgetSubcategory(
      List<SubcategoryCorner> data, int len, dynamic idCategory,
      {bool isHorizontal = false}) {
    return ListView.builder(
      itemCount: len,
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 20.r : 10.r,
        vertical: isHorizontal ? 10.r : 10.r,
      ),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, position) {
        return Card(
          child: ClipPath(
            child: InkWell(
              onTap: () {
                _itemlistFuture = getItemCorner(
                  int.parse(idCategory),
                  int.parse(data[position].idSubcategory ?? "2"),
                  _sortBy,
                );
                print("Id Category : $idCategory");
                print("Id Subcategory : ${data[position].idSubcategory}");
                print("Sort By : $_sortBy");
                Navigator.pop(context);
              },
              splashColor: Colors.greenAccent.shade100,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.greenAccent,
                      width: 5,
                    ),
                  ),
                ),
                child: Text(
                  data[position].titleSubcategory ?? "",
                  style: TextStyle(
                    fontSize: isHorizontal ? 14.sp : 12.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      },
    );
  }
}
