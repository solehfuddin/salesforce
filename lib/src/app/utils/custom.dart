import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
// import 'package:in_app_update/in_app_update.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/econtract/detail_contract.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/login/login_view.dart';
import 'package:sample/src/app/pages/renewcontract/history_contract.dart';
import 'package:sample/src/app/pages/staff/staff_view.dart';
// import 'package:sample/src/app/pages/renewcontract/history_contract.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/widgets/detail_rejected.dart';
// import 'package:sample/src/app/widgets/detail_rejected.dart';
import 'package:sample/src/app/widgets/detail_waiting.dart';
import 'package:sample/src/app/widgets/detail_waiting_admin.dart';
import 'package:sample/src/app/widgets/detail_waiting_contract.dart';
import 'package:sample/src/app/widgets/dialogback.dart';
// import 'package:sample/src/app/widgets/detail_waiting_admin.dart';
// import 'package:sample/src/app/widgets/detail_waitingcontract.dart';
import 'package:sample/src/app/widgets/dialoglogin.dart';
import 'package:sample/src/app/widgets/dialoglogout.dart';
import 'package:sample/src/app/widgets/dialogsigned.dart';
import 'package:sample/src/app/widgets/dialogstatus.dart';
import 'package:sample/src/app/widgets/dialogverifieditheaderinkaro.dart';
import 'package:sample/src/app/widgets/dialogverifupdateinkaroitem.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:sample/src/domain/entities/customer_inkaro.dart';
import 'package:sample/src/domain/entities/customer_noimage.dart';
import 'package:sample/src/domain/entities/inkaro_manual.dart';
import 'package:sample/src/domain/entities/inkaro_program.dart';
import 'package:sample/src/domain/entities/inkaro_reguler.dart';
import 'package:sample/src/domain/entities/list_inkaro_detail.dart';
import 'package:sample/src/domain/entities/list_inkaro_header.dart';
import 'package:sample/src/domain/entities/oldcustomer.dart';
// import 'package:sample/src/domain/entities/oldcustomer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';

late Contract itemContract;
String capitalize(String s) =>
    s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;

waitingLoad() async {
  await Future.delayed(Duration(seconds: 2));
}

dialogLogin(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return DialogLogin();
    },
  );
}

