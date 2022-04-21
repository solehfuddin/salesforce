import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/domain/entities/piereport.dart';
import 'package:sample/src/domain/entities/report.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

SliverPadding areaLineChartSync({List<Report> reportData}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
      vertical: 10.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Card(
        color: Colors.white,
        elevation: 3.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15.r),
              child: SfCartesianChart(
                title: ChartTitle(
                  text: 'Data Penjualan Sales',
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'Segoe Ui',
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.scroll,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                ),
                series: <ChartSeries>[
                  LineSeries<Report, String>(
                    dataSource: reportData,
                    xValueMapper: (Report data, _) => data.category,
                    yValueMapper: (Report data, _) => data.sales1,
                    name: "Sales A",
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                  LineSeries<Report, String>(
                    dataSource: reportData,
                    xValueMapper: (Report data, _) => data.category,
                    yValueMapper: (Report data, _) => data.sales2,
                    name: "Sales B",
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                  LineSeries<Report, String>(
                    dataSource: reportData,
                    xValueMapper: (Report data, _) => data.category,
                    yValueMapper: (Report data, _) => data.sales3,
                    name: "Sales C",
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                  LineSeries<Report, String>(
                    dataSource: reportData,
                    xValueMapper: (Report data, _) => data.category,
                    yValueMapper: (Report data, _) => data.sales4,
                    name: "Sales D",
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                ],
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(
                    width: 0,
                  ),
                ),
                plotAreaBorderWidth: 0,
                borderWidth: 0,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

SliverPadding areaPieChartSync({List<PieReport> dataPie}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 10.r,),
    sliver: SliverToBoxAdapter(
      child: Card(
        elevation: 3.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            15.r,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(
                15.r,
              ),
              child: SfCircularChart(
                series: [
                  PieSeries<PieReport, String>(
                    dataSource: dataPie,
                    xValueMapper: (PieReport data, _) => data.salesName,
                    yValueMapper: (PieReport data, _) => data.value,
                    pointColorMapper: (PieReport data, _) => data.color,
                    radius: '85%',
                    explodeGesture: ActivationMode.doubleTap,
                    explode: true,
                    selectionBehavior: SelectionBehavior(
                      enable: true,
                    ),
                    dataLabelMapper: (PieReport data, _) => data.perc,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                    ),
                    animationDuration: 3000,
                  ),
                ],
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  width: '100%',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
