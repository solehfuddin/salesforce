import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:date_field/date_field.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../domain/entities/trainer.dart';
import '../../controllers/marketingexpense_controller.dart';
import '../../controllers/training_controller.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();
  TrainingController trainingController = Get.find<TrainingController>();

  List<Trainer> _list = List.empty(growable: true);
  final format = DateFormat("dd MMM yyyy");
  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';
  String search = '';
  String? divisi = '';
  String? status = '';
  bool _isLoading = true;
  bool _isHorizontal = false;
  TextEditingController textPassword = new TextEditingController();
  TextEditingController textRePassword = new TextEditingController();
  TextEditingController textNamaLengkap = new TextEditingController();
  TextEditingController textTrainerRole = new TextEditingController();
  TextEditingController textTrainerProfile = new TextEditingController();
  TextEditingController textOfflineUntil = new TextEditingController();
  bool _isNamaLengkap = false;
  bool _isPassword = false;
  bool _isRePassword = false;
  bool isOfflineMode = false;
  String isTrainer = "";
  String offlineUntil = '';
  String _choosenOfflineReason = 'CUTI';
  late File tmpFile;
  String tmpName = '';
  String base64Imgprofile = '';
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
      name = preferences.getString("name") ?? '';
      status = preferences.getString("status") ?? '';
      isTrainer = preferences.getString("isTrainer") ?? '';
      textNamaLengkap.text = name!;

      print('Nama Lengkap : ${textNamaLengkap.text}');
      print('Status : $status');

      if (id != null) {
        getData(int.parse(id!));
      }

      if (isTrainer == "YES") {
        getTrainer(name: name);
      }
    });
  }

  void getTrainer({String? name = ""}) {
    meController
        .getAllTrainer(
          mounted,
          context,
          key: name ?? "",
        )
        .then(
          (value) => setState(
            () {
              _list.addAll(value);

              if (_list.length > 0) {
                trainingController.trainer.value = _list[0];

                isOfflineMode = trainingController.trainer.value.isOnlne == "NO"
                    ? true
                    : false;
                textTrainerRole.text =
                    trainingController.trainer.value.trainerRole ?? "";
                textTrainerProfile.text =
                    trainingController.trainer.value.trainerProfile ?? "";
              }
            },
          ),
        );
  }

  getData(int input) async {
    _isLoading = true;
    int timeout = 5;

    var url = '$API_URL/users?id=$input';

    try {
      var response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));
      print('Response status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool sts = data['status'];

        if (sts) {
          base64Imgprofile = data['data']['imgprofile'] ?? '';
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
      role == 'admin'
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

  onButtonPressed() async {
    await Future.delayed(const Duration(milliseconds: 1500),
        () => checkEntry(isHorizontal: _isHorizontal));

    return () {};
  }

  checkEntry({bool isHorizontal = false}) async {
    textNamaLengkap.text.isEmpty
        ? _isNamaLengkap = true
        : _isNamaLengkap = false;

    textPassword.text.isEmpty ? _isPassword = true : _isPassword = false;

    textRePassword.text.isEmpty ? _isRePassword = true : _isRePassword = false;

    if (!_isNamaLengkap) {
      if (!_isPassword || !_isRePassword) {
        if (textPassword.text == textRePassword.text) {
          perbaruiData(
            isChangePassword: true,
            isHorizontal: isHorizontal,
          );

          print("Offline Mode : $isOfflineMode");
          perbaruiDataTrainer(isHorizontal: isHorizontal);

          print('Eksekusi dengan password');
        } else {
          handleStatus(
            context,
            'Password tidak sesuai',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }
      } else {
        perbaruiData(
          isChangePassword: false,
          isHorizontal: isHorizontal,
        );

        print("Offline Mode : $isOfflineMode");
        perbaruiDataTrainer(isHorizontal: isHorizontal);

        print('Eksekusi nama saja');
      }
    } else {
      handleStatus(
        context,
        'Harap lengkapi data terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    }
  }

  Future chooseImage({bool isHorizontal = false}) async {
    var imgFile = await ImagePicker().pickImage(
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
    var url = '$API_URL/users/changeImageProfile';

    try {
      var response = await http.post(
        Uri.parse(url),
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

  updateNamePref(String newName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    final sts = await pref.remove('name');
    if (sts) {
      await pref.setString("name", newName);
    } else {
      print('Gagal update session name user');
    }
  }

  perbaruiData({
    bool isChangePassword = false,
    bool isHorizontal = false,
  }) async {
    const timeout = 15;
    var url = '$API_URL/users';

    try {
      var response = isChangePassword
          ? await http.put(
              Uri.parse(url),
              body: {
                'id': id,
                'name': textNamaLengkap.text,
                'password': textPassword.text,
              },
            )
          : await http.put(
              Uri.parse(url),
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

        if (sts) {
          updateNamePref(textNamaLengkap.text);
          if (mounted) {
            handleStatus(
              context,
              capitalize(msg),
              sts,
              isHorizontal: isHorizontal,
              isLogout: false,
            );
          }
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
  }

  perbaruiDataTrainer({
    bool isHorizontal = false,
  }) async {
    const timeout = 15;
    var url = '$API_URL/users/trainer';

    try {
      var response = await http.put(
        Uri.parse(url),
        body: {
          'id': id,
          'offline_reason': trainingController.trainer.value.isOnlne == "YES"
              ? _choosenOfflineReason
              : '',
          'offline_until': trainingController.trainer.value.isOnlne == "YES"
              ? offlineUntil
              : '',
          'trainer_role': textTrainerRole.text,
          'trainer_profile': textTrainerProfile.text,
        },
      ).timeout(Duration(seconds: timeout));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (sts) {
          updateNamePref(textNamaLengkap.text);
          if (mounted) {
            handleStatus(
              context,
              capitalize(msg),
              sts,
              isHorizontal: isHorizontal,
              isLogout: false,
            );
          }
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
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        _isHorizontal = true;
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white70,
            title: Text(
              'Profil Pengguna',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 20.sp,
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
                size: 20.r,
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
                          base64Imgprofile == ''
                              ? CircleAvatar(
                                  radius: 60.r,
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/profile.png',
                                      height: 120.h,
                                      width: 120.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 60.r,
                                  backgroundImage: MemoryImage(
                                    Base64Decoder().convert(base64Imgprofile),
                                  ),
                                ),
                          Positioned(
                            bottom: 1,
                            right: 5,
                            child: Container(
                              height: 40.h,
                              width: 25.w,
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                                size: 22.r,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade500,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(22.r),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Center(
                    child: Text(
                      capitalize(username!),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22.sp,
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
                      role == 'SALES'
                          ? capitalize(role!)
                          : capitalize(role!) + ' ' + capitalize(
                              // divisi.toLowerCase(),
                              divisi!),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 22.sp,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
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
                                    fontSize: 18.sp,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.bold,
                                    color: status == 'ACTIVE'
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: isTrainer == "YES" ? true : false,
                                child: Container(
                                  margin: EdgeInsets.only(left: 5.w,),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10.r,
                                    horizontal: 15.r,
                                  ),
                                  decoration: BoxDecoration(
                                    color: trainingController
                                                .trainer.value.isOnlne ==
                                            "YES"
                                        ? Colors.green[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    trainingController.trainer.value.isOnlne ==
                                            "YES"
                                        ? "READY"
                                        : "OFFLINE",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontFamily: 'Segoe ui',
                                      fontWeight: FontWeight.bold,
                                      color: trainingController
                                                  .trainer.value.isOnlne ==
                                              "YES"
                                          ? Colors.green[800]
                                          : Colors.grey[800],
                                    ),
                                  ),
                                ),
                                replacement: SizedBox(
                                  height: 10.h,
                                ),
                              ),
                            ],
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
                          fontSize: 18.sp,
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
                          fontSize: 18.sp,
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
                          fontSize: 18.sp,
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
                    height: 15.h,
                  ),
                  isTrainer == "YES"
                      ? trainerSettingWidget(
                          isHorizontal: true,
                        )
                      : SizedBox(
                          width: 5.w,
                        ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      EasyButton(
                        idleStateWidget: Text(
                          "Perbarui",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700),
                        ),
                        loadingStateWidget: CircularProgressIndicator(
                          strokeWidth: 3.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        useEqualLoadingStateWidgetDimension: true,
                        useWidthAnimation: true,
                        height: 50.h,
                        width: 70.w,
                        borderRadius: 35.r,
                        buttonColor: Colors.blue.shade600,
                        elevation: 2.0,
                        contentGap: 6.0,
                        onPressed: onButtonPressed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }

      _isHorizontal = false;
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
                        base64Imgprofile == ''
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
                    capitalize(username!),
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
                    role == 'SALES'
                        ? capitalize(role!)
                        : capitalize(role!) +
                            ' ' +
                            capitalize(divisi!.toLowerCase()),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
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
                            Visibility(
                              visible: isTrainer == "YES" ? true : false,
                              child: Container(
                                margin: EdgeInsets.only(left: 5.w,),
                                padding: EdgeInsets.symmetric(
                                  vertical: 5.r,
                                  horizontal: 10.r,
                                ),
                                decoration: BoxDecoration(
                                  color: trainingController
                                              .trainer.value.isOnlne ==
                                          "YES"
                                      ? Colors.green[100]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  trainingController.trainer.value.isOnlne ==
                                          "YES"
                                      ? "READY"
                                      : "OFFLINE",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.bold,
                                    color: trainingController
                                                .trainer.value.isOnlne ==
                                            "YES"
                                        ? Colors.green[800]
                                        : Colors.grey[800],
                                  ),
                                ),
                              ),
                              replacement: SizedBox(
                                height: 10.h,
                              ),
                            ),
                          ],
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
                  height: 15.h,
                ),
                isTrainer == "YES"
                    ? trainerSettingWidget(
                        isHorizontal: true,
                      )
                    : SizedBox(
                        width: 5.w,
                      ),
                SizedBox(
                  height: 25.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    EasyButton(
                      idleStateWidget: Text(
                        "Perbarui",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700),
                      ),
                      loadingStateWidget: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                      useEqualLoadingStateWidgetDimension: true,
                      useWidthAnimation: true,
                      height: 40.h,
                      width: 100.w,
                      borderRadius: 35.r,
                      buttonColor: Colors.blue.shade600,
                      elevation: 2.0,
                      contentGap: 6.0,
                      onPressed: onButtonPressed,
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

  Widget trainerSettingWidget({
    bool isHorizontal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Trainer Detail',
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        Container(
          height: 15.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Change Offline Mode',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: isOfflineMode,
                onChanged: (value) {
                  setState(() {
                    isOfflineMode = value;
                  });
                },
                activeTrackColor: Colors.blue.shade400,
                activeColor: Colors.blue,
              ),
            ],
          ),
        ),
        Visibility(
          visible: isOfflineMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offline Until',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 7.h,
              ),
              DateTimeFormField(
                decoration: InputDecoration(
                  hintText: trainingController.trainer.value.isOnlne == "NO"
                      ? convertDateWithMonth(
                          trainingController.trainer.value.offlineUntil ?? "")
                      : 'dd mon yyyy',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  // errorText: _isTanggalLahir ? 'Data wajib diisi' : null,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Segoe Ui',
                  ),
                ),
                dateFormat: format,
                mode: DateTimeFieldPickerMode.date,
                firstDate: DateTime.now(),
                lastDate: DateTime(2050),
                initialDate: DateTime.now(),
                autovalidateMode: AutovalidateMode.always,
                onDateSelected: (DateTime value) {
                  print('before date : $value');
                  offlineUntil = DateFormat('yyyy-MM-dd').format(value);
                  textOfflineUntil.text = offlineUntil;
                  print('after date : $offlineUntil');
                },
              ),
              SizedBox(
                height: 15.h,
              ),
              Text(
                'Offline Reason',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 7.h,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 7.r),
                decoration: BoxDecoration(
                    color: Colors.white70,
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(5.r)),
                child: DropdownButton(
                  underline: SizedBox(),
                  isExpanded: true,
                  value: _choosenOfflineReason,
                  style: TextStyle(
                    color: Colors.black54,
                    fontFamily: 'Segoe Ui',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  items: [
                    'CUTI',
                    'SAKIT',
                    'LAINNYA',
                  ].map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e, style: TextStyle(color: Colors.black54)),
                    );
                  }).toList(),
                  hint: Text(
                    "Select Reason",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Segoe Ui'),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _choosenOfflineReason = value.toString();
                    });
                  },
                ),
              ),
            ],
          ),
          replacement: SizedBox(
            width: 10.w,
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        Text(
          'Trainer Role',
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(
          height: 7.h,
        ),
        TextFormField(
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Role',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            // errorText: _isTrainerRole ? 'Nama wajib diisi' : null,
          ),
          controller: textTrainerRole,
        ),
        SizedBox(
          height: 15.h,
        ),
        Text(
          'Trainer Information',
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(
          height: 7.h,
        ),
        TextFormField(
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.multiline,
          minLines: 4,
          maxLines: 7,
          maxLength: 400,
          decoration: InputDecoration(
            hintText: 'Describe here ...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            // errorText: _isTrainerRole ? 'Nama wajib diisi' : null,
          ),
          controller: textTrainerProfile,
        ),
      ],
    );
  }
}