login(String user, String pass, BuildContext context,
    {bool isHorizontal = false, var token}) async {
  dialogLogin(
    context,
  );

  int timeout = 15;
  var url = '$API_URL/auth/login';

  if (url.contains("dev")) {
    print('DEV MODE');
  } else {
    print('PROD MODE');
  }

  try {
    var response = await http.post(Uri.parse(url), body: {
      'username': user,
      'password': pass,
      'gentoken': token
    }).timeout(Duration(seconds: timeout));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    try {
      var data = json.decode(response.body);
      final bool sts = data['status'];
      final int code = response.statusCode;
      String msg = data['message'];

      if (code == 200) {
        if (sts) {
          final String id = data['data']['id'];
          final String name = data['data']['name'];
          final String username = data['data']['username'];
          final String accstatus = data['data']['status'];
          final String role = data['data']['role'];
          final String divisi = data['data']['divisi'];
          final String ttd = data['data']['ttd'] ?? '';
          final String token = data['data']['gentoken'] ?? '';

          savePref(
            context,
            id,
            name,
            username,
            accstatus,
            role,
            divisi,
            ttd,
            token,
          );
        } else {
          showStyledToast(
            child: Text(msg),
            context: context,
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(15.r),
            duration: Duration(seconds: 2),
          );
          Navigator.of(context).pop();
        }
      } else {
        showStyledToast(
          child: Text(msg),
          context: context,
          backgroundColor: Colors.red,
          borderRadius: BorderRadius.circular(15.r),
          duration: Duration(seconds: 2),
        );
        Navigator.of(context).pop();
      }
    } on FormatException catch (e) {
      print('Format Error : $e');
      handleStatus(
        context,
        e.toString(),
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
      Navigator.of(context).pop();
    }
  } on TimeoutException catch (e) {
    print('Timeout Error : $e');
    handleTimeout(context);
    Navigator.of(context).pop();
  } on SocketException catch (e) {
    print('Socket Error : $e');
    handleSocket(context);
    Navigator.of(context).pop();
  } on Error catch (e) {
    print('General Error : $e');
    handleStatus(
      context,
      e.toString(),
      false,
      isHorizontal: isHorizontal,
      isLogout: false,
    );
    Navigator.of(context).pop();
  }
}

String getNotifImg({int template = 10}) {
  switch (template) {
    case 0:
    case 1:
      return 'assets/images/e_contract_new.png';
    case 2:
    case 3:
    case 4:
    case 5:
      return 'assets/images/renew_contract.png';
    case 6:
    case 7:
    case 11:
    case 15:
      return 'assets/images/success.png';
    case 8:
    case 9:
    case 16:
      return 'assets/images/failure.png';
    case 10:
      return 'assets/images/agenda_menu_new.png';
    case 12:
    case 13:
    case 14:
      return 'assets/images/contract-reward.png';
    default:
      return 'assets/images/myleinz.png';
  }
}

pushNotif(
  int template,
  int type, {
  String? idUser,
  dynamic rcptToken,
  String? opticName,
  String? salesName,
  String? admName,
}) async {
  const timeout = 15;
  var url = '';
  var tmplate, notifType, title, body, to;

  switch (type) {
    case 3:
      url = '$API_URL/notification/sendByToken';
      break;
    default:
      url = '$API_URL/notification/sendBroadcast';
      break;
  }

  switch (template) {
    case 0:
      title = 'Pengajuan Kontrak Sukses';
      body =
          'Pengajuan kontrak $opticName berhasil di-input kedalam sistem. Mohon menunggu untuk persetujuan sales manager dan ar manager';
      tmplate = '0';
      break;
    case 1:
      title = 'Ada Kontrak Baru';
      body =
          '$salesName mengajukan kontrak $opticName. Mohon segera proses pengajuan kontrak tersebut';
      tmplate = '1';
      break;
    case 2:
      title = 'Revisi Kontrak Sukses';
      body =
          'Kontrak $opticName berhasil direvisi. Mohon menunggu untuk persetujuan kontrak tersebut';
      tmplate = '2';
      break;
    case 3:
      title = 'Ada Revisi Kontrak';
      body =
          '$salesName telah merevisi kontrak $opticName. Mohon segera proses pengajuan kontrak tersebut';
      tmplate = '3';
      break;
    case 4:
      title = 'Pengajuan Perubahan Kontrak';
      body =
          'Perubahan kontrak $opticName berhasil di-input kedalam sistem. Mohon menunggu untuk persetujuan sales manager dan ar manager';
      tmplate = '4';
      break;
    case 5:
      title = 'Ada Perubahan Kontrak';
      body =
          '$salesName telah merubah kontrak $opticName. Mohon segera proses pengajuan kontrak tersebut';
      tmplate = '5';
      break;
    case 6:
      title = 'Kontrak Disetujui';
      body =
          'Pengajuan kontrak $opticName sudah disetujui dan berhasil diinformasikan ke akun sales $salesName.';
      tmplate = '6';
      break;
    case 7:
      title = 'Kontrak Telah Diapprove';
      body =
          'Hai, pengajuan kontrak $opticName telah disetujui oleh $admName. Selalu periksa status pengajuan kontrak anda';
      tmplate = '7';
      break;
    case 8:
      title = 'Kontrak Ditangguhkan';
      body =
          'Pengajuan kontrak $opticName berhasil ditangguhkan dan akan segera direvisi oleh sales $salesName.';
      tmplate = '8';
      break;
    case 9:
      title = 'Kontrak Telah Ditolak';
      body =
          'Hai, pengajuan kontrak $opticName telah ditolak oleh $admName. Segera revisi pengajuan kontrak tersebut agar segera diproses admin';
      tmplate = '9';
      break;
    case 10:
      title = 'Ada Aktivitas Baru';
      body =
          '$salesName mengajukan aktivitas $opticName. Mohon segera periksa aktivitas';
      tmplate = '10';
      break;
    case 11:
      title = 'Konfirmasi Aktivitas';
      body =
          'Hai, pengajuan aktivitas $opticName telah dikonfirmasi oleh $admName.';
      tmplate = '11';
      break;
    case 12:
      title = 'Pengajuan Inkaro Sukses';
      body =
          'Pengajuan inkaro $opticName berhasil di-input kedalam sistem. Mohon menunggu untuk persetujuan dari sales manager';
      tmplate = '12';
      break;
    case 13:
      title = 'Ada Inkaro Baru';
      body =
          '$salesName mengajukan inkaro $opticName. Mohon segera proses pengajuan inkaro tersebut';
      tmplate = '13';
      break;
    case 14:
      title = 'Ada Perubahan Inkaro';
      body =
          '$salesName telah meng-update inkaro $opticName. Mohon segera cek pengajuan inkaro tersebut';
      tmplate = '14';
      break;
    case 15:
      title = 'Inkaro Disetujui';
      body =
          'Hai, pengajuan inkaro $opticName telah disetujui oleh $admName. Selalu periksa status pengajuan inkaro anda';
      tmplate = '15';
      break;
    case 16:
      title = 'Inkaro Telah Ditolak';
      body =
          'Hai, pengajuan inkaro $opticName telah ditolak oleh $admName. Segera update pengajuan inkaro tersebut agar segera disetujui sales manager';
      tmplate = '16';
      break;
    case 17:
      title = 'Ada Pengajuan POS';
      body = '$salesName mengajukan POS Material untuk $opticName. Mohon segera proses POS tersebut';
      tmplate = '17';
      break;
    case 18:
      title = 'Pengajuan POS Disetujui';
      body = 'Hai, pengajuan POS $opticName telah disetujui oleh $admName. Selalu periksa status pengajuan POS anda';
      tmplate = '18';
      break;
    case 19:
      title = 'Pengajuan POS Ditolak';
      body =
          'Maaf, pengajuan POS $opticName ditolak oleh $admName. Segera cek data pengajuan POS anda';
      tmplate = '19';
      break;
  }

  switch (type) {
    case 1:
      //ALL ADMIN SALES
      to = "/topics/alladmin";
      notifType = '1';
      break;
    case 2:
      //ALL SALES
      to = "/topics/allsales";
      notifType = '2';
      break;
    case 3:
      to = rcptToken;
      notifType = '3';
      break;
    case 4:
      //ALL ADMIN AR
      to = "/topics/allar";
      notifType = '4';
      break;
    case 5:
      //ALL ADMIN MARKETING
      to = "/topics/allmarketing";
      notifType = '5';
      break;
    case 6:
      //ALL GM
      to = "/topics/allgm";
      notifType = '6';
      break;
    default:
      to = "/topics/all";
      notifType = '0';
      break;
  }

  try {
    var response = await http.post(Uri.parse(url), body: {
      'to': to,
      'body': body,
      'title': title,
      'priority': 'high',
      'type_template': tmplate,
      'type_notifikasi': notifType,
      'id_user': idUser,
    }).timeout(Duration(seconds: timeout));

    print('To : $to');
    print('Body : $body');
    print('Title : $title');
    print('Type Notif : $notifType');
    print('Id User : $idUser');

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    try {
      var res = json.decode(response.body);
      final bool sts = res['status'];

      if (!sts) {
        print('Gagal kirim notifikasi');
      } else {
        print('Sukses');
      }
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

paginatePref(int page, int startAt) async
{
  SharedPreferences pref = await SharedPreferences.getInstance();

  await pref.setInt('paginatePage', page);
  await pref.setInt('paginateStartAt', startAt);
}

paginateClear() async 
{
  SharedPreferences pref = await SharedPreferences.getInstance();

  await pref.setInt('paginatePage', 1);
  await pref.setInt('paginateStartAt', 0);
}

savePref(
  BuildContext context,
  String id,
  String name,
  String username,
  String status,
  String role,
  String divisi,
  String ttdUser,
  String tokenUser,
) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  await pref.setString("id", id);
  await pref.setString("name", name);
  await pref.setString("username", username);
  await pref.setString("status", status);
  await pref.setString("role", role.toUpperCase());
  await pref.setString("divisi", divisi);
  await pref.setString("ttduser", ttdUser);
  await pref.setString("tokenuser", tokenUser);
  await pref.setBool("islogin", true);

  Future.delayed(Duration(seconds: 3), () {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }

    if (role == "ADMIN") {
      print('Login Ke Admin');
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminScreen()));

      print(pref.getString("name"));
      print(pref.getString("role"));
      print(pref.getString("ttduser"));
      print(pref.getString("tokenuser"));
    } else if (role == "STAFF") {
      print('Login Ke Staff');
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => StaffScreen()));

      print(pref.getString("name"));
      print(pref.getString("role"));
      print(pref.getString("ttduser"));
      print(pref.getString("tokenuser"));
    } else {
      print('Login Ke Sales');
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));

      print(pref.getString("name"));
      print(pref.getString("role"));
      print(pref.getString("ttduser"));
      print(pref.getString("tokenuser"));
    }
  });
}

