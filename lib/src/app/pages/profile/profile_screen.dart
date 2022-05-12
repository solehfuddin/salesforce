import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String id = '';
  String role = '';
  String username = '';
  String search = '';
  String divisi = '';
  String status = '';
  bool _isLoading = true;
  TextEditingController textPassword = new TextEditingController();
  TextEditingController textRePassword = new TextEditingController();
  TextEditingController textNamaLengkap = new TextEditingController();
  bool _isNamaLengkap = false;
  bool _isPassword = false;
  bool _isRePassword = false;
  File tmpFile;
  String tmpName, base64Imgprofile;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");

      getData(int.parse(id));
    });
  }

  getData(int input) async {
    _isLoading = true;
    int timeout = 5;

    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';

    try {
      var response = await http.get(url).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');

      var data = json.decode(response.body);
      final bool sts = data['status'];

      if (sts) {
        textNamaLengkap.text = data['data'][0]['name'];
        status = data['data'][0]['status'];
        base64Imgprofile = data['data'][0]['imgprofile'];

        print('Nama Lengkap : ${textNamaLengkap.text}');
        print('Status : $status');
      }

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
      });
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      // handleSocket(context);
      role.contains('admin')
          ? handleConnectionAdmin(context)
          : handleConnection(context);
    } on Error catch (e) {
      print('Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  checkEntry(Function stop) async {
    textNamaLengkap.text.isEmpty
        ? _isNamaLengkap = true
        : _isNamaLengkap = false;

    textPassword.text.isEmpty ? _isPassword = true : _isPassword = false;

    textRePassword.text.isEmpty ? _isRePassword = true : _isRePassword = false;

    if (!_isNamaLengkap) {
      if (!_isPassword || !_isRePassword) {
        if (textPassword.text == textRePassword.text) {
          perbaruiData(
            stop,
            isChangePassword: true,
          );

          print('Eksekusi dengan password');
        } else {
          handleStatus(context, 'Password tidak sesuai', false);
          stop();
        }
      } else {
        perbaruiData(
          stop,
          isChangePassword: false,
        );

        print('Eksekusi nama saja');
      }
    } else {
      handleStatus(context, 'Harap lengkapi data terlebih dahulu', false);
      stop();
    }
  }

  Future chooseImage() async {
    var imgFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      imageQuality: 25,
      preferredCameraDevice: CameraDevice.front,
    );
    setState(() {
      if (imgFile != null) {
        tmpFile = File(imgFile.path);
        tmpName = tmpFile.path.split('/').last;
        base64Imgprofile =
            base64Encode(Io.File(imgFile.path).readAsBytesSync());

        print(imgFile.path);
        print(base64Imgprofile);

        perbaruiProfil();
      }
    });
  }

  perbaruiProfil() async {
    const timeout = 15;
    var url =
        'http://timurrayalab.com/salesforce/server/api/users/changeImageProfile';

    try {
      var response = await http.post(
        url,
        body: {
          'id': id,
          'image': base64Imgprofile,
        },
      ).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('Error : $e');
      handleStatus(context, e.toString(), false);
    }
  }

  perbaruiData(Function stop, {bool isChangePassword}) async {
    const timeout = 15;
    var url = 'http://timurrayalab.com/salesforce/server/api/users';

    try {
      var response = isChangePassword
          ? await http.put(
              url,
              body: {
                'id': id,
                'name': textNamaLengkap.text,
                'password': textPassword.text,
              },
            )
          : await http.put(
              url,
              body: {
                'id': id,
                'name': textNamaLengkap.text,
              },
            ).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var res = json.decode(response.body);
      final bool sts = res['status'];
      final String msg = res['message'];

      handleStatus(context, capitalize(msg), sts);
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      handleTimeout(context);
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : $e');
      handleStatus(context, e.toString(), false);
    }

    stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Profil Pengguna',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.r,
            color: Colors.black54,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: InkWell(
                  onTap: chooseImage,
                  child: Stack(
                    children: <Widget>[
                      base64Imgprofile == null
                          ? CircleAvatar(
                              radius: 50.r,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/profile.png',
                                  height: 100.h,
                                  width: 100.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 50.r,
                              backgroundImage: MemoryImage(
                                Base64Decoder().convert(base64Imgprofile),
                              ),
                            ),
                      Positioned(
                          bottom: 1,
                          right: 5,
                          child: Container(
                            height: 30.h,
                            width: 30.w,
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 15.r,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.green.shade500,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18.r))),
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Center(
                child: Text(
                  capitalize(username),
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              Center(
                child: Text(
                  role.contains('sales')
                      ? capitalize(role)
                      : capitalize(role) +
                          ' ' +
                          capitalize(divisi.toLowerCase()),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 7.h,
              ),
              _isLoading
                  ? areaLoading()
                  : Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.r,
                          horizontal: 10.r,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'active'
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          status == 'active' ? 'AKTIF' : 'TIDAK AKTIF',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.bold,
                            color: status == 'active'
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                        ),
                      ),
                    ),
              SizedBox(
                height: 35.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nama Lengkap',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 7.h,
              ),
              TextFormField(
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'John Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  errorText: _isNamaLengkap ? 'Nama wajib diisi' : null,
                ),
                controller: textNamaLengkap,
              ),
              SizedBox(
                height: 15.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ubah Kata Sandi',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 7.h,
              ),
              TextFormField(
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                controller: textPassword,
                obscureText: true,
              ),
              SizedBox(
                height: 15.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ulangi Kata Sandi',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 7.h,
              ),
              TextFormField(
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                controller: textRePassword,
                obscureText: true,
              ),
              SizedBox(
                height: 25.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ArgonButton(
                    height: 40.h,
                    width: 100.w,
                    borderRadius: 30.0.r,
                    color: Colors.blue[600],
                    child: Text(
                      "Perbarui",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700),
                    ),
                    loader: Container(
                      padding: EdgeInsets.all(8.r),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    onTap: (startLoading, stopLoading, btnState) {
                      if (btnState == ButtonState.Idle) {
                        startLoading();
                        waitingLoad();
                        checkEntry(stopLoading);
                        // stopLoading();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  areaLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
