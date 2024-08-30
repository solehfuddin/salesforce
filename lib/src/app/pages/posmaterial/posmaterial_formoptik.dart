import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/domain/entities/opticwithaddress.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';

// ignore: camel_case_types, must_be_immutable
class Posmaterial_Formoptik extends StatefulWidget {
  final Function(String? input) notifyParent;
  final Function(String? varName, dynamic input) updateParent;
  TextEditingController controllerOptikName = new TextEditingController();
  TextEditingController controllerOptikAddress = new TextEditingController();

  bool isHorizontal = false;
  bool validateOpticName = false;
  bool validateOpticAddress = false;
  String selectedTypePos = 'CUSTOM';
  String accountNo = '';
  String accountType = '';

  Posmaterial_Formoptik({
    Key? key,
    required this.isHorizontal,
    required this.accountNo,
    required this.accountType,
    required this.controllerOptikName,
    required this.controllerOptikAddress,
    required this.selectedTypePos,
    required this.notifyParent,
    required this.updateParent,
    required this.validateOpticName,
    required this.validateOpticAddress,
  }) : super(key: key);

  @override
  State<Posmaterial_Formoptik> createState() => _Posmaterial_FormoptikState();
}

// ignore: camel_case_types
class _Posmaterial_FormoptikState extends State<Posmaterial_Formoptik> {
  ServicePosMaterial service = new ServicePosMaterial();
  late OpticWithAddress selectedOptic;

  bool isProspect = false;

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
                    'Tipe Pos Material',
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
                  Container(
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
                      value: widget.selectedTypePos,
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Segoe ui',
                        fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      items: [
                        'CUSTOM',
                        'KEMEJA_LEINZ_HIJAU',
                        'MATERIAL_KIT',
                        'POSTER',
                        'OTHER'
                      ].map((e) {
                        return DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ));
                      }).toList(),
                      hint: Text(
                        'Pilih tipe pos material',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onChanged: (String? _value) {
                        setState(() {
                          widget.selectedTypePos = _value!;
                          widget.notifyParent(_value);
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 12.h,
                  ),
                  Container(
                    height: 15.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Prospect Customer',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: widget.isHorizontal ? 22.sp : 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: isProspect,
                          onChanged: (value) {
                            setState(() {
                              isProspect = value;
                              widget.controllerOptikName.clear();
                              widget.controllerOptikAddress.clear();
                              widget.accountNo = '';

                              widget.updateParent(
                                'validateOpticName',
                                false,
                              );
                              widget.updateParent(
                                'validateOpticAddress',
                                false,
                              );
                              
                              widget.notifyParent(widget.selectedTypePos);

                              if (value)
                              {
                                widget.updateParent('isProspectCustomer', true);
                              }
                              else
                              {
                                widget.updateParent('isProspectCustomer', false);
                              }
                            });
                          },
                          activeTrackColor: Colors.blue.shade400,
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 12.h,
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
                  Visibility(
                    visible: isProspect,
                    child: TextFormField(
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
                        errorText: widget.validateOpticName
                            ? null
                            : 'Optik belum diisi',
                      ),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          widget.updateParent('validateOpticName', true);
                        } else {
                          widget.updateParent('validateOpticName', false);
                        }
                      },
                      maxLength: 75,
                      controller: widget.controllerOptikName,
                    ),
                    replacement: TextFormField(
                      readOnly: true,
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
                        errorText: widget.validateOpticName
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
                        fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLength: 75,
                      controller: widget.controllerOptikName,
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
                        widget.controllerOptikName.text =
                            selectedOptic.namaUsaha!;
                        widget.controllerOptikAddress.text =
                            selectedOptic.alamatUsaha!;
                        widget.accountNo = selectedOptic.noAccount!;
                        widget.accountType = selectedOptic.typeAccount!;

                        widget.updateParent('validateOpticName', true);
                        widget.updateParent('validateOpticAddress', true);
                        widget.updateParent('accountNo', selectedOptic.noAccount!);
                        widget.updateParent('accountType', selectedOptic.typeAccount!);

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