updateTTdPref(String newTtd) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  final sts = await pref.remove('ttduser');
  if (sts) {
    await pref.setString("ttduser", newTtd);
  } else {
    print('Gagal update session ttduser');
  }
}

handleComing(BuildContext context, {bool isHorizontal = false}) {
  AlertDialog alert = AlertDialog(
    title: Center(
      child: Text(
        "Coming Soon",
        style: TextStyle(
          fontSize: isHorizontal ? 30.sp : 20.sp,
          fontFamily: 'Segoe ui',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    content: Container(
      child: Image.asset(
        'assets/images/coming_soon.png',
        width: isHorizontal ? 110.sp : 80.r,
        height: isHorizontal ? 110.sp : 80.r,
      ),
    ),
    actions: [
      Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            primary: Colors.indigo[600],
            padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 30.r : 20.r,
                vertical: isHorizontal ? 20.r : 10.r),
          ),
          child: Text(
            'Ok',
            style: TextStyle(
              color: Colors.white,
              fontSize: isHorizontal ? 24.sp : 14.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Segoe ui',
            ),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(context);
          },
        ),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

handleSigned(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: DialogSigned(),
    ),
  );
}

handleVerifEditHeaderInkaro(BuildContext context, inkaroHeaderList, position) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: DialogVerifEditHeaderInkaro(inkaroHeaderList, position),
    ),
  );
}

