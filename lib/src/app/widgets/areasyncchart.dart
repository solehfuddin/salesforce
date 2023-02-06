import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/detail_sales.dart';
import 'package:sample/src/domain/entities/piereport.dart';
import 'package:sample/src/domain/entities/salesPerform.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// dynamic _startDate;
// dynamic _endDate;

List<Color> colorList = [
  Colors.green.shade500,
  Colors.deepOrange.shade400,
  Colors.grey.shade500,
  Colors.blue.shade500,
  Colors.red.shade500,
  Colors.purple.shade400,
  Colors.teal.shade500,
];

List<Color> bgList = [
  Colors.green.shade400,
  Colors.deepOrange.shade300,
  Colors.grey.shade400,
  Colors.blue.shade300,
  Colors.red.shade400,
  Colors.purple.shade300,
  Colors.teal.shade400,
];

SliverPadding areaDonutChartHor({
  List<PieReport>? dataPie,
  String startDate = '',
  String endDate = '',
  List<SalesPerform>? sales,
  dynamic totalSales,
  BuildContext? context,
}) {
  // _startDate = startDate;
  // _endDate = endDate;
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
      vertical: 10.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5.r),
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
                            fontSize: 12.sp,
                            fontFamily: 'Segoe Ui',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          labelPosition: ChartDataLabelPosition.inside,
                        ),
                        animationDuration: 1000,
                        innerRadius: '63%',
                        radius: '75%',
                        explode: true,
                        strokeColor: Colors.white,
                        strokeWidth: 2.5,
                        explodeIndex: dataPie!.length == 5 ? 4 : 0,
                      ),
                    ],
                    onChartTouchInteractionDown: (tapArgs) {
                      print('Tapped ${tapArgs.position}');
                    },
                  ),
                ),
              ],
            ),
          ),
          infoSales(
              sales: sales,
              totalSales: totalSales,
              context: context,
              stDate: startDate,
              edDate: endDate),
        ],
      ),
    ),
  );
}

Widget infoSales({
  BuildContext? context,
  List<SalesPerform>? sales,
  dynamic totalSales,
  String stDate = '',
  String edDate = '',
}) {
  final itemList = <Widget>[];
  for (int i = 0; i < sales!.length; i++) {
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
    flex: 6,
    child: Column(
      children: itemList,
    ),
  );
}

SliverPadding areaDonutChart(
    {List<PieReport>? dataPie, String startDate = '', String endDate = ''}) {
  // _startDate = startDate;
  // _endDate = endDate;
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15.r,
      vertical: 0.r,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            height: 260.h,
            padding: EdgeInsets.all(10.r),
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
                    labelPosition: ChartDataLabelPosition.inside,
                  ),
                  animationDuration: 1000,
                  innerRadius: '63%',
                  radius: '75%',
                  explode: true,
                  strokeColor: Colors.white,
                  strokeWidth: 2.5,
                  explodeIndex: dataPie!.length == 5 ? 4 : 0,
                ),
              ],
              onChartTouchInteractionDown: (tapArgs) {
                print('Tapped ${tapArgs.position}');
              },
            ),
          ),
        ],
      ),
    ),
  );
}

SliverPadding areaInfoDonut(
    {List<SalesPerform>? sales,
    dynamic totalSales,
    BuildContext? context,
    String stDate = '',
    String edDate = ''}) {
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
            sales!,
            index,
            totalSales,
            context: context,
            isHorizontal: false,
            stDate: stDate,
            edDate: edDate,
          );
        },
        childCount: sales!.length,
      ),
    ),
  );
}

Widget itemInfo(List<SalesPerform> sales, int position, dynamic totalSales,
    {BuildContext? context,
    bool isHorizontal = false,
    String stDate = '',
    String edDate = ''}) {
  double perc = double.tryParse(sales[position].penjualan)! / totalSales * 100;
  return Container(
    child: Card(
      color: colorList[position],
      elevation: 2,
      child: ClipPath(
        child: InkWell(
          child: Container(
            height: isHorizontal ? 55.h : 55.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 10.r : 15.r,
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
                          fontSize: isHorizontal ? 16.sp : 17.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        capitalize(sales[position].salesPerson),
                        style: TextStyle(
                          fontSize: isHorizontal ? 14.sp : 14.sp,
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
                        fontSize: isHorizontal ? 16.sp : 17.sp,
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
              context!,
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

detailPerform(BuildContext context,
    {SalesPerform? sales,
    int position = 0,
    bool isHorizontal = false,
    String stDate = '',
    String edDate = ''}) {
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

SliverPadding areaInfoDonutUser(
    {List<SalesPerform>? sales,
    dynamic totalSales,
    BuildContext? context,
    String stDate = '',
    String edDate = '',
    bool isHorizontal = false}) {
  return SliverPadding(
    padding: EdgeInsets.only(
      left: isHorizontal ? 16.r : 15.r,
      right: isHorizontal ? 16.r : 15.r,
      bottom: 20.r,
    ),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return itemInfoUser(
            sales!,
            index,
            totalSales,
            context: context,
            isHorizontal: isHorizontal,
            stDate: stDate,
            edDate: edDate,
          );
        },
        childCount: sales!.length,
      ),
    ),
  );
}

Widget itemInfoUser(List<SalesPerform> sales, int position, dynamic totalSales,
    {BuildContext? context,
    bool isHorizontal = false,
    String stDate = '',
    String edDate = ''}) {
  double perc = double.tryParse(sales[position].penjualan)! / totalSales * 100;
  return Container(
    margin: EdgeInsets.only(
      bottom: isHorizontal ? 2.h : 1.h,
    ),
    child: Card(
      color: colorList[position],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipPath(
        child: InkWell(
          child: Container(
            height: isHorizontal ? 55.h : 40.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 13.r : 10.r,
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
                        capitalize(sales[position].salesPerson),
                        style: TextStyle(
                          fontSize: isHorizontal ? 16.sp : 14.sp,
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
                        fontSize: isHorizontal ? 20.sp : 17.sp,
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
