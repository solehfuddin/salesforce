import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/detail_sales.dart';
import 'package:sample/src/domain/entities/piereport.dart';
import 'package:sample/src/domain/entities/report.dart';
import 'package:sample/src/domain/entities/salesPerform.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

dynamic _startDate;
dynamic _endDate;

List<Color> colorList = [
  Colors.green[500],
  Colors.deepOrange[400],
  Colors.grey[500],
  Colors.blue[500],
  Colors.red[500],
  Colors.purple[400],
  Colors.teal[500],
];

List<Color> bgList = [
  Colors.green[400],
  Colors.deepOrange[300],
  Colors.grey[400],
  Colors.blue[300],
  Colors.red[400],
  Colors.purple[300],
  Colors.teal[400],
];

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
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
      vertical: 10.r,
    ),
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

SliverPadding areaDonutChartHor({
  List<PieReport> dataPie,
  String startDate,
  String endDate,
  List<SalesPerform> sales,
  dynamic totalSales,
  BuildContext context,
}) {
  _startDate = startDate;
  _endDate = endDate;
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
      vertical: 5.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(15.r),
                child: SfCircularChart(
                  series: [
                    DoughnutSeries<PieReport, String>(
                      dataSource: dataPie,
                      xValueMapper: (PieReport data, _) => data.salesName,
                      yValueMapper: (PieReport data, _) => data.value,
                      pointColorMapper: (PieReport data, _) => data.color,
                      pointRadiusMapper: (PieReport data, _) => data.size,
                      dataLabelMapper: (PieReport data, _) => data.perc,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          fontSize: 22.sp,
                          fontFamily: 'Segoe Ui',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      enableSmartLabels: false,
                      animationDuration: 1000,
                      innerRadius: '63%',
                      radius: '75%',
                      explode: true,
                      strokeColor: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ],
                  onPointTapped: (pointTapArgs) {
                    print('Tapped ${pointTapArgs.pointIndex}');
                  },
                ),
              ),
            ],
          ),
          infoSales(
              sales: sales,
              totalSales: totalSales,
              context: context,
              stDate: _startDate,
              edDate: _endDate),
        ],
      ),
    ),
  );
}

SliverPadding areaDonutChartHorUser({
  List<PieReport> dataPie,
  String startDate,
  String endDate,
  List<SalesPerform> sales,
  dynamic totalSales,
  BuildContext context,
}) {
  _startDate = startDate;
  _endDate = endDate;
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
      vertical: 5.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(15.r),
                child: SfCircularChart(
                  series: [
                    DoughnutSeries<PieReport, String>(
                      dataSource: dataPie,
                      xValueMapper: (PieReport data, _) => data.salesName,
                      yValueMapper: (PieReport data, _) => data.value,
                      pointColorMapper: (PieReport data, _) => data.color,
                      pointRadiusMapper: (PieReport data, _) => data.size,
                      dataLabelMapper: (PieReport data, _) => data.perc,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          fontSize: 22.sp,
                          fontFamily: 'Segoe Ui',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      enableSmartLabels: false,
                      animationDuration: 1000,
                      innerRadius: '63%',
                      radius: '75%',
                      explode: true,
                      strokeColor: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ],
                  onPointTapped: (pointTapArgs) {
                    print('Tapped ${pointTapArgs.pointIndex}');
                  },
                ),
              ),
            ],
          ),
          infoSalesUser(
              sales: sales,
              totalSales: totalSales,
              context: context,
              stDate: _startDate,
              edDate: _endDate),
        ],
      ),
    ),
  );
}

Widget infoSales({
  BuildContext context,
  List<SalesPerform> sales,
  dynamic totalSales,
  String stDate,
  String edDate,
}) {
  final itemList = <Widget>[];
  for (int i = 0; i < sales.length; i++) {
    itemList.add(itemInfo(
      sales,
      i,
      totalSales,
      context: context,
      isHorizontal: true,
      stDate: stDate,
      edDate: edDate,
    ));
  }
  return Expanded(
    flex: 1,
    child: Column(
      children: itemList,
    ),
  );
}

Widget infoSalesUser({
  BuildContext context,
  List<SalesPerform> sales,
  dynamic totalSales,
  String stDate,
  String edDate,
}) {
  final itemList = <Widget>[];
  for (int i = 0; i < sales.length; i++) {
    itemList.add(itemInfoUser(
      sales,
      i,
      totalSales,
      context: context,
      isHorizontal: true,
      stDate: stDate,
      edDate: edDate,
    ));
  }
  return Expanded(
    flex: 1,
    child: Column(
      children: itemList,
    ),
  );
}

