import 'dart:convert';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/dialogImage.dart';
import 'package:sample/src/domain/entities/posmaterial_attachment.dart';
import 'package:sample/src/domain/entities/posmaterial_header.dart';

enum PosType { CUSTOM, KEMEJA_LEINZ_HIJAU, MATERIAL_KIT, OTHER, POSTER }
enum PosStatus { PENDING, APPROVE, REJECT }
enum MarketingFeature { POS_MATERIAL, CASHBACK, MARKETING_EXPENSE }

String setMarketingFeature(MarketingFeature enumMarketing) {
  String output = "";
  switch (enumMarketing) {
    case MarketingFeature.CASHBACK:
      output = "Cashback";
      break;
    case MarketingFeature.MARKETING_EXPENSE:
      output = "Marketing Expense";
      break;
    default:
      output = "POS Material";
  }

  return output;
}

MarketingFeature getMarketingFeature(String input) {
  MarketingFeature output = MarketingFeature.POS_MATERIAL;

  switch (input) {
    case 'Cashback':
      output = MarketingFeature.CASHBACK;
      break;
    case 'Marketing Expense':
      output = MarketingFeature.MARKETING_EXPENSE;
      break;
    default:
      output = MarketingFeature.POS_MATERIAL;
  }

  return output;
}

int setApprovalStatus(PosStatus enumPos) {
  int status = 0;
  switch (enumPos) {
    case PosStatus.PENDING:
      status = 0;
      break;
    case PosStatus.APPROVE:
      status = 1;
      break;
    case PosStatus.REJECT:
      status = 2;
      break;
  }

  return status;
}

Enum setPosType(String? value) {
  Enum defEnum = PosType.OTHER;
  switch (value) {
    case "CUSTOM":
      defEnum = PosType.CUSTOM;
      break;
    case "KEMEJA_LEINZ_HIJAU":
      defEnum = PosType.KEMEJA_LEINZ_HIJAU;
      break;
    case "MATERIAL_KIT":
      defEnum = PosType.MATERIAL_KIT;
      break;
    case "POSTER":
      defEnum = PosType.POSTER;
      break;
    default:
      defEnum = PosType.OTHER;
  }
  return defEnum;
}

Color getCustomerColor(String input) {
  Color defColor = Colors.grey;
  switch (input) {
    case 'NEW':
      defColor = Colors.orange;
      break;
    case 'OLD':
      defColor = Colors.green;
      break;
    default:
      defColor = Colors.blue;
  }

  return defColor;
}

Color getPosColor(Enum type) {
  Color defColor = Colors.grey;
  switch (type) {
    case PosType.CUSTOM:
      defColor = Colors.indigo;
      break;
    case PosType.KEMEJA_LEINZ_HIJAU:
      defColor = Colors.green;
      break;
    case PosType.MATERIAL_KIT:
      defColor = Colors.orange;
      break;
    case PosType.POSTER:
      defColor = Colors.red;
      break;
    default:
      defColor = Colors.blue;
  }

  return defColor;
}

Color getPosColorAccent(Enum type) {
  Color defColor = Colors.grey;
  switch (type) {
    case PosType.CUSTOM:
      defColor = Colors.indigo.shade100;
      break;
    case PosType.KEMEJA_LEINZ_HIJAU:
      defColor = Colors.green.shade100;
      break;
    case PosType.MATERIAL_KIT:
      defColor = Colors.orange.shade100;
      break;
    case PosType.POSTER:
      defColor = Colors.red.shade100;
      break;
    default:
      defColor = Colors.blue.shade100;
  }

  return defColor;
}

String getImagePos(String? value) {
  String defImage = "";

  switch (value) {
    case "CUSTOM":
      defImage = "assets/images/pos_custom.png";
      break;
    case "KEMEJA_LEINZ_HIJAU":
      defImage = "assets/images/pos_kemeja_leinz.png";
      break;
    case "MATERIAL_KIT":
      defImage = "assets/images/pos_marketing_kit.png";
      break;
    case "POSTER":
      defImage = "assets/images/pos_poster.png";
      break;
    default:
      defImage = "assets/images/pos_other.png";
  }

  return defImage;
}

