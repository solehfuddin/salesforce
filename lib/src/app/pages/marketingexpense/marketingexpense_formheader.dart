import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
// import 'package:sample/src/app/pages/marketingexpense/marketingexpense_widgettrainer.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/domain/entities/opticwithaddress.dart';
// import 'package:sample/src/domain/entities/trainer.dart';
import 'package:sample/src/domain/service/service_cashback.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';

// ignore: camel_case_types
class Marketingexpense_Formheader extends StatefulWidget {
  const Marketingexpense_Formheader({Key? key}) : super(key: key);

  @override
  State<Marketingexpense_Formheader> createState() =>
      _Marketingexpense_FormheaderState();
}

// ignore: camel_case_types
class _Marketingexpense_FormheaderState
    extends State<Marketingexpense_Formheader> {
  ServicePosMaterial service = new ServicePosMaterial();
  ServiceCashback serviceCashback = new ServiceCashback();
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  TextEditingController controllerOpticName = TextEditingController();
  TextEditingController controllerOpticAddress = TextEditingController();

  // List<Trainer> _list = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    // meController.getAllTrainer(mounted, context).then((value) => _list = value);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.only(
          left: meController.isHorizontal.value ? 10.r : 5.r,
          right: meController.isHorizontal.value ? 10.r : 5.r,
          top: meController.isHorizontal.value ? 20.r : 10.r,
          bottom: meController.isHorizontal.value ? 20.r : 5.r,
        ),
        child: Card(
          elevation: 2,
          borderOnForeground: true,
          color: MyColors.desciptionColor,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.r,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: meController.isHorizontal.value ? 20.r : 10.r,
                ),
                child: Center(
                  child: Text(
                    'Informasi Optik',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: meController.isHorizontal.value ? 26.sp : 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(
                  meController.isHorizontal.value ? 24.r : 12.r,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      'Nama Optik',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize:
                            meController.isHorizontal.value ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: meController.isHorizontal.value ? 18.h : 8.h,
                    ),
                    TextFormField(
                      readOnly: true,
                      textCapitalization: TextCapitalization.characters,
                      // autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Nama optik',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Segoe ui',
                          fontSize:
                              meController.isHorizontal.value ? 24.sp : 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 2.h,
                        ),
                        errorText: meController.validateOpticName.value
                            ? null
                            : 'Optik belum diisi',
                        suffixIcon: IconButton(
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return dialogChooseOptic(
                                  isHorizontal: meController.isHorizontal.value,
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 30.r,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize:
                            meController.isHorizontal.value ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLength: 75,
                      controller: controllerOpticName,
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return dialogChooseOptic(
                              isHorizontal: meController.isHorizontal.value,
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(
                      height: meController.isHorizontal.value ? 22.h : 12.h,
                    ),
                    Text(
                      'Alamat Optik',
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Segoe ui',
                        fontSize:
                            meController.isHorizontal.value ? 24.sp : 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: meController.isHorizontal.value ? 18.h : 8.h,
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        errorText: meController.validateOpticAddress.value
                            ? null
                            : 'Alamat optik belum diisi',
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 150,
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Segoe ui',
                        fontSize:
                            meController.isHorizontal.value ? 25.sp : 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      controller: controllerOpticAddress,
                      onChanged: (value) {
                        meController.validateOpticAddress.value = true;
                      },
                    ),
                    SizedBox(
                      height: meController.isHorizontal.value ? 22.h : 12.h,
                    ),
                    // Container(
                    //   height: 15.h,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       Text(
                    //         'Pengajuan Training',
                    //         style: TextStyle(
                    //           color: Colors.black87,
                    //           fontSize: meController.isHorizontal.value
                    //               ? 22.sp
                    //               : 12.sp,
                    //           fontFamily: 'Montserrat',
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //       Switch(
                    //         value: meController.isTraining.value,
                    //         onChanged: (value) {
                    //           meController.isTraining.value = value;
                    //         },
                    //         activeTrackColor: Colors.blue.shade400,
                    //         activeColor: Colors.blue,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Visibility(
                    //   visible: meController.isTraining.value,
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       SizedBox(
                    //         height:
                    //             meController.isHorizontal.value ? 22.h : 12.h,
                    //       ),
                    //       Text(
                    //         'Pilih Trainer',
                    //         style: TextStyle(
                    //           color: Colors.black87,
                    //           fontSize: meController.isHorizontal.value
                    //               ? 24.sp
                    //               : 14.sp,
                    //           fontFamily: 'Montserrat',
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         height:
                    //             meController.isHorizontal.value ? 18.h : 8.h,
                    //       ),
                    //       SizedBox(
                    //         height: 105.h,
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             for (var i in _list)
                    //               Marketingexpense_widgettrainer(
                    //                 trainer: i,
                    //                 isSelected: i.name ==
                    //                         meController.selectedTrainer.value
                    //                     ? true
                    //                     : false,
                    //               ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    //   replacement: SizedBox(
                    //     height: meController.isHorizontal.value ? 18.h : 8.h,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dialogChooseOptic({bool isHorizontal = false}) {
    String search = '';

    return StatefulBuilder(builder: (context, state) {
      return AlertDialog(
        scrollable: true,
        title: Text('Pilih Optik'),
        content: Container(
          height: MediaQuery.of(context).size.height / 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 350.w,
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 10.r : 5.r,
                  vertical: isHorizontal ? 20.r : 10.r,
                ),
                color: Colors.white,
                height: 80.h,
                child: TextField(
                  textInputAction: TextInputAction.search,
                  autocorrect: true,
                  decoration: InputDecoration(
                    hintText: 'Pencarian Data ...',
                    prefixIcon: Icon(Icons.search),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.white70,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 3.r,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          12.r,
                        ),
                      ),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 2.r,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          10.r,
                        ),
                      ),
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2.r,
                      ),
                    ),
                  ),
                  onSubmitted: (value) {
                    search = value;
                  },
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 100.h,
                  child: FutureBuilder(
                    future: service.findAllCustWithAddress(
                        context, mounted, search),
                    builder: (context,
                        AsyncSnapshot<List<OpticWithAddress>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        default:
                          return snapshot.data!.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        'assets/images/not_found.png',
                                        width: isHorizontal ? 100.w : 180.w,
                                        height: isHorizontal ? 100.h : 180.h,
                                      ),
                                    ),
                                    Text(
                                      'Data tidak ditemukan',
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 15.sp : 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red[600],
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                )
                              : itemDialogChooseOptic(snapshot.data!);
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Batal',
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        controllerOpticName.text =
                            meController.selectedOptic.value.namaUsaha!;
                        controllerOpticAddress.text =
                            meController.selectedOptic.value.alamatUsaha!;
                        meController.txtOwner.value.text =
                            meController.selectedOptic.value.contactPerson ??
                                '';

                        meController.dataName.value = meController.txtOwner.value.text;

                        meController.checkRekening(
                            meController.selectedOptic.value.noAccount ?? '');

                        if (meController.selectedOptic.value.typeAccount ==
                            "NEW") {
                          serviceCashback
                              .getIdentitas(
                            context,
                            isMounted: mounted,
                            noAccount:
                                meController.selectedOptic.value.noAccount ??
                                    '',
                          )
                              .then((value) {
                            print("Ktp : ${value?.noKtp}");
                            print("Npwp : ${value?.noNpwp}");

                            meController.txtKtp.value.text = value?.noKtp ?? '';
                            meController.txtNpwp.value.text =
                                value?.noNpwp ?? '';
                            meController.validateDataNik.value = true;

                            meController.dataName.value = value?.nama ?? '';
                            meController.dataNpwp.value = value?.noNpwp ?? '';
                            meController.dataNik.value = value?.noKtp ?? '';
                          });
                        } else {
                          meController.txtKtp.value.text = "";
                          meController.txtNpwp.value.text = "";

                          meController.dataNpwp.value = '';
                          meController.dataNik.value = '';
                        }

                        meController.validateOpticName.value = true;
                        meController.validateOpticAddress.value = true;
                        meController.validateDataName.value = true;

                        Navigator.pop(context);
                      },
                      child: Text(
                        'Pilih',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget itemDialogChooseOptic(List<OpticWithAddress> item) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        width: double.minPositive.w,
        height: 350.h,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: item.length,
          itemBuilder: (BuildContext context, int index) {
            String _key = item[index].namaUsaha!;
            String _type = item[index].typeAccount!;
            return InkWell(
              onTap: () {
                setState(() {
                  item.forEach((element) {
                    element.isChecked = false;
                  });
                  item[index].isChecked = true;
                  meController.selectedOptic.value = item[index];
                });
              },
              child: ListTile(
                title: Text(_key),
                subtitle: Text(
                  _type == 'NEW' ? 'New Customer' : 'Old Customer',
                  style: TextStyle(
                    color: _type == 'NEW' ? Colors.blue : Colors.orange,
                  ),
                ),
                trailing: Visibility(
                  visible: item[index].isChecked,
                  child: Icon(
                    Icons.check,
                    color: Colors.blue.shade700,
                    size: 22.r,
                  ),
                  replacement: SizedBox(
                    width: 5.w,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
