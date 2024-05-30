import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/cashback/cashback_form.dart';
import 'package:sample/src/app/pages/cashback/cashback_itemlist.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/cashback_rekening.dart';
import 'package:sample/src/domain/entities/cashback_resheader.dart';
import 'package:sample/src/domain/entities/opticwithaddress.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:sample/src/domain/entities/product.dart';
import 'package:sample/src/domain/service/service_cashback.dart';

// ignore: must_be_immutable
class CashbackManagement extends StatefulWidget {
  OpticWithAddress optic;
  bool isHorizontal;
  CashbackManagement({
    Key? key,
    required this.isHorizontal,
    required this.optic,
  }) : super(key: key);

  @override
  State<CashbackManagement> createState() => _CashbackManagementState();
}

class _CashbackManagementState extends State<CashbackManagement> {
  ServiceCashback serviceCashback = new ServiceCashback();
  List<CashbackRekening> listRekening = List.empty(growable: true);
  List<Proddiv> listTargetProddiv = List.empty(growable: true);
  List<Proddiv> listProductProddiv = List.empty(growable: true);
  List<Product> listProductKhusus = List.empty(growable: true);
  Future<CashbackResHeader>? header;
  CashbackResHeader? otherHeader;

  String? noKtp, noNpwp, attachmentSign, attachmentOther;
  bool isCashbackExpired = true;
  @override
  void initState() {
    super.initState();
    header = serviceCashback.getCashbackHeader(
      mounted,
      context,
      shipNumber: widget.optic.noAccount ?? '',
      limit: 3,
    );

    serviceCashback
        .getCashbackHeader(
      mounted,
      context,
      shipNumber: widget.optic.noAccount ?? '',
      limit: 1,
    )
        .then((value) {
      otherHeader = value;

      if (value.status) {
        getTargetProddiv(value.cashback[0].targetProduct!);
        getProductLine(value.cashback[0].id!);
        getAttachment(value.cashback[0].id!);
      }

      setState(() {
        if (value.status) {
          isCashbackExpired = getActiveCashback(value.cashback[0].endPeriode);
        }
      });
    });

    getRekening();

    if (widget.optic.typeAccount == "NEW") {
      getIdentitas();
    }
  }

  void getIdentitas() {
    serviceCashback
        .getIdentitas(context,
            isMounted: mounted, noAccount: widget.optic.noAccount ?? '')
        .then((value) {
      noKtp = value?.noKtp;
      noNpwp = value?.noNpwp;
    });
  }

  void getRekening() {
    serviceCashback
        .getRekening(
          context,
          isMounted: mounted,
          noAccount: widget.optic.noAccount ?? '',
        )
        .then((value) => listRekening.addAll(value));
  }

  void getTargetProddiv(String proddiv) {
    listTargetProddiv.clear();
    serviceCashback
        .getProddivCashbackCustom(context,
            isMounted: mounted, inputProddiv: proddiv)
        .then((value) {
      listTargetProddiv.addAll(value);
    });
  }

  void getAttachment(String cashbackId) {
    serviceCashback
        .getAttachment(context, isMounted: mounted, idCashback: cashbackId)
        .then((value) {
      attachmentSign = value.attachmentSign ?? '';
      attachmentOther = value.attachmentOther ?? '';
    });
  }

  void getProductLine(String cashbackId) {
    listProductProddiv.clear();
    listProductKhusus.clear();

    serviceCashback
        .getCashbackLine(context, isMounted: mounted, cashbackId: cashbackId)
        .then((value) {
      value.forEach((element) {
        if (element.categoryId!.isEmpty) {
          listProductProddiv.add(Proddiv(
            element.prodCatDescription ?? '',
            element.prodDiv ?? '',
            element.cashback ?? '',
          ));
        } else {
          listProductKhusus.add(Product(
            element.categoryId ?? '',
            element.prodDiv ?? '',
            element.prodCat ?? '',
            element.prodCatDescription ?? '',
            element.cashback ?? '',
            element.status ?? '',
          ));
        }
      });
    });
  }

  bool getActiveCashback(String? endPeriode) {
    bool output = true;
    DateTime nowDate = DateTime.now();
    DateTime endDate = DateTime.parse(endPeriode!);
    Duration duration = nowDate.difference(endDate);

    if (duration.inDays <= 0) {
      print('Tanggal masih aktif');
      output = false;
    } else {
      print('Tanggal kadaluarsa');
      output = true;
    }

    return output;
  }