Color setStatusColor(String input) {
  Color outColor = Colors.black;

  switch (input) {
    case 'PENDING':
      outColor = Colors.grey.shade600;
      break;
    case 'ACCEPTED':
      outColor = Colors.blue.shade600;
      break;
    default:
      outColor = Colors.red.shade600;
      break;
  }

  return outColor;
}

String setPosStatus(String input) {
  String output;
  switch (input) {
    case 'PENDING':
      output = 'Pengajuan pos material sedang diproses';
      break;
    case 'ACCEPTED':
      output = 'Pengajuan pos material disetujui';
      break;
    default:
      output = 'Pengajuan pos material ditolak';
      break;
  }

  return output;
}

Widget getDetailStatus(
  bool isHorizontal,
  BuildContext context, {
  String pic = 'Sales Manager',
  String picAlias = 'SM',
  String approvalStatus = '0',
  String picName = '',
  String picReason = '',
  String dateApproved = '',
}) {
  return InkWell(
    onTap: () => showStyledToast(
      alignment: Alignment.topCenter,
      child: Text(
        int.parse(approvalStatus) > 0
            ? int.parse(approvalStatus) > 1
                ? 'Ditolak oleh $picName pada $dateApproved'
                : 'Disetujui oleh $picName pada $dateApproved'
            : 'Menunggu persetujuan $pic',
      ),
      context: context,
      backgroundColor: int.parse(approvalStatus) > 0
          ? int.parse(approvalStatus) > 1
              ? Colors.red
              : Colors.green
          : Colors.grey,
      borderRadius: BorderRadius.circular(15.r),
      duration: Duration(seconds: 2),
    ),
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 30.r : 20.r,
              vertical: isHorizontal ? 20.r : 10.r),
          child: Container(
            width: isHorizontal ? 35.w : 45.w,
            padding: EdgeInsets.symmetric(
              vertical: isHorizontal ? 7.r : 5.r,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black54,
              ),
              borderRadius: BorderRadius.circular(
                isHorizontal ? 10.r : 5.r,
              ),
            ),
            child: Center(
              child: Text(
                picAlias,
                style: TextStyle(
                  fontSize: isHorizontal ? 17.sp : 15.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 15.r : 10.r,
            vertical: isHorizontal ? 8.r : 4.r,
          ),
          decoration: BoxDecoration(
            color: int.parse(approvalStatus) > 0
                ? int.parse(approvalStatus) > 1
                    ? Colors.red.shade600
                    : Colors.green.shade600
                : Colors.grey.shade500,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            children: [
              Icon(
                int.parse(approvalStatus) > 0
                    ? int.parse(approvalStatus) > 1
                        ? Icons.close
                        : Icons.done
                    : Icons.timelapse_outlined,
                color: Colors.white,
                size: isHorizontal ? 22.sp : 18.sp,
              ),
              SizedBox(
                width: 5.w,
              ),
              Text(
                int.parse(approvalStatus) > 0
                    ? int.parse(approvalStatus) > 1
                        ? 'Reject'
                        : 'Approved'
                    : 'Waiting',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: isHorizontal ? 13.sp : 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget getDetailPos({
  PosMaterialHeader? item,
  bool isHorizontal = false,
}) {
  Widget output = detailPosOther(isHorizontal: isHorizontal, item: item);

  switch (item!.posType) {
    case 'CUSTOM':
      output = detailPosCustom(
        isHorizontal: isHorizontal,
        item: item,
      );
      break;
    case 'KEMEJA_LEINZ_HIJAU':
      output = detailPosKemeja(
        isHorizontal: isHorizontal,
        item: item,
      );
      break;
    case 'MATERIAL_KIT':
      output = detailPosKit(
        isHorizontal: isHorizontal,
        item: item,
      );
      break;
    case 'POSTER':
      output = detailPosPoster(
        isHorizontal: isHorizontal,
        item: item,
      );
      break;
    default:
      output = detailPosOther(
        isHorizontal: isHorizontal,
        item: item,
      );
  }

  return output;
}

Widget detailPosCustom({bool isHorizontal = false, PosMaterialHeader? item}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nama produk :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Qty produk :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 3.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item!.productName!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.productQty!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Metode pengiriman :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Estimasi Harga :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.deliveryMethod!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.priceAdjustment != '0' ? convertToIdr(int.parse(item.priceAdjustment!), 0) : convertToIdr(int.parse(item.price!), 0),
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Visibility(
        visible: item.notes!.isNotEmpty ? true : false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catatan :',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: isHorizontal ? 14.sp : 12.sp,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 3.h,
            ),
            Text(
              item.notes!,
              style: TextStyle(
                fontFamily: 'Segoe ui',
                fontSize: isHorizontal ? 16.sp : 14.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
          ],
        ),
        replacement: SizedBox(
          width: 5.w,
        ),
      ),
    ],
  );
}

Widget detailPosKemeja({bool isHorizontal = false, PosMaterialHeader? item}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nama produk :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 3.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item!.productName!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Size S :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Size M :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Size L :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 3.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.productSizeS!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.productSizeM!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.productSizeL!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Size XL :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Size XXL :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Size XXXL :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 3.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.productSizeXl!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.productSizeXXL!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.productSizeXXXL!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Metode pengiriman :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Estimasi Harga :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.deliveryMethod!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
           Text(
            item.priceAdjustment != '0' ? convertToIdr(int.parse(item.priceAdjustment!), 0) : convertToIdr(int.parse(item.price!), 0),
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Visibility(
        visible: item.notes!.isNotEmpty ? true : false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catatan :',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: isHorizontal ? 14.sp : 12.sp,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 3.h,
            ),
            Text(
              item.notes!,
              style: TextStyle(
                fontFamily: 'Segoe ui',
                fontSize: isHorizontal ? 16.sp : 14.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
          ],
        ),
        replacement: SizedBox(
          width: 5.w,
        ),
      ),
    ],
  );
}

Widget detailPosKit({bool isHorizontal = false, PosMaterialHeader? item}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nama produk :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Qty produk :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 3.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item!.productName!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.productQty!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Metode pengiriman :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
           Text(
            'Estimasi Harga :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.deliveryMethod!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.priceAdjustment != '0' ? convertToIdr(int.parse(item.priceAdjustment!), 0) : convertToIdr(int.parse(item.price!), 0),
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Visibility(
        visible: item.notes!.isNotEmpty ? true : false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catatan :',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: isHorizontal ? 14.sp : 12.sp,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 3.h,
            ),
            Text(
              item.notes!,
              style: TextStyle(
                fontFamily: 'Segoe ui',
                fontSize: isHorizontal ? 16.sp : 14.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
          ],
        ),
        replacement: SizedBox(
          width: 5.w,
        ),
      ),
    ],
  );
}

