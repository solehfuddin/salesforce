import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/cashback/cashback_itemlist.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/custompagesearch.dart';
import 'package:sample/src/domain/entities/cashback_resheader.dart';
import 'package:sample/src/domain/service/service_cashback.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CashbackApprovalPending extends StatefulWidget {
  Color defaultColor;
  CashbackApprovalPending({Key? key, this.defaultColor = MyColors.greenAccent,}) : super(key: key);

  @override
  State<CashbackApprovalPending> createState() =>
      _CashbackApprovalPendingState();
}

class _CashbackApprovalPendingState extends State<CashbackApprovalPending> {
  TextEditingController txtSearch = new TextEditingController();
  ServiceCashback serviceCashback = new ServiceCashback();
  Future<CashbackResHeader>? _listCashback;

  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';
  String? ttdPertama = '';

  int totalItem = 0;
  int totalPage = 0;
  int limit = 5;
  int offset = 0;
  int page = 1;

  @override
  initState() {
    super.initState();
    getRole();
    paginatePref(page, 0);
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");
      ttdPertama = preferences.getString("ttduser") ?? '';

      if (role == 'ADMIN' && divisi == 'SALES') {
        callApi(int.parse(id!), 0, txtSearch.text, limit, offset);
      }

      if (role == 'ADMIN' && divisi == 'GM') {
        callApiManager(false, 0, txtSearch.text, limit, offset);
      }
    });
  }

  void callApi(
      int idSalesArea, int status, String search, int limit, int offset) {
    _listCashback = serviceCashback.getCashbackHeader(
      mounted,
      context,
      idManager: idSalesArea,
      status: status,
      search: search,
      limit: limit,
      offset: offset,
    );

    setState(() {
      _listCashback?.then((value) {
        totalItem = value.total ?? 0;
        totalPage = initalizePage(value.total ?? 0);
        print("Total row : $totalItem");
      });
    });
  }

  void callApiManager(
    bool isBrandManager,
    int status,
    String search,
    int limit,
    int offset,
  ) {
    _listCashback = serviceCashback.getCashbackManager(
      mounted,
      context,
      status: status,
      search: search,
      limit: limit,
      offset: offset,
    );

    setState(() {
      _listCashback?.then((value) {
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
      if (role == 'ADMIN' && divisi == 'SALES') {
        callApi(int.parse(id!), 0, txtSearch.text, limit, offset);
      }

      if (role == 'ADMIN' && divisi == 'GM') {
        callApiManager(false, 0, txtSearch.text, limit, offset);
      }
    });
  }

  handleSearch(
    dynamic returnVal, {
    int limitVal = 5,
    int offsetVal = 0,
    int pageVal = 1,
  }) {
    setState(() {
      page = pageVal;
      limit = limitVal;
      offset = offsetVal;

      if (role == 'ADMIN' && divisi == 'SALES') {
        callApi(int.parse(id!), 0, txtSearch.text, limit, offset);
      }

      if (role == 'ADMIN' && divisi == 'GM') {
        callApiManager(false, 0, txtSearch.text, limit, offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      if (constraint.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(isHorizontal: true);
      }

      return childWidget(isHorizontal: false);
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FutureBuilder(
          future: _listCashback,
          builder: (context, AsyncSnapshot<CashbackResHeader> snapshot) {
            if (snapshot.hasData && snapshot.data!.count! > 0) {
              return CustomPageSearch(
                isHorizontal: isHorizontal,
                showControl: true,
                totalItem: totalItem,
                limit: limit,
                page: page,
                totalPage: totalPage,
                setColor: widget.defaultColor,
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
        Flexible(
          child: FutureBuilder(
            future: _listCashback,
            builder: (context, AsyncSnapshot<CashbackResHeader> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.total! > 0) {
                  return RefreshIndicator(
                    child: CashbackItemList(
                      isSales: false,
                      isPending: true,
                      showDownload: false,
                      isHorizontal: isHorizontal,
                      itemHeader: snapshot.data,
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
              } else if (snapshot.connectionState == ConnectionState.waiting) {
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
      ],
    );
  }
}