handleVerifUpdateInkaroItem(
    BuildContext context,
    List<ListCustomerInkaro> customerList,
    positionCustomer,
    List<ListInkaroHeader> inkaroHeaderList,
    positionInkaroHeader,
    List<InkaroReguler> inkaroRegSelected,
    List<InkaroProgram> inkaroProgSelected,
    List<InkaroManual> inkaroManualSelected,
    void Function(List<ListInkaroDetail>) inkaroDetail,
    List<ListInkaroDetail> inkaroDetailUpdate,
    int positionDetail,
    String typeUpdate) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: DialogVerifUpdateInkaroItem(
          inkaroHeaderList,
          positionInkaroHeader,
          customerList,
          positionCustomer,
          inkaroRegSelected,
          inkaroProgSelected,
          inkaroManualSelected,
          inkaroDetail,
          inkaroDetailUpdate,
          positionDetail,
          typeUpdate),
    ),
  );
}

handleStatus(
  BuildContext context,
  String msg,
  bool status, {
  bool isHorizontal = false,
  bool isLogout = false,
  bool isNewCust = false,
}) {
  showDialog(
    context: context,
    builder: (context) => DialogStatus(
      msg: msg,
      status: status,
      isLogout: isLogout,
      isNewCust:  isNewCust,
    ),
  );
}

handleBack(
  BuildContext context,
  String msg,
  String accessFrom,
  bool status, {
  bool isHorizontal = false,
  bool isLogout = false,
  bool isAdmin = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: DialogBack(
        msg: msg,
        status: status,
        isLogout: isLogout,
        isAdmin: isAdmin,
        accessFrom: accessFrom,
      ),
    ),
  );
}

// DateTimeRange _selectedDateRange;
// Future<DateTimeRange> showDate(BuildContext context) async {
//   final DateTimeRange result = await showDateRangePicker(
//     context: context,
//     firstDate: DateTime(2022, 1, 1),
//     lastDate: DateTime(2030, 12, 31),
//     currentDate: DateTime.now(),
//     saveText: 'Done',
//   );

//   if (result != null) {
//     print("Start Date : ${result.start.toString()}");
//     print("End Date : ${result.end.toString()}");

//     print("Convert St Date : ${convertDateOra(result.start.toString())}");
//     // setState(() {
//     _selectedDateRange = result;
//     // });

