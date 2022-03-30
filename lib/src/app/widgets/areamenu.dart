import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/pages/econtract/search_contract.dart';
import 'package:sample/src/app/pages/entry/newcust_view.dart';
import 'package:sample/src/app/pages/renewcontract/renewal_contract.dart';
import 'package:sample/src/app/utils/custom.dart';

checkSigned(String id, BuildContext context) async {
  String ttd = await getTtdValid(id, context);
  print(ttd);
  ttd == null
      ? handleSigned(context)
      : Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => NewcustScreen()));
}

checkCustomer(String id, BuildContext context) {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CustomerScreen(int.parse(id))));
}

SliverToBoxAdapter areaMenu(
    double screenHeight, BuildContext context, String idSales) {
  return SliverToBoxAdapter(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/entry_customer_new.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      Text(
                        'Kustomer',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  checkSigned(idSales, context);
                },
              ),
              GestureDetector(
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/e_contract_new.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      Text(
                        'E-Kontrak',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  checkCustomer(idSales, context);
                },
              ),
              GestureDetector(
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/mon_contract.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      Text(
                        'Monitoring',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchContract(),
                    ),
                  );
                },
              ),
              GestureDetector(
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/renew_contract.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      Text(
                        'Ubah Kontrak',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RenewalContract(keyword: '',),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
