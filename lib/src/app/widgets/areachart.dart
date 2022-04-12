import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/widgets/indicator.dart';

int touchedIndex = -1;
int touchedGroupIndex = -1;

SliverPadding areaChartDonuts() {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 15,
    ),
    sliver: SliverToBoxAdapter(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Penjualan',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: Card(
                  color: Colors.white,
                  elevation: 3.5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.2,
                          child: PieChart(
                            PieChartData(
                              pieTouchData:
                                  PieTouchData(touchCallback: (pieTouchResponse) {
                                state(() {
                                  if (pieTouchResponse.touchInput
                                          is FlLongPressEnd ||
                                      pieTouchResponse.touchInput is FlPanEnd) {
                                    touchedIndex = -1;
                                  } else {
                                    touchedIndex =
                                        pieTouchResponse.touchedSectionIndex;
                                  }
                                });
                              }),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              sections: showingSections(),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Indicator(
                            color: Color(0xff0293ee),
                            text: 'Sales A',
                            isSquare: true,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Indicator(
                            color: Color(0xfff8b250),
                            text: 'Sales B',
                            isSquare: true,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Indicator(
                            color: Color(0xff845bef),
                            text: 'Sales C',
                            isSquare: true,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Indicator(
                            color: Color(0xff13d38e),
                            text: 'Sales D',
                            isSquare: true,
                          ),
                          SizedBox(
                            height: 18,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 35,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

SliverPadding areaChart({List<BarChartGroupData> rawBarGroups, List<BarChartGroupData> showingBarGroups}) {
  return SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 15,
    ),
    sliver: SliverToBoxAdapter(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              AspectRatio(
                aspectRatio: 1.2,
                child: Card(
                  elevation: 3.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            iconTransaction(),
                            SizedBox(
                              width: 30,
                            ),
                            Text(
                              'Transaksi',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '/ Semester',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              maxY: 25,
                              borderData: FlBorderData(
                                show: false,
                              ),
                              barGroups: showingBarGroups,
                              barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Colors.grey,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) =>
                                            null,
                                  ),
                                  touchCallback: (response) {
                                    if (response.spot == null) {
                                      state(() {
                                        touchedGroupIndex = -1;
                                        showingBarGroups = List.of(rawBarGroups);
                                      });
                                      return;
                                    }
                                  }),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: SideTitles(
                                  showTitles: true,
                                  getTextStyles: (values) => TextStyle(
                                    color: Colors.black54,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  reservedSize: 42,
                                  getTitles: bottomTitles,
                                ),
                                leftTitles: SideTitles(
                                  showTitles: true,
                                  getTextStyles: (values) => TextStyle(
                                    color: Colors.black54,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  margin: 22,
                                  reservedSize: 28,
                                  interval: 1,
                                  getTitles: leftTitles,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

String bottomTitles(double value) {
  String text;

  switch (value.toInt()) {
    case 0:
      text = 'Jan';
      break;
    case 1:
      text = 'Feb';
      break;
    case 2:
      text = 'Mar';
      break;
    case 3:
      text = 'Apr';
      break;
    case 4:
      text = 'Mei';
      break;
    case 5:
      text = 'Jun';
      break;
    case 6:
      text = 'Jul';
      break;
    case 7:
      text = 'Agt';
      break;
    case 8:
      text = 'Sep';
      break;
    case 9:
      text = 'Okt';
      break;
    case 10:
      text = 'Nov';
      break;
    default:
      text = 'Des';
      break;
  }

  return text;
}

String leftTitles(double value){
  if (value == 0) {
    return '1K';
  }
  else if (value == 10) {
    return '5K';
  }
  else if (value == 19) {
    return '10K';
  } else {
    return '';
  }
}

Widget iconTransaction() {
  const width = 4.5;
  const space = 3.5;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Container(
        width: width,
        height: 7,
        color: Colors.black.withOpacity(0.5),
      ),
      SizedBox(
        width: space,
      ),
      Container(
        width: width,
        height: 14,
        color: Colors.black.withOpacity(0.6),
      ),
      SizedBox(
        width: space,
      ),
      Container(
        width: width,
        height: 21,
        color: Colors.black.withOpacity(0.7),
      ),
    ],
  );
}

List<PieChartSectionData> showingSections() {
  return List.generate(4, (i) {
    final isTouched = i == touchedIndex;
    final fontSize = isTouched ? 18.0 : 12.0;
    final radius = isTouched ? 32.0 : 27.0;
    switch (i) {
      case 0:
        return PieChartSectionData(
          color: const Color(0xff0293ee),
          value: 40,
          title: '40%',
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff)),
        );
      case 1:
        return PieChartSectionData(
          color: const Color(0xfff8b250),
          value: 30,
          title: '30%',
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff)),
        );
      case 2:
        return PieChartSectionData(
          color: const Color(0xff845bef),
          value: 15,
          title: '15%',
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff)),
        );
      case 3:
        return PieChartSectionData(
          color: const Color(0xff13d38e),
          value: 15,
          title: '15%',
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff)),
        );
      default:
        throw Error();
    }
  });
}
