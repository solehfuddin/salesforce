import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AttendanceProminent extends StatefulWidget {
  const AttendanceProminent({Key? key}) : super(key: key);

  @override
  State<AttendanceProminent> createState() => _AttendanceProminentState();
}

class _AttendanceProminentState extends State<AttendanceProminent> {
  Future<bool> _onBackPressed() async {
    return false;
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
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pelacakan lokasi',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Untuk mengaktifkan layanan absensi aplikasi ini perlu mengizinkan akses lokasi pengguna',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'My leinz mengumpulkan data lokasi untuk memudahkan admin dalam memantau lokasi pengguna yang bertugas diluar kantor',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 15,
            ),
            Image.asset(
              'assets/images/map.png',
              width: 205,
              height: 90,
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
                'Selanjutnya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Segoe ui',
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
