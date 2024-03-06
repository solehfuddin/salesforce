import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_form.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_itemlist.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/custompagesearch.dart';
import 'package:sample/src/domain/entities/posmaterial_resheader.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class Posmaterial_Screen extends StatefulWidget {
  const Posmaterial_Screen({Key? key}) : super(key: key);

  @override
  State<Posmaterial_Screen> createState() => _Posmaterial_ScreenState();
}

// ignore: camel_case_types
class _Posmaterial_ScreenState extends State<Posmaterial_Screen> {
  TextEditingController txtSearch = new TextEditingController();

  String? id, role, username, name;
  int totalItem = 0;
  int totalPage = 0;
  int limit = 4;
  int offset = 0;
  int page = 1;

  ServicePosMaterial service = new ServicePosMaterial();
  Future<PosMaterialResHeader>? _listFuture;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id") ?? "0";
      role = preferences.getString("role") ?? '';
      username = preferences.getString("username") ?? '';
      name = preferences.getString("name") ?? '';

      callApi(int.parse(id!), txtSearch.text, limit, offset);
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
    paginatePref(page, 0);
  }

  void callApi(int idSales, String search, int _limit, int _offset) {
    print("""
      idSales: $idSales,
      search: $search,
      limit: $_limit,
      offset: $_offset,
      """);

    _listFuture = service.getPosMaterialHeader(
      mounted,
      context,
      idSales: idSales,
      search: search,
      limit: _limit,
      offset: _offset,
    );

    setState(() {
      _listFuture?.then((value) {
        totalItem = value.total ?? 0;
        totalPage = initalizePage(value.total ?? 0);
        print("Total Row : $totalItem");
      });
    });
  }

  int initalizePage(int totalData) {
    int totalPages = (totalData / limit).floor();
    if (totalData / limit > totalPages) {
      totalPages += 1;
    }

    return totalPages;
  }

  Future<void> _refreshData() async {
    setState(() {
      callApi(int.parse(id!), txtSearch.text, limit, offset);
    });
  }

  handleSearch(dynamic returnVal, {int limitVal = 4, int offsetVal = 0, int pageVal = 1}) {
    setState(() {
      page = pageVal;
      limit = limitVal;
      offset = offsetVal;

      callApi(int.parse(id!), returnVal, limit, offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(isHorizontal: true);
      } else {
        return childWidget(isHorizontal: false);
      }
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: MyColors.darkColor,
        title: Text(
          'Pos Material',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            paginateClear();

            if (role == 'ADMIN') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminScreen()));
            } else if (role == 'SALES') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Posmaterial_Form(),
                ),
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: Colors.white,
              size: isHorizontal ? 20.sp : 18.sp,
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder(
            future: _listFuture,
            builder: (BuildContext context,
                AsyncSnapshot<PosMaterialResHeader> snapshot) {
              if (snapshot.hasData && snapshot.data!.total! > 0) {
                return CustomPageSearch(
                  isHorizontal: isHorizontal,
                  totalItem: totalItem,
                  limit: limit,
                  page: page,
                  totalPage: totalPage,
                  resHeader: snapshot.data,
                  setColor: MyColors.darkColor,
                  txtSearch: txtSearch,
                  handleSearch: handleSearch,
                );
              } else {
                return SizedBox(
                  width: 10.w,
                );
              }
            },
          ),
          Expanded(
            child: SizedBox(
              height: 100.h,
              child: FutureBuilder(
                future: _listFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<PosMaterialResHeader> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data!.total! > 0) {
                      return RefreshIndicator(
                        child: Posmaterial_itemlist(
                          isHorizontal: isHorizontal,
                          itemList: snapshot.data!,
                        ),
                        onRefresh: _refreshData,
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/not_found.png',
                              width: isHorizontal ? 150.w : 200.w,
                              height: isHorizontal ? 150.h : 200.h,
                            ),
                          ),
                          Text(
                            'Data tidak ditemukan',
                            style: TextStyle(
                              fontSize: isHorizontal ? 14.sp : 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
