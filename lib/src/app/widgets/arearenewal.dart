import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/pages/renewcontract/complete_renewal.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';

SliverToBoxAdapter areaLoadingRenewal() {
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

SliverPadding areaHeaderRenewal({bool isHorizontal}) {
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
              'Pembaruan Kontrak',
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

SliverPadding areaRenewal(List<Contract> item, BuildContext context,
    String ttdPertama, String username, String divisi, {bool isHorizontal}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(horizontal: isHorizontal ? 35.r : 15.r, vertical: 0.r),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return itemRenewal(
              item, index, context, ttdPertama, username, divisi, isHorizontal: isHorizontal);
        },
        childCount: item.length,
      ),
    ),
  );
}

Widget itemRenewal(List<Contract> item, int index, BuildContext context,
    String ttdPertama, String username, String divisi, {bool isHorizontal}) {
  return InkWell(
    child: Container(
      margin: EdgeInsets.only(
        bottom: 10.r,
      ),
      padding: EdgeInsets.all(isHorizontal ? 20.r : 15.r),
      height: isHorizontal ? 120.h :  80.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(15.r),
        ),
        border: Border.all(
          color: Colors.black26,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/e_contract_new.png',
            filterQuality: FilterQuality.medium,
            width: isHorizontal ? 50.r : 35.r,
            height: isHorizontal ? 50.r : 35.r,
          ),
          SizedBox(
            width: isHorizontal ? 5.w : 10.w,
          ),
          Expanded(
            flex: 1,
            child: Text(
              item[index].customerShipName != null
                  ? item[index].customerShipName
                  : '-',
              style: TextStyle(
                fontSize: isHorizontal ? 22.sp : 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Segoe ui',
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                convertDateWithMonth(item[index].dateAdded),
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Segoe ui',
                  color: Colors.black,
                ),
              ),
              Text(
                item[index].status,
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Segoe ui',
                  color: item[index].status == "ACTIVE"
                      ? Colors.green.shade700
                      : item[index].status == "INACTIVE"
                          ? Colors.red.shade800
                          : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    onTap: () {
      item[index].idCustomer != null
          ? Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailContract(
                  item[index],
                  divisi,
                  ttdPertama,
                  username,
                  false,
                  isContract: true,
                  isAdminRenewal: true,
                ),
              ),
            )
          : handleStatus(context, 'Id customer tidak ditemukan', false);
    },
  );
}

SliverPadding areaRenewalNotFound(BuildContext context, {bool isHorizontal}) {
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
              width: isHorizontal ? 370.w : 300.w,
              height: isHorizontal ? 370.h : 300.h,
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
                      builder: (context) => CompleteRenewal(),
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

SliverPadding areaButtonRenewal(BuildContext context, bool isShow, {bool isHorizontal}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal:  isHorizontal ? 25.r : 15.r,
      vertical: isHorizontal ? 20.r : 10.r,
    ),
    sliver: SliverToBoxAdapter(
      child: isShow
          ? Center(
              child: ArgonButton(
                height: isHorizontal ? 60.h : 40.h,
                width:  isHorizontal ? 90.w : 130.w,
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
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => CompleteRenewal(),
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
