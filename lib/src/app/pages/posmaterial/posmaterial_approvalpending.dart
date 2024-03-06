import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_itemapproval.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/settings_posmaterial.dart';
import 'package:sample/src/app/widgets/custompagesearch.dart';
import 'package:sample/src/domain/entities/posmaterial_resheader.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PosMaterialApprovalPending extends StatefulWidget {
  const PosMaterialApprovalPending({Key? key}) : super(key: key);

  @override
  State<PosMaterialApprovalPending> createState() =>
      _PosMaterialApprovalPendingState();
}

class _PosMaterialApprovalPendingState
    extends State<PosMaterialApprovalPending> {
  TextEditingController txtSearch = new TextEditingController();

  ServicePosMaterial service = new ServicePosMaterial();
  Future<PosMaterialResHeader>? _listFuture;

  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';
  String? ttdPertama = '';

  int totalItem = 0;
  int totalPage = 0;
  int limit = 4;
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
        callApi(int.parse(id!), setApprovalStatus(PosStatus.PENDING), txtSearch.text, limit, offset);
      }

      if (role == 'ADMIN' && divisi == 'MARKETING') {
        callApiManager(true, setApprovalStatus(PosStatus.PENDING), txtSearch.text, limit, offset);
      }

      if (role == 'ADMIN' && divisi == 'GM') {
        callApiManager(false, setApprovalStatus(PosStatus.PENDING), txtSearch.text, limit, offset);
      }
    });
  }

  void callApi(
      int idSalesArea, int status, String search, int limit, int offset) async {
    _listFuture = service.getPosMaterialHeader(
      mounted,
      context,
      idManager: idSalesArea,
      status: status,
      search: search,
      limit: limit,
      offset: offset,
    );

    setState(() {
      _listFuture?.then((value) {
        totalItem = value.total ?? 0;
        totalPage = initalizePage(value.total ?? 0);
        print("Total Row : $totalItem");
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
    _listFuture = service.getPosMaterialHeaderByManager(
      mounted,
      context,
      isBrandManager: isBrandManager,
      status: status,
      search: search,
      limit: limit,
      offset: offset,
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
      if (role == 'ADMIN' && divisi == 'SALES') {
        callApi(int.parse(id!), setApprovalStatus(PosStatus.PENDING), txtSearch.text, limit, offset);
      }

      if (role == 'ADMIN' && divisi == 'MARKETING') {
        callApiManager(true, setApprovalStatus(PosStatus.PENDING), txtSearch.text, limit, offset);
      }

      if (role == 'ADMIN' && divisi == 'GM') {
        callApiManager(false, setApprovalStatus(PosStatus.PENDING), txtSearch.text, limit, offset);
      }
    });
  }

  handleSearch(
    dynamic returnVal, {
    int limitVal = 4,
    int offsetVal = 0,
    int pageVal = 1,
  }) {
    setState(() {
      page = pageVal;
      limit = limitVal;
      offset = offsetVal;

      if (role == 'ADMIN' && divisi == 'SALES') {
        callApi(int.parse(id!), setApprovalStatus(PosStatus.PENDING), txtSearch.text, limit, offset);
      }

      if (role == 'ADMIN' && divisi == 'MARKETING') {
        callApiManager(true, setApprovalStatus(PosStatus.PENDING), txtSearch.text, limit, offset);
      }

      if (role == 'ADMIN' && divisi == 'GM') {
        callApiManager(false, setApprovalStatus(PosStatus.PENDING), txtSearch.text, limit, offset);
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
          future: _listFuture,
          builder: (context, AsyncSnapshot<PosMaterialResHeader> snapshot) {
            if (snapshot.hasData && snapshot.data!.count! > 0) {
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
        Flexible(
          child: FutureBuilder(
            future: _listFuture,
            builder: (context, AsyncSnapshot<PosMaterialResHeader> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.total! > 0) {
                  return RefreshIndicator(
                    child: PosMaterialItemApproval(
                      isHorizontal: isHorizontal,
                      itemList: snapshot.data!,
                      isPending: true,
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
