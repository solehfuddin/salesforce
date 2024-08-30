import 'dart:convert';

import 'package:fl_toast/fl_toast.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/controllers/my_controller.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/dialogImage.dart';
import 'package:sample/src/domain/entities/marketingexpense_attachment.dart';
import 'package:sample/src/domain/entities/marketingexpense_header.dart';
import 'package:sample/src/domain/entities/marketingexpense_line.dart';
import 'package:sample/src/domain/entities/marketingexpense_paramapprove.dart';

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

String setMEStatus(String input) {
  String output;
  switch (input) {
    case 'PENDING':
      output = 'Pengajuan marketing expense sedang diproses';
      break;
    case 'ACCEPTED':
      output = 'Pengajuan marketing expense disetujui';
      break;
    default:
      output = 'Pengajuan marketing expense ditolak';
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

Widget marketingExpenseLineWidget({
  bool isHorizontal = false,
  required List<MarketingExpenseLine>? selectedProductLine,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Item Marketing Expense',
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
            'Jenis entertaint',
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 15.sp : 14.sp,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Marketing expense',
            style: TextStyle(
              fontFamily: 'Segoe ui',
              fontSize: isHorizontal ? 15.sp : 14.sp,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      Visibility(
        visible: selectedProductLine!.length > 0 ? true : false,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: 7.h,
          ),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: selectedProductLine.length,
          itemBuilder: (_, index) {
            List<MarketingExpenseLine> item = selectedProductLine;
            String priceEstimate = item[index].price ?? "0";
            double priceAdjusment = double.parse(item[index].adjustment ?? "0");
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: isHorizontal ? 5.r : 5.r,
                    bottom: isHorizontal ? 10.r : 5.r,
                  ),
                  child: Text(
                    item[index].judul!,
                    style: TextStyle(
                      fontSize: isHorizontal ? 20.sp : 12.sp,
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
                    priceAdjusment > 0
                        ? convertToIdr(priceAdjusment, 0)
                        : convertToIdr(int.parse(priceEstimate), 0),
                    style: TextStyle(
                      fontSize: isHorizontal ? 20.sp : 12.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        replacement: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/not_found.png',
                width: isHorizontal ? 150.w : 170.w,
                height: isHorizontal ? 150.h : 170.h,
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
        ),
      ),
    ],
  );
}

Widget marketingExpenseAttachmentWidget(
    {bool isHor = false,
    BuildContext? context,
    List<MarketingExpenseAttachment>? listAttachment}) {
  return Visibility(
    visible: listAttachment!.length > 0 ? true : false,
    child: Column(
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
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          mainAxisSpacing: 8.r,
          crossAxisSpacing: 8.r,
          padding: EdgeInsets.all(10.r),
          children: [
            if (listAttachment.length > 0)
              for (var i = 0; i < listAttachment.length; i++)
                InkWell(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      8.r,
                    ),
                    child: Image.memory(
                      base64Decode(listAttachment[i].attachment!),
                      width: isHor ? 95.w : 60.w,
                      height: isHor ? 110.h : 60.h,
                      fit: isHor ? BoxFit.cover : BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                  onTap: () async {
                    int j = i;
                    await showDialog(
                      context: context!,
                      builder: (BuildContext context) {
                        return DialogImage(
                          'Foto ke ${++j}',
                          listAttachment[i].attachment,
                        );
                      },
                    );
                  },
                )
          ],
        ),
      ],
    ),
    replacement: SizedBox(
      height: 5.h,
    ),
  );
}

Widget handleAction({
  BuildContext? context,
  bool isHorizontal = false,
  MarketingExpenseHeader? header,
}) {
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();
  MyController myController = Get.find<MyController>();

  onPressedReject() async {
    handleRejection(
      context!,
      isHorizontal: isHorizontal,
      header: header,
    );

    return () {};
  }

  onPressedApprove() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
      () => meController.handleApprove(
        isHorizontal: isHorizontal,
        isMounted: false,
        param: MarketingExpenseParamApprove(
          idMe: header?.id,
          idSales: header?.createdBy,
          nameSales: myController.nameSales,
          opticName: header?.opticName,
          managerName: myController.sessionName,
          tokenSales: myController.tokenSales,
          approverGm: myController.sessionDivisi == "GM"
              ? myController.sessionUsername
              : '',
          approverSm: myController.sessionDivisi == "SALES"
              ? myController.sessionUsername
              : '',
          reasonGm: '',
          reasonSm: '',
        ),
      ),
    );

    return () {};
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: isHorizontal ? 30.r : 20.r,
          vertical: 5.r,
        ),
        alignment: Alignment.centerRight,
        child: EasyButton(
          idleStateWidget: Text(
            "Reject",
            style: TextStyle(
                color: Colors.white,
                fontSize: isHorizontal ? 24.sp : 14.sp,
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
          height: isHorizontal ? 60.h : 40.h,
          width: isHorizontal ? 80.w : 100.w,
          borderRadius: isHorizontal ? 60.r : 30.r,
          buttonColor: Colors.red.shade700,
          elevation: 2.0,
          contentGap: 6.0,
          onPressed: onPressedReject,
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: isHorizontal ? 30.r : 20.r,
          vertical: 5.r,
        ),
        alignment: Alignment.centerRight,
        child: EasyButton(
          idleStateWidget: Text(
            "Approve",
            style: TextStyle(
                color: Colors.white,
                fontSize: isHorizontal ? 24.sp : 14.sp,
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
          height: isHorizontal ? 60.h : 40.h,
          width: isHorizontal ? 80.w : 100.w,
          borderRadius: isHorizontal ? 60.r : 30.r,
          buttonColor: Colors.blue.shade600,
          elevation: 2.0,
          contentGap: 6.0,
          onPressed: onPressedApprove,
        ),
      ),
    ],
  );
}

