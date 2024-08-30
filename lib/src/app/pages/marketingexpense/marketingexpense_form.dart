import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/controllers/my_controller.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_formdetail.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_formentertaint.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_formheader.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_formpemilik.dart';
import 'package:sample/src/app/utils/colors.dart';

// ignore: camel_case_types
class Marketingexpense_Form extends StatefulWidget {
  const Marketingexpense_Form({Key? key}) : super(key: key);

  @override
  State<Marketingexpense_Form> createState() => _Marketingexpense_FormState();
}

// ignore: camel_case_types
class _Marketingexpense_FormState extends State<Marketingexpense_Form> {
  MyController myController = Get.find<MyController>();
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  onButtonPressed() async {
    await Future.delayed(
      const Duration(milliseconds: 3000),
      () => meController.handleValidation(
        meController.isHorizontal.value,
        salesId: myController.sessionId,
        salesName: myController.sessionUsername,
        idSm: myController.idSm,
        tokenSm: myController.tokenSm,
      ),
    );

    return () {};
  }

  @override
  void initState() {
    super.initState();
    myController.getRole();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(
          isHorizontal: true,
        );
      }

      return childWidget(
        isHorizontal: false,
      );
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.desciptionColor,
        title: Text(
          'Entri Marketing Expense',
          style: TextStyle(
            color: Colors.white,
            fontSize: isHorizontal ? 20.sp : 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.toNamed('/marketingexpense');

            Future.delayed(Duration(milliseconds: 800))
                .then((value) => meController.clearState());
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: isHorizontal ? 20.r : 18.r,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Marketingexpense_Formheader(),
            Marketingexpense_Formpemilik(),
            Marketingexpense_Formdetail(),
            Marketingexpense_Formentertaint(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 30.r : 15.r,
                vertical: isHorizontal ? 10.r : 5.r,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  EasyButton(
                    idleStateWidget: Text(
                      "Simpan",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isHorizontal ? 18.sp : 14.sp,
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
                    height: isHorizontal ? 50.h : 40.h,
                    width: isHorizontal ? 90.w : 100.w,
                    borderRadius: isHorizontal ? 60.r : 30.r,
                    buttonColor: Colors.blue.shade700,
                    elevation: 2.0,
                    contentGap: 6.0,
                    onPressed: onButtonPressed,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
    );
  }
}
