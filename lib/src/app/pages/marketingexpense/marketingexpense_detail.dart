import 'dart:isolate';
import 'dart:ui';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/controllers/my_controller.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/settings_marketingexpense.dart';
import 'package:sample/src/domain/entities/marketingexpense_header.dart';
import 'package:sample/src/domain/service/service_marketingexpense.dart';

// ignore: camel_case_types, must_be_immutable
class Marketingexpense_Detail extends StatefulWidget {
  MarketingExpenseHeader item;
  bool isAdmin;

  Marketingexpense_Detail({
    Key? key,
    required this.item,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<Marketingexpense_Detail> createState() =>
      _Marketingexpense_DetailState();
}

// ignore: camel_case_types
class _Marketingexpense_DetailState extends State<Marketingexpense_Detail> {
  ServiceMarketingExpense serviceMe = new ServiceMarketingExpense();
  MyController myController = Get.find<MyController>();
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    myController.getRole();
    meController.retryRequestPermission();
    myController.getSalesToken(widget.item.id ?? '');

    serviceMe
        .getLine(
      context,
      mounted,
      idMe: widget.item.id ?? '',
    )
        .then(
      (value) {
        meController.listMELine.addAll(value);
        meController.isLoading.value = false;
      },
    );

    serviceMe
        .getAttachment(context, mounted, idMe: widget.item.id ?? '')
        .then((value) {
      meController.listMeImages.addAll(value);
      meController.isLoadingAttachment.value = false;
    });

    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_marketingexpense',
    );

    _port.listen((message) {
      String id = message[0];
      DownloadTaskStatus status = message[1];
      int progress = message[2];

      setState(() {
        print(id);
        print(status);
        print(progress);
      });
    });

    FlutterDownloader.registerCallback(donwloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    super.dispose();
  }

  static void donwloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? sendPort =
        IsolateNameServer.lookupPortByName('downloader_send_port');

    if (sendPort != null) {
      sendPort.send([id, status, progress]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 &&
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(isHorizontal: true);
      }
      return childWidget(isHorizontal: false);
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    return Obx(
      () => Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity.w,
                height: isHorizontal ? 220.h : 235.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 15.r),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          meController.clearState();
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: isHorizontal ? 20.r : 15.r,
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
                  ],
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/banner_me.png',
                    ),
                    fit: isHorizontal ? BoxFit.cover : BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 30.w : 15.w,
                  vertical: isHorizontal ? 20.h : 10.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Diajukan ${widget.item.salesName}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: isHorizontal ? 15.sp : 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${convertDateWithMonth(widget.item.insertDate!)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: isHorizontal ? 15.sp : 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Divider(
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      'Data optik',
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 16.sp,
                        fontFamily: 'Segoe Ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(
                      height: isHorizontal ? 15.h : 10.h,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5.w,
                          ),
                          VerticalDivider(
                            color: Colors.grey[600],
                            thickness: isHorizontal ? 5 : 3.5,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 5.h,
                                ),
                                Text(
                                  'Nama optik : ',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: isHorizontal ? 14.sp : 12.sp,
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Text(
                                  widget.item.opticName!,
                                  style: TextStyle(
                                    fontFamily: 'Segoe ui',
                                    fontSize: isHorizontal ? 14.sp : 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tipe kustomer : ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Nomor Akun : ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${widget.item.opticType!} CUSTOMER',
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        fontFamily: 'Segoe ui',
                                        fontWeight: FontWeight.w600,
                                        color: getCustomerColor(
                                          widget.item.opticType!,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      widget.item.shipNumber!,
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        fontFamily: 'Segoe ui',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Text(
                                  'Alamat optik : ',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: isHorizontal ? 14.sp : 12.sp,
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Text(
                                  widget.item.opticAddress!,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: isHorizontal ? 15.sp : 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      'Data pemilik',
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 16.sp,
                        fontFamily: 'Segoe Ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.green[600],
                      ),
                    ),
                    SizedBox(
                      height: isHorizontal ? 15.h : 10.h,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5.w,
                          ),
                          VerticalDivider(
                            color: Colors.green[600],
                            thickness: isHorizontal ? 5 : 3.5,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 5.h,
                                ),
                                Text(
                                  'Nama pemilik : ',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: isHorizontal ? 14.sp : 12.sp,
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Text(
                                  widget.item.dataName!,
                                  style: TextStyle(
                                    fontFamily: 'Segoe ui',
                                    fontSize: isHorizontal ? 14.sp : 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'NIK / Sesuai KTP : ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Nomor NPWP : ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.item.dataNik!,
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        fontFamily: 'Segoe ui',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      widget.item.dataNpwp!,
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        fontFamily: 'Segoe ui',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      'Data detail',
                      style: TextStyle(
                        fontSize: isHorizontal ? 18.sp : 16.sp,
                        fontFamily: 'Segoe Ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[600],
                      ),
                    ),
                    SizedBox(
                      height: isHorizontal ? 15.h : 10.h,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5.w,
                          ),
                          VerticalDivider(
                            color: Colors.blue[600],
                            thickness: isHorizontal ? 5 : 3.5,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 5.h,
                                ),
                                Visibility(
                                  visible: widget.item.isSpSatuan == "YES"
                                      ? true
                                      : false,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nomor SP : ',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize:
                                              isHorizontal ? 14.sp : 12.sp,
                                          color: Colors.grey.shade400,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Text(
                                        widget.item.spNumber!,
                                        style: TextStyle(
                                          fontFamily: 'Segoe ui',
                                          fontSize:
                                              isHorizontal ? 14.sp : 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  replacement: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Periode kontrak',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize:
                                              isHorizontal ? 14.sp : 12.sp,
                                          color: Colors.grey.shade400,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Text(
                                        "Berlaku mulai ${convertDateWithMonth(widget.item.spStartPeriode ?? '2024-01-01')} hingga ${convertDateWithMonth(widget.item.spEndPeriode ?? '2024-01-1')}",
                                        style: TextStyle(
                                          fontSize:
                                              isHorizontal ? 14.sp : 12.sp,
                                          fontFamily: 'Segoe ui',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nominal ME : ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Mekanisme ME : ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${widget.item.isSpPercent == 'YES' ? convertPercent(widget.item.totalPercent) : convertToIdr(int.parse(widget.item.totalValue ?? '0'), 0)}",
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        fontFamily: 'Segoe ui',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      widget.item.paymentMechanism!,
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 14.sp : 12.sp,
                                        fontFamily: 'Segoe ui',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: widget.item.paymentMechanism ==
                                          'TRANSFER BANK'
                                      ? true
                                      : false,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 8.h,
                                      ),
                                      Text(
                                        'Informasi rekening',
                                        style: TextStyle(
                                          fontFamily: 'Segoe ui',
                                          fontSize:
                                              isHorizontal ? 15.sp : 14.sp,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      Card(
                                        elevation: 2,
                                        child: Container(
                                          width: double.infinity,
                                          height: isHorizontal ? 115.h : 65.h,
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                isHorizontal ? 25.r : 15.r,
                                            vertical:
                                                isHorizontal ? 20.r : 10.r,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      '${widget.item.accountName} (${widget.item.bankName})',
                                                      style: TextStyle(
                                                        fontSize: isHorizontal
                                                            ? 24.sp
                                                            : 14.sp,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Nomor Rekening : ${widget.item.accountNumber}',
                                                      style: TextStyle(
                                                        fontSize: isHorizontal
                                                            ? 24.sp
                                                            : 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily: 'Segoe ui',
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Image.asset(
                                                'assets/images/success.png',
                                                width:
                                                    isHorizontal ? 45.r : 25.r,
                                                height:
                                                    isHorizontal ? 45.r : 25.r,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  replacement: SizedBox(
                                    width: 5.w,
                                  ),
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Text(
                                  'Batas pembayaran ME : ',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: isHorizontal ? 14.sp : 12.sp,
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Text(
                                  convertDateWithMonth(
                                      widget.item.paymentDate ?? '2024-01-01'),
                                  style: TextStyle(
                                    fontFamily: 'Segoe ui',
                                    fontSize: isHorizontal ? 14.sp : 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Visibility(
                      visible: meController.isLoading.value,
                      child: SizedBox(
                        height: 5,
                      ),
                      replacement: marketingExpenseLineWidget(
                        isHorizontal: isHorizontal,
                        selectedProductLine: meController.listMELine,
                      ),
                    ),
                    Visibility(
                      visible: meController.isLoadingAttachment.value,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                      replacement: marketingExpenseAttachmentWidget(
                        isHor: isHorizontal,
                        context: context,
                        listAttachment: meController.listMeImages,
                      ),
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    Visibility(
                      visible: !widget.isAdmin,
                      replacement: handleAction(
                        context: context,
                        isHorizontal: isHorizontal,
                        header: widget.item,
                      ),
                      child: Center(
                        child: ArgonButton(
                          height: isHorizontal ? 50.h : 40.h,
                          width: isHorizontal ? 90.w : 150.w,
                          borderRadius: 30.0.r,
                          color: Colors.blue[700],
                          child: Text(
                            "Unduh Pdf",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: isHorizontal ? 16.sp : 14.sp,
                                fontWeight: FontWeight.w700),
                          ),
                          loader: Container(
                            padding: EdgeInsets.all(8.r),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                          onTap: (startLoading, stopLoading, btnState) {
                            if (btnState == ButtonState.Idle) {
                              if (meController.permissionReady.value) {
                                donwloadPdfME(
                                  widget.item.id ?? '',
                                  widget.item.opticName ?? 'Optik',
                                  meController.localPath.value,
                                );

                                showStyledToast(
                                  child: Text('Sedang mengunduh file'),
                                  context: context,
                                  backgroundColor: Colors.blue,
                                  borderRadius: BorderRadius.circular(15.r),
                                  duration: Duration(seconds: 2),
                                );
                              } else {
                                showStyledToast(
                                  child:
                                      Text('Tidak mendapat izin penyimpanan'),
                                  context: context,
                                  backgroundColor: Colors.red,
                                  borderRadius: BorderRadius.circular(15.r),
                                  duration: Duration(seconds: 2),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
