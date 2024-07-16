import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/attendance/attendance_dialog.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/staff/staff_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/myaddress.dart';
import 'package:sample/src/app/utils/mylocation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class AttendanceScreen extends StatefulWidget {
  bool? isCekin = true;
  AttendanceScreen({this.isCekin, Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  MyLocation _myLocation = MyLocation();
  MyAddress _myAddrees = MyAddress();
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  XFile? image;
  LocationData? _locationData;
  String? id = '';
  String? role = '';
  String? username = '';
  String? name = '';
  String? lattitude = '';
  String? longitude = '';
  String? locationAdress = '';
  String base64Imgprofile = '';
  bool isMocking = false;
  bool isLocationService = false;
  bool isPermissionService = false;
  bool isFrontCamera = true;
  File? imageFile;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");
    });
  }

  @override
  void initState() {
    super.initState();
    loadCamera();
    getRole();
    getLocation();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future getLocation() async {
    // _locationData = await _myLocation.getLocation();
    // setState(() {
    //   print(
    //       "Location : ${_locationData?.latitude}, ${_locationData?.longitude} - ${_locationData?.isMock}");

    //   lattitude = _locationData?.latitude.toString();
    //   longitude = _locationData?.longitude.toString();
    //   isMocking = _locationData?.isMock ?? false;

    //   if (lattitude != null && longitude != null) {
    //     getAddress(_locationData?.latitude, _locationData?.longitude);
    //   }
    // });
    await _myLocation.getLocation().then((value) {
      _locationData = value;
      
      print(
          "Location : ${_locationData?.latitude}, ${_locationData?.longitude} - ${_locationData?.isMock}");

      lattitude = _locationData?.latitude.toString();
      longitude = _locationData?.longitude.toString();
      isMocking = _locationData?.isMock ?? false;

      if (lattitude != null && longitude != null) {
        getAddress(_locationData?.latitude, _locationData?.longitude);
      }
    });
  }

  Future getAddress(double? latt, double? long) async {
    await _myAddrees.getAddress(latt, long).then((value) {
      print(
          "Address : ${value[0].street} ${value[0].subLocality}, ${value[0].subAdministrativeArea} - ${value[0].country}");

      locationAdress =
          "${value[0].street} ${value[0].subLocality}, ${value[0].subAdministrativeArea} - ${value[0].country}";
    });
  }

  loadCamera() async {
    cameras = await availableCameras();
    setState(() {
      if (cameras!.length > 0) {
        if (isFrontCamera) {
          enableCamera(cameras![1]);
        }
        else
        {
          enableCamera(cameras![0]);
        }
      }
    });
  }

  enableCamera(CameraDescription cameraDescription) async {
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);

    try {
      await cameraController?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } catch (e) {
      print("No any camera found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return childWidget();
  }

  Widget childWidget() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          widget.isCekin! ? 'Absensi Masuk' : 'Absensi Pulang',
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
          onPressed: () {
            if (role == 'ADMIN') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminScreen()));
            } else if (role == 'SALES') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            } else {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => StaffScreen()));
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: Colors.black54,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 5.r,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 5.r,
              horizontal: 10.r,
            ),
            decoration: BoxDecoration(
              color: Colors.orange[600],
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              'Arahkan kamera ke wajah dan pose sesukamu',
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'Segoe ui',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 15.r,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 230,
                width: MediaQuery.of(context).size.width - 70,
                child: cameraController == null
                    ? Center(child: Text("Loading Camera..."))
                    : !cameraController!.value.isInitialized
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : CameraPreview(
                            cameraController!,
                          ),
              ),
            ],
          ),
          SizedBox(
            height: 15.r,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: 5,
                ),
                child: Card(
                  color: widget.isCekin!
                      ? Colors.green.shade500
                      : Colors.red.shade500,
                  elevation: 5,
                  child: IconButton(
                    onPressed: () async {
                      print(locationAdress);
                      if (!isMocking) {
                        if (locationAdress != '') {
                          image = await cameraController?.takePicture();

                          setState(() {
                            imageFile = File(image!.path);
                            dialogComplete(
                              context,
                              imageFile,
                              locationAdress,
                              id: id,
                              latt: lattitude,
                              long: longitude,
                            );
                          });
                        } else {
                          handleStatus(
                            context,
                            "Gagal mendapatkan lokasi, beri izin aplikasi untuk mendapatkan lokasi",
                            false,
                            isHorizontal: false,
                            isLogout: false,
                          );
                        }
                      } else {
                        handleStatus(
                          context,
                          "Sistem mendeteksi adanya lokasi palsu",
                          false,
                          isHorizontal: false,
                          isLogout: false,
                        );
                      }
                    },
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      size: 33,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 5,
                ),
                child: Card(
                  color: Colors.blue.shade500,
                  elevation: 5,
                  child: IconButton(
                    onPressed: () async {
                      isFrontCamera = !isFrontCamera;

                      setState(() {
                        loadCamera();
                      });
                    },
                    icon: Icon(
                      Icons.cameraswitch,
                      size: 33,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  dialogComplete(
    BuildContext context,
    File? image,
    String? address, {
    String? id,
    String? latt,
    String? long,
  }) {
    return showModalBottomSheet(
      elevation: 2,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (context) {
        return AttendanceDialog(
          image,
          address,
          id: id,
          lattitude: latt,
          longitude: long,
          isCekin: widget.isCekin,
        );
      },
    );
  }
}