SliverPadding areaDonutChart(
    {List<PieReport> dataPie, String startDate, String endDate}) {
  _startDate = startDate;
  _endDate = endDate;
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
      vertical: 5.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15.r),
            child: SfCircularChart(
              series: [
                DoughnutSeries<PieReport, String>(
                  dataSource: dataPie,
                  xValueMapper: (PieReport data, _) => data.salesName,
                  yValueMapper: (PieReport data, _) => data.value,
                  pointColorMapper: (PieReport data, _) => data.color,
                  pointRadiusMapper: (PieReport data, _) => data.size,
                  dataLabelMapper: (PieReport data, _) => data.perc,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'Segoe Ui',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  enableSmartLabels: false,
                  animationDuration: 1000,
                  innerRadius: '63%',
                  radius: '75%',
                  explode: true,
                  strokeColor: Colors.white,
                  strokeWidth: 2.5,
                ),
              ],
              onPointTapped: (pointTapArgs) {
                print('Tapped ${pointTapArgs.pointIndex}');
              },
            ),
          ),
        ],
      ),
    ),
  );
}

SliverPadding areaInfoDonut(
    {List<SalesPerform> sales,
    dynamic totalSales,
    BuildContext context,
    String stDate,
    String edDate}) {
  return SliverPadding(
    padding: EdgeInsets.only(
      left: 15.r,
      right: 15.r,
      bottom: 20.r,
    ),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return itemInfo(
            sales,
            index,
            totalSales,
            context: context,
            isHorizontal: false,
            stDate: stDate,
            edDate: edDate,
          );
        },
        childCount: sales.length,
      ),
    ),
  );
}

SliverPadding areaInfoDonutUser(
    {List<SalesPerform> sales,
    dynamic totalSales,
    BuildContext context,
    String stDate,
    String edDate}) {
  return SliverPadding(
    padding: EdgeInsets.only(
      left: 15.r,
      right: 15.r,
      bottom: 20.r,
    ),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return itemInfoUser(
            sales,
            index,
            totalSales,
            context: context,
            isHorizontal: false,
            stDate: stDate,
            edDate: edDate,
          );
        },
        childCount: sales.length,
      ),
    ),
  );
}

Widget itemInfo(List<SalesPerform> sales, int position, dynamic totalSales,
    {BuildContext context, bool isHorizontal, String stDate, String edDate}) {
  double perc = double.tryParse(sales[position].penjualan) / totalSales * 100;
  return Container(
    child: Card(
      color: colorList[position],
      elevation: 2,
      child: ClipPath(
        child: InkWell(
          child: Container(
            height: isHorizontal ? 80.h : 55.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 20.r : 15.r,
                vertical: isHorizontal ? 4.r : 3.r,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${perc.toStringAsFixed(2)} %",
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 17.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        sales[position].salesPerson,
                        style: TextStyle(
                          fontSize: isHorizontal ? 20.sp : 14.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      "Rp ${convertThousand(double.tryParse(sales[position].penjualan), 2)}",
                      style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 17.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            detailPerform(
              context,
              sales: sales[position],
              position: position,
              isHorizontal: isHorizontal,
              stDate: stDate,
              edDate: edDate,
            );
          },
        ),
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
      ),
    ),
  );
}

Widget itemInfoUser(List<SalesPerform> sales, int position, dynamic totalSales,
    {BuildContext context, bool isHorizontal, String stDate, String edDate}) {
  double perc = sales[position].penjualan != null
      ? double.tryParse(sales[position].penjualan) / totalSales * 100
      : 0;
  return Container(
    child: Card(
      color: colorList[position],
      elevation: 2,
      child: ClipPath(
        child: InkWell(
          child: Container(
            height: isHorizontal ? 80.h : 55.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 20.r : 15.r,
                vertical: isHorizontal ? 4.r : 3.r,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sales[position].salesPerson,
                        style: TextStyle(
                          fontSize: isHorizontal ? 20.sp : 14.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      "${perc.toStringAsFixed(2)} %",
                      style: TextStyle(
                        fontSize: isHorizontal ? 24.sp : 17.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {},
        ),
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
      ),
    ),
  );
}

detailPerform(BuildContext context,
    {SalesPerform sales,
    int position,
    bool isHorizontal,
    String stDate,
    String edDate}) {
  return showModalBottomSheet(
    elevation: 2,
    backgroundColor: bgList[position],
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isHorizontal ? 25.r : 15.r),
        topRight: Radius.circular(isHorizontal ? 25.r : 15.r),
      ),
    ),
    context: context,
    builder: (context) {
      return DetailSales(
        startDate: stDate,
        endDate: edDate,
        sales: sales,
        position: position,
      );
    },
  );
}
