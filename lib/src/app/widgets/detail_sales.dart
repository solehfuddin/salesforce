import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/salesPerform.dart';
import 'package:sample/src/domain/entities/salesarea.dart';
import 'package:sample/src/domain/entities/salesdetail.dart';
import 'package:http/http.dart' as http;

class DetailSales extends StatefulWidget {
  SalesPerform sales;
  int position;
  String startDate, endDate;

  DetailSales({this.sales, this.position, this.startDate, this.endDate});

  @override
  State<DetailSales> createState() => _DetailSalesState();
}

class _DetailSalesState extends State<DetailSales> {
  List<SalesArea> areaList = [
    SalesArea(
      kodeArea: 'OK1',
      cakupanArea: 'Sumatera Utara & NAD',
    ),
    SalesArea(
      kodeArea: 'OK2',
      cakupanArea:
          'Jabodetabek, Jawa Barat, Banten, Lampung, Sumatera Selatan, Jambi, Bengkulu, Sumatera Barat, Riau, Kepri, Babel & Kalbar',
    ),
    SalesArea(
      kodeArea: 'OK3',
      cakupanArea: 'Jawa Tengah & DI Yogyakarta',
    ),
    SalesArea(
      kodeArea: 'OK4',
      cakupanArea:
          'Jawa Timur, Bali, NTB, NTT, Sulawesi, Maluku, Papua, Kalsel, Kalteng, Kaltim & Kaltara',
    ),
    SalesArea(
      kodeArea: 'MK1',
      cakupanArea: 'Sumatera Utara & NAD',
    ),
    SalesArea(
      kodeArea: 'MK2',
      cakupanArea:
          'Jabodetabek, Jawa Barat, Banten, Lampung, Sumatera Selatan, Jambi, Bengkulu, Sumatera Barat, Riau, Kepri, Kalimantan',
    ),
    SalesArea(
      kodeArea: 'MK3',
      cakupanArea: 'Jawa Tengah & DI Yogyakarta',
    ),
    SalesArea(
      kodeArea: 'MK4',
      cakupanArea: 'Jawa Timur, Bali, NTB, NTT, Sulawesi, Maluku & Papua',
    ),
  ];

  Future<List<SalesDetail>> getSalesDetail(BuildContext context,
      {String stDate,
      String edDate,
      dynamic salesRepId,
      bool isHorizontal}) async {
    const timeout = 15;
    List<SalesDetail> list = List.empty(growable: true);
    List<SalesDetail> dummyList = List.empty(growable: true);

    list.clear();
    dummyList.clear();

    print('Start Date : $stDate');
    print('End Date : $edDate');
    print('Sales Rep id : $salesRepId');

    if (stDate == null && edDate == null) {
      handleStatus(
        context,
        'Terjadi kesalahan, coba lagi',
        false,
        isHorizontal: isHorizontal,
      );
    } else {
      var url =
          'https://timurrayalab.com/salesforce/server/api/performance/detailPerformance?from=$stDate&to=$edDate&salesrep_id=$salesRepId';

      try {
        var response = await http.get(url).timeout(Duration(seconds: timeout));
        print('Response status: ${response.statusCode}');

        try {
          var data = json.decode(response.body);
          final bool sts = data['status'];

          if (sts) {
            var rest = data['data'];
            print(rest);
            list = rest
                .map<SalesDetail>((json) => SalesDetail.fromJson(json))
                .toList();
            print("List Size: ${list.length}");

            for (int i = 0; i < list.length; i++) {
              dynamic cakupan;

              for (int j = 0; j < areaList.length; j++) {
                if (areaList[j].kodeArea == list[i].area) {
                  cakupan = areaList[j].cakupanArea;
                  print('Area cakupan : $cakupan');
                }
              }

              dummyList.add(SalesDetail(
                area: list[i].area,
                cakupan: cakupan,
                salesPerson: list[i].salesPerson,
                penjualan: list[i].penjualan,
              ));
            }

            return dummyList;
          }
        } on FormatException catch (e) {
          print('Format Error : $e');
          handleStatus(
            context,
            e.toString(),
            false,
            isHorizontal: isHorizontal,
          );
        }
      } on TimeoutException catch (e) {
        print('Timeout Error : $e');
      } on SocketException catch (e) {
        print('Socket Error : $e');
      } on Error catch (e) {
        print('General Error : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return salesChild(isHorizontal: true);
      }

      return salesChild(isHorizontal: false);
    });
  }

  Widget salesChild({bool isHorizontal}) {
    return Container(
      padding: EdgeInsets.all(15.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Center(
            child: CircleAvatar(
              radius: isHorizontal ? 50.r : 25.r,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile.png',
                  height: isHorizontal ? 100.h : 50.h,
                  width: isHorizontal ? 100.w : 50.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Center(
            child: Text(
              widget.sales.salesPerson.toString().toUpperCase(),
              style: TextStyle(
                fontSize: isHorizontal ? 24.sp : 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Segoe Ui',
              ),
            ),
          ),
          SizedBox(
            height: 25.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10.r,
            ),
            child: Text(
              'AREA PENJUALAN',
              style: TextStyle(
                fontSize: isHorizontal ? 24.sp : 16.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Segoe Ui',
              ),
            ),
          ),
          SizedBox(
            height: 230.h,
            child: FutureBuilder(
                future: getSalesDetail(
                  context,
                  stDate: widget.startDate,
                  edDate: widget.endDate,
                  salesRepId: widget.sales.salesRepId,
                  isHorizontal: isHorizontal,
                ),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 15.h,
                          ),
                          Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Center(
                            child: Text(
                              'Processing ...',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                        ],
                      );
                    default:
                      return snapshot.data != null
                          ? listViewWidget(
                              snapshot.data,
                              snapshot.data.length,
                              isHorizontal: isHorizontal,
                            )
                          : Column(
                              children: [
                                Center(
                                  child: Image.asset(
                                    'assets/images/not_found.png',
                                    width: isHorizontal ? 125.r : 100.r,
                                    height: isHorizontal ? 125.r : 100.r,
                                  ),
                                ),
                                Text(
                                  'Data tidak ditemukan',
                                  style: TextStyle(
                                    fontSize: isHorizontal ? 24.sp : 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[600],
                                    fontFamily: 'Montserrat',
                                  ),
                                )
                              ],
                            );
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget listViewWidget(List<SalesDetail> detail, int len,
      {bool isHorizontal = false}) {
    return Container(
      child: ListView.builder(
          itemCount: len,
          padding: EdgeInsets.symmetric(
            horizontal: 10.r,
            vertical: 8.r,
          ),
          itemBuilder: (context, position) {
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: 8.r,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        detail[position].area == null
                            ? 'Unknown'
                            : detail[position].area,
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 16.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Rp ${convertThousand(double.tryParse(detail[position].penjualan), 2)}",
                        style: TextStyle(
                          fontSize: isHorizontal ? 24.sp : 16.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    detail[position].cakupan == null
                        ? 'Unknown'
                        : detail[position].cakupan,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: isHorizontal ? 22.sp : 13.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
