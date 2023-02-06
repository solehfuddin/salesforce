import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class DialogPassword extends StatefulWidget {
  dynamic id, nama;

  DialogPassword(
    this.id,
    this.nama,
  );

  @override
  State<DialogPassword> createState() => _DialogPasswordState();
}

class _DialogPasswordState extends State<DialogPassword> {
  TextEditingController textPassword = new TextEditingController();
  TextEditingController textRePassword = new TextEditingController();
  bool _isPassword = true;
  bool _isRePassword = true;
  bool _isNotSame = true;
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

  checkEntry(Function stop, {bool isHorizontal = false}) async {
    setState(() {
      textPassword.text.isNotEmpty ? _isPassword = true : _isPassword = false;
      textRePassword.text.isNotEmpty
          ? _isRePassword = true
          : _isRePassword = false;

      if (_isPassword && _isRePassword) {
        if (textPassword.text == textRePassword.text) {
          print('Iduser : ${widget.id}');
          print('Nama user : ${widget.nama}');
          print('Password : ${textPassword.text}');

          perbaruiData(
            stop,
            isHorizontal: isHorizontal,
            idUser: widget.id,
            namaUser: widget.nama,
            newPassword: textPassword.text,
          );
        } else {
          _isNotSame = false;
        }
      }

      stop();
    });
  }

  perbaruiData(
    Function stop, {
    bool isHorizontal = false,
    dynamic idUser,
    dynamic namaUser,
    dynamic newPassword,
  }) async {
    var url = '$API_URL/users';

    try {
      var response = await http.put(
        Uri.parse(url),
        body: {
          'id': idUser,
          'name': namaUser,
          'password': newPassword,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];
        if (mounted) {
          handleStatus(
            context,
            'Sandi berhasil diubah, silahkan login kembali dengan sandi baru',
            sts,
            isHorizontal: isHorizontal,
            isLogout: true,
          );
          print(msg);
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
        return childPassword(isHor: true);
      }

      return childPassword(isHor: false);
    });
  }

  Widget childPassword({bool isHor = false}) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isHor ? 10.r : 25.r,
            horizontal: isHor ? 25.r : 20.r,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(
                  bottom: isHor ? 10.r : 20.r,
                ),
                child: Text(
                  'Perbarui Sandi Anda',
                  style: TextStyle(
                    fontSize: isHor ? 18.sp : 16.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ubah Kata Sandi',
                    style: TextStyle(
                      fontSize: isHor ? 16.sp : 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
                  hintStyle: TextStyle(
                    fontSize: isHor ? 18.sp : 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  errorText: !_isPassword
                      ? 'Data wajib diisi'
                      : !_isNotSame
                          ? 'Password tidak sama'
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isHor ? 10.r : 3.r,
                    horizontal: isHor ? 20.r : 15.r,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _tooglePassVisibility();
                    },
                    child: Icon(
                      _isHidePass ? Icons.visibility_off : Icons.visibility,
                      color: _isHidePass ? Colors.grey : Colors.blue,
                      size: isHor ? 24.r : 22.r,
                    ),
                  ),
                ),
                controller: textPassword,
                obscureText: _isHidePass,
              ),
              SizedBox(
                height: isHor ? 15.h : 20.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ulangi Kata Sandi',
                    style: TextStyle(
                      fontSize: isHor ? 16.sp : 14.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
                  hintStyle: TextStyle(
                    fontSize: isHor ? 18.sp : 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  errorText: !_isRePassword
                      ? 'Data wajib diisi'
                      : !_isNotSame
                          ? 'Password tidak sama'
                          : null,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isHor ? 10.r : 3.r,
                    horizontal: isHor ? 20.r : 15.r,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _toogleRePassVisibility();
                    },
                    child: Icon(
                      _isReHidePass ? Icons.visibility_off : Icons.visibility,
                      color: _isReHidePass ? Colors.grey : Colors.blue,
                      size: isHor ? 24.r : 22.r,
                    ),
                  ),
                ),
                controller: textRePassword,
                obscureText: _isReHidePass,
              ),
              SizedBox(
                height: isHor ? 15.h : 30.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ArgonButton(
                    height: isHor ? 35.h : 40.h,
                    width: isHor ? 60.w : 80.w,
                    borderRadius: 35.r,
                    color: Colors.blue[600],
                    child: Text(
                      "Perbarui",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isHor ? 16.sp : 14.sp,
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
                        checkEntry(
                          stopLoading,
                          isHorizontal: true,
                        );
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
}
