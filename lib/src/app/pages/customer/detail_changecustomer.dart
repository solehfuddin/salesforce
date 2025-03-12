import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/itemsetting.dart';

import '../../../domain/entities/change_customer.dart';
import '../../../domain/entities/change_customer_file.dart';
import '../../utils/config.dart';
import '../../widgets/dialogImage.dart';
import '../admin/admin_view.dart';

// ignore: must_be_immutable
class DetailChangeCustomer extends StatefulWidget {
  ChangeCustomer? customer;
  String? username, divisi, role;
  bool isPending;
  DetailChangeCustomer({
    Key? key,
    this.customer,
    this.username,
    this.divisi,
    this.role,
    this.isPending = false,
  }) : super(key: key);

  @override
  State<DetailChangeCustomer> createState() => _DetailChangeCustomerState();
}

class _DetailChangeCustomerState extends State<DetailChangeCustomer> {
  TextEditingController textReason = new TextEditingController();
  bool _isLoadingTitle = true;
  bool _isHorizontal = false;
  bool _isReason = false;
  ChangeCustomerFile? fileCust;

  @override
  initState() {
    super.initState();
    getCustomerFile(widget.customer?.id);
  }

  getCustomerFile(dynamic idCust) async {
    const timeout = 15;
    var url = '$API_URL/customers/changeCustomerFile?id=$idCust';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          var rest = data['data'];
          print(rest);

          fileCust = ChangeCustomerFile.fromJson(rest);
        }

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoadingTitle = false;
          });
        });
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
    } on SocketException catch (e) {
      print('Socket Error : $e');
    } on Error catch (e) {
      print('General Error : $e');
    }
  }

  onPressedReject() async {
    handleRejection(
      context,
      isHorizontal: _isHorizontal,
    );

    return () {};
  }

  onPressedApprove() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
      () => widget.divisi == "AR"
          ? approve(true, widget.customer?.id ?? '',
              approverAm: widget.username ?? '')
          : approve(false, widget.customer?.id ?? '',
              approverSm: widget.username ?? ''),
    );

    return () {};
  }

  approve(
    bool isAr,
    String id, {
    bool isHorizontal = false,
    String approverSm = '',
    String approverAm = '',
  }) async {
    const timeout = 15;
    var url = '$API_URL/approval/approveChangeCust';

    try {
      var response = await http
          .post(
            Uri.parse(url),
            body: !isAr
                ? {
                    'id_change_customer': id,
                    'approver_sm': approverSm,
                  }
                : {
                    'id_change_customer': id,
                    'approver_am': approverAm,
                  },
          )
          .timeout(Duration(seconds: timeout));

      print("""
      id_change_customer : $id,
      approver_sm : $approverSm,
      approver_am : $approverAm,
      """);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        handleStatus(
          context,
          capitalize(msg),
          sts,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      } on FormatException catch (e) {
        print('Format Error : $e');
        if (mounted) {
          handleStatus(
            context,
            e.toString(),
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : $e');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      }
    }
  }

  reject(
    bool isAr,
    String id, {
    bool isHorizontal = false,
    String approverSm = '',
    String approverAm = '',
    String reasonSm = '',
    String reasonAm = '',
  }) async {
    const timeout = 15;
    var url = '$API_URL/approval/rejectChangeCust';

    try {
      var response = await http
          .post(
            Uri.parse(url),
            body: !isAr
                ? {
                    'id_change_customer': id,
                    'approver_sm': approverSm,
                    'reason_sm': reasonSm,
                  }
                : {
                    'id_change_customer': id,
                    'approver_am': approverAm,
                    'reason_am': reasonAm,
                  },
          )
          .timeout(Duration(seconds: timeout));
      print("""
      id_change_customer : $id,
      approver_sm : $approverSm,
      reason_sm : $reasonSm
      approver_am : $approverAm,
      reason_am : $reasonAm
      """);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        handleStatus(
          context,
          capitalize(msg),
          sts,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      } on FormatException catch (e) {
        print('Format Error : $e');
        if (mounted) {
          handleStatus(
            context,
            e.toString(),
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : $e');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return masterChild(isHor: true);
      }

      return masterChild(isHor: false);
    });
  }

  Widget masterChild({bool isHor = false}) {
    _isHorizontal = isHor;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity.w,
              height: isHor ? 200.h : 220.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 30.r),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.role != "SALES" && widget.divisi != "SALES"
                            ? Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => AdminScreen()))
                            : Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: isHor ? 20.r : 15.r,
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(CircleBorder()),
                        padding: MaterialStateProperty.all(EdgeInsets.all(8.r)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.r,
                      vertical: widget.customer?.namaUsaha == "null"
                          ? 3.r
                          : widget.customer!.namaUsaha!.length > 32
                              ? 3.r
                              : 15.r,
                    ),
                    child: Center(
                      child: Text(
                        'Perubahan Data Customer',
                        style: TextStyle(
                          fontSize: isHor ? 25.sp : 18.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/sepakat.jpg'),
                  fit: isHor ? BoxFit.cover : BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            SizedBox(
              height: isHor ? 20.h : 15.h,
            ),
            _isLoadingTitle
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.customer?.namaUsaha ?? '',
                              style: TextStyle(
                                fontFamily: 'Segoe Ui',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Tanggal Diajukan',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54),
                                ),
                                SizedBox(
                                  height: 3.h,
                                ),
                                Text(
                                  convertDateWithMonth(
                                      widget.customer!.dateAdded.toString()),
                                  style: TextStyle(
                                    fontFamily: 'Segoe Ui',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isHor ? 15.h : 8.h,
                        ),
                        Container(
                          height: isHor ? 3.h : 1.3.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                        ),
                        SizedBox(
                          height: isHor ? 15.h : 8.h,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 5.h,
                              horizontal: 8.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: isHor ? 10.h : 5.h,
                                ),
                                Text(
                                  'Data Pemilik',
                                  style: TextStyle(
                                    fontSize: isHor ? 16.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(
                                  height: isHor ? 15.h : 10.h,
                                ),
                                ItemSetting(
                                  marginHor: isHor ? 8.w : 3.w,
                                  label: "Nama",
                                  contain: widget.customer?.nama?.trim(),
                                  changeContain: widget.customer?.namaUpdate?.trim(),
                                  iconData: Icons.person_2_outlined,
                                  colorIcon: Colors.green.shade400,
                                  backgroundIcon: Colors.green.shade100,
                                  isOpen: false,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                ItemSetting(
                                  marginHor: isHor ? 8.w : 3.w,
                                  label: "No. NIK / No. NPWP",
                                  contain:
                                      "${widget.customer?.noIdentitas} / ${convertDateWithMonth(widget.customer!.noNpwp!)}",
                                  changeContain: widget.customer!
                                              .noIdentitasUpdate!.isNotEmpty ||
                                          widget.customer!.noNpwpUpdate!
                                              .isNotEmpty
                                      ? "${widget.customer?.noIdentitasUpdate} / ${convertDateWithMonth(widget.customer!.noNpwpUpdate!)}"
                                      : "",
                                  iconData: Icons.contact_emergency_outlined,
                                  colorIcon: Colors.green.shade400,
                                  backgroundIcon: Colors.green.shade100,
                                  isOpen: false,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                ItemSetting(
                                  marginHor: isHor ? 8.w : 3.w,
                                  label: "Tempat / Tgl Lahir",
                                  contain:
                                      "${widget.customer?.tempatLahir} / ${convertDateWithMonth(widget.customer!.tanggalLahir!).toUpperCase()}",
                                  changeContain: widget.customer!
                                              .tempatLahirUpdate!.isNotEmpty &&
                                          widget.customer!.tanggalLahirUpdate!
                                              .isNotEmpty
                                      ? "${widget.customer?.tempatLahirUpdate} / ${convertDateWithMonth(widget.customer!.tanggalLahirUpdate!).toUpperCase()}"
                                      : "",
                                  iconData: Icons.date_range_outlined,
                                  colorIcon: Colors.green.shade400,
                                  backgroundIcon: Colors.green.shade100,
                                  isOpen: false,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                ItemSetting(
                                  marginHor: isHor ? 8.w : 3.w,
                                  label: "Agama",
                                  contain: widget.customer?.agama,
                                  changeContain: widget.customer?.agamaUpdate,
                                  iconData: Icons.volunteer_activism_outlined,
                                  colorIcon: Colors.green.shade400,
                                  backgroundIcon: Colors.green.shade100,
                                  isOpen: false,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                ItemSetting(
                                  marginHor: isHor ? 8.w : 3.w,
                                  label: "No. Tlp / Fax",
                                  contain:
                                      "${widget.customer?.noTelp} / ${widget.customer!.fax!}",
                                  changeContain: widget.customer!.noTelpUpdate!
                                              .isNotEmpty &&
                                          widget.customer!.faxUpdate!.isNotEmpty
                                      ? "${widget.customer?.noTelpUpdate} / ${widget.customer!.faxUpdate!}"
                                      : "",
                                  iconData: Icons.phone_outlined,
                                  colorIcon: Colors.green.shade400,
                                  backgroundIcon: Colors.green.shade100,
                                  isOpen: false,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                ItemSetting(
                                  marginHor: isHor ? 8.w : 3.w,
                                  label: "Alamat",
                                  contain: widget.customer?.alamat,
                                  changeContain: widget.customer!.alamatUpdate,
                                  iconData: Icons.house_outlined,
                                  colorIcon: Colors.green.shade400,
                                  backgroundIcon: Colors.green.shade100,
                                  isOpen: false,
                                ),
                                SizedBox(
                                  height: isHor ? 15.h : 8.h,
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 5.h,
                              horizontal: 8.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: isHor ? 10.h : 5.h,
                                ),
                                Text(
                                  'Data Optik',
                                  style: TextStyle(
                                    fontSize: isHor ? 16.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(
                                  height: isHor ? 15.h : 10.h,
                                ),
                                ItemSetting(
                                  marginHor: isHor ? 8.w : 3.w,
                                  label: "Nama Optik",
                                  contain: widget.customer?.namaUsaha,
                                  changeContain:
                                      widget.customer?.namaUsahaUpdate ?? '',
                                  iconData: Icons.business_center,
                                  colorIcon: Colors.orange.shade400,
                                  backgroundIcon: Colors.orange.shade100,
                                  isOpen: false,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                ItemSetting(
                                  marginHor: isHor ? 8.w : 3.w,
                                  label: "Nama Penanggung Jawab",
                                  contain: widget.customer!.namaPj!.trim(),
                                  changeContain: widget.customer!.namaPjUpdate!.trim(),
                                  iconData: Icons.person_pin_outlined,
                                  colorIcon: Colors.orange.shade400,
                                  backgroundIcon: Colors.orange.shade100,
                                  isOpen: false,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                ItemSetting(
                                  marginHor: isHor ? 8.w : 3.w,
                                  label: "Email Optik",
                                  contain: widget.customer?.emailUsaha != ''
                                      ? widget.customer?.emailUsaha
                                      : "-",
                                  changeContain:
                                      widget.customer?.emailUsahaUpdate,
                                  iconData: Icons.mail_outline,
                                  colorIcon: Colors.orange.shade400,
                                  backgroundIcon: Colors.orange.shade100,
                                  isOpen: false,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                ItemSetting(
                                  marginHor: isHor ? 8.w : 3.w,
                                  label: "No. Telp Optik / No. Fax Optik",
                                  contain:
                                      "${widget.customer?.telpUsaha} / ${widget.customer!.faxUsaha!}",
                                  changeContain: widget.customer!
                                              .telpUsahaUpdate!.isNotEmpty &&
                                          widget.customer!.faxUpdate!.isNotEmpty
                                      ? "${widget.customer?.telpUsahaUpdate} / ${widget.customer!.faxUpdate!}"
                                      : "",
                                  iconData: Icons.phone_outlined,
                                  colorIcon: Colors.orange.shade400,
                                  backgroundIcon: Colors.orange.shade100,
                                  isOpen: false,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                ItemSetting(
                                  marginHor: isHor ? 8.w : 3.w,
                                  label: "Alamat Optik",
                                  contain : "${widget.customer?.alamatUsaha ?? '-'}${widget.customer!.kelurahanUsaha!.length > 0 ? ', KELURAHAN ${widget.customer?.kelurahanUsaha}' : ''}${widget.customer!.kecamatanUsaha!.length > 0 ? ', KECAMATAN ${widget.customer?.kecamatanUsaha}' : ''}${widget.customer!.kotaUsaha!.length > 0 ? ', ${widget.customer?.kotaUsaha}' : ''}${widget.customer!.provinsiUsaha!.length > 0 ? ', ${widget.customer?.provinsiUsaha}' : ''}",
                                  changeContain : "${widget.customer!.alamatUsahaUpdate!.isNotEmpty ? widget.customer?.alamatUsahaUpdate : widget.customer?.alamatUsaha}${widget.customer!.kelurahanUsahaUpdate!.length > 0 ? ', KELURAHAN ${widget.customer?.kelurahanUsahaUpdate}' : ''}${widget.customer!.kecamatanUsahaUpdate!.length > 0 ? ', KECAMATAN ${widget.customer?.kecamatanUsahaUpdate}' : ''}${widget.customer!.kotaUsahaUpdate!.length > 0 ? ', ${widget.customer?.kotaUsahaUpdate}' : ''}${widget.customer!.provinsiUsahaUpdate!.length > 0 ? ', ${widget.customer?.provinsiUsahaUpdate}' : ''}",
                                  iconData: Icons.add_business_outlined,
                                  colorIcon: Colors.orange.shade400,
                                  backgroundIcon: Colors.orange.shade100,
                                  isOpen: false,
                                ),
                                SizedBox(
                                  height: isHor ? 15.h : 8.h,
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 5.h,
                              horizontal: 8.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: isHor ? 10.h : 5.h,
                                ),
                                Text(
                                  'Dokumen Pendukung',
                                  style: TextStyle(
                                    fontSize: isHor ? 16.sp : 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(
                                  height: isHor ? 15.h : 10.h,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              (isHor ? 1.2 : 0.93),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        fileCust?.ktp != ''
                                            ? InkWell(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    8.r,
                                                  ),
                                                  child: Image.memory(
                                                    base64Decode(fileCust!.ktp),
                                                    width: isHor ? 95.w : 60.w,
                                                    height:
                                                        isHor ? 110.h : 60.h,
                                                    fit: isHor
                                                        ? BoxFit.cover
                                                        : BoxFit.cover,
                                                    filterQuality:
                                                        FilterQuality.medium,
                                                  ),
                                                ),
                                                onTap: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return DialogImage(
                                                        'Foto KTP',
                                                        fileCust!.ktp,
                                                      );
                                                    },
                                                  );
                                                },
                                              )
                                            : InkWell(
                                                child: Image.asset(
                                                  'assets/images/picture.png',
                                                  width: isHor ? 95.w : 60.w,
                                                  height: isHor ? 110.h : 60.h,
                                                ),
                                                onTap: () => showStyledToast(
                                                  child: Text(
                                                      'Foto ktp tidak ditemukan'),
                                                  context: context,
                                                  backgroundColor: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.r),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              ),
                                        fileCust?.kartuNama != ''
                                            ? InkWell(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    8.r,
                                                  ),
                                                  child: Image.memory(
                                                    base64Decode(
                                                        fileCust!.kartuNama),
                                                    width: isHor ? 95.w : 60.w,
                                                    height:
                                                        isHor ? 110.h : 60.h,
                                                    fit: isHor
                                                        ? BoxFit.cover
                                                        : BoxFit.cover,
                                                    filterQuality:
                                                        FilterQuality.medium,
                                                  ),
                                                ),
                                                onTap: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return DialogImage(
                                                        'Foto Kartu Nama',
                                                        fileCust!.kartuNama,
                                                      );
                                                    },
                                                  );
                                                },
                                              )
                                            : InkWell(
                                                child: Image.asset(
                                                  'assets/images/picture.png',
                                                  width: isHor ? 95.w : 60.w,
                                                  height: isHor ? 110.h : 60.h,
                                                ),
                                                onTap: () => showStyledToast(
                                                  child: Text(
                                                      'Foto kartu nama tidak ditemukan'),
                                                  context: context,
                                                  backgroundColor: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.r),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              ),
                                        fileCust?.tampakDepan != ''
                                            ? InkWell(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    8.r,
                                                  ),
                                                  child: Image.memory(
                                                    base64Decode(
                                                        fileCust!.tampakDepan),
                                                    width: isHor ? 95.w : 60.w,
                                                    height:
                                                        isHor ? 110.h : 60.h,
                                                    fit: isHor
                                                        ? BoxFit.cover
                                                        : BoxFit.cover,
                                                    filterQuality:
                                                        FilterQuality.medium,
                                                  ),
                                                ),
                                                onTap: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return DialogImage(
                                                        'Foto Tampak Depan',
                                                        fileCust!.tampakDepan,
                                                      );
                                                    },
                                                  );
                                                },
                                              )
                                            : InkWell(
                                                child: Image.asset(
                                                  'assets/images/picture.png',
                                                  width: isHor ? 95.w : 60.w,
                                                  height: isHor ? 110.h : 60.h,
                                                ),
                                                onTap: () => showStyledToast(
                                                  child: Text(
                                                      'Foto tampak depan tidak ditemukan'),
                                                  context: context,
                                                  backgroundColor: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.r),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              ),
                                        fileCust?.npwp != ''
                                            ? InkWell(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    8.r,
                                                  ),
                                                  child: Image.memory(
                                                    base64Decode(
                                                        fileCust!.npwp),
                                                    width: isHor ? 95.w : 60.w,
                                                    height:
                                                        isHor ? 110.h : 60.h,
                                                    fit: isHor
                                                        ? BoxFit.cover
                                                        : BoxFit.cover,
                                                    filterQuality:
                                                        FilterQuality.medium,
                                                  ),
                                                ),
                                                onTap: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return DialogImage(
                                                        'Foto SIUP / NPWP',
                                                        fileCust!.npwp,
                                                      );
                                                    },
                                                  );
                                                },
                                              )
                                            : InkWell(
                                                child: Image.asset(
                                                  'assets/images/picture.png',
                                                  width: isHor ? 95.w : 60.w,
                                                  height: isHor ? 110.h : 60.h,
                                                ),
                                                onTap: () => showStyledToast(
                                                  child: Text(
                                                      'Foto siup/npwp tidak ditemukan'),
                                                  context: context,
                                                  backgroundColor: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.r),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: isHor ? 10.h : 5.h,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Visibility(
                          visible: widget.isPending,
                          child: Column(
                            children: [
                              handleAction(isHorizontal: isHor),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          ),
                          replacement: SizedBox(
                            height: 10.h,
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget handleAction({bool isHorizontal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 30.r : 20.r,
            vertical: 5.r,
          ),
          alignment: Alignment.centerRight,
          child: EasyButton(
            idleStateWidget: Text(
              "Reject",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 24.sp : 14.sp,
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
            height: isHorizontal ? 60.h : 40.h,
            width: isHorizontal ? 80.w : 100.w,
            borderRadius: isHorizontal ? 60.r : 30.r,
            buttonColor: Colors.red.shade700,
            elevation: 2.0,
            contentGap: 6.0,
            onPressed: onPressedReject,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 30.r : 20.r,
            vertical: 5.r,
          ),
          alignment: Alignment.centerRight,
          child: EasyButton(
            idleStateWidget: Text(
              "Approve",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 24.sp : 14.sp,
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
            height: isHorizontal ? 60.h : 40.h,
            width: isHorizontal ? 80.w : 100.w,
            borderRadius: isHorizontal ? 60.r : 30.r,
            buttonColor: Colors.blue.shade600,
            elevation: 2.0,
            contentGap: 6.0,
            onPressed: onPressedApprove,
          ),
        ),
      ],
    );
  }

  checkEntry({bool isHorizontal = false}) {
    textReason.text.isEmpty ? _isReason = true : _isReason = false;

    if (!_isReason) {
      widget.divisi == "AR"
          ? reject(true, widget.customer?.id ?? '',
              approverAm: widget.username ?? '', reasonAm: textReason.text)
          : reject(false, widget.customer?.id ?? '',
              approverSm: widget.username ?? '', reasonSm: textReason.text);

      Navigator.of(context, rootNavigator: true).pop();
    } else {
      handleStatus(
        context,
        'Harap lengkapi data terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    }
  }

  handleRejection(BuildContext context, {bool isHorizontal = false}) {
    AlertDialog alert = AlertDialog(
      scrollable: true,
      title: Center(
        child: Text(
          "Mengapa update customer tidak disetujui ?",
          style: TextStyle(
            fontSize: isHorizontal ? 20.sp : 14.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
                errorText: !_isReason ? 'Data wajib diisi' : null,
              ),
              keyboardType: TextInputType.multiline,
              minLines: isHorizontal ? 3 : 4,
              maxLines: isHorizontal ? 4 : 5,
              maxLength: 100,
              controller: textReason,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Ok',
            style: TextStyle(
              fontSize: isHorizontal ? 22.sp : 14.sp,
            ),
          ),
          onPressed: () {
            checkEntry(
              isHorizontal: isHorizontal,
            );
          },
        ),
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: isHorizontal ? 22.sp : 14.sp,
            ),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alert,
      barrierDismissible: false,
    );
  }
}
