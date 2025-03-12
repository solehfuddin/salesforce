import 'dart:convert';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/training_controller.dart';
import 'package:sample/src/app/pages/training/trainer_counter.dart';
import 'package:sample/src/app/pages/training/trainer_form_attachment.dart';
import 'package:sample/src/app/pages/training/trainer_form_header.dart';
import 'package:sample/src/domain/entities/trainer.dart';

import '../../controllers/my_controller.dart';
import '../../utils/custom.dart';

class TrainerProfile extends StatefulWidget {
  const TrainerProfile({Key? key}) : super(key: key);

  @override
  State<TrainerProfile> createState() => _TrainerProfileState();
}

class _TrainerProfileState extends State<TrainerProfile> {
  MyController myController = Get.find<MyController>();
  TrainingController controller = Get.find<TrainingController>();
  late Trainer trainer;

  @override
  void initState() {
    super.initState();
    trainer = controller.trainer.value;

    print("Trainer Name : ${trainer.name}");
  }

   onButtonPressed() async {
    await Future.delayed(
      const Duration(milliseconds: 3000),
      () => controller.handleValidation(
        controller.isHorizontal.value,
        salesId: myController.sessionId,
        salesName: myController.sessionUsername,
        idSm: myController.idSm,
        tokensSm : myController.tokenSm,
      ),
    );

    return () {};
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
            controller.isHorizontal.value = true;
        return childWidget(isHorizontal: true);
      }

      controller.isHorizontal.value = false;
      return childWidget(isHorizontal: false);
    });
  }

  Widget childWidget({
    bool isHorizontal = false,
  }) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Profil Trainer',
          style: TextStyle(
            color: Colors.black54,
            fontSize: isHorizontal ? 20.sp : 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            paginateClear();
            controller.trainer.value = Trainer();

            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black54,
            size: isHorizontal ? 20.sp : 18.r,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: trainer.imgprofile!.isEmpty ? true : false,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    height: 60.h,
                    width: 60.w,
                    child: Image.asset(
                      'assets/images/profile.png',
                      height: 60.h,
                      width: 60.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                replacement: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    height: 60.h,
                    width: 60.w,
                    child: Image.memory(
                      Base64Decoder().convert(
                        trainer.imgprofile!,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              Text(
                trainer.name ?? '',
                style: TextStyle(
                  fontFamily: 'Segoe Ui',
                  fontSize: isHorizontal ? 18.sp : 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                trainer.trainerRole ?? '',
                style: TextStyle(
                  fontFamily: 'Segoe Ui',
                  fontSize: isHorizontal ? 14.sp : 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              TrainerCounter(
                totalSchedule: 0,
                totalReschedule: 0,
                totalHistory: 0,
              ),
              SizedBox(
                height: isHorizontal ? 25.sp : 18.sp,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isHorizontal ? 30.r : 24.r,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tentang trainer',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 18.sp : 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(
                        height: isHorizontal ? 8.h : 5.h,
                      ),
                      Text(
                        trainer.trainerProfile ?? '',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 14.sp : 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 20.h : 15.h,
              ),
              TrainerFormHeader(
                isHorizontal: isHorizontal,
              ),
              TrainerFormAttachment(
                isHorizontal: isHorizontal,
              ),
              SizedBox(
                height: isHorizontal ? 10.h : 5.h,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.h),
                  child: EasyButton(
                    idleStateWidget: Text(
                      "Simpan",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isHorizontal ? 16.sp : 14.sp,
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
                    height: isHorizontal ? 50.h : 35.h,
                    width: isHorizontal ? 80.w : 90.w,
                    borderRadius: isHorizontal ? 60.r : 30.r,
                    buttonColor: Colors.blue.shade400,
                    elevation: 2.0,
                    contentGap: 6.0,
                    onPressed: onButtonPressed,
                  ),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 20.h : 15.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
