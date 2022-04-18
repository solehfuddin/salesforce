import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/econtract/search_contract.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/monitoring.dart';

SliverToBoxAdapter areaLoading() {
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
              fontSize: 15.sp,
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

SliverPadding areaHeaderMonitoring() {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
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
                fontSize: 23.sp,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
          ]),
    ),
  );
}

SliverPadding areaMonitoring(List<Monitoring> item, BuildContext context,
    String ttdPertama, String username, String divisi) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 0.r),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return itemMonitoring(
              item, index, context, ttdPertama, username, divisi);
        },
        childCount: item.length,
      ),
    ),
  );
}

SliverPadding areaMonitoringNotFound(BuildContext context) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
      vertical: 0.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        children: [
          Center(
            child: Image.asset(
              'assets/images/not_found.png',
              width: 300.w,
              height: 300.h,
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
          ),
          SizedBox(
            height: 25.h,
          ),
          Center(
            child: ArgonButton(
              height: 40.h,
              width: 130.w,
              borderRadius: 30.0.r,
              color: Colors.blue[600],
              child: Text(
                "Search Contract",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
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

SliverPadding areaButtonMonitoring(BuildContext context, bool isShow) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
      vertical: 10.r,
    ),
    sliver: SliverToBoxAdapter(
      child: isShow
          ? Center(
              child: ArgonButton(
                height: 40.h,
                width: 130.w,
                borderRadius: 30.0.r,
                color: Colors.blue[600],
                child: Text(
                  "Selengkapnya",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
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
    String ttdPertama, String username, String divisi) {
  return InkWell(
    child: Container(
      margin: EdgeInsets.symmetric(
        vertical: 7.r,
      ),
      padding: EdgeInsets.all(
        15.r,
      ),
      height: 115.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: Colors.black26,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item[index].namaUsaha,
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Segoe Ui',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 15.h,
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
                      fontSize: 13.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Text(
                    capitalize(item[index].status.toLowerCase()),
                    style: TextStyle(
                      fontSize: 16.sp,
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
                      fontSize: 13.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Text(
                    getEndDays(input: item[index].endDateContract),
                    style: TextStyle(
                      fontSize: 16.sp,
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
      );
    },
  );
}
