import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/training_controller.dart';
import 'package:sample/src/app/pages/training/training_itemlist.dart';
import 'package:sample/src/domain/entities/training_resheader.dart';
import 'package:sample/src/domain/service/service_training.dart';

import '../../controllers/my_controller.dart';
import '../../utils/custom.dart';
import '../../widgets/custompagesearch.dart';

class TrainingHistory extends StatefulWidget {
  const TrainingHistory({Key? key}) : super(key: key);

  @override
  State<TrainingHistory> createState() => _TrainingHistoryState();
}

class _TrainingHistoryState extends State<TrainingHistory> {
  ServiceTraining serviceTraining = new ServiceTraining();
  TextEditingController txtSearch = new TextEditingController();
  MyController myController = Get.find<MyController>();
  TrainingController controller = Get.find<TrainingController>();

  Future<TrainingResHeader>? listRes;
  int totalItem = 0;
  int totalPage = 0;
  int limit = 5;
  int offset = 0;
  int page = 1;

  @override
  void initState() {
    callApi(int.parse(myController.sessionId), txtSearch.text, limit, offset);
    paginatePref(page, 0);
    super.initState();
  }

  Future<void> _refreshData() async {
    setState(() {
      callApi(int.parse(myController.sessionId), txtSearch.text, limit, offset);
    });
  }

  handleSearch(dynamic returnVal,
      {int limitVal = 5, int offsetVal = 0, int pageVal = 1}) {
    setState(() {
      page = pageVal;
      limit = limitVal;
      offset = offsetVal;

      callApi(int.parse(myController.sessionId), returnVal, limit, offset);
    });
  }

  int initalizePage(int totalData) {
    int totalPages = (totalData / limit).floor();
    if (totalData / limit > totalPages) {
      totalPages += 1;
    }

    return totalPages;
  }

  void callApi(int idSales, String search, int _limit, int _offset) {
    print("""
      idSales: $idSales,
      search: $search,
      limit: $_limit,
      offset: $_offset,
      """);

    listRes = serviceTraining.getHeader(
      mounted,
      context,
      idSales: idSales,
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder(
            future: listRes,
            builder: (BuildContext context,
                AsyncSnapshot<TrainingResHeader> snapshot) {
              if (snapshot.hasData && snapshot.data!.total! > 0) {
                return CustomPageSearch(
                  isHorizontal: isHorizontal,
                  showControl: true,
                  totalItem: totalItem,
                  limit: limit,
                  page: page,
                  totalPage: totalPage,
                  setColor: Colors.white,
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
                future: listRes,
                builder: (BuildContext context,
                    AsyncSnapshot<TrainingResHeader> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data!.total! > 0) {
                      return RefreshIndicator(
                        child: Training_itemlist(
                          itemList: snapshot.data!,
                          isHorizontal: isHorizontal,
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
