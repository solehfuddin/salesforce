import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_approval.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_approval.dart';
import 'package:sample/src/app/pages/training/training_approval.dart';
import 'package:sample/src/app/utils/settings_posmaterial.dart';
import 'package:sample/src/app/widgets/cardmarketing.dart';

SliverPadding areaMarketing(
  bool isHorizontal,
  BuildContext context,
  int totalPosMaterial,
  int totalMarketingExpense,
  int totalTraining,
  bool isVisible,
  String divisi,
) {
  print("Total Me Card : $totalMarketingExpense");
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: isHorizontal ? 18.r : 18.r,
      vertical: isVisible
          ? isHorizontal
              ? 20.r
              : 13.r
          : 0.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Visibility(
        visible: isVisible,
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
                    cardTitle:
                        setMarketingFeature(MarketingFeature.POS_MATERIAL),
                    cardSubtitle: '3% dari penjualan',
                    navigateTo: PosMaterialApproval(),
                  ),
                  Visibility(
                    visible: divisi == "GM" || divisi == "SALES",
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12.w,
                        ),
                        CardMarketing(
                          totalExpense: totalMarketingExpense,
                          isHorizontal: isHorizontal,
                          cardIcon: 'assets/images/marketing_expense.png',
                          cardTitle: setMarketingFeature(
                              MarketingFeature.MARKETING_EXPENSE),
                          cardSubtitle: '5% dari penjualan',
                          navigateTo: Marketingexpense_Approval(),
                        ),
                      ],
                    ),
                    replacement: SizedBox(
                      height: 10.h,
                    ),
                  ),
                  Visibility(
                    visible: divisi == "MARKETING" || divisi == "SALES",
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12.w,
                        ),
                        CardMarketing(
                          totalTraining: totalTraining,
                          isHorizontal: isHorizontal,
                          cardIcon: 'assets/images/training.png',
                          cardTitle:
                              setMarketingFeature(MarketingFeature.TRAINING),
                          cardSubtitle: 'Pengajuan training',
                          navigateTo: TrainingAprroval(),
                        ),
                      ],
                    ),
                    replacement: SizedBox(
                      height: 10.h,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        replacement: SizedBox(
          width: 5.w,
        ),
      ),
    ),
  );
}
