import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/econtract/search_contract.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/monitoring.dart';

SliverToBoxAdapter areaLoading({bool isHorizontal}) {
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

SliverPadding areaHeaderMonitoring({bool isHorizontal}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: isHorizontal ? 35.r : 15.r,
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
                fontSize: isHorizontal ? 35.sp : 21.sp,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: isHorizontal ? 20.sp : 10.h,
            ),
          ]),
    ),
  );
}

SliverPadding areaMonitoring(List<Monitoring> item, BuildContext context,
    String ttdPertama, String username, String divisi,
    {bool isHorizontal}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 35.r : 15.r, vertical: 0.r),
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
    {bool isHorizontal}) {
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
              width: isHorizontal ? 370.w : 230.w,
              height: isHorizontal ? 370.h : 230.h,
            ),
          ),
          Text(
            'Data tidak ditemukan',
            style: TextStyle(
              fontSize: isHorizontal ? 28.sp : 18.sp,
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
              height: isHorizontal ? 60.h : 40.h,
              width: isHorizontal ? 90.w : 130.w,
              borderRadius: 30.0.r,
              color: Colors.blue[600],
              child: Text(
                "Search Contract",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 24.sp : 14.sp,
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
    {bool isHorizontal}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: isHorizontal ? 25.r : 15.r,
      vertical: isHorizontal ? 20.r : 10.r,
    ),
    sliver: SliverToBoxAdapter(
      child: isShow
          ? Center(
              child: ArgonButton(
                height: isHorizontal ? 60.h : 40.h,
                width: isHorizontal ? 90.w : 130.w,
                borderRadius: 30.0.r,
                color: Colors.blue[600],
                child: Text(
                  "Selengkapnya",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isHorizontal ? 24.sp : 14.sp,
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
    {bool isHorizontal}) {
  return InkWell(
    child: Container(
      margin: EdgeInsets.symmetric(
        vertical: 7.r,
      ),
      padding: EdgeInsets.all(
        isHorizontal ? 20.r : 15.r,
      ),
      height: isHorizontal ? 176.h : 115.h,
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
              item[index].namaUsaha != null
                  ? item[index].namaUsaha
                  : item[index].customerShipName,
              style: TextStyle(
                fontSize: isHorizontal ? 28.sp : 18.sp,
                fontFamily: 'Segoe Ui',
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 25.h : 15.h,
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
                      fontSize: isHorizontal ? 23.sp : 13.sp,
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
                      fontSize: isHorizontal ? 26.sp : 16.sp,
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
                      fontSize: isHorizontal ? 23.sp : 13.sp,
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
                      fontSize: isHorizontal ? 26.sp : 16.sp,
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
      getCustomerContractNew(
        context: context,
        divisi: divisi,
        username: username,
        ttdPertama: ttdPertama,
        idCust: item[index].idCustomer,
        isSales: true,
        isContract: false,
        isHorizontal: isHorizontal,
      );
    },
  );
}
