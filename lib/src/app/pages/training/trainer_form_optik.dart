import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/training_controller.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';

import '../../../domain/entities/opticwithaddress.dart';

// ignore: must_be_immutable
class TrainerFormOptik extends StatefulWidget {
  bool isHorizontal = false;

  TrainerFormOptik({
    Key? key,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  State<TrainerFormOptik> createState() => _TrainerFormOptikState();

  void updateParent(String s, bool bool) {}
}

class _TrainerFormOptikState extends State<TrainerFormOptik> {
  TrainingController controller = Get.find<TrainingController>();
  ServicePosMaterial service = new ServicePosMaterial();

  TextEditingController controllerOptik = new TextEditingController();
  TextEditingController controllerAddress = new TextEditingController();
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Optik',
              style: TextStyle(
                color: Colors.black54,
                fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: widget.isHorizontal ? 18.h : 8.h,
            ),
            Visibility(
              visible: controller.isProspect.value,
              child: TextFormField(
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Nama optik',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Segoe ui',
                    fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 2.h,
                  ),
                  errorText: controller.validateOpticName.value
                      ? null
                      : 'Optik belum diisi',
                ),
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (value) {
                  // if (value.isNotEmpty) {
                  //   widget.updateParent('validateOpticName', true);
                  // } else {
                  //   widget.updateParent('validateOpticName', false);
                  // }

                  if (value.isNotEmpty) {
                    controller.validateOpticName.value = true;
                  } else {
                    controller.validateOpticName.value = false;
                  }
                },
                // maxLength: 75,
                controller: controllerOptik,
              ),
              replacement: TextFormField(
                readOnly: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Nama optik',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Segoe ui',
                    fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 2.h,
                  ),
                  errorText: controller.validateOpticName.value
                      ? null
                      : 'Optik belum diisi',
                  suffixIcon: IconButton(
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return dialogChooseOptic(
                            isHorizontal: widget.isHorizontal,
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
                  fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                ),
                // maxLength: 75,
                controller: controllerOptik,
                onTap: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return dialogChooseOptic(
                        isHorizontal: widget.isHorizontal,
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: widget.isHorizontal ? 22.h : 10.h,
            ),
            Text(
              'Alamat Optik',
              style: TextStyle(
                color: Colors.black54,
                fontFamily: 'Segoe ui',
                fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: widget.isHorizontal ? 18.h : 8.h,
            ),
            TextFormField(
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
                errorText: controller.validateOpticAddress.value
                    ? null
                    : 'Alamat optik belum diisi',
              ),
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 5,
              // maxLength: 150,
              style: TextStyle(
                color: Colors.black54,
                fontFamily: 'Segoe ui',
                fontSize: widget.isHorizontal ? 18.sp : 12.sp,
                fontWeight: FontWeight.w600,
              ),
              controller: controllerAddress,
              onChanged: (value) {
                // if (value.isNotEmpty) {
                //   widget.updateParent('validateOpticAddress', true);
                // } else {
                //   widget.updateParent('validateOpticAddress', false);
                // }

                if (value.isNotEmpty) {
                  controller.validateOpticAddress.value = true;
                } else {
                  controller.validateOpticAddress.value = false;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget dialogChooseOptic({bool isHorizontal = false}) {
    return StatefulBuilder(builder: (context, state) {
      return Obx(
        () => AlertDialog(
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
                      controller.search.value = value;
                    },
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 100.h,
                    child: FutureBuilder(
                      future: service.findAllCustWithAddress(
                        context,
                        mounted,
                        controller.search,
                      ),
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
                                          fontSize:
                                              isHorizontal ? 15.sp : 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[600],
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  )
                                : itemDialogChooseOptic(
                                    snapshot.data!,
                                  );
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
                          controllerOptik.text   = controller.selectedOptic.value.namaUsaha ?? '';
                          controllerAddress.text = controller.selectedOptic.value.alamatUsaha ?? "";

                          controller.validateOpticName.value = true;
                          controller.validateOpticAddress.value = true;

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
                  controller.selectedOptic.value = item[index];
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
