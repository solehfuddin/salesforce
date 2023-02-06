import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class SignedScreen extends StatefulWidget {
  @override
  _SignedScreenState createState() => _SignedScreenState();
}

class _SignedScreenState extends State<SignedScreen> {
  String? id = '';
  String? role = '';
  String? username = '';
  String? tmpTtd = '';

  final SignatureController _signController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      tmpTtd = preferences.getString("ttduser");

      print("Dashboard : $role");
      print("Ttd user : $tmpTtd");
    });
  }

  @override
  void initState() {
    super.initState();
    _signController.addListener(() => print('Value changed'));
    getRole();
  }

  Widget showImage({
    bool isHorizontal = false,
  }) {
    String ttd = tmpTtd ?? '';
    if (ttd != '') {
      return Column(
        children: [
          Text(
            // 'Last your signed',
            'Tanda Tangan Terbaru',
            style: TextStyle(
              fontSize: isHorizontal ? 30.sp : 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.sp : 15.h,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: isHorizontal ? 250.h : 150.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black54,
              ),
              borderRadius: BorderRadius.circular(isHorizontal ? 20.r : 10.r),
            ),
            child: Image.memory(
              base64Decode(ttd),
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                // 'Digital Signature',
                'Tanda Tangan Digital',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 0.0,
              centerTitle: true,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black54,
                  size: 20.r,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 35.r,
                  vertical: 20.r,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/signedable.png',
                      width: 200.r,
                      height: 173.r,
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Center(
                      child: Text(
                        // 'ELECTRONIC SIGNATURE INSTANTLY',
                        'LENGKAPI TANDA TANGAN',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Center(
                      child: Text(
                        // 'By signing this document with an electronic signature, I agree that such signature will be as valid as handwritten signatures to the extent allowed by local law',
                        'Dengan menandatangani dokumen ini secara digital, saya menyatakan bahwa tanda tangan tersebut asli dan legal sehingga diakui secara hukum yang berlaku',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Signature(
                      controller: _signController,
                      height: 160.h,
                      backgroundColor: Colors.blueGrey.shade50,
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    showImage(isHorizontal: true),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            primary: Colors.orange[800],
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.r, vertical: 10.r),
                          ),
                          child: Text(
                            'Hapus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Segoe ui',
                            ),
                          ),
                          onPressed: () {
                            _signController.clear();
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            primary: Colors.blue[700],
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.r, vertical: 10.r),
                          ),
                          child: Text(
                            'Simpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Segoe ui',
                            ),
                          ),
                          onPressed: () {
                            handleDigitalSigned(
                              _signController,
                              context,
                              id!,
                              isHorizontal: true,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          debugShowCheckedModeBanner: false,
        );
      }

      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              // 'Digital Signature',
              'Tanda Tangan Digital',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18.sp,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 0.0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black54,
                size: 18.r,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 15.r,
                vertical: 20.r,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/signedable.png',
                    width: 200.r,
                    height: 173.r,
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Center(
                    child: Text(
                      // 'ELECTRONIC SIGNATURE INSTANTLY',
                      'LENGKAPI TANDA TANGAN',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Center(
                    child: Text(
                      // 'By signing this document with an electronic signature, I agree that such signature will be as valid as handwritten signatures to the extent allowed by local law',
                      'Dengan menandatangani dokumen ini secara digital, saya menyatakan bahwa tanda tangan tersebut asli dan legal sehingga diakui secara hukum yang berlaku',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Signature(
                    controller: _signController,
                    height: 130.h,
                    backgroundColor: Colors.blueGrey.shade50,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  showImage(isHorizontal: false),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          primary: Colors.orange[800],
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.r, vertical: 10.r),
                        ),
                        child: Text(
                          'Hapus',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Segoe ui',
                          ),
                        ),
                        onPressed: () {
                          _signController.clear();
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          primary: Colors.blue[700],
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.r, vertical: 10.r),
                        ),
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Segoe ui',
                          ),
                        ),
                        onPressed: () {
                          handleDigitalSigned(
                            _signController,
                            context,
                            id!,
                            isHorizontal: false,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