Widget detailPosPoster({bool isHorizontal = false, PosMaterialHeader? item}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Poster Material :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Poster Qty :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Poster Content :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 3.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item!.posterMaterial!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${item.productQty ?? 0} Pcs',
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.posterContent!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Poster Width :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Poster Height :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 3.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${item.posterWidth!} cm',
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${item.posterHeight!} cm',
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Metode pengiriman :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Estimasi Harga :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.deliveryMethod!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.priceAdjustment != '0' ? convertToIdr(int.parse(item.priceAdjustment!), 0) : convertToIdr(int.parse(item.price!), 0),
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Visibility(
        visible: item.notes!.isNotEmpty ? true : false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catatan :',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: isHorizontal ? 14.sp : 12.sp,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 3.h,
            ),
            Text(
              item.notes!,
              style: TextStyle(
                fontFamily: 'Segoe ui',
                fontSize: isHorizontal ? 16.sp : 14.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
          ],
        ),
        replacement: SizedBox(
          width: 5.w,
        ),
      ),
    ],
  );
}

Widget detailPosOther({
  bool isHorizontal = false,
  PosMaterialHeader? item,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nama produk :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Qty produk :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 3.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item!.productName!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.productQty!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Metode pengiriman :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Estimasi Harga :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isHorizontal ? 14.sp : 12.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.deliveryMethod!,
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            item.priceAdjustment == '0' ? 'Belum ditentukan' : convertToIdr(int.parse(item.priceAdjustment!), 0),
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 16.sp : 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.h,
      ),
      Visibility(
        visible: item.notes!.isNotEmpty ? true : false,
        child: Column(
          children: [
            Text(
              'Catatan :',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: isHorizontal ? 14.sp : 12.sp,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 3.h,
            ),
            Text(
              item.notes!,
              style: TextStyle(
                fontFamily: 'Segoe ui',
                fontSize: isHorizontal ? 16.sp : 14.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
          ],
        ),
        replacement: SizedBox(
          width: 5.w,
        ),
      ),
    ],
  );
}