  Future<void> _refreshData() async {
    setState(() {
      header = serviceCashback.getCashbackHeader(
        mounted,
        context,
        shipNumber: widget.optic.noAccount ?? '',
        limit: 3,
      );

      serviceCashback
          .getCashbackHeader(
        mounted,
        context,
        shipNumber: widget.optic.noAccount ?? '',
        limit: 1,
      )
          .then((value) {
        otherHeader = value;

        if (value.status) {
          getTargetProddiv(value.cashback[0].targetProduct!);
          getProductLine(value.cashback[0].id!);
          getAttachment(value.cashback[0].id!);
        }

        setState(() {
          if (value.status) {
            isCashbackExpired = getActiveCashback(value.cashback[0].endPeriode);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return widgetChild(isHorizontal: true);
      }

      return widgetChild(isHorizontal: false);
    });
  }

  Widget widgetChild({bool isHorizontal = false}) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity.w,
                height: isHorizontal ? 240.h : 170.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: isHorizontal
                            ? MediaQuery.of(context).size.height / 1.9
                            : MediaQuery.of(context).size.width / 5,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: isHorizontal ? 25.r : 15.r,
                        ),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(CircleBorder()),
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(8.r)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity.w,
                      height: isHorizontal ? 25.h : 18.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isHorizontal ? 60.r : 30.r),
                          topRight: Radius.circular(isHorizontal ? 60.r : 30.r),
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/green_abstract.png'),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: isHorizontal ? 10.h : 5.h,
                  bottom: isHorizontal ? 20.h : 10.h,
                  left: isHorizontal ? 20.h : 17.h,
                  right: isHorizontal ? 20.h : 17.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        widget.optic.namaUsaha ?? 'Uknown Optic',
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 20.sp : 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Center(
                      child: Text(
                        widget.optic.alamatUsaha ?? '',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isHorizontal ? 15.h : 10.h,
                        vertical: isHorizontal ? 10.h : 5.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: widget.optic.typeAccount == "OLD"
                                ? Colors.amber.shade400
                                : Colors.blue.shade400),
                        borderRadius: BorderRadius.circular(25.w),
                      ),
                      child: Text(
                        widget.optic.typeAccount! == "NEW"
                            ? "New Customer"
                            : "Old Customer",
                        style: TextStyle(
                          fontFamily: 'Segoe ui',
                          fontSize: isHorizontal ? 14.sp : 11.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.optic.typeAccount == "OLD"
                              ? Colors.amber.shade600
                              : Colors.blue.shade600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bill Number',
                          style: TextStyle(
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 20.sp : 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Ship Number',
                          style: TextStyle(
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 18.sp : 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.optic.billNumber ?? '-',
                          style: TextStyle(
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 20.sp : 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          widget.optic.noAccount ?? '-',
                          style: TextStyle(
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 18.sp : 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Contact Person',
                          style: TextStyle(
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 20.sp : 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Phone Number',
                          style: TextStyle(
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 18.sp : 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.optic.contactPerson ?? '-',
                          style: TextStyle(
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 20.sp : 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          widget.optic.phone!
                              .replaceAll("62", "0")
                              .replaceAll("-", ""),
                          style: TextStyle(
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 18.sp : 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Divider(
                      color: Colors.grey.shade400,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isHorizontal ? 12.r : 7.r,
                          ),
                          child: Text(
                            'Cashback Optik : ',
                            style: TextStyle(
                                fontSize: isHorizontal ? 19.sp : 15.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Visibility(
                          visible: isCashbackExpired,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isHorizontal ? 15.r : 0.r,
                            ),
                            child: Ink(
                              decoration: const ShapeDecoration(
                                color: Colors.lightBlue,
                                shape: CircleBorder(),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    constraints: BoxConstraints(
                                      maxHeight: isHorizontal ? 40.r : 30.r,
                                      maxWidth: isHorizontal ? 40.r : 30.r,
                                    ),
                                    icon: const Icon(Icons.add),
                                    iconSize: isHorizontal ? 20.r : 15.r,
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CashbackForm(
                                                isUpdateForm: false,
                                                listRekening: listRekening,
                                                listTargetProddiv: [],
                                                listProductProddiv: [],
                                                listProductKhusus: [],
                                                constructOpticName:
                                                    widget.optic.namaUsaha ??
                                                        '',
                                                constructOpticAddress:
                                                    widget.optic.alamatUsaha ??
                                                        '',
                                                constructShipNumber:
                                                    widget.optic.noAccount ??
                                                        '',
                                                constructBillNumber:
                                                    widget.optic.billNumber ??
                                                        '',
                                                constructTypeAccount:
                                                    widget.optic.typeAccount ??
                                                        '',
                                                constructOwnerName: widget
                                                        .optic.contactPerson ??
                                                    '',
                                                constructOwnerNik: noKtp ?? '',
                                                constructOwnerNpwp:
                                                    noNpwp ?? '',
                                              ),
                                            ),
                                          )
                                          .then((value) => setState(() {
                                                _refreshData();
                                              }));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          replacement: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isHorizontal ? 15.r : 0.r,
                            ),
                            child: Ink(
                              decoration: const ShapeDecoration(
                                color: Colors.orange,
                                shape: CircleBorder(),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    constraints: BoxConstraints(
                                      maxHeight: isHorizontal ? 40.r : 30.r,
                                      maxWidth: isHorizontal ? 40.r : 30.r,
                                    ),
                                    icon: const Icon(Icons.edit_sharp),
                                    iconSize: isHorizontal ? 20.r : 15.r,
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => CashbackForm(
                                            isUpdateForm: true,
                                            listRekening: listRekening,
                                            listTargetProddiv:
                                                listTargetProddiv,
                                            listProductProddiv:
                                                listProductProddiv,
                                            listProductKhusus:
                                                listProductKhusus,
                                            constructIdCashback:
                                                otherHeader!.cashback[0].id ??
                                                    '',
                                            constructOpticName:
                                                widget.optic.namaUsaha ?? '',
                                            constructOpticAddress:
                                                widget.optic.alamatUsaha ?? '',
                                            constructShipNumber:
                                                widget.optic.noAccount ?? '',
                                            constructBillNumber:
                                                widget.optic.billNumber ?? '',
                                            constructTypeAccount:
                                                widget.optic.typeAccount ?? '',
                                            constructOwnerName:
                                                widget.optic.contactPerson ??
                                                    '',
                                            // constructOwnerNik:
                                            //     widget.optic.typeAccount ==
                                            //             "NEW"
                                            //         ? noKtp ?? ''
                                            //         : otherHeader!
                                            //             .cashback[0].dataNik!,
                                            constructOwnerNik:
                                                otherHeader!
                                                        .cashback[0].dataNik!,
                                            // constructOwnerNpwp:
                                            //     widget.optic.typeAccount ==
                                            //             "NEW"
                                            //         ? noNpwp ?? ''
                                            //         : otherHeader!
                                            //             .cashback[0].dataNpwp!,
                                            constructOwnerNpwp: otherHeader!
                                                        .cashback[0].dataNpwp!,
                                            constructIdCashbackRekening:
                                                otherHeader!.cashback[0]
                                                    .idCashbackRekening!,
                                            constructStartDate: otherHeader!
                                                .cashback[0].startPeriode!,
                                            constructEndDate: otherHeader!
                                                .cashback[0].endPeriode!,
                                            constructWithdrawProcess:
                                                otherHeader!.cashback[0]
                                                    .withdrawProcess!,
                                            constructWithdrawDuration:
                                                otherHeader!.cashback[0]
                                                    .withdrawDuration!,
                                            constructPaymentDuration:
                                                otherHeader!.cashback[0]
                                                    .paymentDuration!,
                                            constructTypeCashback: otherHeader!
                                                .cashback[0].cashbackType!,
                                            constructTargetValue: int.parse(
                                                otherHeader!
                                                    .cashback[0].targetValue!),
                                            constructCashbackValue: int.parse(
                                                otherHeader!.cashback[0]
                                                    .cashbackValue!),
                                            constructCashbackPercent:
                                                double.parse(otherHeader!
                                                    .cashback[0]
                                                    .cashbackPercentage!),
                                            constructTargetProduct: otherHeader!
                                                .cashback[0].targetProduct!,
                                            constructAttachmentSign:
                                                attachmentSign ?? '',
                                            constructAttachmentOther:
                                                attachmentOther ?? '',
                                          ),
                                        ),
                                      ).then((value) => setState(() {
                                        _refreshData();
                                      }));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                future: header,
                builder: (BuildContext context,
                    AsyncSnapshot<CashbackResHeader> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data!.total! > 0) {
                      return Column(
                        children: [
                          Visibility(
                            visible: getActiveCashback(
                                snapshot.data!.cashback[0].endPeriode),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 15.w),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.h, vertical: 5.h),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.shade200,
                                    borderRadius: BorderRadius.circular(3.h),
                                  ),
                                  child: Text(
                                    'Kontrak cashback sudah kadaluarsa sejak ${convertDateWithMonth(snapshot.data!.cashback[0].endPeriode!)}',
                                    style: TextStyle(
                                      fontFamily: 'Segoe Ui',
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                              ],
                            ),
                            replacement: SizedBox(
                              width: 5.w,
                            ),
                          ),
                          LimitedBox(
                            maxWidth: 360.w,
                            maxHeight: 245.h,
                            child: CashbackItemList(
                              isHorizontal: isHorizontal,
                              isSales: true,
                              itemHeader: snapshot.data,
                              showDownload: true,
                            ),
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20.h,
                          ),
                          Center(
                            child: Image.asset(
                              'assets/images/not_found.png',
                              width: isHorizontal ? 150.w : 180.w,
                              height: isHorizontal ? 150.h : 180.h,
                            ),
                          ),
                          Text(
                            'Data tidak ditemukan',
                            style: TextStyle(
                              fontSize: isHorizontal ? 14.sp : 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                        ],
                      );
                    }
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