//     return _selectedDateRange;
//   }
// }

// void showDateRange(BuildContext context) async {
//   final DateTimeRange result = await showDateRangePicker(
//     context: context,
//     firstDate: DateTime(2022, 1, 1),
//     lastDate: DateTime(2030, 12, 31),
//     currentDate: DateTime.now(),
//     saveText: 'Done',
//     // builder: (BuildContext context, Widget child) {
//     //   return Theme(
//     //     data: ThemeData.light().copyWith(
//     //       colorScheme: ColorScheme.dark(
//     //         // primary: Color(0xff64c856),
//     //         // onPrimary: Colors.black,
//     //         // surface: Color(0xff64c856),
//     //         // onSurface: Colors.green,
//     //       ),
//     //       dialogBackgroundColor: Colors.green,
//     //     ),
//     //     child: child,
//     //   );
//     // }
//   );

//   if (result != null) {
//     // Rebuild the UI
//     print(result.start.toString());
//     // setState(() {
//     _selectedDateRange = result;
//     // });
//   }
// }

handleCustomStatus(BuildContext context, String msg, bool status,
    {bool isHorizontal = false}) {
  AlertDialog alert = AlertDialog(
    content: Container(
      padding: EdgeInsets.only(
        top: 20.r,
      ),
      height: isHorizontal ? 325.h : 205.h,
      child: Column(
        children: [
          Center(
            child: Image.asset(
              status
                  ? 'assets/images/success.png'
                  : 'assets/images/failure.png',
              width: isHorizontal ? 105.r : 60.r,
              height: isHorizontal ? 105.r : 60.r,
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          Container(
            child: Center(
              child: Text(
                msg,
                style: TextStyle(
                  fontSize: isHorizontal ? 22.sp : 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                primary: Colors.indigo[600],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Ok',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 22.sp : 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Segoe ui',
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
                if (status) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => AdminScreen()));
                }
              },
            ),
          ),
        ],
      ),
    ),
    // actions: [

    // ],
  );

  showDialog(context: context, builder: (context) => alert);
}

