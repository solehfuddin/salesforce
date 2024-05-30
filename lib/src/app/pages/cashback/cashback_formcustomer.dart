import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/domain/entities/cashback_rekening.dart';
import 'package:sample/src/domain/entities/opticwithaddress.dart';
import 'package:sample/src/domain/service/service_cashback.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';

// ignore: must_be_immutable
class CashbackFormCustomer extends StatefulWidget {
  final Function(String? varName, dynamic input) updateParent;
  TextEditingController controllerOpticName = new TextEditingController();
  TextEditingController controllerOptikAddress = new TextEditingController();

  String shipNumber, billNumber, opticType;

  bool isHorizontal = false;
  bool validateOpticName = false;
  bool validateOpticAddress = false;

  CashbackFormCustomer({
    Key? key,
    required this.updateParent,
    required this.isHorizontal,
    required this.validateOpticName,
    required this.validateOpticAddress,
    required this.controllerOpticName,
    required this.controllerOptikAddress,
    required this.shipNumber,
    required this.billNumber,
    required this.opticType,
  }) : super(key: key);

  @override
  State<CashbackFormCustomer> createState() => _CashbackFormCustomerState();
}

class _CashbackFormCustomerState extends State<CashbackFormCustomer> {
  ServicePosMaterial service = new ServicePosMaterial();
  ServiceCashback serviceCashback = new ServiceCashback();

  List<CashbackRekening> listRekening = List.empty(growable: true);
  late OpticWithAddress selectedOptic;

  getIdentitas(String noAccount) {
    serviceCashback
        .getIdentitas(context, isMounted: mounted, noAccount: noAccount)
        .then((value) {
      widget.updateParent('setNamaOwner', value?.nama ?? '');
      widget.updateParent('setKtp', value?.noKtp ?? '');
      widget.updateParent('setNpwp', value?.noNpwp ?? '');
      if (value!.noKtp!.length > 0) {
        widget.updateParent('validateOwnerKtp', true);
      }

      widget.updateParent('validateOwnerName', true);
    });
  }

  getRekening(String noAccount) {
    serviceCashback
        .getRekening(context, isMounted: mounted, noAccount: noAccount)
        .then((value) {
      setState(() {
        listRekening = value;
        widget.updateParent('setWalletAvail', false);

        if (listRekening.isNotEmpty)
        {
           widget.updateParent('setWalletAvail', true);

           print('Set Wallet : true');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: widget.isHorizontal ? 10.r : 5.r,
        right: widget.isHorizontal ? 10.r : 5.r,
        top: widget.isHorizontal ? 20.r : 10.r,
        bottom: widget.isHorizontal ? 20.r : 5.r,
      ),
      child: Card(
        elevation: 2,
        borderOnForeground: true,
        color: MyColors.darkColor,
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
                vertical: widget.isHorizontal ? 20.r : 10.r,
              ),
              child: Center(
                child: Text(
                  'Informasi Optik',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isHorizontal ? 26.sp : 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(
                widget.isHorizontal ? 24.r : 12.r,
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
                      hintText: 'Nama optik',
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
                          widget.validateOpticName ? null : 'Optik belum diisi',
                    ),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: widget.controllerOpticName.text.isNotEmpty ? () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return dialogChooseOptic(
                            isHorizontal: widget.isHorizontal,
                          );
                        },
                      );
                    } : null,
                    maxLength: 100,
                    controller: widget.controllerOpticName,
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 12.h,
                  ),
                  Text(
                    'Alamat Optik',
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Segoe ui',
                      fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                      errorText: widget.validateOpticAddress
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
                      fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    controller: widget.controllerOptikAddress,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        widget.updateParent('validateOpticAddress', true);
                      } else {
                        widget.updateParent('validateOpticAddress', false);
                      }
                    },
                  ),
                  SizedBox(height: 5.h,),
                ],
              ),
            ),
          ],
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
                        primary: Colors.red.shade700,
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
                        primary: Colors.blue,
                      ),
                      onPressed: () {
                        widget.controllerOpticName.text =
                            selectedOptic.namaUsaha!;
                        widget.controllerOptikAddress.text =
                            selectedOptic.alamatUsaha!;

                        widget.updateParent('validateOpticName', true);
                        widget.updateParent('validateOpticAddress', true);
                        widget.updateParent(
                            'setShipNumber', selectedOptic.noAccount!);
                        widget.updateParent(
                            'setBillNumber', selectedOptic.billNumber ?? '');
                        widget.updateParent(
                            'setOpticType', selectedOptic.typeAccount!);

                        getRekening(selectedOptic.billNumber!);

                        //Reset Identitas
                        widget.updateParent('setEnableRekening', false);
                        widget.updateParent('setNamaOwner', '');
                        widget.updateParent('setKtp', '');
                        widget.updateParent('setNpwp', '');
                        widget.updateParent('validateOwnerName', false);
                        widget.updateParent('validateOwnerKtp', false);
                        widget.updateParent('setActiveRekening', false);

                        if (selectedOptic.typeAccount! == 'NEW') {
                          getIdentitas(selectedOptic.billNumber!);
                          widget.updateParent('setEnableRekening', true);
                          widget.updateParent('validateOwnerName', true);
                          widget.updateParent('validateOwnerKtp', true);
                        }

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
                  selectedOptic = item[index];
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
