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
  bool _isHidePass = true;
  bool _isReHidePass = true;

  void _tooglePassVisibility() {
    setState(() {
      _isHidePass = !_isHidePass;
    });
  }

  void _toogleRePassVisibility() {
    setState(() {
      _isReHidePass = !_isReHidePass;
    });
  }

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

      try {
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
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
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
    }
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  checkEntry(Function stop, {bool isHorizontal}) async {
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
            isHorizontal: isHorizontal,
          );

          print('Eksekusi dengan password');
        } else {
          handleStatus(
            context,
            'Password tidak sesuai',
            false,
            isHorizontal: isHorizontal,
          );
          stop();
        }
      } else {
        perbaruiData(
          stop,
          isChangePassword: false,
          isHorizontal: isHorizontal,
        );

        print('Eksekusi nama saja');
      }
    } else {
      handleStatus(
        context,
        'Harap lengkapi data terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
      );
      stop();
    }
  }

  Future chooseImage({bool isHorizontal}) async {
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
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('Error : $e');
    }
  }

  perbaruiData(
    Function stop, {
    bool isChangePassword,
    bool isHorizontal,
  }) async {
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

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];
        if (mounted) {
          handleStatus(
            context,
            capitalize(msg),
            sts,
            isHorizontal: isHorizontal,
          );
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : $e');
    }

    stop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white70,
            title: Text(
              'Profil Pengguna',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 28.sp,
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
                size: 28.r,
                color: Colors.black54,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(25.r),
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
                                  radius: 100.r,
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/profile.png',
                                      height: 200.h,
                                      width: 200.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 100.r,
                                  backgroundImage: MemoryImage(
                                    Base64Decoder().convert(base64Imgprofile),
                                  ),
                                ),
                          Positioned(
                              bottom: 1,
                              right: 5,
                              child: Container(
                                height: 56.h,
                                width: 18.w,
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white,
                                  size: 28.r,
                                ),
                                decoration: BoxDecoration(
                                    color: Colors.green.shade500,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(28.r))),
                              ))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Center(
                    child: Text(
                      capitalize(username),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 28.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Center(
                    child: Text(
                      role.contains('SALES')
                          ? capitalize(role)
                          : capitalize(role) + ' ' + capitalize(
                              // divisi.toLowerCase(),
                              divisi),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 24.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  _isLoading
                      ? areaLoading()
                      : Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10.r,
                              horizontal: 15.r,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'ACTIVE'
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              status == 'ACTIVE' ? 'AKTIF' : 'TIDAK AKTIF',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontFamily: 'Segoe ui',
                                fontWeight: FontWeight.bold,
                                color: status == 'ACTIVE'
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
                          fontSize: 24.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'John Doe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      errorText: _isNamaLengkap ? 'Nama wajib diisi' : null,
                    ),
                    controller: textNamaLengkap,
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ubah Kata Sandi',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Masukkan kata sandi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _tooglePassVisibility();
                        },
                        child: Icon(
                          _isHidePass ? Icons.visibility_off : Icons.visibility,
                          color: _isHidePass ? Colors.grey : Colors.blue,
                        ),
                      ),
                    ),
                    controller: textPassword,
                    obscureText: _isHidePass,
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ulangi Kata Sandi',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Masukkan kata sandi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _toogleRePassVisibility();
                        },
                        child: Icon(
                          _isReHidePass
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: _isReHidePass ? Colors.grey : Colors.blue,
                        ),
                      ),
                    ),
                    controller: textRePassword,
                    obscureText: _isReHidePass,
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ArgonButton(
                        height: 70.h,
                        width: 100.w,
                        borderRadius: 35.r,
                        color: Colors.blue[600],
                        child: Text(
                          "Perbarui",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.sp,
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
                            checkEntry(
                              stopLoading,
                              isHorizontal: true,
                            );
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
                              height: 32.h,
                              width: 28.w,
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                                size: 18.r,
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.green.shade500,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.r))),
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
                    role.contains('SALES')
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
                            color: status == 'ACTIVE'
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            status == 'ACTIVE' ? 'AKTIF' : 'TIDAK AKTIF',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.bold,
                              color: status == 'ACTIVE'
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
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _tooglePassVisibility();
                      },
                      child: Icon(
                        _isHidePass ? Icons.visibility_off : Icons.visibility,
                        color: _isHidePass ? Colors.grey : Colors.blue,
                      ),
                    ),
                  ),
                  controller: textPassword,
                  obscureText: _isHidePass,
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
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _toogleRePassVisibility();
                      },
                      child: Icon(
                        _isReHidePass ? Icons.visibility_off : Icons.visibility,
                        color: _isReHidePass ? Colors.grey : Colors.blue,
                      ),
                    ),
                  ),
                  controller: textRePassword,
                  obscureText: _isReHidePass,
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
                          checkEntry(
                            stopLoading,
                            isHorizontal: false,
                          );
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
    });
  }

  areaLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
