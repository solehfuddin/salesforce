import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/econtract/search_contract.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/monitoring.dart';

SliverToBoxAdapter areaLoading({bool isHorizontal = false}) {
  return SliverToBoxAdapter(
    child: Column(
      children: [
        SizedBox(
          height: 15.h,
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
        SizedBox(
          height: 10.h,
        ),
        Center(
          child: Text(
            'Processing ...',
            style: TextStyle(
              fontSize: isHorizontal ? 25.sp : 15.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
      ],
    ),
  );
}

SliverPadding areaHeaderMonitoring({bool isHorizontal = false}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: isHorizontal ? 18.r : 18.r,
      vertical: 5.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Kontrak segera berakhir',
              style: TextStyle(
                fontSize: isHorizontal ? 21.sp : 18.sp,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: isHorizontal ? 5.sp : 0.h,
            ),
          ]),
    ),
  );
}

SliverPadding areaMonitoring(List<Monitoring> item, BuildContext context,
    String ttdPertama, String username, String divisi,
    {bool isHorizontal = false}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 20.r : 15.r, vertical: 0.r),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return itemMonitoring(
            item,
            index,
            context,
            ttdPertama,
            username,
            divisi,
            isHorizontal: isHorizontal,
          );
        },
        childCount: item.length,
      ),
    ),
  );
}

SliverPadding areaMonitoringNotFound(BuildContext context,
    {bool isHorizontal = false}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
      vertical: isHorizontal ? 5.r : 0.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        children: [
          Center(
            child: Image.asset(
              'assets/images/not_found.png',
              width: isHorizontal ? 160.w : 180.w,
              height: isHorizontal ? 160.h : 180.h,
            ),
          ),
          Text(
            'Data tidak ditemukan',
            style: TextStyle(
              fontSize: isHorizontal ? 16.sp : 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(
            height: isHorizontal ? 35.h : 25.h,
          ),
          Center(
            child: ArgonButton(
              height: isHorizontal ? 40.h : 35.h,
              width: isHorizontal ? 80.w : 120.w,
              borderRadius: 30.0.r,
              color: Colors.blue[600],
              child: Text(
                "Search Contract",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 14.sp : 12.sp,
                    fontWeight: FontWeight.w700),
              ),
              loader: Container(
                padding: EdgeInsets.all(8.r),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              onTap: (startLoading, stopLoading, btnState) {
                if (btnState == ButtonState.Idle) {
                  startLoading();
                  waitingLoad();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchContract(),
                    ),
                  );
                  stopLoading();
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

SliverPadding areaButtonMonitoring(BuildContext context, bool isShow,
    {bool isHorizontal = false}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: isHorizontal ? 20.r : 15.r,
      vertical: isHorizontal ? 10.r : 5.r,
    ),
    sliver: SliverToBoxAdapter(
      child: isShow
          ? Center(
              child: ArgonButton(
                height: isHorizontal ? 50.h : 40.h,
                width: isHorizontal ? 100.w : 130.w,
                borderRadius: 30.0.r,
                color: Colors.blue[600],
                child: Text(
                  "Selengkapnya",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isHorizontal ? 18.sp : 14.sp,
                      fontWeight: FontWeight.w700),
                ),
                loader: Container(
                  padding: EdgeInsets.all(8.r),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                onTap: (startLoading, stopLoading, btnState) {
                  if (btnState == ButtonState.Idle) {
                    startLoading();
                    waitingLoad();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchContract(),
                      ),
                    );
                    stopLoading();
                  }
                },
              ),
            )
          : SizedBox(
              height: 5.h,
            ),
    ),
  );
}

Widget itemMonitoring(List<Monitoring> item, int index, BuildContext context,
    String ttdPertama, String username, String divisi,
    {bool isHorizontal = false}) {
  return InkWell(
    child: Container(
      margin: EdgeInsets.symmetric(
        vertical: 7.r,
      ),
      padding: EdgeInsets.all(
        isHorizontal ? 15.r : 15.r,
      ),
      height: isHorizontal ? 110.h : 100.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isHorizontal ? 20.r : 15.r),
        border: Border.all(
          color: Colors.black26,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              item[index].namaUsaha != ''
                  ? item[index].namaUsaha
                  : item[index].customerShipName,
              style: TextStyle(
                fontSize: isHorizontal ? 18.sp : 16.sp,
                fontFamily: 'Segoe Ui',
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 10.h : 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: isHorizontal ? 15.sp : 13.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 5.h : 2.h,
                  ),
                  Text(
                    capitalize(item[index].status.toLowerCase()),
                    style: TextStyle(
                      fontSize: isHorizontal ? 18.sp : 16.sp,
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sisa Kontrak',
                    style: TextStyle(
                      fontSize: isHorizontal ? 15.sp : 13.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(
                    height: isHorizontal ? 5.h : 2.h,
                  ),
                  Text(
                    getEndDays(input: item[index].endDateContract),
                    style: TextStyle(
                      fontSize: isHorizontal ? 18.sp : 16.sp,
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
    onTap: () {
      print('ID CUSTOMER : ${item[index].idCustomer}');
      getMonitoringContractNew(
        context: context,
        divisi: divisi,
        username: username,
        ttdPertama: ttdPertama,
        idCust: item[index].idCustomer,
        isSales: true,
        isContract: false,
        isHorizontal: isHorizontal,
        isNewCust: item[index].idCustomer.contains("O") ? false : true,
      );
    },
  );
}
