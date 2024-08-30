import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/cashback_rekening.dart';
import 'package:sample/src/domain/entities/master_bank.dart';
import 'package:sample/src/domain/service/service_cashback.dart';

// ignore: must_be_immutable
class CashbackNewRekening extends StatefulWidget {
  final Function(String? varName, dynamic input) updateParent;
  bool isHorizontal = false;
  String billNumber, shipNumber;

  CashbackNewRekening({
    Key? key,
    required this.updateParent,
    required this.isHorizontal,
    required this.billNumber,
    required this.shipNumber,
  }) : super(key: key);

  @override
  State<CashbackNewRekening> createState() => _CashbackNewRekeningState();
}

class _CashbackNewRekeningState extends State<CashbackNewRekening> {
  ServiceCashback serviceCashback = new ServiceCashback();
  TextEditingController controllerNama = new TextEditingController();
  TextEditingController controllerNomor = new TextEditingController();

  List<ListMasterBank> _listBank = List.empty(growable: true);
  List<String> listBank = List.empty(growable: true);

  int selectedIdBank = 1;
  String selectedBank = 'Mandiri';

  bool validateName = false;
  bool validateNomor = false;

  @override
  void initState() {
    super.initState();
    serviceCashback.getMasterBank(context, isMounted: mounted).then((value) {
      _listBank = value;

      setState(() {
        _listBank.forEach((element) => listBank.add(element.shortName));
      });
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
    print("""
    Bank id : $selectedIdBank,
    Bank name : $selectedBank,
    Nomor rekening : ${controllerNomor.text}
    Nama tertera : ${controllerNama.text}
    Bill number : ${widget.billNumber}
    Ship number : ${widget.shipNumber}
    """);

    CashbackRekening item = new CashbackRekening();
    item.setIdBank = selectedIdBank.toString();
    item.setBankName = selectedBank;
    item.setNomorRekening = controllerNomor.text;
    item.setNamaRekening = controllerNama.text;
    item.setBillNumber = widget.billNumber;
    item.setShipNumber = widget.shipNumber;

    if (validateName && validateNomor) {
      serviceCashback
          .insertRekening(context: context, item: item)
          .then((value) {
        print("Id Rekening : $value");
        item.setIdRekening = value;
        widget.updateParent("updateNewRekening", item);

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
          margin: EdgeInsets.symmetric(
            vertical: widget.isHorizontal ? 15.h : 10.h,
            horizontal: widget.isHorizontal ? 20.h : 15.h,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Buat Rekening Baru',
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
              Text(
                'Nama Sesuai Rekening',
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
                  hintText: 'Nama Sesuai Rekening',
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
                  errorText: validateName ? null : 'Nama belum diisi',
                ),
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                ),
                controller: controllerNama,
                onChanged: (value) {
                  if (value.length > 3) {
                    validateName = true;
                  } else {
                    validateName = false;
                  }
                },
              ),
              SizedBox(
                height: widget.isHorizontal ? 40.h : 20.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Pilih Bank',
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
                    flex: 1,
                    child: Text(
                      'Nomor Rekening',
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
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.isHorizontal ? 10.r : 5.r,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black54,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: DropdownButton(
                        underline: SizedBox(),
                        isExpanded: true,
                        value: selectedBank,
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Segoe ui',
                          fontSize: widget.isHorizontal ? 20.sp : 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        items: listBank.map((item) {
                          return DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ));
                        }).toList(),
                        hint: Text(
                          'Pilih Bank',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: widget.isHorizontal ? 20.sp : 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                          ),
                        ),
                        onChanged: (String? _value) {
                          setState(() {
                            int index = _listBank
                                .indexWhere((item) => item.shortName == _value);

                            selectedIdBank = int.parse(_listBank[index].idBank);
                            selectedBank = _listBank[index].shortName;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Nomor Rekening',
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
                      ),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                      ),
                      controller: controllerNomor,
                      onChanged: (value) {
                        if (value.length > 5) {
                          validateNomor = true;
                        } else {
                          validateNomor = false;
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40.h,
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
