import 'dart:convert';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/widgets/dialogImage.dart';
import 'package:sample/src/domain/entities/cashback_header.dart';
import 'package:sample/src/domain/entities/cashback_line.dart';

import 'custom.dart';

enum CashbackStatus { PENDING, ACCEPTED, REJECT, ACTIVE, INACTIVE }
enum CashbackType { BY_PRODUCT, BY_TARGET, COMBINE }

String getCashbackType(CashbackType cashbackType) {
  String output = "";

  switch (cashbackType) {
    case CashbackType.BY_PRODUCT:
      output = "BY PRODUCT";
      break;
    case CashbackType.BY_TARGET:
      output = "BY TARGET";
      break;
    default:
      output = "COMBINE";
  }

  return output;
}

Enum getCashbackStatus(String input) {
  CashbackStatus cashbackStatus = CashbackStatus.PENDING;

  switch (input) {
    case 'ACCEPTED':
      cashbackStatus = CashbackStatus.ACCEPTED;
      break;
    case 'REJECT':
      cashbackStatus = CashbackStatus.REJECT;
      break;
    case 'ACTIVE':
      cashbackStatus = CashbackStatus.ACTIVE;
      break;
    case 'INACTIVE':
      cashbackStatus = CashbackStatus.INACTIVE;
      break;
    default:
      cashbackStatus = CashbackStatus.PENDING;
  }

  return cashbackStatus;
}

Color getCashbackColor(Enum status) {
  Color defColor = Colors.grey.shade600;

  switch (status) {
    case CashbackStatus.REJECT:
      defColor = Colors.red.shade500;
      break;
    case CashbackStatus.ACCEPTED:
      defColor = Colors.green.shade500;
      break;
    case CashbackStatus.ACTIVE:
      defColor = Colors.blue.shade500;
      break;
    case CashbackStatus.INACTIVE:
      defColor = Colors.orange.shade500;
      break;
    default:
      defColor = Colors.grey.shade600;
  }

  return defColor;
}

String setCashbackStatus(String input) {
  String output;
  switch (input) {
    case 'PENDING':
      output = 'Pengajuan cashback sedang diproses';
      break;
    case 'ACCEPTED':
      output = 'Pengajuan cashback disetujui';
      break;
    case 'INACTIVE':
      output = 'Kontrak cashback inactive';
      break;
    case 'ACTIVE':
      output = 'Kontrak cashback active';
      break;
    default:
      output = 'Pengajuan cashback ditolak';
      break;
  }

  return output;
}

Color setCashbackStatusColor(String input) {
  Color outColor = Colors.black;

  switch (input) {
    case 'PENDING':
      outColor = Colors.grey.shade600;
      break;
    case 'ACCEPTED':
      outColor = Colors.green.shade600;
      break;
    case 'INACTIVE':
      outColor = Colors.orange.shade600;
      break;
    case 'ACTIVE':
      outColor = Colors.blue.shade600;
      break;
    default:
      outColor = Colors.red.shade600;
      break;
  }

  return outColor;
}

