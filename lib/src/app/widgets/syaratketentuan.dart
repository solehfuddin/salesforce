import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  Widget childSyaratKetentuan({bool isHorizontal = false}) {
    return SingleChildScrollView(
      child: Container(
        height: isHorizontal
            ? MediaQuery.of(context).size.height * 0.6
            : MediaQuery.of(context).size.height * 0.45,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 15.r : 20.r,
            vertical: isHorizontal ? 5.r : 10.r,
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
                      fontSize: isHorizontal ? 18.sp : 16.sp,
                      fontFamily: 'Segoe Ui',
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: isHorizontal ? 5.h : 10.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.w,
                    child: Text(
                      '1',
                      style: TextStyle(
                        fontSize: isHorizontal ? 14.sp : 12.sp,
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
                        fontSize: isHorizontal ? 14.sp : 14.sp,
                        fontFamily: 'Segoe Ui',
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 5.h : 8.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.w,
                    child: Text(
                      '2',
                      style: TextStyle(
                        fontSize: isHorizontal ? 14.sp : 12.sp,
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
                        fontSize: isHorizontal ? 14.sp : 14.sp,
                        fontFamily: 'Segoe Ui',
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: isHorizontal ? 5.h : 10.h,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(), 
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(
                    horizontal: isHorizontal ? 25.r : 15.r,
                    vertical: isHorizontal ? 10.r : 7.r,
                  ),
                ),
                child: Text(
                  'Mengerti',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 16.sp : 14.sp,
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
      ),
    );
  }
}
