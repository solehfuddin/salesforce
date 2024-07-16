import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/my_controller.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_itemapproval.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/custompagesearch.dart';
import 'package:sample/src/domain/entities/marketingexpense_resheader.dart';
import 'package:sample/src/domain/service/service_marketingexpense.dart';

// ignore: camel_case_types
class Marketingexpense_Approvalreject extends StatefulWidget {
  const Marketingexpense_Approvalreject({ Key? key }) : super(key: key);

  @override
  State<Marketingexpense_Approvalreject> createState() => _Marketingexpense_ApprovalrejectState();
}

// ignore: camel_case_types
class _Marketingexpense_ApprovalrejectState extends State<Marketingexpense_Approvalreject> {
  TextEditingController txtSearch = new TextEditingController();

  ServiceMarketingExpense serviceMe = new ServiceMarketingExpense();

  MyController myController = Get.find<MyController>();
  Future<MarketingExpenseResHeader>? listRes;
  int totalItem = 0;
  int totalPage = 0;
  int limit = 5;
  int offset = 0;
  int page = 1;

  @override
  void initState() {
    if (myController.sessionDivisi == "SALES") {
      callApi(
          int.parse(myController.sessionId), 2, txtSearch.text, limit, offset);
    }

    if (myController.sessionDivisi == "GM") {
      callApiManager(2, txtSearch.text, limit, offset);
    }

    paginatePref(page, 0);
    super.initState();
  }

  void callApi(
      int idManager, int status, String search, int _limit, int _offset) {
    listRes = serviceMe.getHeader(
      mounted,
      context,
      idManager: idManager,
      status: status,
      search: search,
      limit: _limit,
      offset: _offset,
    );

    setState(() {
      listRes?.then((value) {
        totalItem = value.total ?? 0;
        totalPage = initalizePage(value.total ?? 0);
        print("Total Row : $totalItem");
      });
    });
  }

  void callApiManager(
    int status,
    String search,
    int limit,
    int offset,
  ) {
    listRes = serviceMe.getHeaderManager(
      mounted,
      context,
      status: status,
      search: search,
      limit: limit,
      offset: offset,
    );

    setState(() {
      listRes?.then((value) {
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
      if (myController.sessionDivisi == "SALES") {
        callApi(int.parse(myController.sessionId), 2, txtSearch.text, limit,
            offset);
      }

      if (myController.sessionDivisi == "GM") {
        callApiManager(2, txtSearch.text, limit, offset);
      }
    });
  }

  handleSearch(dynamic returnVal,
      {int limitVal = 5, int offsetVal = 0, int pageVal = 1}) {
    setState(() {
      page = pageVal;
      limit = limitVal;
      offset = offsetVal;

      if (myController.sessionDivisi == "SALES") {
        callApi(int.parse(myController.sessionId), 2, txtSearch.text, limit,
            offset);
      }

      if (myController.sessionDivisi == "GM") {
        callApiManager(2, txtSearch.text, limit, offset);
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
          future: listRes,
          builder:
              (context, AsyncSnapshot<MarketingExpenseResHeader> snapshot) {
            if (snapshot.hasData && snapshot.data!.count! > 0) {
              return CustomPageSearch(
                isHorizontal: isHorizontal,
                showControl: true,
                totalItem: totalItem,
                limit: limit,
                page: page,
                totalPage: totalPage,
                setColor: MyColors.desciptionColor,
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
            future: listRes,
            builder:
                (context, AsyncSnapshot<MarketingExpenseResHeader> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.total! > 0) {
                  return RefreshIndicator(
                    child: Marketingexpense_itemapproval(
                      itemList: snapshot.data!,
                      isHorizontal: isHorizontal,
                      isPending: false,
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