Widget posLampiranWidget(
    {bool isHor = false,
    BuildContext? context,
    PosMaterialAttachment? attachment}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: isHor ? 10.h : 5.h,
      ),
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              attachment!.attachmentParaf != ''
                  ? InkWell(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8.r,
                        ),
                        child: Image.memory(
                          base64Decode(attachment.attachmentParaf!),
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
                              'Foto Desain Paraf',
                              attachment.attachmentParaf,
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
                        child: Text('Foto desain paraf ditemukan'),
                        context: context,
                        backgroundColor: Colors.red,
                        borderRadius: BorderRadius.circular(15.r),
                        duration: Duration(seconds: 2),
                      ),
                    ),
              attachment.attachmentKtp != ''
                  ? InkWell(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8.r,
                        ),
                        child: Image.memory(
                          base64Decode(attachment.attachmentKtp!),
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
                              'Foto KTP',
                              attachment.attachmentKtp,
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
                        child: Text('Foto KTP tidak ditemukan'),
                        context: context,
                        backgroundColor: Colors.red,
                        borderRadius: BorderRadius.circular(15.r),
                        duration: Duration(seconds: 2),
                      ),
                    ),
              attachment.attachmentNpwp != ''
                  ? InkWell(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8.r,
                        ),
                        child: Image.memory(
                          base64Decode(attachment.attachmentNpwp!),
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
                              'Foto Npwp',
                              attachment.attachmentNpwp,
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
                        child: Text('Foto NPWP tidak ditemukan'),
                        context: context,
                        backgroundColor: Colors.red,
                        borderRadius: BorderRadius.circular(15.r),
                        duration: Duration(seconds: 2),
                      ),
                    ),
              attachment.attachmentOmzet != ''
                  ? InkWell(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8.r,
                        ),
                        child: Image.memory(
                          base64Decode(attachment.attachmentOmzet!),
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
                              'Foto Omzet 12 bulan terakhir',
                              attachment.attachmentOmzet,
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
                        child: Text('Foto omzet tidak ditemukan'),
                        context: context,
                        backgroundColor: Colors.red,
                        borderRadius: BorderRadius.circular(15.r),
                        duration: Duration(seconds: 2),
                      ),
                    ),
              attachment.attachmentLokasi != ''
                  ? InkWell(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8.r,
                        ),
                        child: Image.memory(
                          base64Decode(attachment.attachmentLokasi!),
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
                              'Foto Rencana Lokasi',
                              attachment.attachmentLokasi,
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
                        child: Text('Foto rencana lokasi tidak ditemukan'),
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

Widget posReview(String message, bool status) {
  return Container(
    margin: EdgeInsets.only(
      top: 5.r,
      bottom: 8.r,
    ),
    padding: EdgeInsets.symmetric(
      horizontal: 10.r,
      vertical: 8.r,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(
        5.r,
      ),
      color: status ? Colors.greenAccent.shade700 : Colors.amber.shade500,
    ),
    child: Row(
      children: [
        Visibility(
          visible: status,
          child: Icon(
            Icons.check_circle_outline_sharp,
            color: Colors.green.shade800,
          ),
          replacement: Icon(
            Icons.warning_amber,
            color: Colors.amber.shade900,
          ),
        ),
        SizedBox(
          width: 8.w,
        ),
        Flexible(
          child: Text(
            message,
            overflow: TextOverflow.visible,
            softWrap: true,
            style: TextStyle(
              height: 1.45,
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    ),
  );
}


donwloadPdfPOS(
    String idPos,
    String custName,
    String locatedFile,
  ) async {
    var dt = DateTime.now();
    var genTimer = dt.second;
    var url = '$PDFURL/posmaterial_pdf/$idPos';

    await FlutterDownloader.enqueue(
      url: url,
      fileName: "POS Material $custName $genTimer.pdf",
      requiresStorageNotLow: true,
      savedDir: locatedFile,
      showNotification: true,
      openFileFromNotification: true,
    );
  }