handleRejection(
  BuildContext context, {
  bool isHorizontal = false,
  MarketingExpenseHeader? header,
}) {
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();
  MyController myController = Get.find<MyController>();
  TextEditingController txtReason = new TextEditingController();

  AlertDialog alert = AlertDialog(
    scrollable: true,
    title: Center(
      child: Text(
        "Mengapa kontrak tidak disetujui ?",
        style: TextStyle(
          fontSize: isHorizontal ? 20.sp : 14.sp,
          fontFamily: 'Segoe ui',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    content: Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              errorText: txtReason.text.isEmpty ? 'Data wajib diisi' : null,
            ),
            keyboardType: TextInputType.multiline,
            minLines: isHorizontal ? 3 : 4,
            maxLines: isHorizontal ? 4 : 5,
            maxLength: 100,
            controller: txtReason,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        child: Text(
          'Ok',
          style: TextStyle(
            fontSize: isHorizontal ? 22.sp : 14.sp,
          ),
        ),
        onPressed: () {
          meController.handleReject(
            isHorizontal: isHorizontal,
            isMounted: false,
            param: MarketingExpenseParamApprove(
              idMe: header?.id,
              idSales: myController.idSales,
              nameSales: myController.nameSales,
              tokenSales: myController.tokenSales,
              opticName: header?.opticName,
              managerName: myController.sessionName,
              approverGm: myController.sessionDivisi == "GM"
                  ? myController.sessionUsername
                  : '',
              approverSm: myController.sessionDivisi == "SALES"
                  ? myController.sessionUsername
                  : '',
              reasonGm:
                  myController.sessionDivisi == "GM" ? txtReason.text : '',
              reasonSm:
                  myController.sessionDivisi == "SALES" ? txtReason.text : '',
            ),
          );
        },
      ),
      TextButton(
        child: Text(
          'Cancel',
          style: TextStyle(
            fontSize: isHorizontal ? 22.sp : 14.sp,
          ),
        ),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (context) => alert,
    barrierDismissible: false,
  );
}

donwloadPdfME(
  String idPos,
  String custName,
  String locatedFile,
) async {
  var dt = DateTime.now();
  var genTimer = dt.second;
  var url = '$PDFURL/me_pdf/$idPos';

  await FlutterDownloader.enqueue(
    url: url,
    fileName: "ME $custName $genTimer.pdf",
    requiresStorageNotLow: true,
    savedDir: locatedFile,
    showNotification: true,
    openFileFromNotification: true,
  );
}
