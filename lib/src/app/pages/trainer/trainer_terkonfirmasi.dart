import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/training_resheader.dart';
import '../../../domain/service/service_training.dart';
import '../../controllers/marketingexpense_controller.dart';
import '../../controllers/my_controller.dart';
import '../../widgets/custompagesearch.dart';
import '../training/training_itemlist.dart';

class TrainerTerkonfirmasi extends StatefulWidget {
  const TrainerTerkonfirmasi({Key? key}) : super(key: key);

  @override
  State<TrainerTerkonfirmasi> createState() => _TrainerTerkonfirmasiState();
}

class _TrainerTerkonfirmasiState extends State<TrainerTerkonfirmasi> {
  TextEditingController txtSearch = new TextEditingController();

  ServiceTraining serviceTraining = new ServiceTraining();
  MyController myController = Get.find<MyController>();
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();
  Future<TrainingResHeader>? listRes;
  int totalItem = 0;
  int totalPage = 0;
  int limit = 3;
  int offset = 0;
  int page = 1;

  String? id = '';
  String? role = '';
  String? name = '';
  String? username = '';
  String? divisi = '';
  String? ttdPertama = '';
  String? userUpper = '';

  @override
  void initState() {
    super.initState();
    getRole();
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      name = preferences.getString("name");
      username = preferences.getString("username");
      userUpper = username?.toUpperCase();
      divisi = preferences.getString("divisi");
      ttdPertama = preferences.getString("ttduser");

      callApi(id!, '', txtSearch.text, limit, offset);
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      callApi(myController.sessionId, '', txtSearch.text, limit, offset);
    });
  }

  handleSearch(dynamic returnVal,
      {int limitVal = 3, int offsetVal = 0, int pageVal = 1}) {
    setState(() {
      page = pageVal;
      limit = limitVal;
      offset = offsetVal;

      callApi(myController.sessionId, '', txtSearch.text, limit, offset);
    });
  }

  int initalizePage(int totalData) {
    int totalPages = (totalData / limit).floor();
    if (totalData / limit > totalPages) {
      totalPages += 1;
    }

    return totalPages;
  }

  void callApi(String _idTrainer, String _selectedDate, String search,
      int _limit, int _offset) {
    print("""
      Tanggal dipilih: $_selectedDate,
      limit: $_limit,
      offset: $_offset,
      """);

    listRes = serviceTraining.getHeaderTrainer(
      mounted,
      context,
      idTrainer: _idTrainer,
      selectedDate: _selectedDate,
      status: 'CONFIRMED',
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
          builder: (context, AsyncSnapshot<TrainingResHeader> snapshot) {
            if (snapshot.hasData && snapshot.data!.count! > 0) {
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
        Flexible(
          child: FutureBuilder(
            future: listRes,
            builder: (context, AsyncSnapshot<TrainingResHeader> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.total! > 0) {
                  return RefreshIndicator(
                    child: Training_itemlist(
                      itemList: snapshot.data!,
                      isHorizontal: meController.isHorizontal.value,
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