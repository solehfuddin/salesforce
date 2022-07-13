import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';

class SyaratKetentuan extends StatefulWidget {
  @override
  State<SyaratKetentuan> createState() => _SyaratKetentuanState();
}

class _SyaratKetentuanState extends State<SyaratKetentuan> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childSyaratKetentuan(isHorizontal: true);
      }

      return childSyaratKetentuan(isHorizontal: false);
    });
  }

  Widget childSyaratKetentuan({bool isHorizontal}) {
    return Container(
      height: isHorizontal
          ? MediaQuery.of(context).size.height * 0.52
          : MediaQuery.of(context).size.height * 0.41,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.r,
          vertical: 10.r,
        ),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10.r,
                ),
                child: Text(
                  'Syarat Dan Ketentuan Kontrak',
                  style: TextStyle(
                    fontSize: isHorizontal ? 28.sp : 18.sp,
                    fontFamily: 'Segoe Ui',
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20.w,
                  child: Text(
                    '1',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Apabila ada tagihan yang jatuh tempo untuk customer yang sistem pembayarannya kredit, maka pembayaran akan otomatis berubah menjadi cod atau transfer.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20.w,
                  child: Text(
                    '2',
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Setiap pesanan akan dikenakan ongkos kirim sesuai tarif yang berlaku dan akan tercantum di invoice.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                primary: Colors.blue[800],
                padding: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 40.r : 20.r,
                  vertical: isHorizontal ? 20.r : 10.r,
                ),
              ),
              child: Text(
                'Mengerti',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 24.sp : 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Segoe ui',
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
