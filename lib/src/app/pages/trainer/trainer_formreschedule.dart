import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';

import '../../../domain/entities/training_header.dart';
import '../../utils/config.dart';
import '../../utils/custom.dart';

// ignore: must_be_immutable
class TrainerFormReschedule extends StatefulWidget {
  TrainingHeader item;
  TrainerFormReschedule({Key? key, required this.item}) : super(key: key);

  @override
  State<TrainerFormReschedule> createState() => _TrainerFormRescheduleState();
}

class _TrainerFormRescheduleState extends State<TrainerFormReschedule> {
  MarketingExpenseController meController = Get.find<MarketingExpenseController>();
  TextEditingController txtKeterangan = new TextEditingController();

  @override
  void initState() {
    super.initState();

    print("Token Sales : ${widget.item.salesToken}");
  }

  onButtonPressed() async {
    await Future.delayed(const Duration(milliseconds: 1500),
        () => confirmReschedule(isHorizontal: meController.isHorizontal.value));

    return () {};
  }

  confirmReschedule({
    bool isChangePassword = false,
    bool isHorizontal = false,
  }) async {
    const timeout = 15;
    var url = '$API_URL/training/reschedule';

    try {
      var response = await http.put(
        Uri.parse(url),
        body: {
          'id_training': widget.item.id,
          'notes': txtKeterangan.text,
        },
      ).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (sts) {
          print('Response sts: $sts');
          if (mounted) {
            print('Mounting context');

            handleStatus(
              context,
              capitalize(msg),
              sts,
              isHorizontal: isHorizontal,
              isLogout: false,
            );

            pushNotif(
              30,
              3,
              salesName: widget.item.salesName,
              idUser: widget.item.createdBy,
              rcptToken: widget.item.salesToken,
              opticName: widget.item.opticName,
            );

            // Navigator.of(context, rootNavigator: true).pop();
          }
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(isHorizontal: true);
      }

      return childWidget(isHorizontal: false);
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    return Container(
      padding: EdgeInsets.all(isHorizontal ? 20.r : 15.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Isi informasi terkait perubahan jadwal training',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.red.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 15.h,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.multiline,
            minLines: 6,
            maxLines: 8,
            maxLength: 500,
            decoration: InputDecoration(
              // hintText: 'Tolong diubah waktu training menjadi pukul 13.00 WIB',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            controller: txtKeterangan,
          ),
          SizedBox(
            height: 15.h,
          ),
          EasyButton(
            idleStateWidget: Text(
              "Submit",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
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
            height: 40.h,
            width: 100.w,
            borderRadius: 35.r,
            buttonColor: Colors.blue.shade600,
            elevation: 2.0,
            contentGap: 6.0,
            onPressed: onButtonPressed,
          ),
        ],
      ),
    );
  }
}
