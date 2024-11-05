// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/pages/training/training_itemapproval.dart';

import '../../../domain/entities/training_resheader.dart';
import '../../../domain/service/service_training.dart';
import '../../controllers/my_controller.dart';
import '../../utils/custom.dart';
import '../../widgets/custompagesearch.dart';

class Training_ApprovalApprove extends StatefulWidget {
  const Training_ApprovalApprove({Key? key}) : super(key: key);

  @override
  State<Training_ApprovalApprove> createState() => _Training_ApprovalApproveState();
}

class _Training_ApprovalApproveState extends State<Training_ApprovalApprove> {
  TextEditingController txtSearch = new TextEditingController();

  ServiceTraining serviceTraining = new ServiceTraining();

  MyController myController = Get.find<MyController>();
  Future<TrainingResHeader>? listRes;
  int totalItem = 0;
  int totalPage = 0;
  int limit = 5;
  int offset = 0;
  int page = 1;

  @override
  void initState() {
    if (myController.sessionDivisi == "SALES") {
      callApi(int.parse(myController.sessionId), 1, txtSearch.text, limit, offset);
    }

    if (myController.sessionDivisi == "MARKETING") {
      callApiManager(1, txtSearch.text, limit, offset);
    }

    paginatePref(page, 0);
    super.initState();
  }

  void callApi(int idManager, int status, String search, int _limit, int _offset) {
    listRes = serviceTraining.getHeader(
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
    listRes = serviceTraining.getHeaderManager(
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
        callApi(
            int.parse(myController.sessionId), 1, txtSearch.text, limit, offset);
      }

      if (myController.sessionDivisi == "MARKETING") {
        callApiManager(1, txtSearch.text, limit, offset);
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
        callApi(
            int.parse(myController.sessionId), 1, txtSearch.text, limit, offset);
      }

      if (myController.sessionDivisi == "MARKETING") {
        callApiManager(1, txtSearch.text, limit, offset);
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
              (context, AsyncSnapshot<TrainingResHeader> snapshot) {
            if (snapshot.hasData && snapshot.data!.count! > 0) {
              return CustomPageSearch(
                isHorizontal: isHorizontal,
                showControl: true,
                totalItem: totalItem,
                limit: limit,
                page: page,
                totalPage: totalPage,
                setColor: Color.fromARGB(255, 158, 92, 6),
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
                (context, AsyncSnapshot<TrainingResHeader> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.total! > 0) {
                  return RefreshIndicator(
                    child: Training_ItemApproval(
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