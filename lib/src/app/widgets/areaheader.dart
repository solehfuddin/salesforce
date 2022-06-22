import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/profile/profile_screen.dart';

SliverToBoxAdapter areaHeader(
    double screenHeight, String userUpper, BuildContext context,
    {bool isHorizontal}) {
  return SliverToBoxAdapter(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10.r, horizontal: isHorizontal ? 35.r : 19.r),
      decoration: BoxDecoration(
        color: Colors.green[500],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HAI, $userUpper',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isHorizontal ? 42.0.sp : 23.0.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.account_circle),
                label: Text('Profil'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueGrey[600],
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.r, vertical: isHorizontal ? 5.r : 7.r),
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          Column(
            children: [
              Text(
                'Digitalisasi data customer, monitoring kontrak dan kinerja agar lebih mudah dan efisien',
                //'Digitalize customer data, e-contract monitoring and task more easily and efficient',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isHorizontal ? 27.sp : 14.0.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    ),
  );
}
