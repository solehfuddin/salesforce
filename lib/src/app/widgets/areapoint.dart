import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/custom.dart';

SliverToBoxAdapter areaPoint(double screenHeight, BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Poin',
                            style: TextStyle(
                              fontFamily: 'Segoe ui',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontFamily: 'Segoe ui',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Image.asset(
                                'assets/images/point.png',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      handleComing(context);
                    },
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Penghargaan',
                            style: TextStyle(
                              fontFamily: 'Segoe ui',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lebih lanjut',
                                style: TextStyle(
                                  fontFamily: 'Segoe ui',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Image.asset(
                                'assets/images/reward.png',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      handleComing(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }