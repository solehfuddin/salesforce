import 'package:date_field/date_field.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sample/src/app/controllers/contractpromo_controller.dart';
import 'package:sample/src/domain/entities/contract_promo.dart';
import 'package:sample/src/domain/service/service_promo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/custom.dart';

// ignore: must_be_immutable
class EcontractPromo extends StatefulWidget {
  bool isHorizontal = false;

  EcontractPromo({
    Key? key,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  State<EcontractPromo> createState() => _EcontractPromoState();
}

class _EcontractPromoState extends State<EcontractPromo> {
  ContractPromoController controllerPromo = Get.find<ContractPromoController>();
  ServicePromo servicePromo = new ServicePromo();
  TextEditingController textTitle = new TextEditingController();
  TextEditingController textDescription = new TextEditingController();
  TextEditingController textDateUntil = new TextEditingController();

  final format = DateFormat("dd MMM yyyy");
  String dateUntil = "";
  bool validatePromo = false;
  bool validateUntil = false;
  String? id, role, username, name;

   @override
  void initState() {
    super.initState();
    getRole();
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");
    });
  }

  onButtonPressed() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
      () => handleValidationForm(
        isHorizontal: widget.isHorizontal,
      ),
    );

    return () {};
  }

  handleValidationForm({bool isHorizontal = false}) {
    ContractPromo item = new ContractPromo();
    item.promoName = textTitle.text;
    item.promoDescription = textDescription.text;
    item.promoUntil = dateUntil;
    item.createdBy = id;

    print("""
    Promo Name : ${item.promoName},
    Promo Desc : ${item.promoDescription},
    Promo Until : ${item.promoUntil}
    Promo created by : ${item.createdBy}
    """);

    if (validatePromo && validateUntil) {
      servicePromo
          .insertPromo(context: context, item: item)
          .then((value) {

        item.id = value;
        item.isChecked = true;
        controllerPromo.selectedPromo.value = item;

        Navigator.pop(context);
      });
    } else {
      handleStatus(
        context,
        'Harap lengkapi data',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          margin:
              EdgeInsets.symmetric(vertical: widget.isHorizontal ? 10.r : 5.r),
          padding: EdgeInsets.symmetric(
              horizontal: widget.isHorizontal ? 20.r : 15.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Buat promo manual',
                  style: TextStyle(
                    fontFamily: 'Segoe Ui',
                    fontSize: widget.isHorizontal ? 20.sp : 18.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: widget.isHorizontal ? 40.h : 25.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Program Promo',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Batas waktu',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: widget.isHorizontal ? 18.h : 8.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Isi Promo',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Segoe ui',
                          fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 2.h,
                        ),
                        errorText:
                            validatePromo ? null : 'Program promo belum diisi',
                      ),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                      ),
                      controller: textTitle,
                      onChanged: (value) {
                        setState(() {
                          if (value.length > 3) {
                            validatePromo = true;
                          } else {
                            validatePromo = false;
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    flex: 3,
                    child: DateTimeFormField(
                      decoration: InputDecoration(
                        hintText: 'dd mon yyyy',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        errorText: !validateUntil ? 'Data wajib diisi' : null,
                        hintStyle: TextStyle(
                          fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Segoe Ui',
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 2.h,
                        ),
                      ),
                      dateFormat: format,
                      mode: DateTimeFieldPickerMode.date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                      autovalidateMode: AutovalidateMode.always,
                      onDateSelected: (DateTime value) {
                        print('before date : $value');
                        dateUntil = DateFormat('yyyy-MM-dd').format(value);
                        textDateUntil.text = dateUntil;
                        setState(() {
                          validateUntil = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: widget.isHorizontal ? 20.h : 10.h,
              ),
              Text(
                'Deskripsi Promo',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                  fontFamily: 'Montserrat',
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
                ),
                keyboardType: TextInputType.multiline,
                minLines: 2,
                maxLines: 3,
                maxLength: 250,
                controller: textDescription,
                style: TextStyle(
                  fontSize: widget.isHorizontal ? 18.sp : 14.sp,
                  fontFamily: 'Segoe Ui',
                ),
              ),
              SizedBox(
                height: widget.isHorizontal ? 40.h : 20.h,
              ),
              Center(
                child: EasyButton(
                  idleStateWidget: Text(
                    "Simpan",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.isHorizontal ? 18.sp : 14.sp,
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
                  height: widget.isHorizontal ? 50.h : 40.h,
                  width: widget.isHorizontal ? 90.w : 100.w,
                  borderRadius: widget.isHorizontal ? 60.r : 30.r,
                  buttonColor: Colors.blue.shade700,
                  elevation: 2.0,
                  contentGap: 6.0,
                  onPressed: onButtonPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
