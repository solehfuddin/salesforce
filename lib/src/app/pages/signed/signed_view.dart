import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';

class SignedScreen extends StatefulWidget {
  @override
  _SignedScreenState createState() => _SignedScreenState();
}

class _SignedScreenState extends State<SignedScreen> {
  String path = '/storage/emulated/0/salesapp';

  final SignatureController _signController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _signController.addListener(() => print('Value changed'));
  }

  // Future<void> _createFile(var data) async {
  //   String base64 = base64Encode(data);
  //   return print(base64);
  // }

  Future<String> _createFile(var data) async {
    Uint8List bytes = data;

    final result = await ImageGallerySaver.saveImage(bytes);
    print(result);

    return result;
  }

  String uint8ListTob64(Uint8List uint8list) {
    String base64String = base64Encode(uint8list);
    String header = "data:image/png;base64,";
    return header + base64String;
  }

  uploadImg() async {
    if (_signController.isNotEmpty) {
      var data = await _signController.toPngBytes();
      // await _createFile(signed);
      // print(signed);
      // File file = File.fromRawPath(signed);
      // String base64Image = base64Encode(file.readAsBytesSync());
      // print(base64Image);

      // if (await Permission.storage.request().isGranted) {
      //     await _createFile(data);
      // }

      var data1 = await _signController.toImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Digital Signature',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18,
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
              size: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/signedable.png',
                  width: 220,
                  height: 193,
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    'ELECTRONIC SIGNATURE INSTANTLY',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    'By signing this document with an electronic signature, I agree that such signature will be as valid as handwritten signatures to the extent allowed by local law',
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Signature(
                  controller: _signController,
                  height: 150,
                  backgroundColor: Colors.blueGrey.shade50,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        primary: Colors.orange[800],
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Segoe ui',
                        ),
                      ),
                      onPressed: () {
                        uploadImg();
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
}