handleStatusChangeContract(
  BuildContext context,
  String msg,
  bool status, {
  OldCustomer? item,
  dynamic keyword,
  bool isHorizontal = false,
  bool isNewCust = false,
  CustomerNoImage? customer,
}) {
  AlertDialog alert = AlertDialog(
    content: Container(
      padding: EdgeInsets.only(
        top: 20.r,
      ),
      height: isHorizontal ? 325.h : 205.h,
      child: Column(
        children: [
          Center(
            child: Image.asset(
              status
                  ? 'assets/images/success.png'
                  : 'assets/images/failure.png',
              width: isHorizontal ? 110.r : 70.r,
              height: isHorizontal ? 110.r : 70.r,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Center(
            child: Text(
              msg,
              style: TextStyle(
                fontSize: isHorizontal ? 22.sp : 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                primary: Colors.indigo[600],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Ok',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 22.sp : 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Segoe ui',
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
                if (status) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HistoryContract(
                        item: item,
                        cust: customer,
                        keyword: keyword,
                        isAdmin: false,
                        isNewCust: isNewCust,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    ),
  );

  showDialog(context: context, builder: (context) => alert);
}

handleConnection(BuildContext context) {
  AlertDialog alert = AlertDialog(
    title: Text("Informasi"),
    content: Container(
      child: Text("Sambungan terputus, ulangi proses!"),
    ),
    actions: [
      TextButton(
        child: Text('Ok'),
        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

handleConnectionAdmin(BuildContext context) {
  AlertDialog alert = AlertDialog(
    title: Text("Informasi"),
    content: Container(
      child: Text("Sambungan terputus, ulangi proses!"),
    ),
    actions: [
      TextButton(
        child: Text('Ok'),
        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AdminScreen()),
            (route) => false),
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

// Ini hapus aja
// Future<String> getTtdValid(String idUser, BuildContext context,
//     {String role}) async {
//   const timeout = 15;
//   var url = '$API_URL/users?id=$idUser';

//   try {
//     var response = await http.get(url).timeout(Duration(seconds: timeout));

//     try {
//       var data = json.decode(response.body);
//       print(data);
//       String ttd = data['data']['ttd'];

//       return ttd;
//     } on FormatException catch (e) {
//       print('Format Error : $e');
//     }
//   } on TimeoutException catch (e) {
//     print('Timeout Error : $e');
//     handleTimeout(context);
//   } on SocketException catch (e) {
//     print('Socket Error : $e');
//     // handleSocket(context);
//     role.contains('admin')
//         ? handleConnectionAdmin(context)
//         : handleConnection(context);
//   } on Error catch (e) {
//     print('General Error : $e');
//   }
// }

handleDigitalSigned(
    SignatureController signController, BuildContext context, String id,
    {bool isHorizontal = false}) async {
  const timeout = 15;
  if (signController.isNotEmpty) {
    var data = await signController.toPngBytes();
    String signedImg = base64Encode(data!);
    print(signedImg);
    print(id);

    var url = '$API_URL/users/update';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id': id,
          'ttd': signedImg,
        },
      ).timeout(Duration(seconds: timeout));
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

        updateTTdPref(signedImg);
      } on FormatException catch (e) {
        print('Format Error : $e');
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(
        context,
        e.toString(),
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    }
  } else {
    showStyledToast(
      child: Text('Mohon tanda tangani form'),
      context: context,
      backgroundColor: Colors.red,
      borderRadius: BorderRadius.circular(15.r),
      duration: Duration(seconds: 2),
    );
  }
}

formWaiting(
  BuildContext context,
  List<CustomerNoImage> customer,
  int position, {
  String reasonSM = '',
  String reasonAM = '',
  Contract? contract,
}) {
  return showModalBottomSheet(
    elevation: 2,
    enableDrag: true,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.r),
        topRight: Radius.circular(15.r),
      ),
    ),
    context: context,
    builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          child: DetailWaiting(
            customer: customer,
            position: position,
            reasonSM: reasonSM,
            reasonAM: reasonAM,
            contract: contract!,
          ),
        ),
      );
    },
  );
}

formWaitingAdmin(
  BuildContext context,
  List<CustomerNoImage> customer,
  int position, {
  String reasonSM = '',
  String reasonAM = '',
  Contract? contract,
}) {
  return showModalBottomSheet(
    elevation: 2,
    enableDrag: true,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.r),
        topRight: Radius.circular(15.r),
      ),
    ),
    context: context,
    builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          child: DetailWaitingAdmin(
            customer: customer,
            position: position,
            reasonSM: reasonSM,
            reasonAM: reasonAM,
            contract: contract,
          ),
        ),
      );
    },
  );
}

formWaitingContract(
  BuildContext context,
  List<Contract> item,
  int position,
  String reasonSM,
  String reasonAM, {
  bool isNewCust = false,
  CustomerNoImage? customer,
  String? ttdCustomer,
  dynamic idCustomer,
}) {
  return showModalBottomSheet(
    elevation: 2,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
    ),
    context: context,
    builder: (context) {
      return DetailWaitingContract(
        item,
        position,
        reasonSM,
        reasonAM,
        isNewCust: isNewCust,
        customer: customer,
        idCustomer: idCustomer,
        ttdCustomer: ttdCustomer,
      );
    },
  );
}

// donwloadContract(dynamic idCust, Function stopLoading()) async {
//   var url = 'https://timurrayalab.com/salesforce/download/contract_pdf/$idCust';
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     throw 'Could not launch $url';
//   }
// }

// approveCustomerContract(bool isAr, String idCust, String username) async {
//   var url = !isAr
//       ? '$API_URL/approval/approveContractSM'
//       : '$API_URL/approval/approveContractAM';

//   var response = await http.post(
//     url,
//     body: !isAr
//         ? {
//             'id_customer': idCust,
//             'approver_sm': username,
//           }
//         : {
//             'id_customer': idCust,
//             'approver_am': username,
//           },
//   );

//   print('Response status: ${response.statusCode}');
//   print('Response body: ${response.body}');
// }

