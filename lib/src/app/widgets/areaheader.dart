import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/profile/profile_screen.dart';

SliverToBoxAdapter areaHeader(
    double screenHeight, String? userUpper, BuildContext context,
    {bool isHorizontal = false}) {
  return SliverToBoxAdapter(
    child: Container(
      padding: EdgeInsets.symmetric(
        vertical: 10.r,
        horizontal: isHorizontal ? 18.r : 19.r,
      ),
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
                  fontSize: isHorizontal ? 20.sp : 19.sp,
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
                  backgroundColor: Colors.blueGrey[600],
                  padding: EdgeInsets.symmetric(
                      horizontal: isHorizontal ? 10.r : 10.r,
                      vertical: isHorizontal ? 5.r : 4.r),
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
                  fontSize: isHorizontal ? 15.sp : 13.sp,
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
