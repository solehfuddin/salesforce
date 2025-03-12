import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/training_controller.dart';
import 'package:sample/src/domain/entities/training_header.dart';
import 'package:sample/src/domain/entities/training_paramapprove.dart';

import '../controllers/my_controller.dart';

Color setStatusColor(String input) {
  Color outColor = Colors.black;

  switch (input) {
    case 'PENDING':
      outColor = Colors.grey.shade600;
      break;
    case 'APPROVE':
      outColor = Colors.blue.shade600;
      break;
    case 'CONFIRMED':
      outColor = Colors.green.shade600;
      break;
    case 'RESCHEDULE' :
      outColor = Colors.orange.shade600;
      break;
    case 'DONE' :
      outColor = Colors.indigo.shade600;
      break;
    default:
      outColor = Colors.red.shade600;
      break;
  }

  return outColor;
}

String setStatus(String input) {
  String output;
  switch (input) {
    case 'PENDING':
      output = 'Pengajuan training sedang diproses';
      break;
    case 'APPROVE':
      output = 'Pengajuan training disetujui';
      break;
    case 'CONFIRMED':
      output = 'Pengajuan training sudah dikonfirmasi trainer';
      break;
    case 'RESCHEDULE':
      output = 'Pengajuan training sedang dijadwalkan ulang';
      break;
    case 'DONE' :
      output = 'Training sudah dinyatakan selesai oleh Trainer';
      break;
    default:
      output = 'Pengajuan training ditolak';
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

Widget handleAction({
  BuildContext? context,
  bool isHorizontal = false,
  TrainingHeader? header,
}) {
  TrainingController trainingController =
      Get.find<TrainingController>();
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
      () => trainingController.handleApprove(
        isHorizontal: isHorizontal,
        isMounted: false,
        param: TrainingParamApprove(
          idTraining: header?.id,
          idSales: header?.createdBy,
          nameSales: myController.nameSales,
          opticName: header?.opticName,
          managerName: myController.sessionName,
          tokenSales: myController.tokenSales,
          approverBm: myController.sessionDivisi == "MARKETING"
              ? myController.sessionUsername
              : '',
          approverSm: myController.sessionDivisi == "SALES"
              ? myController.sessionUsername
              : '',
          reasonBm: '',
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
          horizontal: isHorizontal ? 20.r : 10.r,
          vertical: 5.r,
        ),
        alignment: Alignment.centerRight,
        child: EasyButton(
          idleStateWidget: Text(
            "Reject",
            style: TextStyle(
                color: Colors.white,
                fontSize: isHorizontal ? 24.sp : 12.sp,
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
          height: isHorizontal ? 40.h : 30.h,
          width: isHorizontal ? 70.w : 80.w,
          borderRadius: isHorizontal ? 60.r : 30.r,
          buttonColor: Colors.red.shade700,
          elevation: 2.0,
          contentGap: 6.0,
          onPressed: onPressedReject,
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: isHorizontal ? 20.r : 10.r,
          vertical: 5.r,
        ),
        alignment: Alignment.centerRight,
        child: EasyButton(
          idleStateWidget: Text(
            "Approve",
            style: TextStyle(
                color: Colors.white,
                fontSize: isHorizontal ? 24.sp : 12.sp,
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
          height: isHorizontal ? 40.h : 30.h,
          width: isHorizontal ? 70.w : 80.w,
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
  TrainingHeader? header,
}) {
  TrainingController trainingController =
      Get.find<TrainingController>();
  MyController myController = Get.find<MyController>();
  TextEditingController txtReason = new TextEditingController();

  AlertDialog alert = AlertDialog(
    scrollable: true,
    title: Center(
      child: Text(
        "Mengapa tidak disetujui ?",
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
          trainingController.handleReject(
            isHorizontal: isHorizontal,
            isMounted: false,
            param: TrainingParamApprove(
              idTraining: header?.id,
              idSales: myController.idSales,
              nameSales: myController.nameSales,
              tokenSales: myController.tokenSales,
              opticName: header?.opticName,
              managerName: myController.sessionName,
              approverBm: myController.sessionDivisi == "MARKETING"
                  ? myController.sessionUsername
                  : '',
              approverSm: myController.sessionDivisi == "SALES"
                  ? myController.sessionUsername
                  : '',
              reasonBm:
                  myController.sessionDivisi == "MARKETING" ? txtReason.text : '',
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