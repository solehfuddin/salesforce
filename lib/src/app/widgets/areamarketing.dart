import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_approval.dart';
import 'package:sample/src/app/utils/settings_posmaterial.dart';
import 'package:sample/src/app/widgets/cardmarketing.dart';

SliverPadding areaMarketing(
  bool isHorizontal,
  BuildContext context,
  int totalPosMaterial,
) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: isHorizontal ? 18.r : 18.r,
      vertical: isHorizontal ? 20.r : 13.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marketing Fitur',
            style: TextStyle(
              fontSize: isHorizontal ? 21.sp : 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 15.h,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CardMarketing(
                  totalPos: totalPosMaterial,
                  isHorizontal: isHorizontal,
                  cardIcon: 'assets/images/pos_material.png',
                  cardTitle: setMarketingFeature(MarketingFeature.POS_MATERIAL),
                  cardSubtitle: 'Max 3% dari penjualan',
                  navigateTo: PosMaterialApproval(),
                ),
                SizedBox(
                  width: 12.w,
                ),
                CardMarketing(
                  totalCashback: 0,
                  isHorizontal: isHorizontal,
                  cardIcon: 'assets/images/cashback.png',
                  cardTitle: setMarketingFeature(MarketingFeature.CASHBACK),
                  cardSubtitle: 'Max 10% dari penjualan',
                  navigateTo: null,
                ),
                SizedBox(
                  width: 12.w,
                ),
                CardMarketing(
                  totalExpense: 0,
                  isHorizontal: isHorizontal,
                  cardIcon: 'assets/images/pos_material.png',
                  cardTitle: setMarketingFeature(MarketingFeature.MARKETING_EXPENSE),
                  cardSubtitle: 'Max 5% dari penjualan',
                  navigateTo: null,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
