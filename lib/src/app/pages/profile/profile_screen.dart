import 'dart:convert';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
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

    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      textNamaLengkap.text = data['data'][0]['name'];
      status = data['data'][0]['status'];

      print('Nama Lengkap : ${textNamaLengkap.text}');
      print('Status : $status');
    }

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
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

  perbaruiData(Function stop, {bool isChangePassword}) async {
    var url = 'http://timurrayalab.com/salesforce/server/api/users';

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
          );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    var res = json.decode(response.body);
    final bool sts = res['status'];
    final String msg = res['message'];

    stop();
    handleStatus(context, capitalize(msg), sts);
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
            fontSize: 18,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black54,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/profile.png',
                  width: 90,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  capitalize(username),
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
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
                    fontSize: 14,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 7,
              ),
              _isLoading
                  ? areaLoading()
                  : Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
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
                            fontSize: 12,
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
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nama Lengkap',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 7,
              ),
              TextFormField(
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'John Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: _isNamaLengkap ? 'Nama wajib diisi' : null,
                ),
                controller: textNamaLengkap,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ubah Kata Sandi',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 7,
              ),
              TextFormField(
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: textPassword,
                obscureText: true,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ulangi Kata Sandi',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 7,
              ),
              TextFormField(
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: textRePassword,
                obscureText: true,
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ArgonButton(
                    height: 40,
                    width: 100,
                    borderRadius: 30.0,
                    color: Colors.blue[600],
                    child: Text(
                      "Perbarui",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    loader: Container(
                      padding: EdgeInsets.all(8),
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