formRejected(
  BuildContext context,
  List<Customer> customer,
  int position, {
  String div = '',
  ttd,
  idCust,
  username,
  String reasonSM = '',
  String reasonAM = '',
  Contract? contract,
}) {
  return showModalBottomSheet(
    elevation: 2,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.r),
        topRight: Radius.circular(15.r),
      ),
    ),
    context: context,
    builder: (context) {
      return DetailRejected(
        customer: customer,
        position: position,
        div: div,
        ttd: ttd,
        idCust: idCust,
        username: username,
        reasonSM: reasonSM,
        reasonAM: reasonAM,
        contract: contract,
      );
    },
  );
}

// convertDateOra(String tgl) {
//   DateFormat dateFormat = DateFormat("yyyy-MM-dd hh:mm:ss");
//   DateTime date = dateFormat.parse(tgl);

//   return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}";
// }

convertDateIndo(String tgl) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateTime date = dateFormat.parse(tgl);

  return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString()}";
}

convertDateSql(String tgl) {
  var split = tgl.split(" ");
  var month = convertMonth(split[1]);

  return "${split[2]}-$month-${split[0]}";
}

convertMonth(String input) {
  switch (input) {
    case 'Jan':
      return '01';
    case 'Feb':
      return '02';
    case 'Mar':
      return '03';
    case 'Apr':
      return '04';
    case 'May':
      return '05';
    case 'Jun':
      return '06';
    case 'Jul':
      return '07';
    case 'Aug':
      return '08';
    case 'Sep':
      return '09';
    case 'Oct':
      return '10';
    case 'Nov':
      return '11';
    default:
      return '12';
  }
}

convertDateWithMonth(String tgl) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateTime date = dateFormat.parse(tgl);

  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Des'
  ];

  return "${date.day.toString().padLeft(2, '0')} ${months.elementAt(date.month - 1)} ${date.year.toString()}";
}

convertDateWithMonthHour(
  String tgl, {
  bool isPukul = true,
}) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  DateTime date = dateFormat.parse(tgl);

  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Des'
  ];

  return "${date.day.toString().padLeft(2, '0')} ${months.elementAt(date.month - 1)} ${date.year.toString()} ${isPukul ? 'Pukul' : ''} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
}

convertDateWithMonthHourNoSecond(
  String tgl, {
  bool isPukul = true,
}) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
  DateTime date = dateFormat.parse(tgl);

  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Des'
  ];

  return "${date.day.toString().padLeft(2, '0')} ${months.elementAt(date.month - 1)} ${date.year.toString()} ${isPukul ? 'Pukul' : ''} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}

String convertToIdr(dynamic number, int decimalDigit) {
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: decimalDigit,
  );
  return currencyFormatter.format(number);
}

String convertThousand(dynamic number, int decimalDigit) {
  NumberFormat currencyFormatter = NumberFormat.currency(
    decimalDigits: decimalDigit,
    locale: 'id',
    symbol: '',
  );
  return currencyFormatter.format(number);
}

int counterTwoDays(DateTime from, DateTime to) {
  Duration diff = to.difference(from);
  return diff.inDays;
}

String getEndDays({String input = ''}) {
  if (input.isNotEmpty) {
    DateTime now = DateTime.now();
    DateTime compare = DateTime.parse(input);

    return '${counterTwoDays(now, compare)} Hari';
  } else {
    return 'Inputan kosong';
  }
}

// void showError(BuildContext context, dynamic exception) {
//   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//     content: Text(exception),
//     duration: Duration(seconds: 2),
//   ));
// }

Future<void> checkUpdate(BuildContext context) async {
  AppUpdateInfo _updateInfo;

  InAppUpdate.checkForUpdate().then((info) {
    _updateInfo = info;
    if (_updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      print('Info : $_updateInfo');
      print('Update please');

      InAppUpdate.performImmediateUpdate().catchError((e) {
        showStyledToast(
          child: Text(
            e.toString(),
          ),
          context: context,
          backgroundColor: Colors.red,
          borderRadius: BorderRadius.circular(15.r),
          duration: Duration(seconds: 2),
        );
        SystemNavigator.pop();
      });
    }
  }).catchError((e) {
    showStyledToast(
      child: Text(
        e.toString(),
      ),
      context: context,
      backgroundColor: Colors.red,
      borderRadius: BorderRadius.circular(15.r),
      duration: Duration(seconds: 2),
    );

    print(e.toString());
  });
}

