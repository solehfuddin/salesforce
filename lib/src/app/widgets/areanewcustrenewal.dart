import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/econtract/contract_newcust.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';

SliverToBoxAdapter areaLoadingNewcustRenewal({bool isHorizontal = false}) {
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

SliverPadding areaHeaderNewcustRenewal({bool isHorizontal = false}) {
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
              'Pembaruan Kontrak (Kustomer Baru)',
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

SliverPadding areaNewcustRenewal(List<Contract> item, BuildContext context,
    String ttdPertama, String username, String divisi,
    {bool isHorizontal = false}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 20.r : 15.r, vertical: 0.r),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return itemNewcustRenewal(
              item, index, context, ttdPertama, username, divisi,
              isHorizontal: isHorizontal);
        },
        childCount: item.length,
      ),
    ),
  );
}

Widget itemNewcustRenewal(List<Contract> item, int index, BuildContext context,
    String ttdPertama, String username, String divisi,
    {bool isHorizontal = false}) {
  return InkWell(
    child: Container(
      margin: EdgeInsets.only(bottom: 5.r, top: 5.r),
      padding: EdgeInsets.all(
        isHorizontal ? 15.r : 10.r,
      ),
      height: isHorizontal ? 120.h : 80.h,
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
            width: isHorizontal ? 45.r : 35.r,
            height: isHorizontal ? 45.r : 35.r,
          ),
          SizedBox(
            width: isHorizontal ? 5.w : 10.w,
          ),
          Expanded(
            flex: 1,
            child: Text(
              item[index].customerShipName != ''
                  ? item[index].customerShipName.toUpperCase()
                  : '-',
              style: TextStyle(
                fontSize: isHorizontal ? 20.sp : 14.sp,
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
                  fontSize: isHorizontal ? 20.sp : 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Segoe ui',
                  color: Colors.black,
                ),
              ),
              Text(
                item[index].status,
                style: TextStyle(
                  fontSize: isHorizontal ? 20.sp : 14.sp,
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
      item[index].idCustomer != ''
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
                  isNewCust: true,
                ),
              ),
            )
          : handleStatus(
              context,
              'Id customer tidak ditemukan',
              false,
              isHorizontal: isHorizontal,
              isLogout: false,
            );
    },
  );
}

SliverPadding areaNewcustRenewalNotFound(
  BuildContext context, {
  bool isHorizontal = false,
  List<Contract>? item,
}) {
  onButtonPressed() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContractNewcust(
          len: 0,
        ),
      ),
    );

    return () {};
  }

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
            child: EasyButton(
              idleStateWidget: Text(
                "Search Contract",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 14.sp : 12.sp,
                    fontWeight: FontWeight.w700),
              ),
              loadingStateWidget: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
              useEqualLoadingStateWidgetDimension: true,
              useWidthAnimation: true,
              height: isHorizontal ? 40.h : 35.h,
              width: isHorizontal ? 80.w : 120.w,
              borderRadius: 30.r,
              buttonColor: Colors.blue.shade600,
              elevation: 2.0,
              contentGap: 6.0,
              onPressed: onButtonPressed,
            ),
          ),
        ],
      ),
    ),
  );
}

SliverPadding areaButtonNewcustRenewal(
  BuildContext context,
  bool isShow, {
  bool isHorizontal = false,
  List<Contract>? item,
}) {
  onButtonPressed() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContractNewcust(
          len: item!.length,
        ),
      ),
    );

    return () {};
  }

  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: isHorizontal ? 25.r : 15.r,
      vertical: isHorizontal ? 10.r : 5.r,
    ),
    sliver: SliverToBoxAdapter(
      child: isShow
          ? Center(
              child: EasyButton(
                idleStateWidget: Text(
                  "Selengkapnya",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isHorizontal ? 18.sp : 14.sp,
                      fontWeight: FontWeight.w700),
                ),
                loadingStateWidget: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
                useEqualLoadingStateWidgetDimension: true,
                useWidthAnimation: true,
                height: isHorizontal ? 50.h : 40.h,
                width: isHorizontal ? 100.w : 130.w,
                borderRadius: 30.r,
                buttonColor: Colors.blue.shade600,
                elevation: 2.0,
                contentGap: 6.0,
                onPressed: onButtonPressed,
              ),
            )
          : SizedBox(
              height: 5.h,
            ),
    ),
  );
}
