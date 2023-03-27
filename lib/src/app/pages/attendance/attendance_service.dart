import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class AttendanceService extends StatefulWidget {
  const AttendanceService({Key? key}) : super(key: key);

  @override
  State<AttendanceService> createState() => _AttendanceServiceState();
}

class _AttendanceServiceState extends State<AttendanceService> {
  bool isEnabled = false;

  Future<bool> _onBackPressed() async {
    return isEnabled;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Container(
        height: 350,
        padding: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/map.png',
              width: 235,
              height: 135,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Mohon aktifkan layanan lokasi',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Lokasimu akan terdeteksi secara otomatis untuk bisa mengakses layanan absensi',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                primary: Colors.blue[800],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'AKTIFKAN LOKASI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Segoe ui',
                ),
              ),
              onPressed: () async {
                if (Platform.isAndroid) {
                  Location _myLocation = Location(); 
                  isEnabled = await _myLocation.requestService();

                  setState(() {
                    if (isEnabled)
                    {
                      Navigator.pop(context);
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
