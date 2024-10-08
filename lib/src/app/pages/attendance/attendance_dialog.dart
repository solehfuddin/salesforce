import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:screenshot/screenshot.dart';

// ignore: must_be_immutable
class AttendanceDialog extends StatefulWidget {
  File? imageFile;
  String? address;
  String? id = '';
  String? lattitude = '';
  String? longitude = '';
  bool? isCekin = true;
  AttendanceDialog(
    this.imageFile,
    this.address, {
    this.id,
    this.lattitude,
    this.longitude,
    this.isCekin,
    Key? key,
  }) : super(key: key);

  @override
  State<AttendanceDialog> createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends State<AttendanceDialog> {
  ScreenshotController screenshotController = ScreenshotController();
  Uint8List? screenshoot;
  String base64Imgprofile = '';

  cekIn() async {
    const timeout = 60;
    var url = '$API_URL/absensi';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id_user': widget.id,
          'latitude': widget.lattitude,
          'longtitude': widget.longitude,
          'alamat': widget.address,
          'foto': base64Imgprofile,
        },
      ).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (sts) {
          handleStatus(
            context,
            "Terima kasih sudah hadir tepat waktu",
            true,
            isLogout: false,
          );
        } else {
          handleStatus(
            context,
            msg,
            false,
            isLogout: false,
          );
        }

        setState(() {});
      } on FormatException catch (e) {
        print('Format Error : $e');
        if (mounted) {
          handleStatus(
            context,
            e.toString(),
            false,
            isLogout: false,
          );
        }
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        // handleTimeout(context);
        handleTimeoutAbsen(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('Error : $e');
    }
  }

  cekOut() async {
    const timeout = 60;
    var url = '$API_URL/absensi/checkout';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id_user': widget.id,
          'latitude_pulang': widget.lattitude,
          'longtitude_pulang': widget.longitude,
          'alamat_pulang': widget.address,
          'foto_pulang': base64Imgprofile,
        },
      ).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (sts) {
          handleStatus(
            context,
            "Terima kasih sudah absen pulang",
            true,
            isLogout: false,
          );
        } else {
          handleStatus(
            context,
            msg,
            false,
            isLogout: false,
          );
        }

        setState(() {});
      } on FormatException catch (e) {
        print('Format Error : $e');
        if (mounted) {
          handleStatus(
            context,
            e.toString(),
            false,
            isLogout: false,
          );
        }
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        // handleTimeout(context);
        handleTimeoutAbsen(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('Error : $e');
    }
  }

  onButtonPressed() async {
    await Future.delayed(const Duration(milliseconds: 1500), () async {
      screenshoot = await screenshotController.capture(pixelRatio: 1.0).then((value) {
        setState(() {
          waitingLoad();

          compressImageUint8List(value!).then((output) {
            base64Imgprofile = base64Encode(output as List<int>);

            print("Eksekusi db");
            print(base64Imgprofile);

            if (widget.isCekin!) {
              cekIn();
            } else {
              cekOut();
            }
          });
        });
        return null;
      });

      return () {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return childWidget();
  }

  Widget childWidget() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Container(
      padding: EdgeInsets.all(
        15.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              'Konfirmasi Kehadiran',
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Screenshot(
            controller: screenshotController,
            child: Container(
              height: 450,
              child: Stack(children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    width: MediaQuery.of(context).size.width - 10,
                    height: MediaQuery.of(context).size.height - 10,
                    child: Image.file(
                      widget.imageFile!,
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 70,
                  margin: EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.address!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              EasyButton(
                idleStateWidget: Text(
                  "Selesaikan",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
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
                height: 40.h,
                width: 120.w,
                borderRadius: 30.r,
                buttonColor: Colors.blue.shade700,
                elevation: 2.0,
                contentGap: 6.0,
                onPressed: onButtonPressed,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  backgroundColor: Colors.red[800],
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Batalkan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Segoe ui',
                  ),
                ),
                onPressed: () {
                  // Navigator.pop(context);
                  Get.back();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
