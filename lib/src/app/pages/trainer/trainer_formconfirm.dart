import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/pages/trainer/trainer_formreschedule.dart';
import 'package:sample/src/domain/entities/training_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/my_controller.dart';
import '../../utils/config.dart';
import 'package:http/http.dart' as http;

import '../../utils/custom.dart';

// ignore: must_be_immutable
class TrainerFormConfirm extends StatefulWidget {
  TrainingHeader item;

  TrainerFormConfirm({Key? key, required this.item}) : super(key: key);

  @override
  State<TrainerFormConfirm> createState() => _TrainerFormConfirmState();
}

class _TrainerFormConfirmState extends State<TrainerFormConfirm> {
  MyController myController = Get.find<MyController>();
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();
  TextEditingController txtInvitationLink = new TextEditingController();

  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';
  String search = '';
  String? divisi = '';
  String? status = '';

  @override
  void initState() {
    super.initState();
    getRole();
    print("Token Sales : ${widget.item.salesToken}");
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");
      name = preferences.getString("name") ?? '';
      status = preferences.getString("status") ?? '';
    });
  }

  onButtonPressed() async {
    await Future.delayed(const Duration(milliseconds: 1500),
        () => confirmSchedule(isHorizontal: meController.isHorizontal.value));

    return () {};
  }

  onReschedulePressed() async {
    Navigator.of(context, rootNavigator: true).pop();

    showModalBottomSheet(
      context: context,
      elevation: 2,
      enableDrag: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            15.r,
          ),
          topRight: Radius.circular(
            15.r,
          ),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: TrainerFormReschedule(
            item: widget.item,
          ),
        );
      },
    );

    return () {};
  }

  confirmSchedule({
    bool isChangePassword = false,
    bool isHorizontal = false,
  }) async {
    const timeout = 15;
    var url = '$API_URL/training/confirm';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id_training': widget.item.id,
          'invitation_training': txtInvitationLink.text,
          'trainer' : username,
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
              29,
              3,
              salesName: widget.item.salesName,
              idUser: widget.item.createdBy,
              rcptToken: myController.tokenSales,
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
            widget.item.mechanism!.contains("OFFLINE")
                ? 'Apakah anda mengkonfirmasi agenda training tersebut ?'
                : 'Link Undangan',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Visibility(
            visible: !widget.item.mechanism!.contains("OFFLINE"),
            child: Column(
              children: [
                SizedBox(
                  height: 10.h,
                ),
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.multiline,
                  minLines: 6,
                  maxLines: 8,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Invitation Link',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  controller: txtInvitationLink,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EasyButton(
                idleStateWidget: Text(
                  "Ubah Jadwal",
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
                width: 120.w,
                borderRadius: 35.r,
                buttonColor: Colors.red.shade600,
                elevation: 2.0,
                contentGap: 6.0,
                onPressed: onReschedulePressed,
              ),
              EasyButton(
                idleStateWidget: Text(
                  "Konfirmasi",
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
                width: 110.w,
                borderRadius: 35.r,
                buttonColor: Colors.blue.shade600,
                elevation: 2.0,
                contentGap: 6.0,
                onPressed: onButtonPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
