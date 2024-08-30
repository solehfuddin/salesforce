import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/pages/cashback/cashback_newrekening.dart';
import 'package:sample/src/app/pages/cashback/cashback_oldrekening.dart';
import 'package:sample/src/domain/entities/cashback_rekening.dart';

// ignore: camel_case_types
class Marketingexpense_Rekening extends StatefulWidget {
  const Marketingexpense_Rekening({Key? key}) : super(key: key);

  @override
  State<Marketingexpense_Rekening> createState() =>
      _Marketingexpense_RekeningState();
}

// ignore: camel_case_types
class _Marketingexpense_RekeningState extends State<Marketingexpense_Rekening> {
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Visibility(
            visible: meController.selectedPayment.value == "TRANSFER BANK",
            child: Column(
              children: [
                Text(
                  'Informasi Rekening',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: meController.isHorizontal.value ? 24.sp : 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: meController.isWalletAvail.value
                            ? () {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                        builder: (context, state) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: Center(
                                          child: Text('Pilih Rekening'),
                                        ),
                                        content: CashbackOldRekening(
                                          isHorizontal:
                                              meController.isHorizontal.value,
                                          // updateParent:
                                          //     updateSelected,
                                          updateParent: (_, dynamic) {
                                            if (dynamic is CashbackRekening) {
                                              print(
                                                  'Nomor Rekening : ${dynamic.nomorRekening}');
                                              meController.selectedRekening
                                                  .value = dynamic;
                                              meController.isActiveRekening
                                                  .value = true;
                                            } else {
                                              print("Nomor rekening salah");
                                              meController.isActiveRekening
                                                  .value = false;
                                            }
                                          },
                                          noAccount: meController.selectedOptic
                                                  .value.noAccount ??
                                              '',
                                        ),
                                      );
                                    });
                                  },
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade400,
                        ),
                        icon: Icon(Icons.check_circle),
                        label: Text(
                          'Pilih Rekening',
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      flex: 4,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            elevation: 2,
                            backgroundColor: Colors.white,
                            isDismissible: true,
                            enableDrag: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            context: context,
                            builder: (context) {
                              return CashbackNewRekening(
                                isHorizontal: meController.isHorizontal.value,
                                billNumber: meController
                                        .selectedOptic.value.billNumber ??
                                    '',
                                shipNumber: meController
                                        .selectedOptic.value.noAccount ??
                                    '',
                                updateParent: (_, dynamic) {
                                  if (dynamic is CashbackRekening) {
                                    print(
                                        'Id Rekening : ${dynamic.idRekening}');
                                    meController.selectedRekening.value =
                                        dynamic;
                                    meController.isActiveRekening.value = true;
                                  } else {
                                    print("Nomor rekening salah");
                                    meController.isActiveRekening.value = false;
                                  }
                                },
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400,
                        ),
                        icon: Icon(
                          Icons.add_circle_rounded,
                        ),
                        label: Text(
                          'Tambah rekening baru',
                        ),
                      ),
                    ),
                  ],
                ),
                meController.isActiveRekening.value
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.r,
                          vertical: 5.r,
                        ),
                        child: Card(
                          elevation: 2,
                          child: Container(
                            height:
                                meController.isHorizontal.value ? 115.h : 65.h,
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  meController.isHorizontal.value ? 25.r : 15.r,
                              vertical:
                                  meController.isHorizontal.value ? 20.r : 10.r,
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
                                        // '${widget.cashbackRekening.getNamaRekening} (${widget.cashbackRekening.getBankName})',
                                        '${meController.selectedRekening.value.namaRekening} (${meController.selectedRekening.value.bankName})',
                                        style: TextStyle(
                                          fontSize:
                                              meController.isHorizontal.value
                                                  ? 24.sp
                                                  : 14.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        // 'Nomor Rekening : ${widget.cashbackRekening.getNomorRekening}',
                                        'Nomor Rekening : ${meController.selectedRekening.value.nomorRekening}',
                                        style: TextStyle(
                                          fontSize:
                                              meController.isHorizontal.value
                                                  ? 24.sp
                                                  : 14.sp,
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
                                  width: meController.isHorizontal.value
                                      ? 45.r
                                      : 25.r,
                                  height: meController.isHorizontal.value
                                      ? 45.r
                                      : 25.r,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Card(
                        elevation: 3,
                        child: Container(
                          height:
                              meController.isHorizontal.value ? 115.h : 65.h,
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                meController.isHorizontal.value ? 25.r : 15.r,
                            vertical:
                                meController.isHorizontal.value ? 20.r : 10.r,
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
                                      'Tidak ada informasi rekening',
                                      style: TextStyle(
                                        fontSize:
                                            meController.isHorizontal.value
                                                ? 24.sp
                                                : 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Pilih rekening atau buat rekening baru',
                                      style: TextStyle(
                                        fontSize:
                                            meController.isHorizontal.value
                                                ? 24.sp
                                                : 14.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Segoe ui',
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Image.asset(
                                'assets/images/failure.png',
                                width: meController.isHorizontal.value
                                    ? 45.r
                                    : 25.r,
                                height: meController.isHorizontal.value
                                    ? 45.r
                                    : 25.r,
                              ),
                            ],
                          ),
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
      ),
    );
  }
}
