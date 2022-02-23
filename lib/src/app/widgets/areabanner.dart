import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/custom.dart';

SliverToBoxAdapter areaBanner(double screenHeight, BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                // 'Get rewarded with Challenges',
                'Dapatkan hadiah menarik',
                style: TextStyle(
                  fontSize: 23,
                  fontFamily: 'Segoe ui',
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.all(8),
                height: screenHeight * 0.18,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      'assets/images/espresso.png',
                      width: 50,
                      height: 70,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gratis kopi, misi 5 kustomer baru ..',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Berakhir pada 28 Feb 2022',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Ikuti misi',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          handleComing(context);
        },
      ),
    );
  }