getCustomerContractNew({
  BuildContext? context,
  dynamic idCust,
  String? divisi,
  String? ttdPertama,
  String? username,
  bool isSales = false,
  bool isContract = false,
  bool isHorizontal = false,
  bool isNewCust = false,
}) async {
  const timeout = 15;
  var url = '$API_URL/contract?id_customer=$idCust';

  try {
    var response =
        await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
    print('Response status: ${response.statusCode}');

    try {
      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        itemContract = Contract.fromJson(rest[0]);

        openDialogNew(
          context!,
          divisi!,
          ttdPertama!,
          username!,
          isSales,
          isContract,
          isNewCust: isNewCust,
        );
      } else {
        handleStatus(
          context!,
          'Kontrak belum disetujui',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      }
    } on FormatException catch (e) {
      print('Format Error : $e');
      handleStatus(
        context!,
        e.toString(),
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    }
  } on TimeoutException catch (e) {
    print('Timeout Error : $e');
    handleTimeout(context!);
  } on SocketException catch (e) {
    print('Socket Error : $e');
    handleSocket(context!);
  } on Error catch (e) {
    print('General Error : $e');
    handleStatus(
      context!,
      e.toString(),
      false,
      isHorizontal: isHorizontal,
      isLogout: false,
    );
  }
}

getMonitoringContractNew({
  BuildContext? context,
  dynamic idCust,
  String? divisi,
  String? ttdPertama,
  String? username,
  bool isSales = false,
  bool isContract = false,
  bool isHorizontal = false,
  bool isNewCust = false,
}) async {
  const timeout = 15;
  var url = '$API_URL/contract/getActiveContractById?id=$idCust';

  try {
    var response =
        await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
    print('Response status: ${response.statusCode}');

    try {
      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        var rest = data['data'];
        print(rest);
        itemContract = Contract.fromJson(rest[0]);

        openDialogNew(
          context!,
          divisi!,
          ttdPertama!,
          username!,
          isSales,
          isContract,
          isNewCust: isNewCust,
        );
      } else {
        handleStatus(
          context!,
          'Kontrak belum disetujui',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      }
    } on FormatException catch (e) {
      print('Format Error : $e');
      handleStatus(
        context!,
        e.toString(),
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    }
  } on TimeoutException catch (e) {
    print('Timeout Error : $e');
    handleTimeout(context!);
  } on SocketException catch (e) {
    print('Socket Error : $e');
    handleSocket(context!);
  } on Error catch (e) {
    print('General Error : $e');
    handleStatus(
      context!,
      e.toString(),
      false,
      isHorizontal: isHorizontal,
      isLogout: false,
    );
  }
}

openDialogNew(BuildContext context, String div, String ttdPertama,
    String username, bool isSales, bool isContract,
    {bool isNewCust = false}) async {
  await formContractNew(
    context,
    itemContract,
    div,
    ttdPertama,
    username,
    isSales,
    isContract,
    isNewCust: isNewCust,
  );
}

formContractNew(BuildContext context, Contract item, String div,
    String ttdPertama, String username, bool isSales, bool isContract,
    {bool isNewCust = false}) {
  return showModalBottomSheet(
      elevation: 2,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.r),
          topRight: Radius.circular(15.r),
        ),
      ),
      builder: (context) {
        return DetailContract(
          item,
          div,
          ttdPertama,
          username,
          isSales,
          isContract: isContract,
          isAdminRenewal: false,
          isNewCust: isNewCust,
        );
      });
}

signOut({bool isChangePassword = false, BuildContext? context}) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setBool("islogin", false);
  await preferences.setString("role", '');
  await Future.delayed(const Duration(seconds: 2), () {});
  if (isChangePassword) {
    Navigator.pop(context!);
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
  } else {
    SystemNavigator.pop();
  }
}

handleLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return DialogLogout();
    },
  );
}

void handleTimeout(BuildContext context) {
  handleStatus(
    context,
    'Internet tidak stabil atau lambat',
    false,
    isLogout: false,
  );
}

void handleTimeoutAbsen(BuildContext context) {
  handleStatus(
    context,
    'Server tidak merespon (401)',
    true,
    isLogout: false,
  );
}

void handleSocket(BuildContext context) {
  handleStatus(
    context,
    'Aktifkan paket data atau wifi',
    false,
    isLogout: false,
  );
}