Widget cashbackDetailOptikWidget({
  bool isHorizontal = false,
  required CashbackHeader? itemHeader,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Data optik',
        style: TextStyle(
          fontSize: isHorizontal ? 18.sp : 16.sp,
          fontFamily: 'Segoe Ui',
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
      SizedBox(
        height: isHorizontal ? 15.h : 10.h,
      ),
      IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 5.w,
            ),
            VerticalDivider(
              color: Colors.grey[600],
              thickness: isHorizontal ? 5 : 3.5,
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama optik',
                    style: TextStyle(
                      fontFamily: 'Segoe ui',
                      fontSize: isHorizontal ? 15.sp : 14.sp,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Text(
                    itemHeader?.opticName ?? '',
                    style: TextStyle(
                      fontFamily: 'Segoe ui',
                      fontSize: isHorizontal ? 15.sp : 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ship number',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Bill number',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        itemHeader?.shipNumber ?? '',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        itemHeader?.billNumber ?? '',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Text(
                    'Alamat optik',
                    style: TextStyle(
                      fontFamily: 'Segoe ui',
                      fontSize: isHorizontal ? 15.sp : 14.sp,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Text(
                    itemHeader?.opticAddress ?? '',
                    style: TextStyle(
                      fontFamily: 'Segoe ui',
                      fontSize: isHorizontal ? 15.sp : 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget cashbackDetailPemilikWidget({
  bool isHorizontal = false,
  required CashbackHeader? itemHeader,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Data pemilik',
        style: TextStyle(
          fontSize: isHorizontal ? 18.sp : 16.sp,
          fontFamily: 'Segoe Ui',
          fontWeight: FontWeight.w600,
          color: Colors.green[600],
        ),
      ),
      SizedBox(
        height: isHorizontal ? 15.h : 10.h,
      ),
      IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 5.w,
            ),
            VerticalDivider(
              color: Colors.green[600],
              thickness: isHorizontal ? 5 : 3.5,
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama pemilik',
                    style: TextStyle(
                      fontFamily: 'Segoe ui',
                      fontSize: isHorizontal ? 15.sp : 14.sp,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Text(
                    itemHeader?.dataNama ?? '',
                    style: TextStyle(
                      fontFamily: 'Segoe ui',
                      fontSize: isHorizontal ? 15.sp : 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NIK KTP',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Npwp',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        itemHeader?.dataNik ?? '',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        itemHeader?.dataNpwp ?? '-',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Text(
                    'Informasi rekening',
                    style: TextStyle(
                      fontFamily: 'Segoe ui',
                      fontSize: isHorizontal ? 15.sp : 14.sp,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Card(
                    elevation: 2,
                    child: Container(
                      width: double.infinity,
                      height: isHorizontal ? 115.h : 65.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: isHorizontal ? 25.r : 15.r,
                        vertical: isHorizontal ? 20.r : 10.r,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${itemHeader?.accountName} (${itemHeader?.bankName})',
                                  style: TextStyle(
                                    fontSize: isHorizontal ? 24.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Nomor Rekening : ${itemHeader?.accountNumber}',
                                  style: TextStyle(
                                    fontSize: isHorizontal ? 24.sp : 14.sp,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Segoe ui',
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Image.asset(
                            'assets/images/success.png',
                            width: isHorizontal ? 45.r : 25.r,
                            height: isHorizontal ? 45.r : 25.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget cashbackDetailKontrakWidget({
  bool isHorizontal = false,
  required CashbackHeader? itemHeader,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Data cashback',
        style: TextStyle(
          fontSize: isHorizontal ? 18.sp : 16.sp,
          fontFamily: 'Segoe Ui',
          fontWeight: FontWeight.w600,
          color: Colors.orange[600],
        ),
      ),
      SizedBox(
        height: isHorizontal ? 15.h : 10.h,
      ),
      IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 5.w,
            ),
            VerticalDivider(
              color: Colors.orange[600],
              thickness: isHorizontal ? 5 : 3.5,
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Periode kontrak',
                    style: TextStyle(
                      fontFamily: 'Segoe ui',
                      fontSize: isHorizontal ? 15.sp : 14.sp,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Text(
                    'Berlaku mulai ${convertDateWithMonth(itemHeader?.startPeriode ?? '-')} hingga ${convertDateWithMonth(itemHeader?.endPeriode ?? '-')}',
                    style: TextStyle(
                      fontFamily: 'Segoe ui',
                      fontSize: isHorizontal ? 15.sp : 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pencairan cashback',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Durasi pencairan',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        itemHeader?.withdrawProcess ?? '-',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${itemHeader?.withdrawDuration} hari',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 15.sp : 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Text(
                    'Termin pembayaran',
                    style: TextStyle(
                      fontFamily: 'Segoe ui',
                      fontSize: isHorizontal ? 15.sp : 14.sp,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    itemHeader?.paymentDuration ?? '-',
                    style: TextStyle(
                      fontFamily: 'Segoe ui',
                      fontSize: isHorizontal ? 15.sp : 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Visibility(
                    visible: itemHeader?.cashbackType == 'BY TARGET' ||
                        itemHeader?.cashbackType == 'COMBINE',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tipe cashback',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Durasi cashback',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              itemHeader?.cashbackType ?? '-',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${itemHeader?.targetDuration} bulan',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Target penjualan',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Nilai cashback',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${convertToIdr(int.parse(itemHeader?.targetValue ?? "0"), 0)}',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              double.parse(itemHeader?.cashbackValue ?? '0') >
                                      100
                                  ? convertToIdr(
                                      int.parse(
                                          itemHeader?.cashbackValue ?? '0'),
                                      0)
                                  : '${itemHeader?.cashbackPercentage} %',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    replacement: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tipe cashback',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Durasi cashback',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              itemHeader?.cashbackType ?? '-',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${itemHeader?.targetDuration} bulan',
                              style: TextStyle(
                                fontFamily: 'Segoe ui',
                                fontSize: isHorizontal ? 15.sp : 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget cashbackLineTargetWidget({
  bool isHorizontal = false,
  required CashbackHeader? itemHeader,
  required List<String> selectedTargetProddiv,
}) {
  return Visibility(
    visible: itemHeader?.cashbackType != 'BY PRODUCT' ? true : false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kontrak cashback - BY TARGET',
          style: TextStyle(
            fontFamily: 'Segoe ui',
            fontSize: isHorizontal ? 18.sp : 16.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Text(
          'Deskripsi produk',
          style: TextStyle(
            fontFamily: 'Segoe ui',
            fontSize: isHorizontal ? 15.sp : 14.sp,
            color: Colors.black45,
            fontWeight: FontWeight.w600,
          ),
        ),
        ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: 7.h,
          ),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: selectedTargetProddiv.length,
          itemBuilder: (_, index) {
            return Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: isHorizontal ? 5.r : 5.r,
                    bottom: isHorizontal ? 10.r : 5.r,
                  ),
                  child: Text(
                    selectedTargetProddiv[index],
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
    replacement: SizedBox(
      height: 5.w,
    ),
  );
}

Widget cashbackLineProductWidget({
  bool isHorizontal = false,
  required CashbackHeader? itemHeader,
  required Future<List<CashbackLine>>? selectedProductLine,
}) {
  return Visibility(
    visible: itemHeader?.cashbackType != 'BY TARGET' ? true : false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kontrak cashback - BY PRODUCT',
          style: TextStyle(
            fontFamily: 'Segoe ui',
            fontSize: isHorizontal ? 18.sp : 16.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deskripsi produk',
              style: TextStyle(
                fontFamily: 'Segoe ui',
                fontSize: isHorizontal ? 15.sp : 14.sp,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Nilai cashback',
              style: TextStyle(
                fontFamily: 'Segoe ui',
                fontSize: isHorizontal ? 15.sp : 14.sp,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        FutureBuilder(
          future: selectedProductLine,
          builder: (BuildContext context,
              AsyncSnapshot<List<CashbackLine>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    vertical: 7.h,
                  ),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, index) {
                    List<CashbackLine> item = snapshot.data!;
                    String cashbackStr = item[index].cashback ?? "0";
                    double cashbackVal =
                        double.parse(item[index].cashback ?? "0");
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: isHorizontal ? 5.r : 5.r,
                            bottom: isHorizontal ? 10.r : 5.r,
                          ),
                          child: Text(
                            item[index].prodCatDescription!,
                            style: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: isHorizontal ? 5.r : 5.r,
                            bottom: isHorizontal ? 10.r : 5.r,
                          ),
                          child: Text(
                            cashbackVal > 100
                                ? convertToIdr(cashbackVal, 0)
                                : '$cashbackStr %',
                            style: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/not_found.png',
                        width: isHorizontal ? 150.w : 200.w,
                        height: isHorizontal ? 150.h : 200.h,
                      ),
                    ),
                    Text(
                      'Data tidak ditemukan',
                      style: TextStyle(
                        fontSize: isHorizontal ? 14.sp : 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[600],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                );
              }
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ],
    ),
    replacement: SizedBox(
      height: 5.w,
    ),
  );
}

Widget cashbackLampiranWidget(
    {bool isHor = false,
    BuildContext? context,
    String attachmentSign = '',
    String attchmentOther = ''}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Lampiran Dokumen',
        style: TextStyle(
          fontSize: isHor ? 18.sp : 16.sp,
          fontFamily: 'Segoe Ui',
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(
        height: isHor ? 15.h : 10.h,
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context!).size.width * (isHor ? 1.2 : 0.93),
          ),
          child: Row(
            children: [
              attachmentSign != ''
                  ? InkWell(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8.r,
                        ),
                        child: Image.memory(
                          base64Decode(attachmentSign),
                          width: isHor ? 95.w : 60.w,
                          height: isHor ? 110.h : 60.h,
                          fit: isHor ? BoxFit.cover : BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DialogImage(
                              'Foto ttd dengan stampel',
                              attachmentSign,
                            );
                          },
                        );
                      },
                    )
                  : InkWell(
                      child: Image.asset(
                        'assets/images/picture.png',
                        width: isHor ? 95.w : 60.w,
                        height: isHor ? 110.h : 60.h,
                      ),
                      onTap: () => showStyledToast(
                        child: Text('Foto ttd tidak ditemukan'),
                        context: context,
                        backgroundColor: Colors.red,
                        borderRadius: BorderRadius.circular(15.r),
                        duration: Duration(seconds: 2),
                      ),
                    ),
              SizedBox(width: 10.w),
              attchmentOther != ''
                  ? InkWell(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8.r,
                        ),
                        child: Image.memory(
                          base64Decode(attchmentOther),
                          width: isHor ? 95.w : 60.w,
                          height: isHor ? 110.h : 60.h,
                          fit: isHor ? BoxFit.cover : BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DialogImage(
                              'Foto tambahan',
                              attchmentOther,
                            );
                          },
                        );
                      },
                    )
                  : InkWell(
                      child: Image.asset(
                        'assets/images/picture.png',
                        width: isHor ? 95.w : 60.w,
                        height: isHor ? 110.h : 60.h,
                      ),
                      onTap: () => showStyledToast(
                        child: Text('Foto tambahan tidak ditemukan'),
                        context: context,
                        backgroundColor: Colors.red,
                        borderRadius: BorderRadius.circular(15.r),
                        duration: Duration(seconds: 2),
                      ),
                    ),
            ],
          ),
        ),
      ),
    ],
  );
}

donwloadPdfCashback(
    String idCashback,
    String custName,
    String locatedFile,
  ) async {
    var dt = DateTime.now();
    var genTimer = dt.second;
    var url = '$PDFURL/cashback_pdf/$idCashback';

    await FlutterDownloader.enqueue(
      url: url,
      fileName: "Cashback $custName $genTimer.pdf",
      requiresStorageNotLow: true,
      savedDir: locatedFile,
      showNotification: true,
      openFileFromNotification: true,
    );
  }
