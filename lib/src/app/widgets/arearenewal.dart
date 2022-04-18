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

SliverPadding areaHeaderRenewal() {
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
              'Pembaruan Kontrak',
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

SliverPadding areaRenewal(List<Contract> item, BuildContext context,
    String ttdPertama, String username, String divisi) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 0.r),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return itemRenewal(
              item, index, context, ttdPertama, username, divisi);
        },
        childCount: item.length,
      ),
    ),
  );
}

Widget itemRenewal(List<Contract> item, int index, BuildContext context,
    String ttdPertama, String username, String divisi) {
  return InkWell(
    child: Container(
      margin: EdgeInsets.only(
        bottom: 10.r,
      ),
      padding: EdgeInsets.all(15.r),
      height: 80,
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
            width: 35.r,
            height: 35.r,
          ),
          SizedBox(
            width: 10.w,
          ),
          Expanded(
            flex: 1,
            child: Text(
              item[index].customerShipName != null
                  ? item[index].customerShipName
                  : '-',
              style: TextStyle(
                fontSize: 14.sp,
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
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Segoe ui',
                  color: Colors.black,
                ),
              ),
              Text(
                item[index].status,
                style: TextStyle(
                  fontSize: 14.sp,
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

SliverPadding areaRenewalNotFound(BuildContext context) {
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

SliverPadding areaButtonRenewal(BuildContext context, bool isShow) {
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
